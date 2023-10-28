# frozen_string_literal: true

require_relative "data/uts46"

module URI
  module IDNA
    module UTS46
      class << self
        # https://unicode.org/reports/tr46/#ProcessingStepMap
        def map_string(domain, uts46_std3: true, uts46_transitional: false)
          output = ""
          domain.each_char do |char|
            code_point = char.ord
            _, status, replacement = uts46_status(code_point)
            case status
            when "I"
              next
            when "V", "X"
              output += char
            when "M"
              if uts46_transitional && code_point == 7838
                output += "ss"
              else
                output += replacement
              end
            when "D"
              output += uts46_transitional ? replacement : char
            when "3"
              if uts46_std3
                output += char
              else
                output += replacement || char
              end
            end
          end
          output.unicode_normalize(:nfc)
        end

        def valid?(char, uts46_transitional: false)
          _, status, = uts46_status(char.ord)
          return true if status == "V"
          return true if uts46_transitional && status == "D"

          false
        end

        private

        def uts46_status(code_point)
          index =
            if code_point < 256
              code_point
            else
              (UTS46_DATA.bsearch_index { |x| x[0] > code_point } || UTS46_DATA.length) - 1
            end
          UTS46_DATA[index] || []
        end
      end
    end
  end
end
