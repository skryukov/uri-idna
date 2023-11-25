# frozen_string_literal: true

module URI
  module IDNA
    # Punycode implementation based on a simplified version of RFC 3492
    # https://datatracker.ietf.org/doc/html/rfc3492#appendix-C
    module Punycode
      class << self
        BASE = 36
        TMIN = 1
        TMAX = 26
        SKEW = 38
        DAMP = 700
        INITIAL_BIAS = 72
        INITIAL_N = 0x80
        ADAPT_THRESHOLD = ((BASE - TMIN) * TMAX) / 2

        DELIMITER = 0x2D
        MAXINT = 0x7FFFFFFF

        def decode_digit(cp)
          if cp - 48 < 10
            cp - 22
          elsif cp - 65 < 26
            cp - 65
          elsif cp - 97 < 26
            cp - 97
          else
            BASE
          end
        end

        def encode_digit(d)
          return d + 22 if d >= 26

          d + 97
        end

        def adapt(delta, num_points, first_time)
          delta = first_time ? (delta / DAMP) : (delta >> 1)
          delta += (delta / num_points)

          k = 0
          while delta > ADAPT_THRESHOLD
            delta /= BASE - TMIN
            k += BASE
          end
          k + ((BASE - TMIN + 1) * delta / (delta + SKEW))
        end

        def encode(input)
          input = input.codepoints

          n = INITIAL_N
          delta = 0
          bias = INITIAL_BIAS

          output = input.select { |cp| cp < 0x80 }
          h = b = output.length

          output << DELIMITER if b > 0
          input_length = input.length
          while h < input_length
            m = MAXINT
            input.each do |cp|
              m = cp if cp >= n && cp < m
            end

            raise PunycodeError, "Arithmetic overflow" if m - n > (MAXINT - delta) / (h + 1)

            delta += (m - n) * (h + 1)
            n = m

            input.each do |cp|
              if cp < n
                delta += 1
                raise PunycodeError, "Arithmetic overflow" if delta > MAXINT
              end
              next unless cp == n

              q = delta
              k = BASE
              loop do
                t =
                  if k <= bias
                    TMIN
                  elsif k >= bias + TMAX
                    TMAX
                  else
                    k - bias
                  end
                break if q < t

                output << encode_digit(t + ((q - t) % (BASE - t)))
                q = (q - t) / (BASE - t)
                k += BASE
              end

              output << encode_digit(q)
              bias = adapt(delta, h + 1, h == b)
              delta = 0
              h += 1
            end

            delta += 1
            n += 1
          end
          output.pack("U*")
        end

        def decode(input)
          input = input.codepoints
          output = []

          n = INITIAL_N
          i = 0
          bias = INITIAL_BIAS

          b = input.rindex(DELIMITER) || 0

          input[0, b].each do |cp|
            raise PunycodeError, "Invalid input" unless cp < 0x80

            output << cp
          end

          inc = b > 0 ? b + 1 : 0
          input_length = input.length
          while inc < input_length
            old_i = i
            w = 1
            k = BASE
            loop do
              raise PunycodeError, "Invalid input" if inc >= input.length

              digit = decode_digit(input[inc])
              inc += 1
              raise PunycodeError, "Invalid input" if digit >= BASE
              raise PunycodeError, "Arithmetic overflow" if digit > (MAXINT - i) / w

              i += digit * w
              t = if k <= bias
                    TMIN
                  elsif k >= bias + TMAX
                    TMAX
                  else
                    k - bias
                  end
              break if digit < t
              raise PunycodeError, "Arithmetic overflow" if w > MAXINT / (BASE - t)

              w *= BASE - t
              k += BASE
            end
            out = output.length
            bias = adapt(i - old_i, out + 1, old_i == 0)
            raise PunycodeError, "Arithmetic overflow" if (i / (out + 1)) > MAXINT - n

            n += i / (out + 1)
            i %= (out + 1)

            output.insert(i, n)

            i += 1
          end

          output.pack("U*")
        end
      end
    end
  end
end
