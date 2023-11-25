# frozen_string_literal: true

require_relative "../data/codepoint_classes"
require_relative "../data/joining_types"
require_relative "../data/virama_combining_classes"

module URI
  module IDNA
    module Validation
      # https://datatracker.ietf.org/doc/html/rfc5892
      module ContextJ
        class << self
          CONTEXTJ_REGEX = Regexp.new("[#{CODEPOINT_CLASSES['CONTEXTJ']}]").freeze

          def call(label)
            return if label.ascii_only?

            offset = 0
            while (pos = label.index(CONTEXTJ_REGEX, offset))
              raise InvalidCodepointContextError, error_message(label, pos) unless valid_contextj?(label, pos)

              offset = pos + 1
            end
          end

          private

          def valid_contextj?(label, pos)
            case label[pos]
              # https://datatracker.ietf.org/doc/html/rfc5892#appendix-A.1
            when "\u200c"
              return true if pos > 0 && VIRAMA_COMBINING_CLASSES.match?(label[pos - 1])

              ok = false
              (pos - 1).downto(0) do |i|
                joining_type = JOINING_TYPES[label[i]]
                if [0x4c, 0x44].include?(joining_type)
                  ok = true
                  break
                end
              end
              return false unless ok

              (pos + 1).upto(label.length - 1) do |i|
                joining_type = JOINING_TYPES[label[i]]
                return true if [0x52, 0x44].include?(joining_type)
              end
              # https://datatracker.ietf.org/doc/html/rfc5892#appendix-A.2
            when "\u200d"
              return VIRAMA_COMBINING_CLASSES.match?(label[pos - 1]) if pos > 0
            end
            false
          end

          def error_message(label, pos)
            format("ContextJ codepoint U+%04X at position %d of %p not allowed", label[pos].ord, pos + 1, label)
          end
        end
      end
    end
  end
end
