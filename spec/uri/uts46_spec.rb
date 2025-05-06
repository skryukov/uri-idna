# frozen_string_literal: true

RSpec.describe "UTS46" do
  describe "IdnaTestV2.txt" do
    tests = []
    File.open(File.join(File.dirname(__FILE__), "..", "data", "IdnaTestV2.txt"), "r") do |f|
      f.each_line do |line|
        next if /^#/.match?(line)
        next if /^$/.match?(line)

        tests << line.split(/\s*;\s*/)
      end
    end

    tests.each do |test|
      test = test.map do |t|
        t.gsub(/\\u?\{?([\da-fA-F]{4})}?/) do
          [Regexp.last_match(1)].pack("H*").unpack("n*").pack("U*")
        end
      end
      source = test[0]
      to_unicode = test[1].empty? ? source : test[1]
      to_unicode_status = test[2].empty? ? [] : test[2].scan(/\w+/)
      to_ascii_n = test[3].empty? ? to_unicode : test[3]
      to_ascii_n_status = test[4].empty? ? to_unicode_status : test[4].scan(/\w+/)
      to_ascii_t = test[5].empty? ? to_ascii_n : test[5]
      to_ascii_t_status = test[6].split("#").first.strip
      to_ascii_t_status = to_ascii_t_status.empty? ? to_ascii_n_status : to_ascii_t_status.scan(/\w+/)

      # Ignore X4_2 status for to_unicode
      # UTS46 does not provide instructions for a default behavior of to_unicode in regard to length checks
      to_unicode_status -= ["X4_2"]

      describe source do
        if to_unicode_status.empty?
          it "decodes to #{to_unicode}" do
            expect(URI::IDNA.to_unicode(source)).to eq(to_unicode)
          end
        else
          it "raises an error while decoding: #{to_unicode_status}" do
            expect { URI::IDNA.to_unicode(source) }.to raise_error(URI::IDNA::Error)
          end
        end

        if to_ascii_n_status.empty?
          it "encodes to #{to_ascii_n}" do
            expect(URI::IDNA.to_ascii(source)).to eq(to_ascii_n)
          end
        else
          it "raises an error while encoding: #{to_ascii_n_status}" do
            expect { URI::IDNA.to_ascii(source) }.to raise_error(URI::IDNA::Error)
          end

          if (to_ascii_n_status - %w[A4_1 A4_2]).empty?
            it "doesn't raise with verify_dns_length: false" do
              expect(URI::IDNA.to_ascii(source, verify_dns_length: false)).to be_a(String)
            end
          end

          if (to_ascii_n_status - %w[V2 V3]).empty?
            it "doesn't raise with check_hyphens: false" do
              expect(URI::IDNA.to_ascii(source, check_hyphens: false)).to be_a(String)
            end
          end

          if (to_ascii_n_status - %w[C1 C2]).empty?
            it "doesn't raise with check_joiners: false" do
              expect(URI::IDNA.to_ascii(source, check_joiners: false)).to be_a(String)
            end
          end

          if (to_ascii_n_status - %w[B1 B2 B3 B4 B5 B6]).empty?
            it "doesn't raise with check_bidi: false" do
              expect(URI::IDNA.to_ascii(source, check_bidi: false)).to be_a(String)
            end
          end
        end

        if to_ascii_t_status.empty?
          it "encodes transitionally to #{to_ascii_t}" do
            expect(URI::IDNA.to_ascii(source, transitional_processing: true)).to eq(to_ascii_t)
          end
        else
          it "raises an error while encoding transitionally: #{to_ascii_t_status}" do
            expect { URI::IDNA.to_ascii(source, transitional_processing: true) }.to raise_error(URI::IDNA::Error)
          end
        end
      end
    end
  end
end
