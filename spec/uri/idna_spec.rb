# frozen_string_literal: true

require "spec_helper"

RSpec.describe URI::IDNA do
  describe ".lookup" do
    subject(:lookup) { described_class.lookup(input, **options) }

    let(:options) { {} }
    let(:input) { "ハロー・ワールド.jp" }
    let(:result) { "xn--gdkl8fhk5egc.jp" }

    it { is_expected.to eq(result) }

    context "when the input is already ASCII" do
      let(:input) { result }

      it { is_expected.to eq(result) }
    end

    context "when the input is not a valid domain" do
      let(:input) { "34--hyphens.com" }

      it "raises an error" do
        expect { lookup }.to raise_error(URI::IDNA::Error)
      end
    end

    context "with options" do
      let(:input) { "34--hyphens.com" }
      let(:options) { { check_hyphens: false } }

      it { is_expected.to eq(input) }
    end
  end

  describe ".register" do
    subject(:register) { described_class.register(alabel: alabel, ulabel: ulabel, **options) }

    let(:options) { {} }
    let(:result) { "xn--gdkl8fhk5egc.jp" }
    let(:alabel) { result }
    let(:ulabel) { "ハロー・ワールド.jp" }

    it { is_expected.to eq(result) }

    context "when only alabel is provided" do
      let(:ulabel) { nil }

      it { is_expected.to eq(result) }
    end

    context "when only ulabel is provided" do
      let(:alabel) { nil }

      it { is_expected.to eq(result) }
    end

    context "when the input is not a valid domain" do
      let(:alabel) { "34--hyphens.com" }
      let(:ulabel) { "34--hyphens.com" }

      it "raises an error" do
        expect { register }.to raise_error(URI::IDNA::Error)
      end
    end

    context "with options" do
      let(:alabel) { "34--hyphens.com" }
      let(:ulabel) { "34--hyphens.com" }
      let(:options) { { check_hyphens: false } }

      it { is_expected.to eq(alabel) }
    end
  end

  describe ".to_unicode" do
    subject(:to_unicode) { described_class.to_unicode(input, **options) }

    let(:options) { {} }
    let(:input) { "xn--gdkl8fhk5egc.jp" }
    let(:result) { "ハロー・ワールド.jp" }

    it { is_expected.to eq(result) }

    context "when the input is already Unicode" do
      let(:input) { result }

      it { is_expected.to eq(result) }
    end

    context "when the input is not a valid domain" do
      let(:input) { "34--hyphens.com" }

      it "raises an error" do
        expect { to_unicode }.to raise_error(URI::IDNA::Error)
      end
    end

    context "with options" do
      let(:input) { "34--hyphens.com" }
      let(:options) { { check_hyphens: false } }

      it { is_expected.to eq(input) }
    end
  end

  describe ".to_ascii" do
    subject(:to_ascii) { described_class.to_ascii(input, **options) }

    let(:options) { {} }
    let(:input) { "ハロー・ワールド.jp" }
    let(:result) { "xn--gdkl8fhk5egc.jp" }

    it { is_expected.to eq(result) }

    context "when the input is already ASCII" do
      let(:input) { result }

      it { is_expected.to eq(result) }
    end

    context "when the input is not a valid domain" do
      let(:input) { "34--hyphens.com" }

      it "raises an error" do
        expect { to_ascii }.to raise_error(URI::IDNA::Error)
      end
    end

    context "with options" do
      let(:input) { "34--hyphens.com" }
      let(:options) { { check_hyphens: false } }

      it { is_expected.to eq(input) }
    end
  end

  describe ".whatwg_to_unicode" do
    subject(:whatwg_to_unicode) { described_class.whatwg_to_unicode(input, **options) }

    let(:options) { {} }
    let(:input) { "xn--gdkl8fhk5egc.jp" }
    let(:result) { "ハロー・ワールド.jp" }

    it { is_expected.to eq(result) }

    context "when the input is already Unicode" do
      let(:input) { result }

      it { is_expected.to eq(result) }
    end

    context "when the input is not a valid domain" do
      let(:input) { "under_scored.com" }

      it "raises an error" do
        expect { whatwg_to_unicode }.to raise_error(URI::IDNA::Error)
      end
    end

    context "with options" do
      let(:input) { "under_scored.com" }
      let(:options) { { be_strict: false } }

      it { is_expected.to eq(input) }
    end
  end

  describe ".whatwg_to_ascii" do
    subject(:whatwg_to_ascii) { described_class.whatwg_to_ascii(input, **options) }

    let(:options) { {} }
    let(:input) { "ハロー・ワールド.jp" }
    let(:result) { "xn--gdkl8fhk5egc.jp" }

    it { is_expected.to eq(result) }

    context "when the input is already ASCII" do
      let(:input) { result }

      it { is_expected.to eq(result) }
    end

    context "when the input is not a valid domain" do
      let(:input) { "under_scored.com" }

      it "raises an error" do
        expect { whatwg_to_ascii }.to raise_error(URI::IDNA::Error)
      end
    end

    context "with options" do
      let(:input) { "under_scored.com" }
      let(:options) { { be_strict: false } }

      it { is_expected.to eq(input) }
    end
  end
end
