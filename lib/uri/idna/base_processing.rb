# frozen_string_literal: true

require_relative "validation/label"
require_relative "validation/codepoint"
require_relative "validation/bidi"

module URI
  module IDNA
    class BaseProcessing
      def initialize(domain_name, **options)
        @domain_name = domain_name
        @options = options_class.new(**options)
      end

      private

      attr_reader :domain_name, :options

      def options_class
        raise NotImplementedError, "Implement #options_class method"
      end

      def punycode_decode(label)
        raise Error, "Label contains non-ASCII code point" unless label.ascii_only?

        code = label[ACE_PREFIX.length..]
        raise Error, "Malformed A-label, no Punycode eligible content found" if code.empty?

        Punycode.decode(code)
      end

      def punycode_encode(label)
        return label if label.ascii_only?

        ACE_PREFIX + Punycode.encode(label)
      end

      def process_labels(domain)
        labels, trailing_dot = split_domain(domain)

        labels.map! do |label|
          raise Error, "Empty label" if label.empty?

          yield label
        end

        join_labels(labels, trailing_dot)
      end

      def join_labels(labels, trailing_dot)
        labels << "" if trailing_dot
        labels.join(".")
      end

      def split_domain(domain)
        labels = domain.split(".", -1)
        trailing_dot = labels[-1] && labels[-1].empty? ? labels.pop : false

        raise Error, "Empty domain" if labels.empty? || labels == [""]

        [labels, trailing_dot]
      end

      def check_bidi?
        return @check_bidi if instance_variable_defined?(:@check_bidi)

        @check_bidi = options.check_bidi? && Validation::Bidi.check?(domain_name)
      end
    end
  end
end
