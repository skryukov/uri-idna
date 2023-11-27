# frozen_string_literal: true

require_relative "base_generator"

class IDNAGenerator < BaseGenerator
  BIDI_MAPPING = {
    "R" => "RTL",
    "AL" => "RTL",
    "L" => "L",
    "EN" => "EN",
    "AN" => "AN",
    "NSM" => "NSM",
    "ES" => "OTHER",
    "CS" => "OTHER",
    "ET" => "OTHER",
    "ON" => "OTHER",
    "BN" => "OTHER",
  }.freeze

  def data
    @data ||= { bidi_classes: {}, codepoint_classes: {}, combiners: [], virama_combining_classes: [] }.tap do |hash|
      ucdata.codepoints do |cp|
        # skip UTF-16 surrogates
        next if cp.value >= 0xd800 && cp.value <= 0xdfff

        bidi_class = BIDI_MAPPING[cp.bidi_class] || "UNUSED"
        hash[:bidi_classes][bidi_class] ||= []
        hash[:bidi_classes][bidi_class] << cp

        status = cp.idna2008_status
        unless %w[UNASSIGNED DISALLOWED].include?(status)
          hash[:codepoint_classes][status] ||= []
          hash[:codepoint_classes][status] << cp
        end

        hash[:combiners] << cp if cp.general_category&.start_with?("M")

        hash[:virama_combining_classes] << cp if cp.combining_class == "9"
      end
    end
  end
end
