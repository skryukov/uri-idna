# frozen_string_literal: true

RSpec.describe "IDNA 2008 lookup protocol" do
  tests = [
    ["all-ascii", "all-ascii"],
    ["fass", "fass"],
    ["xn--ä", URI::IDNA::Error],
    ["xn--all-ascii-", URI::IDNA::Error],
    ["no--hyphens", URI::IDNA::Error],
    ["-no-hyphens-", "-no-hyphens-"],
    # Combining characters
    ["xn--b-bcba413a", URI::IDNA::Error],
    ["\u0308\u0308\u0628b", URI::IDNA::Error],
    # BIDI
    ["0à.\u05D0", URI::IDNA::BidiError],
    ["xn--0ca24w", URI::IDNA::BidiError],
    ["à\u05D0", URI::IDNA::BidiError],
    # Contextj
    ["a\u200Cb", URI::IDNA::InvalidCodepointContextError],
    ["xn--ab-j1t", URI::IDNA::InvalidCodepointContextError],
    # Contexto
    ["l\u00b7a", URI::IDNA::InvalidCodepointContextError],
    ["xn--la-0ea", URI::IDNA::InvalidCodepointContextError],
    # Unpermitted characters
    ["\u2764", URI::IDNA::InvalidCodepointError],
    ["xn--qei", URI::IDNA::InvalidCodepointError],
    ["\u0640", URI::IDNA::InvalidCodepointError],
    ["xn--chb", URI::IDNA::InvalidCodepointError],
    ["\u{E02EF}", URI::IDNA::InvalidCodepointError],
    ["xn--hr36e", URI::IDNA::InvalidCodepointError],
    # length
    ["xn--fafafafafafafafafafafafafafafafafafafa-69cccccccccccccccccc",
     "xn--fafafafafafafafafafafafafafafafafafafa-69cccccccccccccccccc"],
    ["#{'faß' * 18}fa", "xn--fafafafafafafafafafafafafafafafafafafa-69cccccccccccccccccc"],
    ["faß" * 19, URI::IDNA::Error],
  ]

  tests.each do |domain, expected|
    if expected.is_a?(String)
      it "should return #{expected} for #{domain}" do
        expect(URI::IDNA.lookup(domain)).to eq(expected)
      end
    else
      it "should raise an error for #{domain}" do
        expect { URI::IDNA.lookup(domain) }.to raise_error(expected)
      end
    end
  end
end
