# coding: ASCII-8BIT

# The difference between "compressed" and "uncompressed" private keys is
# explained well here:  https://bitcointalk.org/index.php?topic=129652.msg1384929#msg1384929

# TODO: fix all calls to String#hex_inspect here and elsewhere, perhaps replacing with Hex.decode and Hex.encode.

module BitcoinAddressUtils
  module Base58PrivateKey
    def self.decode_with_metadata(string)
      version, data = Base58Check.decode string
      if version != 0x80
        raise DecodeError, "Expected version byte of public key to be 0x80, got %#x." % version
      end
      if data.size < 32
        raise DecodeError, "Expected at least 32 bytes of data in private key, got "
      end
      
      # The first 32 bytes are the private key.
      private_key = ECDSA::Format::IntegerOctetString.decode data[0, 32]

      # The rest is metadata (whether to use compression in the public key).
      metadata_binary = data[32..-1]
      metadata = decode_metadata(metadata_binary)
      
      [private_key, metadata]
    end

    def self.convert_to_public_key_binary(string)
      private_key, metadata = decode_with_metadata(string)
      public_key = BitcoinAddressUtils.ecdsa_group.new_point private_key
      ECDSA::Format::PointOctetString.encode public_key, compression: metadata[:compression]
    end
    
    def self.decode(string)
      decode_with_metadata(string).first
    end

    private
    def self.decode_metadata(string)
      metadata = case string
             when "\x01" then { compression: true }
             when "" then { compression: false }
             else raise DecodeError, "Unrecognized metadata in private key: #{string.hex_inspect}."
             end
    end    
  end
end

