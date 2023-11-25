# frozen_string_literal: true

require "spec_helper"
require "uri/idna/validation/bidi"

RSpec.describe URI::IDNA::Validation::Bidi do
  l = "\u0061"
  r = "\u05d0"
  al = "\u0627"
  an = "\u0660"
  en = "\u0030"
  es = "\u002d"
  cs = "\u002c"
  et = "\u0024"
  on = "\u0021"
  bn = "\u200c"
  nsm = "\u0610"
  ws = "\u0020"

  describe "RFC 5893 Rule 1" do
    it_behaves_like "valid", l
    it_behaves_like "valid", r
    it_behaves_like "valid", al
    it_behaves_like "invalid", an
  end

  describe "RFC 5893 Rule 2" do
    it_behaves_like "valid", r + al
    it_behaves_like "valid", r + al
    it_behaves_like "valid", r + an
    it_behaves_like "valid", r + en
    it_behaves_like "valid", r + es + al
    it_behaves_like "valid", r + cs + al
    it_behaves_like "valid", r + et + al
    it_behaves_like "valid", r + on + al
    it_behaves_like "valid", r + bn + al
    it_behaves_like "valid", r + nsm
    it_behaves_like "invalid", r + l
    it_behaves_like "invalid", r + ws
  end

  describe "RFC 5893 Rule 3" do
    it_behaves_like "valid", r + al
    it_behaves_like "valid", r + en
    it_behaves_like "valid", r + an
    it_behaves_like "valid", r + nsm
    it_behaves_like "valid", r + nsm + nsm
    it_behaves_like "invalid", r + on
  end

  describe "RFC 5893 Rule 4" do
    it_behaves_like "valid", r + en
    it_behaves_like "valid", r + an
    it_behaves_like "invalid", r + en + an
    it_behaves_like "invalid", r + an + en
  end

  describe "RFC 5893 Rule 5" do
    it_behaves_like "valid", l + en
    it_behaves_like "valid", l + es + l
    it_behaves_like "valid", l + cs + l
    it_behaves_like "valid", l + et + l
    it_behaves_like "valid", l + on + l
    it_behaves_like "valid", l + bn + l
    it_behaves_like "valid", l + nsm
    it_behaves_like "invalid", l + r
    it_behaves_like "invalid", l + al
    it_behaves_like "invalid", an + l
  end

  describe "RFC 5893 Rule 6" do
    it_behaves_like "valid", l + l
    it_behaves_like "valid", l + en
    it_behaves_like "valid", l + en + nsm
    it_behaves_like "valid", l + en + nsm + nsm
    it_behaves_like "invalid", l + cs
    it_behaves_like "invalid", l + cs + nsm
  end
end
