# frozen_string_literal: true

module URI
  module IDNA
    module UTS46
      # Options for ToUnicode operation
      # https://www.unicode.org/reports/tr46/#ToUnicode
      class Options
        USE_STD3_ASCII_RULES      = 1 << 0
        CHECK_HYPHENS             = 1 << 1
        CHECK_BIDI                = 1 << 2
        CHECK_JOINERS             = 1 << 3
        TRANSITIONAL_PROCESSING   = 1 << 4
        IGNORE_INVALID_PUNYCODE   = 1 << 5

        def initialize(
          use_std3_ascii_rules: true,
          check_hyphens: true,
          check_bidi: true,
          check_joiners: true,
          transitional_processing: false,
          ignore_invalid_punycode: false
        )
          @flags = 0
          @flags |= USE_STD3_ASCII_RULES if use_std3_ascii_rules
          @flags |= CHECK_HYPHENS if check_hyphens
          @flags |= CHECK_BIDI if check_bidi
          @flags |= CHECK_JOINERS if check_joiners
          @flags |= TRANSITIONAL_PROCESSING if transitional_processing
          @flags |= IGNORE_INVALID_PUNYCODE if ignore_invalid_punycode
        end

        def use_std3_ascii_rules?
          (@flags & USE_STD3_ASCII_RULES) != 0
        end

        def check_hyphens?
          (@flags & CHECK_HYPHENS) != 0
        end

        def check_bidi?
          (@flags & CHECK_BIDI) != 0
        end

        def check_joiners?
          (@flags & CHECK_JOINERS) != 0
        end

        def transitional_processing?
          (@flags & TRANSITIONAL_PROCESSING) != 0
        end

        def ignore_invalid_punycode?
          (@flags & IGNORE_INVALID_PUNYCODE) != 0
        end
      end

      # Options for ToASCII operation
      # https://www.unicode.org/reports/tr46/#ToASCII
      class ToASCIIOptions < Options
        VERIFY_DNS_LENGTH = 1 << 6

        def initialize(verify_dns_length: true, **options)
          @flags_extended = 0
          @flags_extended |= VERIFY_DNS_LENGTH if verify_dns_length
          super(**options)
        end

        def verify_dns_length?
          (@flags_extended & VERIFY_DNS_LENGTH) != 0
        end
      end
    end
  end
end
