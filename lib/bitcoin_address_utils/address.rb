# encoding: US-ASCII

require 'digest'

module BitcoinAddressUtils
  # This module provides a method for creating Bitcoin addresses.
  #
  # Some wallets like Multibit incorrectly use ECDSA point compression
  # when generating addresses.
  # 
  # https://en.bitcoin.it/wiki/Technical_background_of_Bitcoin_addresses
  module Address
    def self.encode(input, opts={})
      case input
      when Integer       # Private key
        public_key = BitcoinAddressUtils.ecdsa_group.new_point input
        encode public_key, opts
      when ECDSA::Point  # Public key
        string = ECDSA::Format::PointOctetString.encode(input, compression: opts.fetch(:compression, false))
        encode string, opts
      when String        # Binary-encoded public key
        hash = Digest::RMD160.digest Digest::SHA256.digest input
        BitcoinAddressUtils::Base58Check.encode 0, hash
      else
        raise ArgumentError, "Invalid input for creating a Bitcoin address."
      end
    end
  end
  
end
