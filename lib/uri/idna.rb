# frozen_string_literal: true

require_relative "idna/version"
require_relative "idna/process"

module URI
  module IDNA
    ALABEL_PREFIX = "xn--"

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
      UTS46_PARAMS = {
        check_dot: true,
        idna_validity: false,
        uts46: true,
        uts46_std3: true,
        uts46_transitional: false,
        contexto: false,
      }.freeze

      LOOKUP_PARAMS = {
        hyphen_sides: false,
        leading_combining: false,
      }.freeze

      def lookup(s, **params)
        Process.new(**LOOKUP_PARAMS.merge(params)).lookup(s)
      end

      def register(alabel: nil, ulabel: nil, **params)
        Process.new(**params).register(alabel: alabel, ulabel: ulabel)
      end

      # UTS46 ToUnicode process
      # https://unicode.org/reports/tr46/#ToUnicode
      def to_unicode(s, **params)
        Process.new(**UTS46_PARAMS.merge(params)).decode(s)
      end

      # UTS46 ToASCII process
      # https://unicode.org/reports/tr46/#ToASCII
      def to_ascii(s, **params)
        Process.new(**UTS46_PARAMS.merge(params)).encode(s)
      end
    end
  end
end
