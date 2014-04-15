# coding: ASCII-8BIT

require_relative 'spec_helper'

describe AuditorForArmory::SixteenEasyBytes do
  describe '.decode_easy' do
    subject do
      AuditorForArmory::SixteenEasyBytes.method(:decode_easy)
    end
  
    it 'works' do
      expect(subject.call('asdf')).to eq "\x01\x23"
    end
  end
  
  describe '.decode' do
    subject do
      AuditorForArmory::SixteenEasyBytes.method(:decode)
    end
    
    it 'works' do
      # This test case comes from:
      # https://bitcointalk.org/index.php?topic=510346.msg5684238#msg5684238
      easy = 'fntf euji uofg kkhf  ewfe keft uawj garh  twsu'
      expect(subject.call(easy)).to eq "\x3F\xB3\x9C\x6D\xCE\x34\x77\x53\x98\x39\x79\x3B\xC0\x86\x40\xA5"
    end
  end
end