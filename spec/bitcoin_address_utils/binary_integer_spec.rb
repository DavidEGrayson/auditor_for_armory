# encoding: ASCII-8BIT
require 'spec_helper'

describe BitcoinAddressUtils::BinaryInteger do
  describe 'encode' do
    cases = {
      0 => '',
      0xABCDEF123441 => "\xAB\xCD\xEF\x12\x34\x41",
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
      "\x00\x00\xFF" => 0xFF,
      "\xAB\xCD\xEF\x12\x34\x41" => 0xABCDEF123441,
    }
    
    cases.each do |string, integer|
      it "converts #{string.inspect} properly" do
        expect(described_class.decode(string)).to eq integer
      end
    end  
  end
end