# frozen_string_literal: true

require_relative "../data/codepoint_classes"
require_relative "../data/scripts"

module URI
  module IDNA
    module Validation
      # https://datatracker.ietf.org/doc/html/rfc5892
      module ContextO
        class << self
          CONTEXTO_REGEX = Regexp.new("[#{CODEPOINT_CLASSES['CONTEXTO']}]").freeze
          CONTEXTO_A4_REGEX = Regexp.new(SCRIPTS["Greek"])
          CONTEXTO_A5_REGEX = Regexp.new(SCRIPTS["Hebrew"])
          CONTEXTO_A7_REGEX = Regexp.new("#{SCRIPTS['Hiragana']}|#{SCRIPTS['Katakana']}|#{SCRIPTS['Han']}").freeze
          CONTEXTO_A8_REGEX = /[\u06F0-\u06F9]/.freeze
          CONTEXTO_A9_REGEX = /[\u0660-\u0669]/.freeze

          def call(label)
            offset = 0
            while (pos = label.index(CONTEXTO_REGEX, offset))
              raise InvalidCodepointContextError, error_message(label, pos) unless valid_contexto?(label, pos)

              offset = pos + 1
            end
          end

          private

          def valid_contexto?(label, pos)
            case label[pos]
              # https://datatracker.ietf.org/doc/html/rfc5892#appendix-A.3
            when "\u00b7"
              pos > 0 && pos < label.length - 1 ? (label[pos - 1] == "\u006c" && label[pos + 1] == "\u006c") : false
              # https://datatracker.ietf.org/doc/html/rfc5892#appendix-A.4
            when "\u0375"
              pos < label.length - 1 ? CONTEXTO_A4_REGEX.match?(label[pos + 1]) : false
              # https://datatracker.ietf.org/doc/html/rfc5892#appendix-A.5
              # https://datatracker.ietf.org/doc/html/rfc5892#appendix-A.6
            when "\u05f3", "\u05f4"
              pos > 0 ? CONTEXTO_A5_REGEX.match?(label[pos - 1]) : false
              # https://datatracker.ietf.org/doc/html/rfc5892#appendix-A.7
            when "\u30fb"
              CONTEXTO_A7_REGEX.match?(label)
              # https://datatracker.ietf.org/doc/html/rfc5892#appendix-A.8
            when "\u0660".."\u0669"
              !CONTEXTO_A8_REGEX.match?(label)
              # https://datatracker.ietf.org/doc/html/rfc5892#appendix-A.9
            when "\u06f0".."\u06f9"
              !CONTEXTO_A9_REGEX.match?(label)
            end
          end

          def error_message(label, pos)
            format("ContextO codepoint U+%04X at position %d of %p not allowed", label[pos].ord, pos + 1, label)
          end
        end
      end
    end
  end
end
