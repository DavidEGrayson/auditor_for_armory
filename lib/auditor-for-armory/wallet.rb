# coding: ASCII-8BIT

require_relative 'sixteen_easy_bytes'
require_relative 'bitcoin-address-utils'
require 'digest'
require 'openssl'

module AuditorForArmory
  class Wallet
    def self.from_paper_backup(string)
      lines = string.strip.split("\n")
      if lines.size != 2
        raise ArgumentError, "Expected 2 lines, got #{lines.size}."
      end
      
      byte_lines = lines.map do |line|
        SixteenEasyBytes.decode line
      end
      
      private_key = ECDSA::Format::IntegerOctetString.decode byte_lines[0, 2].join 
      
      #puts
      #puts byte_lines[0].hex_inspect
      #puts byte_lines[1].hex_inspect
    end

    # Mimics DeriveChaincodeFromRootKey in Armory source.
    def self.chain_code_from_root_key(root_key)
      hmac256 hash256(sbdPrivKey), 'Derive Chaincode from Root Key'
    end
    
    def self.hash256(string)
      Digest::SHA256.digest Digest::SHA256.digest string
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