# encoding: ASCII-8BIT
require 'spec_helper'

describe BitcoinAddressUtils::Base58Check do
  cases = {
    # Source: https://en.bitcoin.it/wiki/Technical_background_of_Bitcoin_addresses
    [0, "\x01\x09\x66\x77\x60\x06\x95\x3D\x55\x67\x43\x9E\x5E\x39\xF8\x6A\x0D\x27\x3B\xEE\xD6\x19\x67\xF6"] =>
      '16UwLL9Risc3QfPqBUvKofHmBQ7wMtjvM',
  }

  describe 'encode' do    
    cases.each do |data, base58|
      it "converts #{data.inspect} to #{base58}" do
        expect(described_class.encode(*data)).to eq base58
      end
    end
  end
  
  describe 'decode' do
    cases.each do |data, base58|
      it "converts #{base58} to #{data.inspect}" do
        expect(described_class.decode(base58)).to eq data
      end
    end
    
    it 'raises an error if you give it invalid characters' do
      expect { described_class.decode('-') }.to raise_error BitcoinAddressUtils::DecodeError,
        'Character is not valid in base 58: "-".'
    end
  end
end