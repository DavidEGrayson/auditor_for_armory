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
    def self.from_base58_private_key(string, opts = {})
      private_key = Base58PrivateKey.decode(string)
      from_private_key private_key, opts
    end

    def self.from_private_key(input, opts = {})
      public_key = BitcoinAddressUtils.ecdsa_group.new_point input
      from_public_key public_key, opts
    end

    def self.from_public_key(public_key, opts = {})
      case public_key
      when ECDSA::Point
        string = ECDSA::Format::PointOctetString.encode(public_key, compression: opts.fetch(:compression, false))
      when String
        string = public_key
      else
        raise ArgumentError, "Invalid input for creating a Bitcoin address."
      end
      hash = Digest::RMD160.digest Digest::SHA256.digest string
      from_hash160 hash, opts
    end

    def self.from_hash160(hash160_binary, opts = {})
      version = opts.fetch(:version, 0)
      BitcoinAddressUtils::Base58Check.encode version, hash160_binary
    end

    def self.from_hash160_hex(hash160_hex, opts = {})
      from_hash160 [hash160_hex].pack('H*'), opts
    end
  end
end