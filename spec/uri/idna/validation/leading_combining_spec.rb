# frozen_string_literal: true

require "spec_helper"
require "uri/idna/validation/leading_combining"

RSpec.describe URI::IDNA::Validation::LeadingCombining do
  m = "\u0300"
  a = "\u0061"

  it_behaves_like "valid", a
  it_behaves_like "valid", a + m
  it_behaves_like "invalid", m + a
end
