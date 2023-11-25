# frozen_string_literal: true

require_relative "code_point"
require_relative "unicode_data"
require_relative "idna_generator"
require_relative "scripts_generator"
require_relative "uts46_generator"

namespace :idna do
  desc "Generate data files for IDNA"
  task :generate, [:version] do
    dest_dir = ENV.fetch("DEST_DIR", ".")
    FileUtils.mkdir_p(dest_dir)

    File.write(File.join(dest_dir, "joining_types.rb"), BaseGenerator.new(ucdata, "joining_types.erb"))
    File.write(File.join(dest_dir, "unicode_version.rb"), BaseGenerator.new(ucdata, "unicode_version.erb"))
    File.write(File.join(dest_dir, "scripts.rb"), ScriptsGenerator.new(ucdata, "scripts.erb"))
    File.write(File.join(dest_dir, "uts46.rb"), UTS46Generator.new(ucdata, "uts46.erb"))

    generator = IDNAGenerator.new(ucdata)
    File.write(File.join(dest_dir, "bidi_classes.rb"), generator.render("bidi_classes.erb"))
    File.write(File.join(dest_dir, "codepoint_classes.rb"), generator.render("codepoint_classes.erb"))
    File.write(File.join(dest_dir, "leading_combiners.rb"), generator.render("leading_combiners.erb"))
    File.write(File.join(dest_dir, "virama_combining_classes.rb"), generator.render("virama_combining_classes.erb"))
  end

  desc "Inspect code point data: bundle exec rake 'idna:inspect[U+FFFF]'"
  task :inspect, [:cp] do |_task, args|
    result = args[:cp].match(/\A(?:U\+|)(?<cp>[\dA-F]{2,6})\z/i)
    if result.nil?
      warn "usage: bundle exec rake 'cp_inspect[U+FFFF]'"
      exit!
    end

    puts CodePoint.new(result[:cp].hex, ucdata: ucdata).diagnose
  end

  desc "Update UTS46 test suite data file"
  task :update_uts46_test_suite do
    require_relative "../lib/uri/idna/data/unicode_version"

    filename = "IdnaTestV2.txt"
    version = ENV.fetch("VERSION", URI::IDNA::UNICODE_VERSION)
    url = UnicodeData::UTS46_URL % ({ version: version, filename: filename })

    io = URI.parse(url).open
    File.write(File.join(__dir__, "..", "spec", "data", filename), io.read)
  end
end

def ucdata
  cache = ENV["NO_CACHE"] ? nil : ENV["CACHE_DIR"] || "tmp"
  version = ENV.fetch("VERSION", RbConfig::CONFIG["UNICODE_VERSION"])
  UnicodeData.new(version, cache)
end
