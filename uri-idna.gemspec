# frozen_string_literal: true

require_relative "lib/uri/idna/version"

Gem::Specification.new do |spec|
  spec.name = "uri-idna"
  spec.version = URI::IDNA::VERSION
  spec.authors = ["Svyatoslav Kryukov"]
  spec.email = ["s.g.kryukov@yandex.ru"]

  spec.summary = "Internationalized Domain Names for Ruby (IDNA 2008 and UTS #46)"
  spec.description = "Internationalized Domain Names in Applications (IDNA)"
  spec.homepage = "https://github.com/skryukov/uri-idna"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.7.0"

  spec.metadata = {
    "bug_tracker_uri" => "#{spec.homepage}/issues",
    "changelog_uri" => "#{spec.homepage}/blob/main/CHANGELOG.md",
    "documentation_uri" => "#{spec.homepage}/blob/main/README.md",
    "homepage_uri" => spec.homepage,
    "source_code_uri" => spec.homepage,
    "rubygems_mfa_required" => "true",
  }

  spec.files = Dir.glob("lib/**/*") + %w[README.md LICENSE.txt CHANGELOG.md]
  spec.require_paths = ["lib"]
end
