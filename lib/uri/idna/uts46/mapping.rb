# frozen_string_literal: true

require_relative "../data/uts46"

module URI
  module IDNA
    module UTS46
      # https://www.unicode.org/reports/tr46/#IDNA_Mapping_Table
      module Mapping
        class << self
          STATUS_D_REGEX = Regexp.new(REGEX_D_STRING, Regexp::EXTENDED).freeze
          REGEX_STD3_M_REGEX = Regexp.new(REGEX_STD3_M_STRING, Regexp::EXTENDED).freeze

          MAP_REGEX = Regexp.new("#{REGEX_M_STRING}|#{REGEX_I_STRING}").freeze
          REGEX_NOT_V = Regexp.new("[^#{REGEX_V_STRING}]").freeze
          REGEX_NOT_VD = Regexp.new("[^#{REGEX_V_STRING}|#{REGEX_D_STRING}]").freeze
          REGEX_NOT_V3 = Regexp.new("[^#{REGEX_V_STRING}|#{REGEX_STD3_M_STRING}|#{REGEX_STD3_V_STRING}]").freeze
          REGEX_NOT_VD3 = Regexp.new(
            "[^#{REGEX_V_STRING}|#{REGEX_D_STRING}|#{REGEX_STD3_M_STRING}|#{REGEX_STD3_V_STRING}]",
          ).freeze

          def call(domain_name, transitional_processing: false, use_std3_ascii_rules: true)
            return domain_name.downcase if domain_name.ascii_only?

            output = domain_name.gsub(MAP_REGEX) do |match|
              if transitional_processing && match == "\u1E9E"
                "ss"
              else
                REPLACEMENTS[match]
              end
            end
            output.gsub!(STATUS_D_REGEX, REPLACEMENTS) if transitional_processing
            output.gsub!(REGEX_STD3_M_REGEX, REPLACEMENTS) unless use_std3_ascii_rules

            output.ascii_only? ? output : output.unicode_normalize!(:nfc)
          end

          def validate_label_status(label, transitional_processing:, use_std3_ascii_rules:)
            regex =
              if transitional_processing && use_std3_ascii_rules
                REGEX_NOT_V
              elsif transitional_processing
                REGEX_NOT_V3
              elsif use_std3_ascii_rules
                REGEX_NOT_VD
              else
                REGEX_NOT_VD3
              end

            return unless (pos = label.index(regex))

            raise InvalidCodepointError, error_message(label, pos)
          end

          private

          def error_message(label, pos)
            format("Codepoint U+%04X at position %d of %p not allowed in UTS46", label[pos].ord, pos + 1, label)
          end
        end
      end
    end
  end
end
