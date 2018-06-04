# encoding: ASCII-8BIT

require_relative 'spec_helper'

describe 'base58 integer' do
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
        expect(base58_int_encode(integer)).to eq string
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
        expect(base58_int_decode(string)).to eq integer
      end
    end

    it 'raises an error if you give it invalid characters' do
      expect { base58_int_decode('-') }.to raise_error DBTC::DecodeError,
        'Character is not valid in base 58: "-".'
    end
  end
end
