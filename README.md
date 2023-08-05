# URI::IDNA

[![Gem Version](https://badge.fury.io/rb/uri-idna.svg)](https://rubygems.org/gems/uri-idna)
[![Ruby](https://github.com/skryukov/uri-idna/actions/workflows/main.yml/badge.svg)](https://github.com/skryukov/uri-idna/actions/workflows/main.yml)

A IDNA 2008, UTS 46 and Punycode implementation in pure Ruby.

This gem provides a number of functions for converting internationalized domain names (IDNs) between the Unicode and ASCII Compatible Encoding (ACE) forms.

<a href="https://evilmartians.com/?utm_source=rubocop-gradual&utm_campaign=project_page">
<img src="https://evilmartians.com/badges/sponsored-by-evil-martians.svg" alt="Sponsored by Evil Martians" width="236" height="54">
</a>

## Installation

Add to your Gemfile:
```ruby
gem "idna-idna"
```

And then run `bundle install`.

## Usage

There are plenty of ways to convert IDNs between Unicode and ACE forms.

### IDNA 2008

The [RFC 5890] defines two protocols for IDN conversion: [Registration](https://datatracker.ietf.org/doc/html/rfc5891#section-4) and [Domain Name Lookup](https://datatracker.ietf.org/doc/html/rfc5891#section-5).

#### Registration protocol

```ruby
require "uri/idna"

URI::IDNA.register(alabel: "xn--gdkl8fhk5egc", ulabel: "ハロー・ワールド")
#=> "xn--gdkl8fhk5egc"

URI::IDNA.register(ulabel: "ハロー・ワールド")
#=> "xn--gdkl8fhk5egc"

URI::IDNA.register(alabel: "xn--gdkl8fhk5egc")
#=> "xn--gdkl8fhk5egc"

URI::IDNA.register(ulabel: "☕.us")
#<URI::IDNA::InvalidCodepointError: Codepoint U+2615 at position 1 of "☕" not allowed>
```

#### Domain Name Lookup Protocol

```ruby
require "uri/idna"

URI::IDNA.lookup("ハロー・ワールド")
#=> "xn--pck0a1b0a6a2e"

URI::IDNA.lookup("xn--pck0a1b0a6a2e")
#=> "xn--pck0a1b0a6a2e"

URI::IDNA.lookup("Ῠ.me")
#<URI::IDNA::InvalidCodepointError: Codepoint U+1FE8 at position 1 of "Ῠ" not allowed>
```

### Unicode UTS 46(TR46)

The [UTS 46](https://www.unicode.org/reports/tr46) defines two IDN conversion functions: [ToASCII](https://www.unicode.org/reports/tr46/#ToASCII) and [ToUnicode](https://www.unicode.org/reports/tr46/#ToUnicode).

#### ToASCII

```ruby
require "uri/idna"

URI::IDNA.to_ascii("Bloß.de")
#=> "xn--blo-7ka.de"

# UTS 46 transitional processing is disabled by default,
# but can be enabled via option:
URI::IDNA.to_ascii("Bloß.de", uts46_transitional: true)
#=> "bloss.de"

# Note that UTS 46 transitional processing is not fully IDNA 2008 compliant:
URI::IDNA.to_ascii("☕.us")
#=> "xn--53h.us"
```

#### ToUnicode

```ruby
require "uri/idna"

URI::IDNA.to_unicode("xn--blo-7ka.de")
#=> "bloß.de"
```

#### IDNA 2008 compatibility

It's possible to apply both IDNA 2008 and UTS 46 at once:

```ruby
require "uri/idna"

URI::IDNA.to_ascii("☕.us", idna_validity: true, contexto: true)
#<URI::IDNA::InvalidCodepointError: Codepoint U+2615 at position 1 of "☕" not allowed>

# It's also possible to apply UTS 46 to IDNA 2008 protocols:
URI::IDNA.lookup("Ῠ.me", check_dot: true, uts46: true, uts46_std3: true)
#=> "xn--rtg.me"
```

### Punycode

Punycode module performs conversion between Unicode and Punycode. Note that Punycode is not IDNA 2008 compliant, it is only used for conversion, no validations performed.

```ruby
require "uri/idna/punycode"

URI::IDNA::Punycode.encode("ハロー・ワールド")
#=> "gdkl8fhk5egc"

URI::IDNA::Punycode.decode("gdkl8fhk5egc")
#=> "ハロー・ワールド"
```

## Full technical reference:

### IDNA 2008
- [RFC 5890] – Definitions and Document Framework
- [RFC 5891] – Protocol
- [RFC 5892] – The Unicode Code Points
- [RFC 5893] – Bidi rule

### Punycode

- [RFC 3492] – Punycode: A Bootstring encoding of Unicode

### UTS 46 (also referenced as TS46)

- [Unicode IDNA Compatibility Processing]

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

### Generating Unicode data

This gem uses Unicode data files to perform IDN conversion. To generate new Unicode data files, run `bundle exec rake idna:generate`.

To specify Unicode version, use `UNICODE_VERSION` environment variable, e.g. `UNICODE_VERSION=14.0.0 bundle exec rake idna:generate`.

By default, used Unicode version is the one used by the Ruby version (`RbConfig::CONFIG["UNICODE_VERSION"]`).

To set directory for generated files, use `DATA_DIR` environment variable, e.g. `DATA_DIR=lib/uri/idna/data bundle exec rake idna:generate`.

Unicode data cached in the `tmp` directory by default, to change it, use `CACHE_DIR` environment variable, e.g. `CACHE_DIR=~/.cache/unicode_data bundle exec rake idna:generate`.

### Inspect Unicode data

To inspect Unicode data, run `bundle exec rake idna:inspect[<HEX_CODE>]`.

To specify Unicode version, or cache directory, use `UNICODE_VERSION` or `CACHE_DIR` environment variables, e.g. `UNICODE_VERSION=15.0.0 bundle exec rake idna:inspect[1f495]`.

Note: if you getting the `no matches found: idna:inspect[1f495]` error, try to escape the brackets: `bundle exec rake idna:inspect\[1f495\]`.

### Update UTS 46 test suite data

To update UTS 46 test suite data, run `bundle exec rake idna:update_uts46_test_suite`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/skryukov/uri-idna.

## License

The gem is available as open source under the terms of the [MIT License].

[RFC 5890]: (https://datatracker.ietf.org/doc/html/rfc5890)
[RFC 5891]: (https://datatracker.ietf.org/doc/html/rfc5891)
[RFC 5892]: (https://datatracker.ietf.org/doc/html/rfc5892)
[RFC 5893]: (https://datatracker.ietf.org/doc/html/rfc5893)
[RFC 3492]: (https://datatracker.ietf.org/doc/html/rfc3492)
[Unicode IDNA Compatibility Processing]: (https://www.unicode.org/reports/tr46)
[MIT License]: (https://opensource.org/licenses/MIT)
