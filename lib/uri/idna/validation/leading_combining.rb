# frozen_string_literal: true

require_relative "../data/leading_combiners"

module URI
  module IDNA
    module Validation
      # 4.2.3.2. Leading Combining Marks
      # https://datatracker.ietf.org/doc/html/rfc5891#section-4.2.3.2
      module LeadingCombining
        class << self
          LEADING_COMBINERS_REGEX = Regexp.new(LEADING_COMBINERS).freeze

          def call(label)
            return unless label[0].match?(LEADING_COMBINERS_REGEX)

            raise Error, "Label begins with an illegal combining character"
          end
        end
      end
    end
  end
end
