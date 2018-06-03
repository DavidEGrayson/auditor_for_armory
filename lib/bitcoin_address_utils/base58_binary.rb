# coding: ASCII-8BIT

require_relative 'base58_integer'

module BitcoinAddressUtils
  # This module provides methods for converting between arbitrary binary
  # strings and base 58 strings.
  module Base58Binary
    def self.encode(string)
      string = string.dup.force_encoding('BINARY') # TODO: remove
      leading_zeros_count = string.match(/\A(\0*)/)[1].size
      number = DBTC.int_decode string
      '1' * leading_zeros_count + Base58Integer.encode(number)
    end

    def self.decode(string)
      string = string.dup.force_encoding('BINARY') # TODO: remove
      leading_ones_count = string.match(/\A(1*)/)[1].size
      number = Base58Integer.decode(string)
      "\x00" * leading_ones_count + DBTC.int_encode(number)
    end
  end
end
