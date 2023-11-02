# frozen_string_literal: true

RSpec.describe URI::IDNA::UTS46::ToUnicode do
  subject(:call) { described_class.new(domain, **options).call }

  let(:options) { {} }

  context "with invalid Bidi symbol" do
    let(:domain) { "0a.\u05D0" }

    it "raises an error" do
      expect { call }.to raise_error(URI::IDNA::Error)
    end

    context "with check_bidi: false" do
      let(:options) { { check_bidi: false } }

      it "returns the domain" do
        expect(call).to eq(domain)
      end
    end
  end

  context "with invalid ContextJ symbol" do
    let(:domain) { "a\u200Cb" }

    it "raises an error" do
      expect { call }.to raise_error(URI::IDNA::Error)
    end

    context "with check_joiners: false" do
      let(:options) { { check_joiners: false } }

      it "returns the domain" do
        expect(call).to eq(domain)
      end
    end
  end

  context "with non-LDH symbol" do
    let(:domain) { "std3_rules.com" }

    it "raises an error" do
      expect { call }.to raise_error(URI::IDNA::Error)
    end

    context "with use_std3_ascii_rules: false" do
      let(:options) { { use_std3_ascii_rules: false } }

      it "returns the domain" do
        expect(call).to eq(domain)
      end
    end
  end

  context "with hyphens on left side" do
    let(:domain) { "-hyphen.com" }

    it "raises an error" do
      expect { call }.to raise_error(URI::IDNA::Error)
    end

    context "with check_hyphens: false" do
      let(:options) { { check_hyphens: false } }

      it "returns the domain" do
        expect(call).to eq(domain)
      end
    end
  end

  context "with hyphens on right side" do
    let(:domain) { "hyphen-.com" }

    it "raises an error" do
      expect { call }.to raise_error(URI::IDNA::Error)
    end

    context "with check_hyphens: false" do
      let(:options) { { check_hyphens: false } }

      it "returns the domain" do
        expect(call).to eq(domain)
      end
    end
  end

  context "with hyphens in both the third and fourth positions" do
    let(:domain) { "34--hyphens.com" }

    it "raises an error" do
      expect { call }.to raise_error(URI::IDNA::Error)
    end

    context "with check_hyphens: false" do
      let(:options) { { check_hyphens: false } }

      it "returns the domain" do
        expect(call).to eq(domain)
      end
    end
  end

  context "with double encoded string" do
    let(:domain) { "a.xn--xn-----" }

    it "raises an error" do
      expect { call }.to raise_error(URI::IDNA::Error)
    end

    context "with check_hyphens: false" do
      let(:options) { { check_hyphens: false } }

      it "raises an error" do
        expect { call }.to raise_error(URI::IDNA::Error)
      end
    end
  end

  context "when domain with invalid punycode passed" do
    let(:domain) { "xn--a123.com" }

    it "raises an error" do
      expect { call }.to raise_error(URI::IDNA::Error)
    end

    context "with ignore_invalid_punycode: true" do
      let(:options) { { ignore_invalid_punycode: true } }

      it "returns the domain" do
        expect(call).to eq(domain)
      end

      context "with invalid label in the domain" do
        let(:domain) { "xn--a123.xn--a.com" }

        it "raises an error" do
          expect { call }.to raise_error(URI::IDNA::Error)
        end
      end
    end
  end
end
