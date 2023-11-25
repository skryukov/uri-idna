# frozen_string_literal: true

require_relative "../data/codepoint_classes"

module URI
  module IDNA
    module Validation
      module IDNAPermitted
        class << self
          IDNA_REGEX = Regexp.new(
            "[^(#{CODEPOINT_CLASSES['PVALID']}|#{CODEPOINT_CLASSES['CONTEXTJ']}|#{CODEPOINT_CLASSES['CONTEXTO']})]",
          ).freeze

          # https://datatracker.ietf.org/doc/html/rfc5891#section-4.2.2
          def call(label)
            return unless (pos = label.index(IDNA_REGEX))

            raise InvalidCodepointError, error_message(label, pos)
          end

          private

          def error_message(label, pos)
            format("Codepoint U+%04X at position %d of %p not allowed in IDNA2008", label[pos].ord, pos + 1, label)
          end
        end
      end
    end
  end
end
