# encoding: ASCII-8BIT

require_relative 'spec_helper'

describe 'base58_check' do
  cases = {
    # Source: https://en.bitcoin.it/wiki/Technical_background_of_Bitcoin_addresses
    [0, "\x01\x09\x66\x77\x60\x06\x95\x3D\x55\x67\x43\x9E\x5E\x39\xF8\x6A\x0D\x27\x3B\xEE"] =>
      '16UwLL9Risc3QfPqBUvKofHmBQ7wMtjvM',
    [0, ''] =>  '1Wh4bh',
    [255, ''] => 'VrZDWwe',
  }

  describe 'base58_check_encode' do
    cases.each do |data, base58|
      it "converts #{data.inspect} to #{base58}" do
        expect(base58_check_encode(*data)).to eq base58
      end
    end
  end

  describe 'base58_check_decode' do
    cases.each do |data, base58|
      it "converts #{base58} to #{data.inspect}" do
        expect(base58_check_decode(base58)).to eq data
      end
    end

    it 'raises an error if you give it invalid characters' do
      expect { base58_check_decode('-') }.to raise_error DBTC::DecodeError,
        'Character is not valid in base 58: "-".'
    end

    it 'raises an error if the checksum is wrong' do
      expect { base58_check_decode('16UwLL9Risc3QfPqBUvKofHmBQ7wMtjzz') }.to raise_error(
        DBTC::DecodeError, 'Invalid checksum.')
    end

    it 'raises an error if there is not enough data' do
      expect { base58_check_decode('12') }.to raise_error(DBTC::DecodeError,
        'Decoded string not long enough: expected at least 5 bytes, got 2.')
    end
  end

  describe '4-byte version support' do
    it 'round-trips correctly' do
      # https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki
      encoded1 = 'xpub661MyMwAqRbcFtXgS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8'
      decoded = base58_check_decode(encoded1)
      expect(decoded[0]).to eq 0x0488B21E
      encoded2 = base58_check_encode(*decoded)
      expect(encoded1).to eq encoded2
    end
  end
end
