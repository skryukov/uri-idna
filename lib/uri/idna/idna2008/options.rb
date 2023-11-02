# frozen_string_literal: true

module URI
  module IDNA
    module IDNA2008
      class Options
        attr_reader :flags

        CHECK_HYPHENS        = 1 << 0
        LEADING_COMBINING    = 1 << 1
        CHECK_JOINERS        = 1 << 2
        CHECK_OTHERS         = 1 << 3
        CHECK_BIDI           = 1 << 4
        VERIFY_DNS_LENGTH    = 1 << 5

        def initialize(
          check_hyphens: true,
          leading_combining: true,
          check_joiners: true,
          check_others: true,
          check_bidi: true,
          verify_dns_length: true
        )
          @flags = 0
          @flags |= CHECK_HYPHENS if check_hyphens
          @flags |= LEADING_COMBINING if leading_combining
          @flags |= CHECK_JOINERS if check_joiners
          @flags |= CHECK_OTHERS if check_others
          @flags |= CHECK_BIDI if check_bidi
          @flags |= VERIFY_DNS_LENGTH if verify_dns_length
        end

        def check_hyphens?
          (flags & CHECK_HYPHENS) != 0
        end

        def leading_combining?
          (flags & LEADING_COMBINING) != 0
        end

        def check_joiners?
          (flags & CHECK_JOINERS) != 0
        end

        def check_others?
          (flags & CHECK_OTHERS) != 0
        end

        def check_bidi?
          (flags & CHECK_BIDI) != 0
        end

        def verify_dns_length?
          (flags & VERIFY_DNS_LENGTH) != 0
        end
      end
    end
  end
end
