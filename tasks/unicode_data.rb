# frozen_string_literal: true

require "open-uri"

class UnicodeData
  UCD_URL = "https://www.unicode.org/Public/%<version>s/ucd/%<filename>s"
  UTS46_URL = "https://www.unicode.org/Public/idna/%<version>s/%<filename>s"

  attr_reader :ucd_cf, :ucd_data, :ucd_props, :ucd_block, :ucd_hst, :ucd_as, :ucd_s, :ucd_idnamt, :version,
              :system_version

  def initialize(version, cache)
    @version = version
    @system_version = RbConfig::CONFIG["UNICODE_VERSION"]
    @cache = cache
    @max = 0

    load_unicode_data
    load_prop_list
    load_derived_core_props
    load_blocks
    load_case_folding
    load_hangul
    load_arabic_shaping
    load_scripts
    load_uts46_mapping
  end

  def codepoints
    (0..@max).each do |i|
      yield CodePoint.new(i, ucdata: self)
    end
  end

  private

  def load_unicode_data
    @ucd_data = {}
    range_begin = nil
    ucdfile("UnicodeData.txt").each do |(cp, _), fields|
      start_marker = /\A<(?<name>.*?), First>\z/.match(fields[0])
      end_marker = /\A<(?<name>.*?), Last>\z/.match(fields[0])

      if start_marker
        range_begin = cp
      elsif end_marker
        (range_begin..cp).each do |i|
          fields[0] = "<#{end_marker['name']}>"
          @ucd_data[i] = fields[0..]
        end
        range_begin = nil
      else
        @ucd_data[cp] = fields[0..]
      end
    end
  end

  def load_prop_list
    @ucd_props = {}
    ucdfile("PropList.txt").each do |cp, fields|
      cp.each do |i|
        @ucd_props[i] ||= []
        @ucd_props[i] += fields
      end
    end
  end

  def load_derived_core_props
    ucdfile("DerivedCoreProperties.txt").each do |cp, fields|
      cp.each do |i|
        @ucd_props[i] ||= []
        @ucd_props[i] += fields
      end
    end
  end

  def load_blocks
    @ucd_block = {}
    ucdfile("Blocks.txt").each do |cp, fields|
      cp.each do |i|
        @ucd_block[i] = fields[0]
        @max = [@max, i].max
      end
    end
  end

  def load_case_folding
    @ucd_cf = {}
    ucdfile("CaseFolding.txt").each do |cp, fields|
      cp.each do |i|
        @ucd_cf[i] = fields[1].split(" ").map { |x| x.to_i(16) } if %w[C F].include?(fields[0])
      end
    end
  end

  def load_hangul
    @ucd_hst = {}
    ucdfile("HangulSyllableType.txt").each do |cp, fields|
      cp.each do |i|
        @ucd_hst[i] = fields[0]
      end
    end
  end

  def load_arabic_shaping
    @ucd_as = {}
    ucdfile("ArabicShaping.txt").each do |cp, fields|
      cp.each do |i|
        @ucd_as[i] = fields[1]
      end
    end
  end

  def load_scripts
    @ucd_s = {}
    ucdfile("Scripts.txt").each do |cp, fields|
      @ucd_s[fields[0]] ||= []
      cp.each do |i|
        @ucd_s[fields[0]] << i
      end
    end
  end

  def load_uts46_mapping
    @ucd_idnamt = {}
    ucdfile("IdnaMappingTable.txt", url_base: UTS46_URL).each do |cp, fields|
      cp.each do |i|
        @ucd_idnamt[i] = fields
      end
    end
  end

  def ucdfile(filename, url_base: UCD_URL)
    cache_file = nil
    if @cache
      cache_file = File.expand_path(File.join(@cache, @version, filename), File.join(__dir__, ".."))
      return read_data_file(File.open(cache_file)) if File.file?(cache_file)
    end
    version_path = version_path == "latest" ? "UCD/#{@version}" : @version
    url = url_base % ({ version: version_path, filename: filename })
    io = URI.parse(url).open
    if cache_file
      FileUtils.mkdir_p(File.dirname(cache_file))
      File.write(cache_file, io.read)
    end
    read_data_file(io)
  end

  def inspect
    "UnicodeData(#{@version})"
  end

  def read_data_file(io)
    {}.tap do |result|
      each_line(io) do |line|
        codepoint, *fields = line.split(/\s*;\s*/, -1)
        codepoint =
          if codepoint.include?("..")
            left, right = codepoint.split("..").map { |value| value.to_i(16) }
            left..right
          else
            [codepoint.to_i(16)]
          end
        result[codepoint] ||= []
        result[codepoint] += fields
      end
    end
  end

  def each_line(io)
    io.each_line do |line|
      line.tap(&:chomp!).gsub!(/\s*#.*$/, "")
      yield line unless line.empty?
    end
  end
end
