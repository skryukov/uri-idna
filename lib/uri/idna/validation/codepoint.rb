# frozen_string_literal: true

require_relative "../intranges"
require_relative "../data/idna"

module URI
  module IDNA
    module Validation
      module Codepoint
        class << self
          # https://datatracker.ietf.org/doc/html/rfc5891#section-4.2.2
          def check_idna_validity(label, cp, pos)
            return true if codepoint?(cp, "PVALID")

            raise InvalidCodepointError, cp_error_message(label, cp, pos)
          end

          # https://datatracker.ietf.org/doc/html/rfc5892
          def check_contextj(label, cp, pos)
            return false if cp < 256
            return false unless codepoint?(cp, "CONTEXTJ")
            return true if valid_contextj?(label, cp, pos)

            raise InvalidCodepointContextError, cp_error_message(label, cp, pos)
          end

          # https://datatracker.ietf.org/doc/html/rfc5892
          def check_contexto(label, cp, pos)
            return false if cp < 183
            return false unless codepoint?(cp, "CONTEXTO")
            return true if valid_contexto?(label, cp, pos)

            raise InvalidCodepointContextError, cp_error_message(label, cp, pos)
          end

          def cp_error_message(label, cp, pos)
            format("Codepoint U+%04X at position %d of %p not allowed", cp, pos + 1, label)
          end

          private

          def valid_contexto?(label, cp, pos)
            case cp
              # https://datatracker.ietf.org/doc/html/rfc5892#appendix-A.3
            when 0x00b7
              pos > 0 && pos < label.length - 1 ? (label[pos - 1].ord == 0x006c && label[pos + 1].ord == 0x006c) : false
              # https://datatracker.ietf.org/doc/html/rfc5892#appendix-A.4
            when 0x0375
              pos < label.length - 1 ? script?(label[pos + 1].ord, "Greek") : false
              # https://datatracker.ietf.org/doc/html/rfc5892#appendix-A.5
              # https://datatracker.ietf.org/doc/html/rfc5892#appendix-A.6
            when 0x05f3, 0x05f4
              pos > 0 ? script?(label[pos - 1].ord, "Hebrew") : false
              # https://datatracker.ietf.org/doc/html/rfc5892#appendix-A.7
            when 0x30fb
              label.each_codepoint do |codepoint|
                next if codepoint == 0x30fb
                return true if script?(codepoint,
                                       "Hiragana") || script?(codepoint, "Katakana") || script?(codepoint, "Han")
              end
              false
              # https://datatracker.ietf.org/doc/html/rfc5892#appendix-A.8
            when 0x0660..0x0669
              label.each_codepoint do |codepoint|
                return false if codepoint >= 0x06f0 && codepoint <= 0x06f9
              end
              true
              # https://datatracker.ietf.org/doc/html/rfc5892#appendix-A.9
            when 0x06f0..0x06f9
              label.each_codepoint do |codepoint|
                return false if codepoint >= 0x0660 && codepoint <= 0x0669
              end
              true
            else
              false
            end
          end

          def valid_contextj?(label, cp, pos)
            case cp
              # https://datatracker.ietf.org/doc/html/rfc5892#appendix-A.1
            when 0x200c
              return true if pos > 0 && virama_combining_class?(label[pos - 1].ord)

              ok = false
              (pos - 1).downto(0) do |i|
                joining_type = JOINING_TYPES[label[i].ord]
                next if joining_type == 0x54

                if [0x4c, 0x44].include?(joining_type)
                  ok = true
                  break
                end
              end
              return false unless ok

              (pos + 1).upto(label.length - 1) do |i|
                joining_type = JOINING_TYPES[label[i].ord]
                next if joining_type == 0x54
                return true if [0x52, 0x44].include?(joining_type)
              end
              # https://datatracker.ietf.org/doc/html/rfc5892#appendix-A.2
            when 0x200d
              return virama_combining_class?(label[pos - 1].ord) if pos > 0
            end
            false
          end

          def script?(cp, script)
            return false if cp < 256

            Intranges.contain?(cp, SCRIPTS[script])
          end

          def virama_combining_class?(cp)
            return false if cp < 256

            Intranges.contain?(cp, VIRAMA_COMBINING_CLASSES)
          end

          def codepoint?(cp, class_name)
            Intranges.contain?(cp, CODEPOINT_CLASSES[class_name])
          end
        end
      end
    end
  end
end
