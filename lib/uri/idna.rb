# frozen_string_literal: true

require_relative "idna/version"
require_relative "idna/punycode"
require_relative "idna/base_processing"
require_relative "idna/idna2008/processing"
require_relative "idna/uts46/processing"
require_relative "idna/whatwg/processing"

module URI
  module IDNA
    ACE_PREFIX = "xn--"

    class Error < StandardError; end

    # Raised when bidirectional requirements are not satisfied
    class BidiError < Error; end

    # Raised when a disallowed or unallocated codepoint is used
    class InvalidCodepointError < Error; end

    # Raised when the codepoint is not valid in the context it is used
    class InvalidCodepointContextError < Error; end

    # Raised when an error occurs during a punycode operation
    class PunycodeError < Error; end

    class << self
      # IDNA2008 Lookup protocol defined in RFC 5891
      # https://datatracker.ietf.org/doc/html/rfc5891#section-5
      def lookup(domain_name, **options)
        IDNA2008::Lookup.new(domain_name, **options).call
      end

      # IDNA2008 Registration protocol defined in RFC 5891
      # https://datatracker.ietf.org/doc/html/rfc5891#section-4
      def register(alabel: nil, ulabel: nil, **options)
        IDNA2008::Registration.new(alabel: alabel, ulabel: ulabel, **options).call
      end

      # UTS46 ToUnicode process
      # https://unicode.org/reports/tr46/#ToUnicode
      def to_unicode(domain_name, **options)
        UTS46::ToUnicode.new(domain_name, **options).call
      end

      # UTS46 ToASCII process
      # https://unicode.org/reports/tr46/#ToASCII
      def to_ascii(domain_name, **options)
        UTS46::ToASCII.new(domain_name, **options).call
      end

      # WHATWG URL Standard domain to ASCII algorithm
      # https://url.spec.whatwg.org/#idna
      def whatwg_to_unicode(domain_name, **options)
        WHATWG::ToUnicode.new(domain_name, **options).call
      end

      # WHATWG URL Standard domain to Unicode algorithm
      # https://url.spec.whatwg.org/#idna
      def whatwg_to_ascii(domain_name, **options)
        WHATWG::ToASCII.new(domain_name, **options).call
      end
    end
  end
end
