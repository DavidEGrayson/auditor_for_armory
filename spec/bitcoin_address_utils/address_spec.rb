# encoding: ASCII-8BIT
require 'spec_helper'

# TODO: everything that takes opts should complain about invalid keys

describe BitcoinAddressUtils::Address do

  describe '.from_base58_private_key' do
    it 'converts the private key from the wiki (compression off)' do
      # Source: https://en.bitcoin.it/wiki/Private_key#Base_58_Wallet_Import_format
      address = described_class.from_base58_private_key '5Kb8kLf9zgWQnogidDA76MzPL6TsZZY36hWXMssSzNydYXYB9KF'
      expect(address).to eq '1CC3X2gu58d6wXUWMffpuzN9JAfTUWu4Kj'
    end

    it 'converts the private key from the wiki (compression on)' do
      # Source: https://bitcointalk.org/index.php?topic=129652.msg1697154#msg1697154
      address = described_class.from_base58_private_key 'KyvGbxRUoofdw3TNydWn2Z78dBHSy2odn1d3wXWN2o3SAtccFNJL'
      expect(address).to eq '1JMsC6fCtYWkTjPPdDrYX3we2aBrewuEM3'
    end
  end

  describe '.from_private_key' do
    it 'converts the private key from the wiki' do
      # Source: https://en.bitcoin.it/wiki/Technical_background_of_Bitcoin_addresses
      private_key = 0x18E14A7B6A307F426A94F8114701E7C8E774E7F9A47E2C2035DB29A206321725
      address = described_class.from_private_key private_key
      expect(address).to eq '16UwLL9Risc3QfPqBUvKofHmBQ7wMtjvM'
    end
  end

  describe '.from_public_key' do
    let(:public_key) do
      BitcoinAddressUtils.ecdsa_group.new_point [
        0xfa887609c14d7a5e7bff26fe7cc24dd30e1ded52b6b6309bfa45d32d1d02ec65,
        0x9488e44d8ce59e4d2f274d5768d7a2f6ad9c185e911195b85e31aec5f08aa2d5,
      ]
    end

    let (:address) do
      '1PibbFWLLrVfjKYLxn5f1sREDsuF55N2Aw'
    end

    it 'can take an ECDSA::Point object' do
      expect(described_class.from_public_key(public_key)).to eq address
    end

    it 'has an ECDSA compression option' do
      # To support wallets that calculate addresses that way.
      alt_address = '1P3yG3ekBWYn7xQYVchE1y5UVZfSLADPZU'
      expect(described_class.from_public_key(public_key, compression: true)).to eq alt_address
    end

    it 'can take an ECDSA integer octet string' do
      string = ECDSA::Format::PointOctetString.encode(public_key, compression: false)
      expect(described_class.from_public_key(string)).to eq address
    end
  end

  describe '.from_hash160' do
    let(:hash160) { "\xf9\x30\xb2\x46\x74\xa3\x29\x44\x89\x71\x39\x8b\x9e\x2d\xfc\x6d\x9d\x04\xf1\xa6" }

    it 'works' do
      expect(described_class.from_hash160(hash160)).to eq '1PibbFWLLrVfjKYLxn5f1sREDsuF55N2Aw'
    end

    it 'takes a version argument' do
      # Dogecoin public key
      expect(described_class.from_hash160(hash160, version: 30)).to eq 'DTrh8WSyeGPxGKiwhN5DZdaq71dYTvekV3'
    end
    
    it 'rejects inputs that are not 160-bit' do
      # This is NOT a DecodeError; the hash160 will probably come from an
      # internal part of the program and converting it to an address makes it
      # go futher away from being a usage integer, so it's not really decoding.
      expect { described_class.from_hash160("\x00" * 19) }.to raise_error(
        ArgumentError, 'Expected 20 bytes in hash160, got 19.')
    end
  end

  describe '.from_hash160_hex' do
    it 'works' do
      hash160_hex = 'f930b24674a329448971398b9e2dfc6d9d04f1a6'
      expect(described_class.from_hash160_hex(hash160_hex)).to eq '1PibbFWLLrVfjKYLxn5f1sREDsuF55N2Aw'
    end
  end

end