# frozen_string_literal: true

require "spec_helper"
require "uri/idna/validation/label"

RSpec.describe URI::IDNA::Validation::Label do
  describe ".check_nfc" do
    subject(:check_nfc) { described_class.check_nfc(label) }

    let(:label) { "a" }

    it "doesn't raise an error" do
      expect { check_nfc }.not_to raise_error
    end

    context "when label is not in NFC" do
      let(:label) { "a\u0301" }

      it "raises an error" do
        expect { check_nfc }.to raise_error(URI::IDNA::Error)
      end
    end
  end

  describe ".check_hyphen34" do
    subject(:check_hyphen34) { described_class.check_hyphen34(label) }

    let(:label) { "a--b" }

    it "doesn't raise an error" do
      expect { check_hyphen34 }.not_to raise_error
    end

    context "when label contains a hyphen in the third and fourth positions" do
      let(:label) { "ab--b" }

      it "raises an error" do
        expect { check_hyphen34 }.to raise_error(URI::IDNA::Error)
      end
    end
  end

  describe ".check_hyphen_sides" do
    subject(:check_hyphen_sides) { described_class.check_hyphen_sides(label) }

    let(:label) { "a-b" }

    it "doesn't raise an error" do
      expect { check_hyphen_sides }.not_to raise_error
    end

    context "when label begins with a hyphen" do
      let(:label) { "-ab" }

      it "raises an error" do
        expect { check_hyphen_sides }.to raise_error(URI::IDNA::Error)
      end
    end

    context "when label ends with a hyphen" do
      let(:label) { "ab-" }

      it "raises an error" do
        expect { check_hyphen_sides }.to raise_error(URI::IDNA::Error)
      end
    end
  end

  describe ".check_ace_prefix" do
    subject(:check_ace_prefix) { described_class.check_ace_prefix(label) }

    let(:label) { "xf--a" }

    it "doesn't raise an error" do
      expect { check_ace_prefix }.not_to raise_error
    end

    context "when label begins with `xn--`" do
      let(:label) { "xn--ab" }

      it "raises an error" do
        expect { check_ace_prefix }.to raise_error(URI::IDNA::Error)
      end
    end
  end

  describe ".check_dot" do
    subject(:check_dot) { described_class.check_dot(label) }

    let(:label) { "a" }

    it "doesn't raise an error" do
      expect { check_dot }.not_to raise_error
    end

    context "when label contains a dot" do
      let(:label) { "a.b" }

      it "raises an error" do
        expect { check_dot }.to raise_error(URI::IDNA::Error)
      end
    end
  end

  describe ".check_length" do
    subject(:check_length) { described_class.check_length(label) }

    let(:label) { "a" * 63 }

    it "doesn't raise an error" do
      expect { check_length }.not_to raise_error
    end

    context "when label is too long" do
      let(:label) { "a" * 64 }

      it "raises an error" do
        expect { check_length }.to raise_error(URI::IDNA::Error)
      end
    end
  end

  describe ".check_domain_length" do
    subject(:check_domain_length) { described_class.check_domain_length(domain_name) }

    let(:domain_name) { "a" * 253 }

    it "doesn't raise an error" do
      expect { check_domain_length }.not_to raise_error
    end

    context "when domain is too long" do
      let(:domain_name) { "a" * 254 }

      it "raises an error" do
        expect { check_domain_length }.to raise_error(URI::IDNA::Error)
      end
    end

    context "with trailing dot" do
      let(:domain_name) { "#{'a' * 253}." }

      it "doesn't raise an error" do
        expect { check_domain_length }.not_to raise_error
      end

      context "when domain is too long" do
        let(:domain_name) { "#{'a' * 254}." }

        it "raises an error" do
          expect { check_domain_length }.to raise_error(URI::IDNA::Error)
        end
      end
    end
  end
end
