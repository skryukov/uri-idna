# frozen_string_literal: true

require "spec_helper"
require "uri/idna/validation/idna_permitted"

RSpec.describe URI::IDNA::Validation::IDNAPermitted do
  rtl = "\u05d0"
  latin = "\u0061"
  arabic_digit = "\u0660"
  zwnj = "\u200c"
  hebrew = "\u05d0"
  symbol = "\u0021"
  latin_upcase = "\u0041"
  non_ascii_upcase = "\u0102"

  it_behaves_like "valid", rtl + latin + arabic_digit + zwnj + hebrew
  it_behaves_like "invalid", latin + symbol + latin
  it_behaves_like "invalid", latin + latin_upcase
  it_behaves_like "invalid", non_ascii_upcase + latin
end
