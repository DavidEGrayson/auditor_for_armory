# encoding: ASCII-8BIT
require 'spec_helper'

describe BitcoinAddressUtils::Base58Integer do
  describe 'encode' do
    cases = {
      0 => '',
      1 => '2',
      58 => '21',
      0x3e09ee41b38b9d3f47968edec9c5b17dee6be6fbc8969421c3546bb58587d6530ae215fee59aabed6762 =>
        '23456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz1',
    }

    cases.each do |integer, string|
      it "converts %#x properly" % integer do
        expect(described_class.encode(integer)).to eq string
      end
    end
  end

  describe 'decode' do
    cases = {
      '' => 0,
      '2' => 1,
      '11z' => 57,
      '23456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz1' =>
        0x3e09ee41b38b9d3f47968edec9c5b17dee6be6fbc8969421c3546bb58587d6530ae215fee59aabed6762,
    }

    cases.each do |string, integer|
      it "converts #{string.inspect} properly" do
        expect(described_class.decode(string)).to eq integer
      end
    end

    it 'raises an error if you give it invalid characters' do
      expect { described_class.decode('-') }.to raise_error DecodeError,
        'Character is not valid in base 58: "-".'
    end
  end

  describe 'Chars' do
    it 'are sorted' do
      # This could be very useful in some cases.  For example, if you have a sorted list of
      # addresses and you want to look for all addresses in a certain range of hash160 values.
      expect(described_class::Chars).to eq described_class::Chars.sort
    end
  end
end
