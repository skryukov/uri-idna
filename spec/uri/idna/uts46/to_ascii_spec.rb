# frozen_string_literal: true

RSpec.describe URI::IDNA::UTS46::ToASCII do
  subject(:call) { described_class.new(domain, **options).call }

  let(:options) { {} }

  context "with invalid Bidi symbol" do
    let(:domain) { "0a.\u05D0" }
    let(:ascii_domain) { "0a.xn--4db" }

    it "raises an error" do
      expect { call }.to raise_error(URI::IDNA::Error)
    end

    context "with check_bidi: false" do
      let(:options) { { check_bidi: false } }

      it "returns the domain" do
        expect(call).to eq(ascii_domain)
      end
    end
  end

  context "with ContextJ symbol" do
    let(:domain) { "a\u200Cb" }
    let(:ascii_domain) { "xn--ab-j1t" }

    it "raises an error" do
      expect { call }.to raise_error(URI::IDNA::Error)
    end

    context "with check_joiners: false" do
      let(:options) { { check_joiners: false } }

      it "returns the domain" do
        expect(call).to eq(ascii_domain)
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

    context "with invalid label dns length" do
      let(:domain) { "1234567890ä1234567890123456789012345678901234567890123456" }
      let(:ascii_domain) { "xn--12345678901234567890123456789012345678901234567890123456-fxe" }

      it "raises an error" do
        expect { call }.to raise_error(URI::IDNA::Error)
      end

      context "with verify_dns_length: false" do
        let(:options) { { verify_dns_length: false } }

        it "returns the domain" do
          expect(call).to eq(ascii_domain)
        end
      end
    end

    context "with invalid domain dns length" do
      let(:domain) do
        %w[123456789012345678901234567890123456789012345678901234567890123
           1234567890ä1234567890123456789012345678901234567890123456
           123456789012345678901234567890123456789012345678901234567890123
           1234567890123456789012345678901234567890123456789012345678901].join(".")
      end
      let(:ascii_domain) do
        %w[123456789012345678901234567890123456789012345678901234567890123
           xn--12345678901234567890123456789012345678901234567890123456-fxe
           123456789012345678901234567890123456789012345678901234567890123
           1234567890123456789012345678901234567890123456789012345678901].join(".")
      end

      it "raises an error" do
        expect { call }.to raise_error(URI::IDNA::Error)
      end

      context "with verify_dns_length: false" do
        let(:options) { { verify_dns_length: false } }

        it "returns the domain" do
          expect(call).to eq(ascii_domain)
        end
      end
    end
  end

  context "with multiple flags" do
    let(:domain) { "Bl_oß.de" }
    let(:ascii_domain) { "bl_oss.de" }

    it "raises an error" do
      expect { call }.to raise_error(URI::IDNA::Error)
    end

    context "with use_std3_ascii_rules: false, transitional_processing: true" do
      let(:options) { { use_std3_ascii_rules: false, transitional_processing: true } }

      it "returns the domain" do
        expect(call).to eq(ascii_domain)
      end
    end
  end
end
