# encoding: ASCII-8BIT
require 'spec_helper'

describe BitcoinAddressUtils::Address do

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

    it 'can take an ECDSA integer octet string' do
      string = ECDSA::Format::PointOctetString.encode(public_key, compression: false)
      expect(described_class.from_public_key(string)).to eq address
    end
  end

  describe '.from_hash160' do
    it 'works' do
      hash160 = "\xf9\x30\xb2\x46\x74\xa3\x29\x44\x89\x71\x39\x8b\x9e\x2d\xfc\x6d\x9d\x04\xf1\xa6"
      expect(described_class.from_hash160(hash160)).to eq '1PibbFWLLrVfjKYLxn5f1sREDsuF55N2Aw'
    end
  end

  describe '.from_hash160_hex' do
    it 'works' do
      hash160_hex = 'f930b24674a329448971398b9e2dfc6d9d04f1a6'
      expect(described_class.from_hash160_hex(hash160_hex)).to eq '1PibbFWLLrVfjKYLxn5f1sREDsuF55N2Aw'
    end
  end

end