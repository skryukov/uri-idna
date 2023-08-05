# frozen_string_literal: true

module URI
  module IDNA
    module Intranges
      class << self
        def from_list(list)
          sorted_list = list.sort
          ranges = []
          last_write = -1
          sorted_list.each_with_index do |value, i|
            next if value + 1 == sorted_list[i + 1]

            ranges << encode_range(sorted_list[last_write + 1], sorted_list[i] + 1)
            last_write = i
          end
          ranges
        end

        def contain?(int, ranges)
          tuple = encode_range(int, 0)
          pos = ranges.bsearch_index { |x| x > tuple } || ranges.length
          # we could be immediately ahead of a tuple (start, end)
          # with start < int_ <= end
          if pos > 0
            left, right = decode_range(ranges[pos - 1])
            return true if left <= int && int < right
          end
          # or we could be immediately behind a tuple (int_, end)
          if pos < ranges.length
            left, = decode_range(ranges[pos])
            return true if left == int
          end
          false
        end

        private

        def encode_range(start, finish)
          (start << 32) | finish
        end

        def decode_range(r)
          [(r >> 32), (r & ((1 << 32) - 1))]
        end
      end
    end
  end
end
