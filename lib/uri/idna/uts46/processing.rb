# frozen_string_literal: true

require_relative "mapping"
require_relative "options"

module URI
  module IDNA
    module UTS46
      # https://www.unicode.org/reports/tr46/#Processing
      class Processing < BaseProcessing
        def call
          domain = Mapping.call(
            domain_name,
            transitional_processing: options.transitional_processing?,
            use_std3_ascii_rules: options.use_std3_ascii_rules?,
          )

          process_labels(domain) do |label|
            if label.start_with?(ACE_PREFIX)
              begin
                label = punycode_decode(label)
              rescue PunycodeError => e
                next label if options.ignore_invalid_punycode?

                raise e
              end
              validate(label, transitional_processing: false)
            else
              validate(label)
            end

            label = yield label if block_given?

            label
          end
        end

        private

        def options_class
          Options
        end

        def check_bidi?
          return @check_bidi if instance_variable_defined?(:@check_bidi)

          @check_bidi = options.check_bidi? && Validation::Bidi.check?(domain_name)
        end

        # https://www.unicode.org/reports/tr46/#Validity_Criteria
        def validate(label, transitional_processing: options.transitional_processing?)
          return if label.empty?

          Validation::Label.check_nfc(label)
          if options.check_hyphens?
            Validation::Label.check_hyphen34(label)
            Validation::Label.check_hyphen_sides(label)
          else
            Validation::Label.check_ace_prefix(label)
          end
          Validation::Label.check_dot(label)
          Validation::Label.check_leading_combining(label)

          label.each_codepoint.with_index do |cp, pos|
            Mapping.validate_status(
              label, cp, pos,
              transitional_processing: transitional_processing, use_std3_ascii_rules: options.use_std3_ascii_rules?
            )

            Validation::Codepoint.check_contextj(label, cp, pos) if options.check_joiners?
          end
          Validation::Bidi.call(label) if check_bidi?
        end
      end

      # https://www.unicode.org/reports/tr46/#ToUnicode
      class ToUnicode < Processing
      end

      # https://www.unicode.org/reports/tr46/#ToASCII
      class ToASCII < Processing
        def options_class
          ToASCIIOptions
        end

        def call
          result = super do |label|
            label = punycode_encode(label)
            Validation::Label.check_length(label) if options.verify_dns_length?
            label
          end
          Validation::Label.check_domain_length(result) if options.verify_dns_length?
          result
        end
      end
    end
  end
end
