# frozen_string_literal: true

require_relative "base_generator"

class UTS46Generator < BaseGenerator
  UTS46_MAPPED_STATUSES = %w[mapped deviation disallowed_STD3_mapped].freeze

  private

  def replacements
    ucdata.codepoints do |cp|
      status_name, mapping_value = cp.uts46_data
      next unless mapping_value
      next unless UTS46_MAPPED_STATUSES.include?(status_name)

      mapping = mapping_value.split.map { |point| CodePoint.new(point.hex, ucdata: ucdata).to_utf8 }.join

      yield cp.to_utf8, mapping
    end
  end

  def status_regex_string(status, &block)
    regex_string(ucdata.codepoints.filter { |cp| cp.uts46_data[0] == status }, &block)
  end
end
