# encoding: ASCII-8BIT
require 'spec_helper'

describe BitcoinAddressUtils::Address do
  cases = {
    # Source: https://en.bitcoin.it/wiki/Technical_background_of_Bitcoin_addresses
    0x18E14A7B6A307F426A94F8114701E7C8E774E7F9A47E2C2035DB29A206321725 =>
      '16UwLL9Risc3QfPqBUvKofHmBQ7wMtjvM',
  }

  describe 'encode' do    
    cases.each do |data, base58|
      it "converts #{data.inspect} to #{base58}" do
        expect(described_class.encode(*data)).to eq base58
      end
    end
  end

end