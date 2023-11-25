# frozen_string_literal: true

require_relative "../data/bidi_classes"

module URI
  module IDNA
    module Validation
      # 4.2.3.4. Labels Containing Characters Written Right to Left
      # https://datatracker.ietf.org/doc/html/rfc5891#section-4.2.3.4
      # https://datatracker.ietf.org/doc/html/rfc5893#section-2
      module Bidi
        class << self
          BIDI_R1_RTL = Regexp.new(BIDI_CLASSES["RTL"]).freeze
          BIDI_R1_LTR = Regexp.new(BIDI_CLASSES["L"]).freeze
          BIDI_R2 = Regexp.new("#{BIDI_CLASSES['L']}|#{BIDI_CLASSES['UNUSED']}").freeze
          BIDI_R3 = Regexp.new(
            "(?:#{"#{BIDI_CLASSES['RTL']}|#{BIDI_CLASSES['AN']}|#{BIDI_CLASSES['EN']}"})#{BIDI_CLASSES['NSM']}*\\z",
          ).freeze
          BIDI_R4_EN = Regexp.new(BIDI_CLASSES["EN"]).freeze
          BIDI_R4_AN = Regexp.new(BIDI_CLASSES["AN"]).freeze
          BIDI_R5 = Regexp.new("#{BIDI_CLASSES['RTL']}|#{BIDI_CLASSES['AN']}").freeze
          BIDI_R6 = Regexp.new("(?:#{"#{BIDI_CLASSES['L']}|#{BIDI_CLASSES['EN']}"})#{BIDI_CLASSES['NSM']}*\\z").freeze

          def call(label)
            # Bidi rule 1
            if BIDI_R1_LTR.match?(label[0])
              rtl = false
            elsif BIDI_R1_RTL.match?(label[0])
              rtl = true
            else
              raise BidiError, "First codepoint in label #{label} must be directionality L, R or AL"
            end

            if rtl
              # Bidi rule 2
              if (pos = label.index(BIDI_R2))
                raise BidiError, "Invalid direction for codepoint at position #{pos + 1} in a right-to-left label"
              end
              # Bidi rule 3
              raise BidiError, "Label ends with illegal codepoint directionality" unless label.match?(BIDI_R3)
              # Bidi rule 4
              if label.match?(BIDI_R4_EN) && label.match?(BIDI_R4_AN)
                raise BidiError, "Can not mix numeral types in a right-to-left label"
              end
            else
              # Bidi rule 5
              if (pos = label.index(BIDI_R5))
                raise BidiError, "Invalid direction for codepoint at position #{pos + 1} in a left-to-right label"
              end
              # Bidi rule 6
              raise BidiError, "Label ends with illegal codepoint directionality" unless label.match?(BIDI_R6)
            end
          end

          # https://www.rfc-editor.org/rfc/rfc5891.html#section-4.2.3.4
          def check?(domain)
            domain.split(".").each do |label|
              if label.start_with?(ACE_PREFIX)
                begin
                  label = Punycode.decode(label[ACE_PREFIX.length..])
                rescue PunycodeError
                  next
                end
              end
              next if label.ascii_only?

              return true if label.match?(BIDI_R5)
            end

            false
          end
        end
      end
    end
  end
end
