# frozen_string_literal: true

require_relative "../data/uts46"

module URI
  module IDNA
    module UTS46
      # https://www.unicode.org/reports/tr46/#IDNA_Mapping_Table
      module Mapping
        class << self
          def call(domain_name, transitional_processing: false, use_std3_ascii_rules: true)
            output = []
            domain_name.each_codepoint do |codepoint|
              _, status, replacement = status(codepoint)
              case status
              when "V", "X" # valid, disallowed
                output << codepoint
              when "M" # mapped
                output += if transitional_processing && codepoint == 7838
                            [115, 115]
                          else
                            replacement
                          end
              when "D" # deviation
                if transitional_processing
                  output += replacement
                else
                  output << codepoint
                end
              when "3" # disallowed_STD3_valid, disallowed_STD3_mapped
                if use_std3_ascii_rules || !replacement
                  output << codepoint
                else
                  output += replacement
                end
              when "I" # ignored
                next
              end
            end
            output.pack("U*").unicode_normalize!(:nfc)
          end

          def validate_status(label, cp, pos, transitional_processing:, use_std3_ascii_rules:)
            _, status, = status(cp)
            return if status == "V"
            return if !transitional_processing && status == "D"
            return if !use_std3_ascii_rules && status == "3"

            raise InvalidCodepointError, Validation::Codepoint.cp_error_message(label, cp, pos)
          end

          def status(codepoint)
            return UTS46_DATA[codepoint] if codepoint < 256

            index = (UTS46_DATA.bsearch_index { |x| x[0] > codepoint } || UTS46_DATA.length) - 1
            UTS46_DATA[index] || []
          end
        end
      end
    end
  end
end
