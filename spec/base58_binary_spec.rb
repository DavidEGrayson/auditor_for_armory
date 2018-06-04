# encoding: ASCII-8BIT

require_relative 'spec_helper'

describe 'base58 binary' do
  cases = {
    "\x03" => '4',
    "\x00\x08" => '19',
    "\x0D\x24" => '211',
    "\x00\x00\x00\x0D\x24" => '111211',
  }

  describe 'encode' do
    cases.each do |binary, base58|
      it "converts #{binary.inspect} to #{base58}" do
        expect(base58_encode(binary)).to eq base58
      end
    end
  end

  describe 'decode' do
    cases.each do |binary, base58|
      it "converts #{base58} to #{binary.inspect}" do
        expect(base58_decode(base58)).to eq binary
      end
    end

    it 'raises an error if you give it invalid characters' do
      expect { base58_decode('-') }.to raise_error DBTC::DecodeError,
        'Character is not valid in base 58: "-".'
    end
  end
end
