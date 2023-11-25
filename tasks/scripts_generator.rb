# frozen_string_literal: true

require_relative "base_generator"

class ScriptsGenerator < BaseGenerator
  def scripts
    %w[Greek Han Hebrew Hiragana Katakana]
  end
end
