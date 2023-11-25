# frozen_string_literal: true

RSpec.describe URI::IDNA::IDNA2008::Registration do
  subject(:call) { described_class.new(alabel: alabel, ulabel: ulabel, **options).call }

  let(:call_ulabel) { described_class.new(ulabel: ulabel, **options).call }
  let(:call_alabel) { described_class.new(alabel: alabel, **options).call }

  let(:options) { {} }

  context "with invalid Bidi symbol" do
    let(:ulabel) { "0a.\u05D0" }
    let(:alabel) { "0a.xn--4db" }

    it "raises an error" do
      expect { call }.to raise_error(URI::IDNA::Error)
      expect { call_ulabel }.to raise_error(URI::IDNA::Error)
      expect { call_alabel }.to raise_error(URI::IDNA::Error)
    end

    context "with check_bidi: false" do
      let(:options) { { check_bidi: false } }

      it "returns the alabel" do
        expect(call).to eq(alabel)
        expect(call_alabel).to eq(alabel)
        expect(call_ulabel).to eq(alabel)
      end
    end
  end

  context "with ContextJ symbol" do
    let(:ulabel) { "a\u200Cb" }
    let(:alabel) { "xn--ab-j1t" }

    it "raises an error" do
      expect { call }.to raise_error(URI::IDNA::Error)
      expect { call_ulabel }.to raise_error(URI::IDNA::Error)
      expect { call_alabel }.to raise_error(URI::IDNA::Error)
    end

    context "with check_joiners: false" do
      let(:options) { { check_joiners: false } }

      it "returns the alabel" do
        expect(call).to eq(alabel)
        expect(call_alabel).to eq(alabel)
        expect(call_ulabel).to eq(alabel)
      end
    end
  end

  context "with ContextO symbol" do
    let(:ulabel) { "l\u00b7a" }
    let(:alabel) { "xn--la-0ea" }

    it "raises an error" do
      expect { call }.to raise_error(URI::IDNA::Error)
      expect { call_ulabel }.to raise_error(URI::IDNA::Error)
      expect { call_alabel }.to raise_error(URI::IDNA::Error)
    end

    context "with check_others: false" do
      let(:options) { { check_others: false } }

      it "returns the alabel" do
        expect(call).to eq(alabel)
        expect(call_alabel).to eq(alabel)
        expect(call_ulabel).to eq(alabel)
      end
    end
  end

  context "with hyphens on left side" do
    let(:ulabel) { "-hyphen.com" }
    let(:alabel) { "-hyphen.com" }

    it "raises an error" do
      expect { call }.to raise_error(URI::IDNA::Error)
      expect { call_ulabel }.to raise_error(URI::IDNA::Error)
      expect { call_alabel }.to raise_error(URI::IDNA::Error)
    end

    context "with check_hyphens: false" do
      let(:options) { { check_hyphens: false } }

      it "returns the alabel" do
        expect(call).to eq(alabel)
        expect(call_alabel).to eq(alabel)
        expect(call_ulabel).to eq(alabel)
      end
    end
  end

  context "with hyphens on right side" do
    let(:ulabel) { "hyphen-.com" }
    let(:alabel) { "hyphen-.com" }

    it "raises an error" do
      expect { call }.to raise_error(URI::IDNA::Error)
      expect { call_ulabel }.to raise_error(URI::IDNA::Error)
      expect { call_alabel }.to raise_error(URI::IDNA::Error)
    end

    context "with check_hyphens: false" do
      let(:options) { { check_hyphens: false } }

      it "returns the alabel" do
        expect(call).to eq(alabel)
        expect(call_alabel).to eq(alabel)
        expect(call_ulabel).to eq(alabel)
      end
    end
  end

  context "with hyphens in both the third and fourth positions" do
    let(:ulabel) { "34--hyphens.com" }
    let(:alabel) { "34--hyphens.com" }

    it "raises an error" do
      expect { call }.to raise_error(URI::IDNA::Error)
      expect { call_ulabel }.to raise_error(URI::IDNA::Error)
      expect { call_alabel }.to raise_error(URI::IDNA::Error)
    end

    context "with check_hyphens: false" do
      let(:options) { { check_hyphens: false } }

      it "returns the alabel" do
        expect(call).to eq(alabel)
        expect(call_alabel).to eq(alabel)
        expect(call_ulabel).to eq(alabel)
      end
    end
  end

  context "with double encoded string" do
    let(:ulabel) { "a.xn---" }
    let(:alabel) { "a.xn--xn-----" }

    it "raises an error" do
      expect { call }.to raise_error(URI::IDNA::Error)
      expect { call_ulabel }.to raise_error(URI::IDNA::Error)
      expect { call_alabel }.to raise_error(URI::IDNA::Error)
    end

    context "with check_hyphens: false" do
      let(:options) { { check_hyphens: false } }

      it "raises an error" do
        expect { call }.to raise_error(URI::IDNA::Error)
        expect { call_ulabel }.to raise_error(URI::IDNA::Error)
        expect { call_alabel }.to raise_error(URI::IDNA::Error)
      end
    end
  end

  context "when domain with invalid punycode passed" do
    let(:ulabel) { "xn--a123.com" }
    let(:alabel) { "xn--a123.com" }

    it "raises an error" do
      expect { call }.to raise_error(URI::IDNA::Error)
      expect { call_ulabel }.to raise_error(URI::IDNA::Error)
      expect { call_alabel }.to raise_error(URI::IDNA::Error)
    end
  end

  context "with invalid label dns length" do
    let(:ulabel) { "1234567890ä1234567890123456789012345678901234567890123456" }
    let(:alabel) { "xn--12345678901234567890123456789012345678901234567890123456-fxe" }

    it "raises an error" do
      expect { call }.to raise_error(URI::IDNA::Error)
      expect { call_ulabel }.to raise_error(URI::IDNA::Error)
      expect { call_alabel }.to raise_error(URI::IDNA::Error)
    end

    context "with verify_dns_length: false" do
      let(:options) { { verify_dns_length: false } }

      it "returns the alabel" do
        expect(call).to eq(alabel)
        expect(call_alabel).to eq(alabel)
        expect(call_ulabel).to eq(alabel)
      end
    end
  end

  context "with invalid domain dns length" do
    let(:ulabel) do
      %w[123456789012345678901234567890123456789012345678901234567890123
         1234567890ä1234567890123456789012345678901234567890123456
         123456789012345678901234567890123456789012345678901234567890123
         1234567890123456789012345678901234567890123456789012345678901].join(".")
    end
    let(:alabel) do
      %w[123456789012345678901234567890123456789012345678901234567890123
         xn--12345678901234567890123456789012345678901234567890123456-fxe
         123456789012345678901234567890123456789012345678901234567890123
         1234567890123456789012345678901234567890123456789012345678901].join(".")
    end

    it "raises an error" do
      expect { call }.to raise_error(URI::IDNA::Error)
      expect { call_ulabel }.to raise_error(URI::IDNA::Error)
      expect { call_alabel }.to raise_error(URI::IDNA::Error)
    end

    context "with verify_dns_length: false" do
      let(:options) { { verify_dns_length: false } }

      it "returns the alabel" do
        expect(call).to eq(alabel)
        expect(call_alabel).to eq(alabel)
        expect(call_ulabel).to eq(alabel)
      end
    end
  end

  context "with leading combining symbol" do
    let(:ulabel) { "a.\uAA32abc.com" }
    let(:alabel) { "a.xn--abc-235l.com" }

    it "raises an error" do
      expect { call }.to raise_error(URI::IDNA::Error)
      expect { call_ulabel }.to raise_error(URI::IDNA::Error)
      expect { call_alabel }.to raise_error(URI::IDNA::Error)
    end

    context "with leading_combining: false" do
      let(:options) { { leading_combining: false } }

      it "returns the alabel" do
        expect(call).to eq(alabel)
        expect(call_alabel).to eq(alabel)
        expect(call_ulabel).to eq(alabel)
      end
    end
  end

  context "with unmatched alabel and ulabel" do
    let(:alabel) { "hello.com" }
    let(:ulabel) { "example.hello.com" }

    it "raises an error" do
      expect { call }.to raise_error(URI::IDNA::Error)
    end
  end

  describe "Test cases from RFCs" do
    tests = [
      [nil, "all-ascii", "all-ascii"],
      [nil, "fass.com", "fass.com"],
      ["xn--fa-hia", "faß", "xn--fa-hia"],
      ["xn--fa-hia", "Faß", URI::IDNA::Error],
      ["non-ace-label", nil, "non-ace-label"],
      ["a.xn--ä", nil, URI::IDNA::Error],
      ["a.xn--all-ascii-", nil, URI::IDNA::Error],
      [nil, "no--hyphens", URI::IDNA::Error],
      [nil, "-no-hyphens-", URI::IDNA::Error],
      # Combining characters
      ["a.xn--abc-235l.com", nil, URI::IDNA::Error],
      [nil, "a.\uAA32abc.com", URI::IDNA::Error],
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
        it "returns #{expected} for #{alabel} #{ulabel}" do
          expect(described_class.new(alabel: alabel, ulabel: ulabel).call).to eq(expected)
        end
      else
        it "raises an error for #{alabel} #{ulabel}" do
          expect { described_class.new(alabel: alabel, ulabel: ulabel).call }.to raise_error(expected)
        end
      end
    end
  end
end
