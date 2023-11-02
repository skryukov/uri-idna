# frozen_string_literal: true

module URI
  module IDNA
    # https://url.spec.whatwg.org/#idna
    module WHATWG
      class ToASCII < UTS46::ToASCII
        def initialize(domain_name, be_strict: true)
          super(
            domain_name,
            use_std3_ascii_rules: be_strict,
            check_hyphens: false,
            check_bidi: true,
            check_joiners: true,
            transitional_processing: false,
            verify_dns_length: be_strict,
          )
        end
      end

      class ToUnicode < UTS46::ToUnicode
        def initialize(domain_name, be_strict: true)
          super(
            domain_name,
            use_std3_ascii_rules: be_strict,
            check_hyphens: false,
            check_bidi: true,
            check_joiners: true,
            transitional_processing: false,
          )
        end
      end
    end
  end
end
