# frozen_string_literal: true

require_relative "mapping"
require_relative "options"
require_relative "../validation/contextj"
require_relative "../validation/leading_combining"

module URI
  module IDNA
    module UTS46
      # https://www.unicode.org/reports/tr46/#Processing
      class Processing < BaseProcessing
        def self.options_class
          Options
        end

        def initialize(domain_name, **options)
          super
          @domain_name = Mapping.call(
            domain_name,
            transitional_processing: @options.transitional_processing?,
            use_std3_ascii_rules: @options.use_std3_ascii_rules?,
          )
        end

        def call
          process_labels(domain_name) do |label|
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
          Validation::LeadingCombining.call(label)
          Mapping.validate_label_status(
            label,
            transitional_processing: transitional_processing,
            use_std3_ascii_rules: options.use_std3_ascii_rules?,
          )
          Validation::ContextJ.call(label) if options.check_joiners?
          Validation::Bidi.call(label) if check_bidi?
        end
      end

      # https://www.unicode.org/reports/tr46/#ToUnicode
      class ToUnicode < Processing
      end

      # https://www.unicode.org/reports/tr46/#ToASCII
      class ToASCII < Processing
        def self.options_class
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
