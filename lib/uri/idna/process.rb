# frozen_string_literal: true

require_relative "punycode"
require_relative "validation"

require_relative "uts46"

module URI
  module IDNA
    class Process
      UNICODE_DOTS_REGEX = /[\u002e\u3002\uff0e\uff61]/.freeze

      def initialize(**options)
        @options = options
      end

      def register(alabel: nil, ulabel: nil)
        raise ArgumentError, "Provide alabel or ulabel" if alabel.nil? && ulabel.nil?

        return encode(ulabel) if alabel.nil?

        raise ArgumentError, "String expected" unless alabel.is_a?(String)
        raise Error, "Invalid alabel #{alabel}" unless alabel.start_with?(ALABEL_PREFIX)

        process_labels(alabel) do |l|
          to_alabel(l, roundtrip: true, ulabel: ulabel)
        end
      end

      def lookup(s)
        raise ArgumentError, "String expected" unless s.is_a?(String)

        s = process_labels(s) do |l|
          to_alabel(l, roundtrip: true)
        end
        validate_domain_length(s) if options.fetch(:dns_length, true)
        s
      end

      def encode(s)
        raise ArgumentError, "String expected" unless s.is_a?(String)

        s = process_labels(s) { |l| to_alabel(l) }
        validate_domain_length(s) if options.fetch(:dns_length, true)
        s
      end

      def decode(s)
        raise ArgumentError, "String expected" unless s.is_a?(String)

        process_labels(s) { |l| to_ulabel(l) }
      end

      private

      attr_reader :labels, :options

      def splitter
        @splitter ||= options.fetch(:uts46, false) ? "." : UNICODE_DOTS_REGEX
      end

      def process_labels(s)
        s = UTS46.map_string(s, **options.slice(:uts46_std3, :uts46_transitional)) if options.fetch(:uts46, false)
        @labels ||= s.split(splitter, -1)
        trailing_dot = labels[-1] && labels[-1].empty? ? labels.pop : false

        raise Error, "Empty domain" if labels.empty? || labels == [""]

        result = []
        labels.each do |label|
          str = yield(label)
          raise Error, "Empty label" if str.empty?

          result << str
        end

        result << "" if trailing_dot
        result.join(".")
      end

      def to_alabel(label, roundtrip: false, ulabel: nil)
        orig_label = label
        # validate label is a valid U-label
        label = to_ulabel(label)
        if ulabel && ulabel != label
          raise Error, "Provided ulabel does not match conversion of alabel, #{ulabel.inspect} != #{label.inspect}"
        end

        label = encode_punycode_label(label) unless label.ascii_only?
        validate_label_length(label)

        if roundtrip && orig_label.ascii_only? && orig_label != label
          raise Error, "Roundtrip encoding failed, #{orig_label.inspect} != #{label.inspect}"
        end

        label
      end

      # https://datatracker.ietf.org/doc/html/rfc5891#section-5.3
      def to_ulabel(label)
        decoded = false
        label, decoded = decode_punycode_label(label) if label.ascii_only?
        validation.call(label, decoded: decoded)
        label
      end

      def encode_punycode_label(label)
        ALABEL_PREFIX + Punycode.encode(label)
      end

      def decode_punycode_label(label)
        label = label.downcase
        return [label, false] unless label.start_with?(ALABEL_PREFIX)

        code = label[ALABEL_PREFIX.length..]
        raise Error, "Malformed A-label, no Punycode eligible content found" if code.empty?
        raise Error, "A-label must not end with a hyphen" if code[-1] == "-"

        [URI::IDNA::Punycode.decode(code), true]
      end

      def validate_label_length(label)
        raise Error, "Label too long" unless label.length < 64
      end

      def validate_domain_length(s)
        raise Error, "Domain too long" unless s.length < (s[-1] == "." ? 255 : 254)
      end

      def validation
        @validation ||= Validation.new(options.merge(bidi: check_bidi?))
      end

      def check_bidi?
        options.fetch(:bidi, true) && Validation::Bidi.check?(labels)
      end
    end
  end
end
