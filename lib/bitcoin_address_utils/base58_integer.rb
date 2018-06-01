require_relative 'decode_error'

module BitcoinAddressUtils
  # This module provides methods for converting between unsigned integers
  # and base 58 strings.
  module Base58Integer
    Chars = '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz'.split('')

    def self.encode(integer)
      raise ArgumentError, 'Integer to encode is negative.' if integer < 0

      string = ''
      while integer > 0
        integer, remainder = integer.divmod 58
        string << Chars[remainder]
      end
      string.reverse
    end

    def self.decode(string)
      string = string.dup.force_encoding('BINARY')
      string.each_char.reduce(0) do |result, char|
        value = Chars.index(char)
        if !value
          raise DecodeError,
            "Character is not valid in base 58: #{char.inspect}."
        end
        result * 58 + value
      end
    end

  end
end
