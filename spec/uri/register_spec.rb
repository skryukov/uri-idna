# frozen_string_literal: true

RSpec.describe "IDNA 2008 register protocol" do
  tests = [
    [nil, "all-ascii", "all-ascii"],
    [nil, "fass", "fass"],
    ["xn--fa-hia", "faß", "xn--fa-hia"],
    ["xn--fa-hia", "Faß", URI::IDNA::Error],
    ["wrong", nil, URI::IDNA::Error],
    ["xn--ä", nil, URI::IDNA::Error],
    ["xn--all-ascii-", nil, URI::IDNA::Error],
    [nil, "no--hyphens", URI::IDNA::Error],
    [nil, "-no-hyphens-", URI::IDNA::Error],
    # Combining characters
    ["xn--b-bcba413a", nil, URI::IDNA::Error],
    [nil, "\u0308\u0308\u0628b", URI::IDNA::Error],
    # BIDI
    ["xn--ssa73l", "\u05D0\u0308", "xn--ssa73l"],
    [nil, "0à.\u05D0", URI::IDNA::BidiError],
    ["xn--0ca24w", nil, URI::IDNA::BidiError],
    [nil, "à\u05D0", URI::IDNA::BidiError],
    # Contextj
    ["xn--dmc4by94h", "ஹ\u0BCD\u200C", "xn--dmc4by94h"],
    [nil, "a\u200Cb", URI::IDNA::InvalidCodepointContextError],
    ["xn--ab-j1t", nil, URI::IDNA::InvalidCodepointContextError],
    # Contexto
    ["xn--ll-0ea", "l\u00b7l", "xn--ll-0ea"],
    [nil, "l\u00b7a", URI::IDNA::InvalidCodepointContextError],
    ["xn--la-0ea", nil, URI::IDNA::InvalidCodepointContextError],
    # Unpermitted characters
    [nil, "\u2764", URI::IDNA::InvalidCodepointError],
    ["xn--qei", nil, URI::IDNA::InvalidCodepointError],
    [nil, "\u0640", URI::IDNA::InvalidCodepointError],
    ["xn--chb", nil, URI::IDNA::InvalidCodepointError],
    [nil, "\u{E02EF}", URI::IDNA::InvalidCodepointError],
    ["xn--hr36e", nil, URI::IDNA::InvalidCodepointError],
    # length
    ["xn--fafafafafafafafafafafafafafafafafafafa-69cccccccccccccccccc", nil,
     "xn--fafafafafafafafafafafafafafafafafafafa-69cccccccccccccccccc"],
    [nil, "#{'faß' * 18}fa", "xn--fafafafafafafafafafafafafafafafafafafa-69cccccccccccccccccc"],
    [nil, "faß" * 19, URI::IDNA::Error],
  ]

  tests.each do |alabel, ulabel, expected|
    if expected.is_a?(String)
      it "should return #{expected} for #{alabel} #{ulabel}" do
        expect(URI::IDNA.register(alabel: alabel, ulabel: ulabel)).to eq(expected)
      end
    else
      it "should raise an error for #{alabel} #{ulabel}" do
        expect { URI::IDNA.register(alabel: alabel, ulabel: ulabel) }.to raise_error(expected)
      end
    end
  end
end
