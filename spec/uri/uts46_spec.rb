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
      to_unicode_status = test[2].empty? ? "[]" : test[2]
      to_ascii_n = test[3].empty? ? to_unicode : test[3]
      to_ascii_n_status = test[4].empty? ? to_unicode_status : test[4]
      to_ascii_t = test[5].empty? ? to_ascii_n : test[5]
      to_ascii_t_status = test[6].split("#").first.strip
      to_ascii_t_status = to_ascii_n_status if to_ascii_t_status.empty?

      describe source do
        if to_unicode_status == "[]"
          it "decodes to #{to_unicode}" do
            expect(URI::IDNA.to_unicode(source)).to eq(to_unicode)
          end
        else
          it "raises an error while decoding: #{to_unicode_status}" do
            expect { URI::IDNA.to_unicode(source) }.to raise_error(URI::IDNA::Error)
          end
        end

        if to_ascii_n_status == "[]"
          it "encodes to #{to_ascii_n}" do
            expect(URI::IDNA.to_ascii(source)).to eq(to_ascii_n)
          end
        else
          it "raises an error while encoding: #{to_ascii_n_status}" do
            expect { URI::IDNA.to_ascii(source) }.to raise_error(URI::IDNA::Error)
          end
        end

        if to_ascii_t_status == "[]"
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
