# coding: ASCII-8BIT

module BitcoinAddressUtils
  # The difference between "compressed" and "uncompressed" private keys is
  # explained well here:  https://bitcointalk.org/index.php?topic=129652.msg1384929#msg1384929
  #
  # This is also known as Wallet Import Format (WIF), but modern wallets
  # are not just lists of private keys, so we don't use that name.
  module Base58PrivateKey
    Version = 0x80

    def self.encode(private_key, metadata = {})
      data = ECDSA::Format::IntegerOctetString.encode(private_key, 32) +
             encode_metadata(metadata)
      Base58Check.encode Version, data
    end

    def self.decode_with_metadata(string)
      read_version, data = Base58Check.decode string
      if read_version != Version
        raise DecodeError, "Expected version byte of public key to be %#x, got %#x." % [Version, read_version]
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

    def self.decode(string)
      decode_with_metadata(string).first
    end

    def self.convert_to_public_key_binary(string)
      private_key, metadata = decode_with_metadata(string)
      public_key = BitcoinAddressUtils.ecdsa_group.new_point private_key
      ECDSA::Format::PointOctetString.encode public_key, compression: metadata[:compression]
    end

    private
    def self.decode_metadata(string)
      metadata = case string
        when "\x01" then { compression: true }
        when "" then { compression: false }
        else raise DecodeError, "Unrecognized metadata in private key: #{string.unpack('H*').first}."
        end
    end

    def self.encode_metadata(metadata)
      allowed_keys = [:compression]
      bad_keys = metadata.keys - allowed_keys
      if !bad_keys.empty?
        raise ArgumentError, "Unrecognized keys in metadata: #{bad_keys.inspect}."
      end

      if metadata[:compression]
        "\x01"
      else
        ''
      end
    end
  end
end

