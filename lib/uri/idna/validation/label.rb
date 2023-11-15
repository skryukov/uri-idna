# frozen_string_literal: true

require_relative "../intranges"
require_relative "../data/idna"

module URI
  module IDNA
    module Validation
      module Label
        class << self
          # 4.1. Input to IDNA Registration
          # https://datatracker.ietf.org/doc/html/rfc5891#section-4.1
          def check_nfc(label)
            return if label.unicode_normalized?(:nfc)

            raise Error, "Label must be in Unicode Normalization Form NFC"
          end

          # 4.2.3.1. Hyphen Restrictions
          # https://datatracker.ietf.org/doc/html/rfc5891#section-4.2.3.1
          def check_hyphen34(label)
            return if label[2..3] != "--"

            raise Error, "Label must not contain a U+002D HYPHEN-MINUS character in both the third and fourth positions"
          end

          # 4.2.3.1. Hyphen Restrictions
          # https://datatracker.ietf.org/doc/html/rfc5891#section-4.2.3.1
          def check_hyphen_sides(label)
            return unless label.start_with?("-") || label.end_with?("-")

            raise Error, "Label must neither begin nor end with a U+002D HYPHEN-MINUS character"
          end

          def check_ace_prefix(label)
            return unless label.start_with?(ACE_PREFIX)

            raise Error, "Label must not begin with `xn--`"
          end

          # 4.2.3.2. Leading Combining Marks
          # https://datatracker.ietf.org/doc/html/rfc5891#section-4.2.3.2
          def check_leading_combining(label)
            cp = label[0].ord
            return if cp < 256
            return unless Intranges.contain?(cp, INITIAL_COMBINERS)

            raise Error, "Label begins with an illegal combining character"
          end

          def check_dot(label)
            raise Error, "Label must not contain a U+002E ( . ) FULL STOP" if label.include?(".")
          end

          # DNS label size limit
          # See Processing step 4.2
          # https://www.unicode.org/reports/tr46/#ToASCII
          def check_length(label)
            raise Error, "Label too long" unless label.length < 64
          end

          # DNS name size limit
          # See Processing step 4.1
          # https://www.unicode.org/reports/tr46/#ToASCII
          def check_domain_length(domain_name)
            raise Error, "Domain too long" unless domain_name.length < (domain_name[-1] == "." ? 255 : 254)
          end
        end
      end
    end
  end
end
