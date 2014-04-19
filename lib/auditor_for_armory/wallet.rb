# coding: ASCII-8BIT

require 'digest'
require 'bitcoin_address_utils'
require_relative 'sixteen_easy_bytes'

module AuditorForArmory
  class Wallet
    AddressStartByte = "\x00"  # address first byte for bitcoin main network

    attr_accessor :chain_code
    
    # @param root_key (Integer)
    # @param chain_code (Integer)
    def initialize(root_key, chain_code = self.class.chain_code_from_root_key(root_key))
      @chain_code = chain_code
      @private_keys = [root_key]
      @public_keys = []
    end

    # Mimics calcWalletIDFromRoot in Bitcoin Armory.
    def wallet_id
      data = (AddressStartByte + hash160(1)[0, 5]).reverse
      BitcoinAddressUtils::Base58Binary.encode data
    end

    def address(num)
      BitcoinAddressUtils::Address.from_public_key public_key(num)
    end

    def hash160(num)
      string = ECDSA::Format::PointOctetString.encode(public_key(num), compression: false)
      hash = BitcoinAddressUtils.hash160 string
    end

    def public_key(num)
      @public_keys[num] ||= BitcoinAddressUtils.ecdsa_group.new_point private_key(num)
    end

    def private_key(num)
      @private_keys[num] ||= extend_chain_for_private_key(num)
    end

    def extend_chain_for_private_key(num)
      self.class.extend_chain @private_keys[num - 1], @chain_code
    end

    def self.from_paper_backup(string)
      private_key_binary = decode_private_key_binary string
      private_key = ECDSA::Format::IntegerOctetString.decode private_key_binary
      new private_key
    end

    # Converts the data of a non-fragmented Armory paper backup to
    # the binary string representing the root private key.
    def self.decode_private_key_binary(string)
      lines = string.strip.split("\n")
      if lines.size != 2
        raise ArgumentError, "Expected 2 lines, got #{lines.size}."
      end

      byte_lines = lines.map do |line|
        SixteenEasyBytes.decode line
      end

      byte_lines.join
    end

    def self.extend_chain(private_key, chain_code)
      # extendAddressChain in armoryengine.py
      # calls ComputeChainedPrivateKey from in EncryptionUtils.cpp

      public_key = BitcoinAddressUtils.ecdsa_group.new_point private_key
      public_key_binary = ECDSA::Format::PointOctetString.encode(public_key, compression: false)
      public_key_hash = BitcoinAddressUtils.hash256 public_key_binary
      public_key_hash_num = ECDSA::Format::IntegerOctetString.decode public_key_hash

      (private_key * (chain_code ^ public_key_hash_num)) % BitcoinAddressUtils.ecdsa_group.order
    end

    # Mimics DeriveChaincodeFromRootKey in Armory source.
    def self.chain_code_from_root_key(root_key)
      root_key_binary = ECDSA::Format::IntegerOctetString.encode root_key, 32
      chain_code_binary = hmac256 BitcoinAddressUtils.hash256(root_key_binary), 'Derive Chaincode from Root Key'
      ECDSA::Format::IntegerOctetString.decode chain_code_binary
    end

    def self.hmac256(key, string)
      key = key.dup.force_encoding 'BINARY'
      string = string.dup.force_encoding 'BINARY'

      hash_size = 32
      if key.size > hash_size
        key = Digest::SHA256.digest key
      end
      key = key.ljust hash_size, "\x00".force_encoding('BINARY')
      okey = key.each_char.map { |c| (c.ord ^ 0x5C).chr 'BINARY' }.join
      ikey = key.each_char.map { |c| (c.ord ^ 0x36).chr 'BINARY' }.join
      Digest::SHA256.digest(okey + Digest::SHA256.digest(ikey + string))
    end

  end
end