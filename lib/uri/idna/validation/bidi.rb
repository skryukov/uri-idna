# frozen_string_literal: true

module URI
  module IDNA
    module Validation
      # 4.2.3.4. Labels Containing Characters Written Right to Left
      # https://datatracker.ietf.org/doc/html/rfc5891#section-4.2.3.4
      # https://datatracker.ietf.org/doc/html/rfc5893#section-2
      module Bidi
        class << self
          def call(label)
            # Bidi rule 1
            if bidi_class(label[0].ord, "RTL")
              rtl = true
            elsif bidi_class(label[0].ord, "L")
              rtl = false
            else
              raise BidiError, "First codepoint in label #{label} must be directionality L, R or AL"
            end

            valid_ending = false
            number_type = nil
            label.each_codepoint.with_index do |cp, pos|
              if rtl
                # Bidi rule 2
                if bidi_class(cp, "L") || bidi_class(cp, "UNUSED")
                  raise BidiError, "Invalid direction for codepoint at position #{pos + 1} in a right-to-left label"
                end

                # Bidi rule 3
                direction = bidi_class(cp, "RTL") || bidi_class(cp, "EN") || bidi_class(cp, "AN")
                if direction
                  valid_ending = true
                elsif !bidi_class(cp, "NSM")
                  valid_ending = false
                end
                # Bidi rule 4
                if %w[EN AN].include?(direction)
                  number_type ||= direction
                  raise BidiError, "Can not mix numeral types in a right-to-left label" if number_type != direction
                end
              else
                # Bidi rule 5
                if bidi_class(cp, "RTL") || bidi_class(cp, "AN")
                  raise BidiError, "Invalid direction for codepoint at position #{pos + 1} in a left-to-right label"
                end

                # Bidi rule 6
                if bidi_class(cp, "L") || bidi_class(cp, "EN")
                  valid_ending = true
                elsif !bidi_class(cp, "NSM")
                  valid_ending = false
                end
              end
            end

            raise BidiError, "Label ends with illegal codepoint directionality" unless valid_ending

            true
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

              label.each_codepoint do |cp|
                next if cp < 256
                return true if bidi_class(cp, "RTL") || bidi_class(cp, "AN")
              end
            end

            false
          end

          private

          def bidi_class(codepoint, bidi_class)
            return bidi_class if Intranges.contain?(codepoint, BIDI_CLASSES[bidi_class])

            false
          end
        end
      end
    end
  end
end
