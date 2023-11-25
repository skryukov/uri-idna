# frozen_string_literal: true

require "spec_helper"
require "uri/idna/validation/contexto"

RSpec.describe URI::IDNA::Validation::ContextO do
  latin = "\u0061"
  hebrew = "\u05d0"
  arabic_digit = "\u0660"
  ext_arabic_digit = "\u06f0"

  describe "RFC 5892 Rule A.3 (Middle Dot)" do
    latin_l = "\u006c"
    latin_middle_dot = "\u00b7"

    it_behaves_like "valid", latin_l + latin_middle_dot + latin_l
    it_behaves_like "invalid", latin_middle_dot + latin_l
    it_behaves_like "invalid", latin_l + latin_middle_dot
    it_behaves_like "invalid", latin_middle_dot
    it_behaves_like "invalid", latin_l + latin_middle_dot + latin
  end

  describe "RFC 5892 Rule A.4 (Greek Lower Numeral Sign)" do
    greek = "\u03b1"
    glns = "\u0375"

    it_behaves_like "valid", glns + greek
    it_behaves_like "invalid", glns + latin
    it_behaves_like "invalid", glns
    it_behaves_like "invalid", greek + glns
  end

  describe "RFC 5892 Rule A.5 (Hebrew Punctuation Geresh)" do
    geresh = "\u05f3"

    it_behaves_like "valid", hebrew + geresh
    it_behaves_like "invalid", latin + geresh
  end

  describe "RFC 5892 Rule A.6 (Hebrew Punctuation Gershayim)" do
    gershayim = "\u05f4"

    it_behaves_like "valid", hebrew + gershayim
    it_behaves_like "invalid", latin + gershayim
  end

  describe "RFC 5892 Rule A.7 (Katakana Middle Dot)" do
    katakana_middle_dot = "\u30fb"
    hiragana = "\u3041"
    katakana = "\u30a1"
    han = "\u6f22"

    it_behaves_like "valid", katakana + katakana_middle_dot + katakana
    it_behaves_like "valid", hiragana + katakana_middle_dot + hiragana
    it_behaves_like "valid", han + katakana_middle_dot + han
    it_behaves_like "valid", han + katakana_middle_dot + latin
    it_behaves_like "valid", han + katakana_middle_dot + hebrew
    it_behaves_like "invalid", latin + katakana_middle_dot + latin
  end

  describe "RFC 5892 Rule A.8 (Arabic-Indic Digits)" do
    it_behaves_like "valid", arabic_digit + arabic_digit
    it_behaves_like "invalid", arabic_digit + ext_arabic_digit
  end

  describe "RFC 5892 Rule A.9 (Extended Arabic-Indic Digits)" do
    it_behaves_like "valid", ext_arabic_digit + ext_arabic_digit
    it_behaves_like "invalid", ext_arabic_digit + arabic_digit
  end
end
