# frozen_string_literal: true

require "spec_helper"
require "uri/idna/validation/contextj"

RSpec.describe URI::IDNA::Validation::ContextJ do
  latin = "\u0061"
  zwnj = "\u200c"
  zwj = "\u200d"
  virama = "\u094d"
  jt_0x4c = "\uA872"
  jt_0x44 = "\u0620"
  jt_0x55 = "\u0621"
  jt_0x52 = "\u0622"
  jt_0x54 = "\u070F"

  describe "RFC 5892 Appendix A.1 (Zero Width Non-Joiner)" do
    it_behaves_like "valid", virama + zwnj
    it_behaves_like "valid", jt_0x4c + zwnj + jt_0x52
    it_behaves_like "valid", jt_0x4c + zwnj + jt_0x44
    it_behaves_like "valid", jt_0x44 + zwnj + jt_0x52
    it_behaves_like "valid", jt_0x44 + zwnj + jt_0x54 + jt_0x52
    it_behaves_like "valid", jt_0x44 + jt_0x54 + zwnj + jt_0x52
    it_behaves_like "invalid", zwnj
    it_behaves_like "invalid", latin + zwnj
    it_behaves_like "invalid", jt_0x44 + zwnj + latin
    it_behaves_like "invalid", jt_0x4c + zwnj + latin
    it_behaves_like "invalid", jt_0x44 + zwnj + jt_0x54
    it_behaves_like "invalid", jt_0x54 + zwnj + jt_0x52
    it_behaves_like "invalid", jt_0x55 + zwnj + jt_0x52
    it_behaves_like "invalid", jt_0x4c + zwnj + jt_0x55
  end

  describe "RFC 5892 Appendix A.2 (Zero Width Joiner)" do
    it_behaves_like "valid", virama + zwj
    it_behaves_like "invalid", zwj
    it_behaves_like "invalid", latin + zwj
  end
end
