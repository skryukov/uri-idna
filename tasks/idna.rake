# frozen_string_literal: true

require_relative "code_point"
require_relative "unicode_data"

namespace :idna do
  desc "Generate data files for IDNA"
  task :generate, [:version] do
    generate_data_files
  end

  desc "Inspect code point data: bundle exec rake 'idna:inspect[U+FFFF]'"
  task :inspect, [:cp] do |_task, args|
    result = args[:cp].match(/\A(?:U\+|)(?<cp>[\dA-F]{2,6})\z/i)
    if result.nil?
      warn "usage: bundle exec rake 'cp_inspect[U+FFFF]'"
      exit!
    end

    codepoint = result[:cp].to_i(16)
    puts CodePoint.new(codepoint, ucdata: ucdata).diagnose
  end

  desc "Update UTS46 test suite data file"
  task :update_uts46_test_suite do
    require_relative "../lib/uri/idna/data/idna"

    filename = "IdnaTestV2.txt"
    version = ENV.fetch("VERSION", URI::IDNA::UNICODE_VERSION)
    url = UnicodeData::UTS46_URL % ({ version: version, filename: filename })

    io = URI.parse(url).open
    File.write(File.join(__dir__, "..", "spec", "data", filename), io.read)
  end

  def generate_data_files
    require_relative "idna_data"
    require_relative "uts64_data"

    dest_dir = ENV.fetch("DEST_DIR", ".")
    FileUtils.mkdir_p(dest_dir)
    target_filename = File.join(dest_dir, "idna.rb")
    File.open(target_filename, "w") do |f|
      IDNAData.new(ucdata).each_entry { |l| f.puts l }
    end
    target_filename = File.join(dest_dir, "uts46.rb")
    File.open(target_filename, "w") do |f|
      UTS64Data.new(ucdata).each_entry { |l| f.puts l }
    end
  end

  def ucdata
    cache = ENV["CACHE_DIR"] || "tmp"
    cache = nil if ENV["NO_CACHE"]
    UnicodeData.new(ENV.fetch("VERSION", RbConfig::CONFIG["UNICODE_VERSION"]), cache)
  end
end
