# encoding: ASCII-8BIT
require 'spec_helper'

# The test cases here came from Blowfeld on bitcointalk.org:
#   https://bitcointalk.org/index.php?topic=129652.msg1697154#msg1697154

describe BitcoinAddressUtils::Base58PrivateKey do
  let(:private_key) do
    0x508A33B81EAEB4B8563D4D330CEE86A6F00E4EE48B3E3088B9C8499F97E773A7
  end

  let(:base58_private_key_compressed) do
    'KyvGbxRUoofdw3TNydWn2Z78dBHSy2odn1d3wXWN2o3SAtccFNJL'
  end
  
  let(:base58_private_key_uncompressed) do
    '5JRks4Vf268r9cuCKiod2iFz1VcSpawX5m6T3PKSA1v7cRqfZZD'
  end

  describe '.encode' do
    it 'works with compression turned on' do
      expect(described_class.encode(private_key, compression: true)).to eq base58_private_key_compressed
    end
    
    it 'works with compression turned off (default)' do
      expect(described_class.encode(private_key)).to eq base58_private_key_uncompressed
    end
    
    it 'complains about bad keys in metadata' do
      expect { described_class.encode(private_key, { 7 => 2, compression: true }) }.to raise_error(
        ArgumentError, "Unrecognized keys in metadata: [7]."
      )
    end
  end
  
  describe '.decode_with_metadata' do
    it 'can decode a private key with compression metadata' do
      private_key, metadata = described_class.decode_with_metadata base58_private_key_compressed
      expect(private_key).to eq private_key
      expect(metadata).to eq compression: true
    end
    
    it 'can decode a private key without metadata' do
      private_key, metadata = described_class.decode_with_metadata base58_private_key_uncompressed
      expect(private_key).to eq private_key
      expect(metadata).to eq compression: false
    end
    
    it 'complains if the metadata is not recognized' do
      data = ("\x22" * 32) + "\x44\x55"
      b58c = BitcoinAddressUtils::Base58Check.encode(0x80, data)
      expect { described_class.decode_with_metadata b58c }.to raise_error(
        BitcoinAddressUtils::DecodeError, "Unrecognized metadata in private key: 4455."
      )
    end
    
    it 'complains if the version is wrong' do
      data = ("\x22" * 32) + "\x44\x55"
      b58c = BitcoinAddressUtils::Base58Check.encode(0x83, data)
      expect { described_class.decode_with_metadata b58c }.to raise_error(
        BitcoinAddressUtils::DecodeError, "Expected version byte of private key to be 0x80, got 0x83.")
    end
    
    it 'complains if hte decoded string does not have enough data' do
      b58c = BitcoinAddressUtils::Base58Check.encode(0x80, "hi")
      expect { described_class.decode(b58c) }.to raise_error(
        BitcoinAddressUtils::DecodeError,
        'Decoded private key string not long enough: expected at least 32 bytes, got 2.'
      )
    end
  end
  
  describe '.decode' do
    it 'just returns the private key (throws away metadata)' do
      private_key = described_class.decode base58_private_key_uncompressed
      expect(private_key).to eq private_key
    end
  end
  
  describe '.convert_to_public_key_binary' do
    it 'works with compressed addresses' do
      public_key_binary = described_class.convert_to_public_key_binary(base58_private_key_compressed)
      expect(public_key_binary).to eq "\x03" \
        "\x57\xed\x2d\x63\xb7\x1e\x94\x4b\x9f\x0b\x2b\xf7\x49\x11\xea\xdb" \
        "\x35\xdc\xd9\x60\xae\xd1\xa7\x0d\x6a\x0b\x28\x63\xb8\x1d\xbd\x9d"
    end
    
    it 'works with uncompressed addresses' do
      public_key_binary = described_class.convert_to_public_key_binary(base58_private_key_uncompressed)
      expect(public_key_binary).to eq "\x04" \
        "\x57\xed\x2d\x63\xb7\x1e\x94\x4b\x9f\x0b\x2b\xf7\x49\x11\xea\xdb" \
        "\x35\xdc\xd9\x60\xae\xd1\xa7\x0d\x6a\x0b\x28\x63\xb8\x1d\xbd\x9d" \
        "\x99\xd8\x91\x16\xf9\x5d\xbd\xbf\xf5\x7f\xb0\x45\x26\x74\xf0\x27" \
        "\xc7\xae\x07\x01\x52\x7d\x80\xc2\x26\xea\x3a\x4c\x3c\x30\x40\x21"
    end
  end
  
end