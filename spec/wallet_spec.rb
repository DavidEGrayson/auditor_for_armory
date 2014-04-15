require_relative 'spec_helper'

describe AuditorForArmory::Wallet do
  context 'when created from a paper backup' do
    subject do
      described_class.from_paper_backup <<END
hijd snna kree iehk sgnn jtag soed jsgr njhg
jaio irgh strt jhsn nheg nshi jstt itje gard
END
    end

    it 'has the right addresses' do
    pending
      expect(subject.hash160(0)).to eq "\x06\x95\xc9\xf7\x73\xe4\xb4\xfb\xb5\xa5\xc8\xf4\x2d\xd1\x5a\x2c\xaa\x9e\x26\x83"
      expect(subject.address(0)).to eq '1bpVfmdYbMbzdiGXxPQUwitPjVzpVKk3n'
      expect(subject.address(1)).to eq '1P6Yih7wihx9CxKc3Fm9b6xg6qvMPckYdo'
      expect(subject.address(2)).to eq '1KHFzmGxPbz3MeMBr5CJrksJGmaW1CnVoB'
      expect(subject.address(3)).to eq '1DNNy3DDLCdWwStXPBaFTMC55YCwiCbNgo'
    end
  end
end