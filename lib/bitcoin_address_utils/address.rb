# encoding: US-ASCII

require 'digest'

module BitcoinAddressUtils
  # This module provides a method for creating Bitcoin addresses.
  #
  # https://en.bitcoin.it/wiki/Technical_background_of_Bitcoin_addresses
  module Address
    def self.from_base58_private_key(string, opts = {})
      public_key_binary = Base58PrivateKey.convert_to_public_key_binary(string)
      from_public_key public_key_binary, opts
    end

    def self.from_private_key(input, opts = {})
      public_key = BitcoinAddressUtils.ecdsa_group.new_point input
      from_public_key public_key, opts
    end

    def self.from_public_key(public_key, opts = {})
      validate_options opts

      case public_key
      when ECDSA::Point
        string = ECDSA::Format::PointOctetString.encode(public_key,
          compression: opts[:compression])
      when String
        string = public_key
      else
        raise ArgumentError, "Invalid public key: #{public_key.inspect}."
      end
      hash = Digest::RMD160.digest Digest::SHA256.digest string
      from_hash160 hash, opts
    end

    def self.from_hash160(hash160_binary, opts = {})
      validate_options opts

      hash160_binary = hash160_binary.dup.force_encoding('BINARY')
      if hash160_binary.size != 20
        raise ArgumentError, "Expected 20 bytes in hash160, " \
          "got #{hash160_binary.size}."
      end

      version = opts.fetch(:version, 0)
      BitcoinAddressUtils::Base58Check.encode version, hash160_binary
    end

    def self.from_hash160_hex(hash160_hex, opts = {})
      from_hash160 [hash160_hex].pack('H*'), opts
    end

    private
    AllowedOptions = [:compression, :version]
    def self.validate_options(opts)
      bad_keys = opts.keys - AllowedOptions
      if !bad_keys.empty?
        raise ArgumentError, "Unrecognized options: #{bad_keys.inspect}."
      end
    end
  end
end
