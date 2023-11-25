# frozen_string_literal: true

require_relative "options"
require_relative "../validation/contextj"
require_relative "../validation/contexto"
require_relative "../validation/idna_permitted"
require_relative "../validation/leading_combining"

module URI
  module IDNA
    module IDNA2008
      class Processing < BaseProcessing
        def self.options_class
          Options
        end

        private

        def validate(label)
          return if label.empty?

          Validation::Label.check_nfc(label)
          if options.check_hyphens?
            Validation::Label.check_hyphen34(label)
          else
            Validation::Label.check_ace_prefix(label)
          end
          Validation::LeadingCombining.call(label) if options.leading_combining?
          Validation::ContextJ.call(label) if options.check_joiners?
          Validation::ContextO.call(label) if options.check_others?
          Validation::IDNAPermitted.call(label)
          Validation::Bidi.call(label) if check_bidi?
        end

        def punycode_decode(label)
          return label unless label.start_with?(ACE_PREFIX)

          super
        end
      end

      # https://datatracker.ietf.org/doc/html/rfc5891#section-4
      class Registration < Processing
        def initialize(alabel: nil, ulabel: nil, **options)
          raise ArgumentError, "Provide alabel or ulabel" if alabel.nil? && ulabel.nil?

          @alabel = alabel
          @ulabel = ulabel

          super(ulabel || alabel, **options)
        end

        def call
          alabels, alabel_trailing_dot = split_domain(alabel.encode("UTF-8").unicode_normalize!(:nfc)) if alabel
          ulabels, ulabel_trailing_dot = split_domain(ulabel.encode("UTF-8").unicode_normalize!(:nfc)) if ulabel

          if alabels && ulabels && (alabels.size != ulabels.size || alabel_trailing_dot != ulabel_trailing_dot)
            raise Error, "alabel doesn't match ulabel"
          end

          trailing_dot = alabel_trailing_dot || ulabel_trailing_dot
          size = (alabels || ulabels).size

          result = Array.new(size) do |i|
            alabel = alabels&.[](i)
            ulabel = ulabels&.[](i)

            raise Error, "Provided alabel must be downcased" if alabel && alabel.downcase != alabel

            if alabel
              u_alabel = punycode_decode(alabel)
              if ulabel && u_alabel != ulabel
                raise Error,
                      "Provided ulabel #{ulabel.inspect} doesn't match punycoded alabel #{u_alabel.inspect}"
              end
            end

            validate(ulabel || punycode_decode(alabel))
            a_ulabel = punycode_encode(ulabel || punycode_decode(alabel))

            Validation::Label.check_length(a_ulabel) if options.verify_dns_length?

            if alabel && ulabel && a_ulabel != alabel
              raise Error,
                    "Provided alabel #{alabel.inspect} doesn't match de-punycoded ulabel #{a_ulabel.inspect}"
            end

            a_ulabel
          end

          result = join_labels(result, trailing_dot)

          Validation::Label.check_domain_length(result) if options.verify_dns_length?
          result
        end

        private

        attr_reader :ulabel, :alabel

        def validate(label)
          Validation::Label.check_hyphen_sides(label) if options.check_hyphens?
          super
        end
      end

      # # https://datatracker.ietf.org/doc/html/rfc5891#section-5
      class Lookup < Processing
        def call
          domain = domain_name.encode("UTF-8").unicode_normalize!(:nfc)

          result = process_labels(domain) do |label|
            orig_label = label
            alabel_input = label.start_with?(ACE_PREFIX)

            label = punycode_decode(label)

            validate(label)

            label = punycode_encode(label)

            Validation::Label.check_length(label) if options.verify_dns_length?

            if alabel_input && orig_label != label
              raise Error, "Resulting label #{label.inspect} doesn't match initial label #{orig_label.inspect}"
            end

            label
          end

          Validation::Label.check_domain_length(result) if options.verify_dns_length?
          result
        end
      end
    end
  end
end
