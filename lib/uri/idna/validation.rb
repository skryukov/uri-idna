# frozen_string_literal: true

require_relative "intranges"
require_relative "data/idna"
require_relative "validation/bidi"

module URI
  module IDNA
    # U-label domain validation for IDNA and UTS46.
    class Validation
      # @param [Hash] params
      # @option params [Boolean] :nfc Normalize to NFC (true by default)
      # @option params [Boolean] :hyphen34 Hyphen restrictions (true by default)
      # @option params [Boolean] :hyphen_sides Hyphen restrictions (true for the register protocol and UTS46)
      # @option params [Boolean] :leading_combining Leading combining marks (true for the register protocol and UTS46)
      # @option params [Boolean] :contextj Contextual rules CONTEXTJ (true by default)
      # @option params [Boolean] :contexto Contextual rules CONTEXTO (true for IDNA2008 protocols)
      # @option params [Boolean] :bidi Bidi rules (true by default)
      # @option params [Boolean] :idna_validity IDNA2008 validity (true for IDNA2008 protocols)
      # @option params [Boolean] :uts46 UTS46 validity (true for UTS46)
      # @option params [Boolean] :uts46_transitional UTS46 transitional validity (false by default)
      # @option params [Boolean] :check_dot Check for dots (true for UTS46)
      #
      def initialize(params)
        @nfc = params.fetch(:nfc, true)
        @hyphen34 = params.fetch(:hyphen34, true)
        @hyphen_sides = params.fetch(:hyphen_sides, true)

        # Contextual rules
        @leading_combining = params.fetch(:leading_combining, true)
        @contextj = params.fetch(:contextj, true)
        @contexto = params.fetch(:contexto, true)
        @bidi = params.fetch(:bidi, true)
        # IDNA2008 specific
        @idna_validity = params.fetch(:idna_validity, true)

        # UTS46 specific
        @uts46 = params.fetch(:uts46, false)
        @uts46_transitional = params.fetch(:uts46_transitional, false)
        @check_dot = params.fetch(:check_dot, false)
      end

      def call(label, decoded: false)
        raise Error, "Empty label" if label.empty?

        check_nfc(label) if @nfc
        check_hyphen34(label) if @hyphen34
        check_hyphen_sides(label) if @hyphen_sides
        check_leading_combining(label) if @leading_combining
        check_dot(label) if @check_dot
        label.each_char.with_index do |cp, pos|
          next if codepoint?(cp, "PVALID")

          if @contextj && codepoint?(cp, "CONTEXTJ")
            next if valid_contextj?(label, pos)

            raise InvalidCodepointContextError, cp_error_message(cp, label, pos)
          end

          if @contexto && codepoint?(cp, "CONTEXTO")
            next if valid_contexto?(label, pos)

            raise InvalidCodepointContextError, cp_error_message(cp, label, pos)
          end

          # 4.2.2. Rejection of Characters That Are Not Permitted
          # https://datatracker.ietf.org/doc/html/rfc5891#section-4.2.2
          raise InvalidCodepointError, cp_error_message(cp, label, pos) if @idna_validity

          if @uts46 && !UTS46.valid?(cp, uts46_transitional: @uts46_transitional && !decoded)
            raise InvalidCodepointError, cp_error_message(cp, label, pos)
          end
        end
        Bidi.call(label) if @bidi
      end

      private

      # 4.1. Input to IDNA Registration
      # https://datatracker.ietf.org/doc/html/rfc5891#section-4.1
      def check_nfc(label)
        return true if label.unicode_normalized?(:nfc)

        raise Error, "Label must be in Normalization Form C"
      end

      # 4.2.3.1. Hyphen Restrictions
      # https://datatracker.ietf.org/doc/html/rfc5891#section-4.2.3.1
      def check_hyphen34(label)
        return unless label[2..3] == "--"

        raise Error, "Label has disallowed hyphens in 3rd and 4th position"
      end

      # 4.2.3.1. Hyphen Restrictions
      # https://datatracker.ietf.org/doc/html/rfc5891#section-4.2.3.1
      def check_hyphen_sides(label)
        return unless label[0] == "-" || label[-1] == "-"

        raise Error, "Label must not start or end with a hyphen"
      end

      # 4.2.3.2. Leading Combining Marks
      # https://datatracker.ietf.org/doc/html/rfc5891#section-4.2.3.2
      def check_leading_combining(label)
        return unless Intranges.contain?(label[0].ord, INITIAL_COMBINERS)

        raise Error, "Label begins with an illegal combining character"
      end

      def check_dot(label)
        raise Error, "Label must not contain dots" if label.include?(".")
      end

      def valid_contexto?(label, pos)
        cp_value = label[pos].ord
        case cp_value
          # https://datatracker.ietf.org/doc/html/rfc5892#appendix-A.3
        when 0x00b7
          pos > 0 && pos < label.length - 1 ? (label[pos - 1].ord == 0x006c && label[pos + 1].ord == 0x006c) : false
          # https://datatracker.ietf.org/doc/html/rfc5892#appendix-A.4
        when 0x0375
          pos < label.length - 1 ? script?(label[pos + 1], "Greek") : false
          # https://datatracker.ietf.org/doc/html/rfc5892#appendix-A.5
          # https://datatracker.ietf.org/doc/html/rfc5892#appendix-A.6
        when 0x05f3, 0x05f4
          pos > 0 ? script?(label[pos - 1], "Hebrew") : false
          # https://datatracker.ietf.org/doc/html/rfc5892#appendix-A.7
        when 0x30fb
          label.each_char do |cp|
            next if cp.ord == 0x30fb
            return true if script?(cp, "Hiragana") || script?(cp, "Katakana") || script?(cp, "Han")
          end
          false
          # https://datatracker.ietf.org/doc/html/rfc5892#appendix-A.8
        when 0x0660..0x0669
          label.each_char do |cp|
            return false if cp.ord >= 0x06f0 && cp.ord <= 0x06f9
          end
          true
          # https://datatracker.ietf.org/doc/html/rfc5892#appendix-A.9
        when 0x06f0..0x06f9
          label.each_char do |cp|
            return false if cp.ord >= 0x0660 && cp.ord <= 0x0669
          end
          true
        else
          false
        end
      end

      def valid_contextj?(label, pos)
        case label[pos].ord
          # https://datatracker.ietf.org/doc/html/rfc5892#appendix-A.1
        when 0x200c
          return true if pos > 0 && virama_combining_class?(label[pos - 1])

          ok = false
          (pos - 1).downto(0) do |i|
            joining_type = JOINING_TYPES[label[i].ord]
            next if joining_type == 0x54

            if [0x4c, 0x44].include?(joining_type)
              ok = true
              break
            end
          end
          return false unless ok

          (pos + 1).upto(label.length - 1) do |i|
            joining_type = JOINING_TYPES[label[i].ord]
            next if joining_type == 0x54
            return true if [0x52, 0x44].include?(joining_type)
          end
          # https://datatracker.ietf.org/doc/html/rfc5892#appendix-A.2
        when 0x200d
          return virama_combining_class?(label[pos - 1]) if pos > 0
        end
        false
      end

      def codepoint?(cp, class_name)
        Intranges.contain?(cp.ord, CODEPOINT_CLASSES[class_name])
      end

      def script?(cp, script)
        Intranges.contain?(cp.ord, SCRIPTS[script])
      end

      def virama_combining_class?(cp)
        Intranges.contain?(cp.ord, VIRAMA_COMBINING_CLASSES)
      end

      def cp_error_message(cp, label, pos)
        format("Codepoint U+%04X at position %d of %p not allowed", cp.ord, pos + 1, label)
      end
    end
  end
end
