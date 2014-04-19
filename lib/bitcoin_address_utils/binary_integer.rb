module BitcoinAddressUtils
  # This module provides methods for converting between unsigned integers and
  # big endian binary strings.
  #
  # This is very similar to ECDSA::Format::IntegerOctetString, but it does not
  # take a length parameter when encoding.
  module BinaryInteger
    # @param integer (Integer) The integer to encode.
    # @return (String)
    def self.encode(integer)
      raise ArgumentError, 'Integer to encode is negative.' if integer < 0

      string = ''.force_encoding('BINARY')
      while integer > 0
        integer, remainder = integer.divmod 256
        string << remainder.chr
      end
      string.reverse
    end

    # @param string (String)
    # @return (Integer)
    def self.decode(string)
      string.bytes.reduce(0) { |n, b| (n << 8) + b }
    end
  end
end