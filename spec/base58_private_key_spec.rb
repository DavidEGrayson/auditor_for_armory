# encoding: ASCII-8BIT

require_relative 'spec_helper'

# The test cases here came from Blowfeld on bitcointalk.org:
#   https://bitcointalk.org/index.php?topic=129652.msg1697154#msg1697154

describe 'private_key' do
  let(:private_key) do
    0x508A33B81EAEB4B8563D4D330CEE86A6F00E4EE48B3E3088B9C8499F97E773A7
  end

  let(:base58_private_key_compressed) do
    'KyvGbxRUoofdw3TNydWn2Z78dBHSy2odn1d3wXWN2o3SAtccFNJL'
  end

  let(:base58_private_key_uncompressed) do
    '5JRks4Vf268r9cuCKiod2iFz1VcSpawX5m6T3PKSA1v7cRqfZZD'
  end

  describe 'encode' do
    it 'works with compression turned on' do
      expect(private_key_encode(private_key, true)).to eq base58_private_key_compressed
    end

    it 'works with compression turned off' do
      expect(private_key_encode(private_key, false)).to eq base58_private_key_uncompressed
    end
  end

  describe 'decode' do
    it 'can decode a private key with compression metadata' do
      private_key, compressed = private_key_decode base58_private_key_compressed
      expect(private_key).to eq private_key
      expect(compressed).to eq true
    end

    it 'can decode a private key without metadata' do
      private_key, compressed = private_key_decode base58_private_key_uncompressed
      expect(private_key).to eq private_key
      expect(compressed).to eq false
    end

    it 'complains if the metadata is not recognized' do
      data = ("\x22" * 32) + "\x44\x55"
      b58c = base58_check_encode(0x80, data)
      expect { private_key_decode(b58c) }.to raise_error(
        DBTC::DecodeError, "Private key metadata unrecognized.")
    end

    it 'complains if the version is wrong' do
      data = ("\x22" * 32) + "\x44\x55"
      b58c = base58_check_encode(0x83, data)
      expect { private_key_decode(b58c) }.to raise_error(
        DBTC::DecodeError, "Private key has wrong version byte.")
    end

    it 'complains if the decoded string does not have enough data' do
      b58c = base58_check_encode(0x80, "hi")
      expect { private_key_decode(b58c) }.to raise_error(
        DBTC::DecodeError, 'Private key has wrong size.')
    end
  end
end
