# URI::IDNA

[![Gem Version](https://badge.fury.io/rb/uri-idna.svg)](https://rubygems.org/gems/uri-idna)
[![Ruby](https://github.com/skryukov/uri-idna/actions/workflows/main.yml/badge.svg)](https://github.com/skryukov/uri-idna/actions/workflows/main.yml)

A IDNA2008, UTS46, IDNA from WHATWG URL Standard and Punycode implementation in pure Ruby.

This gem provides a number of functions for converting internationalized domain names (IDNs) between the Unicode and ASCII Compatible Encoding (ACE) forms.

<a href="https://evilmartians.com/?utm_source=uri-idna&utm_campaign=project_page">
<img src="https://evilmartians.com/badges/sponsored-by-evil-martians.svg" alt="Sponsored by Evil Martians" width="236" height="54">
</a>

## Installation

Add to your Gemfile:
```ruby
gem "uri-idna"
```

And then run `bundle install`.

## Usage

There are plenty of ways to convert IDNs between Unicode and ACE forms.

### IDNA2008

The [RFC 5891] defines two protocols for IDN conversion: [Registration](https://datatracker.ietf.org/doc/html/rfc5891#section-4) and [Domain Name Lookup](https://datatracker.ietf.org/doc/html/rfc5891#section-5).

#### Registration protocol

`URI::IDNA.register(alabel:, ulabel:, **options)`

##### Options

- `check_hyphens`: `true` – whether to check hyphens according to [Section 5.4](https://datatracker.ietf.org/doc/html/rfc5891#section-5.4).
- `leading_combining`: `true` – whether to check leading combining marks according to [Section 5.4](https://datatracker.ietf.org/doc/html/rfc5891#section-5.4).
- `check_joiners`: `true` – whether to check `CONTEXTJ` code points according to [Section 5.4](https://datatracker.ietf.org/doc/html/rfc5891#section-5.4).
- `check_others`: `true` – whether to check `CONTEXTO` code points according to [Section 5.4](https://datatracker.ietf.org/doc/html/rfc5891#section-5.4).
- `check_bidi`: `true` – whether to check bidirectional characters according to [Section 5.4](https://datatracker.ietf.org/doc/html/rfc5891#section-5.4).

```ruby
require "uri/idna"

URI::IDNA.register(alabel: "xn--gdkl8fhk5egc.jp", ulabel: "ハロー・ワールド.jp")
#=> "xn--gdkl8fhk5egc.jp"

URI::IDNA.register(ulabel: "ハロー・ワールド.jp")
#=> "xn--gdkl8fhk5egc.jp"

URI::IDNA.register(alabel: "xn--gdkl8fhk5egc.jp")
#=> "xn--gdkl8fhk5egc.jp"

URI::IDNA.register(ulabel: "☕.us")
#<URI::IDNA::InvalidCodepointError: Codepoint U+2615 at position 1 of "☕" not allowed>
```

#### Domain Name Lookup Protocol

`URI::IDNA.lookup(domain_name, **options)`

##### Options

- `check_hyphens`: `true` – whether to check hyphens according to [Section 4.2.3.1](https://datatracker.ietf.org/doc/html/rfc5891#section-4.2.3.1).
- `leading_combining`: `true` – whether to check leading combining marks according to [Section 4.2.3.2](https://datatracker.ietf.org/doc/html/rfc5891#section-4.2.3.2).
- `check_joiners`: `true` – whether to check CONTEXTJ code points according to [Section 4.2.3.3](https://datatracker.ietf.org/doc/html/rfc5891#section-4.2.3.3).
- `check_others`: `true` – whether to check CONTEXTO code points according to [Section 4.2.3.3](https://datatracker.ietf.org/doc/html/rfc5891#section-4.2.3.3).
- `check_bidi`: `true` – whether to check bidirectional characters according to [Section 4.2.3.4](https://datatracker.ietf.org/doc/html/rfc5891#section-4.2.3.4).
- `verify_dns_length`: `true` – whether to check DNS length according to [Section 4.4](https://datatracker.ietf.org/doc/html/rfc5891#section-4.4).

```ruby
require "uri/idna"

URI::IDNA.lookup("ハロー・ワールド.jp")
#=> "xn--pck0a1b0a6a2e.jp"

URI::IDNA.lookup("xn--pck0a1b0a6a2e.jp")
#=> "xn--pck0a1b0a6a2e.jp"

URI::IDNA.lookup("Ῠ.me")
#<URI::IDNA::InvalidCodepointError: Codepoint U+1FE8 at position 1 of "Ῠ" not allowed>
```

### Unicode UTS46 (TR46)

_Current revision: 31_

The [UTS46] defines two IDN conversion functions: [ToASCII](https://www.unicode.org/reports/tr46/#ToASCII) and [ToUnicode](https://www.unicode.org/reports/tr46/#ToUnicode).

#### ToASCII

`URI::IDNA.to_ascii(domain_name, **options)`

##### Options

- `use_std3_ascii_rules`: `true` – whether to apply [STD3 rules](https://www.unicode.org/reports/tr46/#STD3_Rules) for both mapping and validation.
- `check_hyphens`: `true` – whether to check hyphens according to [Section 4.2.3.1](https://datatracker.ietf.org/doc/html/rfc5891#section-4.2.3.1) of [RFC 5891].
- `check_bidi`: `true` – whether to check bidirectional characters according to [Section 4.2.3.4](https://datatracker.ietf.org/doc/html/rfc5891#section-4.2.3.4) of [RFC 5891].
- `check_joiners`: `true` – whether to check CONTEXTJ code points according to [Section 4.2.3.3](https://datatracker.ietf.org/doc/html/rfc5891#section-4.2.3.3) of [RFC 5891].
- `transitional_processing`: `false` – (deprecated) whether to apply [transitional processing](https://www.unicode.org/reports/tr46/#ProcessingStepMap) for mapping.
- `ignore_invalid_punycode`: `false` – whether to fast-path invalid Punycode labels according to [4th step of Processing](https://www.unicode.org/reports/tr46/#ProcessingStepPunycode).
- `verify_dns_length`: `true` – whether to check DNS length according to [Section 4.4](https://datatracker.ietf.org/doc/html/rfc5891#section-4.4) of [RFC 5891].

```ruby
require "uri/idna"

URI::IDNA.to_ascii("Bloß.de")
#=> "xn--blo-7ka.de"

# UTS46 transitional processing is disabled by default,
# but can be enabled via option:
URI::IDNA.to_ascii("Bloß.de", transitional_processing: true)
#=> "bloss.de"

# Note that UTS46 processing is not fully IDNA2008 compliant:
URI::IDNA.to_ascii("☕.us")
#=> "xn--53h.us"
```

#### ToUnicode

`URI::IDNA.to_unicode(domain_name, **options)`

##### Options

- `use_std3_ascii_rules`: `true` – whether to apply [STD3 rules](https://www.unicode.org/reports/tr46/#STD3_Rules) for both mapping and validation.
- `check_hyphens`: `true` – whether to check hyphens according to [Section 4.2.3.1](https://datatracker.ietf.org/doc/html/rfc5891#section-4.2.3.1) of [RFC 5891].
- `check_bidi`: `true` – whether to check bidirectional characters according to [Section 4.2.3.4](https://datatracker.ietf.org/doc/html/rfc5891#section-4.2.3.4) of [RFC 5891].
- `check_joiners`: `true` – whether to check CONTEXTJ code points according to [Section 4.2.3.3](https://datatracker.ietf.org/doc/html/rfc5891#section-4.2.3.3) of [RFC 5891].
- `transitional_processing`: `false` – (deprecated) whether to apply [transitional processing](https://www.unicode.org/reports/tr46/#ProcessingStepMap) for mapping.
- `ignore_invalid_punycode`: `false` – whether to fast-path invalid Punycode labels according to [4th step of Processing](https://www.unicode.org/reports/tr46/#ProcessingStepPunycode).

```ruby
require "uri/idna"

URI::IDNA.to_unicode("xn--blo-7ka.de")
#=> "bloß.de"
```

#### IDNA2008 compatibility

It's possible to use UTS46 mapping first and then apply IDNA2008, so the processing fully conforms IDNA2008:

```ruby
require "uri/idna"

# For example we can use UTS46 mapping to downcase some characters
char = "⼤"
char.ord # "\u2F24"
#=> 12068

# just downcase doesn't work in this case
char.downcase.ord
#=> 12068

# but UTS46 mapping does it's thing:
URI::IDNA::UTS46::Mapping.call(char).ord
#=> 22823

# so here is a full example:
domain = "⼤.cn" # "\u2F24.cn"
URI::IDNA.lookup(domain)
# <URI::IDNA::InvalidCodepointError: Codepoint U+2F24 at position 1 of "⼤" not allowed>

mapped_domain = URI::IDNA::UTS46::Mapping.call(domain)
URI::IDNA.lookup(mapped_domain)
#=> "xn--pss.cn"
```

### WHATWG

WHATWG's [URL Standard] uses UTS46 algorithm to define ToASCII and ToUnicode functions, it abstracts all available flags and provides only one—the `be_btrict` flag instead.

Note that the `check_hyphens` UTS46 option is set to `false` in this algorithm.

#### ToASCII

`URI::IDNA.whatwg_to_ascii(domain_name, **options)`

##### Options

- `be_strict`: `true` – defines values of `use_std3_ascii_rules` and `verify_dns_length` UTS46 options.

```ruby
require "uri/idna"

URI::IDNA.whatwg_to_ascii("Bloß.de")
#=> "xn--blo-7ka.de"

# The be_strict flag sets use_std3_ascii_rules and verify_dns_length UTS46 flags to its value
URI::IDNA.whatwg_to_ascii("2003_rules.com", be_strict: false)
#=> "2003_rules.com"

# By default be_strict is set to true
URI::IDNA.whatwg_to_ascii("2003_rules.com")
#<URI::IDNA::InvalidCodepointError: Codepoint U+005F at position 5 of "2003_rules" not allowed>
```

#### ToUnicode

`URI::IDNA.whatwg_to_unicode(domain_name, **options)`

##### Options

- `be_strict`: `true` - defines value of `use_std3_ascii_rules` UTS46 option.

```ruby
require "uri/idna"

URI::IDNA.whatwg_to_unicode("xn--blo-7ka.de")
#=> "bloß.de"
```

### Punycode

Punycode module performs conversion between Unicode and Punycode. Note that Punycode is not IDNA2008 compliant, it is only used for conversion, no validations performed.

```ruby
require "uri/idna/punycode"

URI::IDNA::Punycode.encode("ハロー・ワールド")
#=> "gdkl8fhk5egc"

URI::IDNA::Punycode.decode("gdkl8fhk5egc")
#=> "ハロー・ワールド"
```

## Full technical reference:

### IDNA2008
- [RFC 5890] – Definitions and Document Framework
- [RFC 5891] – Protocol
- [RFC 5892] – The Unicode Code Points
- [RFC 5893] – Bidi rule

### Punycode

- [RFC 3492] – Punycode: A Bootstring encoding of Unicode

### UTS46 (also referenced as TS46)

- [Unicode IDNA Compatibility Processing][UTS46]

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

### Generating Unicode data

This gem uses Unicode data files to perform IDN conversion. To generate new Unicode data files, run `bundle exec rake idna:generate`.

To specify Unicode version, use `VERSION` environment variable, e.g. `VERSION=15.1.0 bundle exec rake idna:generate`.

By default, used Unicode version is the one used by the Ruby version (`RbConfig::CONFIG["UNICODE_VERSION"]`).

To set directory for generated files, use `DEST_DIR` environment variable, e.g. `DEST_DIR=lib/uri/idna/data bundle exec rake idna:generate`.

Unicode data cached in the `tmp` directory by default, to change it, use `CACHE_DIR` environment variable, e.g. `CACHE_DIR=~/.cache/unicode_data bundle exec rake idna:generate`.

_Note: `rake idna:generate` might generate different results on different versions of Ruby due to usage of built-in Unicode normalization methods._

### Inspect Unicode data

To inspect Unicode data, run `bundle exec rake 'idna:inspect[<HEX_CODE>]'`.

To specify Unicode version, or cache directory, use `VERSION` or `CACHE_DIR` environment variables, e.g. `VERSION=15.1.0 bundle exec rake 'idna:inspect[1f495]'`.

### Update UTS46 test suite data

To update UTS46 test suite data, run `bundle exec rake idna:update_uts46_test_suite`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/skryukov/uri-idna.

## License

The gem is available as open source under the terms of the [MIT License].

[RFC 5890]: https://datatracker.ietf.org/doc/html/rfc5890
[RFC 5891]: https://datatracker.ietf.org/doc/html/rfc5891
[RFC 5892]: https://datatracker.ietf.org/doc/html/rfc5892
[RFC 5893]: https://datatracker.ietf.org/doc/html/rfc5893
[RFC 3492]: https://datatracker.ietf.org/doc/html/rfc3492
[UTS46]: https://www.unicode.org/reports/tr46
[URL Standard]: https://url.spec.whatwg.org/#idna
[MIT License]: https://opensource.org/licenses/MIT
