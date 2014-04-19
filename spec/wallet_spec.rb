# coding: ASCII-8BIT

require_relative 'spec_helper'

describe AuditorForArmory::Wallet do
  let(:root_private_key) do
    0x5d621ff07a99d95714ff6b041e92614a60deda451bab651ff594f15d61bbdb69
  end

  let(:paper_backup) do
    "hijd snna kree iehk sgnn jtag soed jsgr njhg\n" \
    "jaio irgh strt jhsn nheg nshi jstt itje gard"
  end

  let(:first_address) do
    '1bpVfmdYbMbzdiGXxPQUwitPjVzpVKk3n'
  end

  subject do
    described_class.new(root_private_key)
  end

  shared_examples_for 'the right wallet (watch only)' do
    it 'has the right ID' do
      expect(subject.wallet_id). to eq 'zkRR49p3'
    end

    it 'has the right addresses' do
      expect(subject.address(1)).to eq first_address
      expect(subject.address(2)).to eq '1P6Yih7wihx9CxKc3Fm9b6xg6qvMPckYdo'
    end
  end

  shared_examples_for 'the right wallet' do
    it 'has the right root private key' do
      expect(subject.private_key(0)).to eq root_private_key
    end

    it_behaves_like 'the right wallet (watch only)'
  end

  context 'when created from a paper backup' do
    subject do
      described_class.from_paper_backup paper_backup
    end

    it_behaves_like 'the right wallet'
  end

  context 'when created from a root private key' do
    it_behaves_like 'the right wallet'
  end

  describe 'wallet ID' do
    it 'actually contains the first 5 bytes of the first address' do
      # The wallet ID contains the first few bytes of the first address in it.
      fragment = BitcoinAddressUtils::Base58Binary.decode(subject.wallet_id).reverse[1, 5]
    
      version, hash160 = BitcoinAddressUtils::Base58Check.decode first_address
      expect(fragment).to eq hash160[0, 5]
      
      # This form will be more useful.
      x = BitcoinAddressUtils::Base58Binary.encode("\x00" + fragment.ljust(24, "\x00"))
      y = BitcoinAddressUtils::Base58Binary.encode("\x00" + fragment.ljust(24, "\xFF"))
      expect(x).to eq '1bpVfmcpivEQD3WAX1NhGL9k1a6Uiezv3'
      expect(y).to eq '1bpVfmddbA3NM5YWGJMfSwqUEh1biyvge'
      # first_address: 1bpVfmdYbMbzdiGXxPQUwitPjVzpVKk3n'
      expect(x).to be < first_address
      expect(y).to be > first_address
    end
  end

  describe 'HMAC256' do
    context 'for keys up to 32 bytes long' do
      it 'behaves like the HMAC256 method from Armory' do
        # This test case was made by running Armory code from the Python REPL.
        expect(described_class.hmac256('abcde', 'Derive Chaincode from Root Key')).to start_with "\x13\xf2\xfa\x91"
      end
    end
    
    context 'for keys longer than 32 bytes' do
      it 'behaves like the HMAC256 method from Armory' do
        # This test case was made by running Armory code from the Python REPL.
        expect(described_class.hmac256('a' * 33, 'hi')).to start_with "Whc\x02"        
      end
    end
  end

  specify 'armory test wallet reproduction steps' do
    # This might look like a mess, but it will be very helpful if the other more
    # succinct tests ever fail and we don't immediately know why.  It will also
    # be useful to others who want to implement the Armory wallet and need a
    # step-by-step tutorial with intermediate values shown.
    root_key_binary = described_class.decode_private_key_binary(paper_backup)
    expect(root_key_binary).to eq "]b\x1f\xf0z\x99\xd9W\x14\xffk\x04\x1e\x92aJ`\xde\xdaE\x1b\xabe\x1f\xf5\x94\xf1]a\xbb\xdbi"

    hash1 = BitcoinAddressUtils.hash256 root_key_binary
    expect(hash1).to eq "\xc6\xd6H\xc0\x97\xcd\xe3hY\x86(\x96>q\xc6\x07lk\x10U\x99#\x18\x17\x97\xff\x8c\xd0\x0c\xeb!-"
    hash2 = described_class.hmac256 hash1, 'Derive Chaincode from Root Key'
    expect(hash2).to eq "~\x1bt\x8a\xf8\xab\xd5\xb8\\\xf0\xe05w\xc6]\xc7\x07\xcd}\xb8y\x98\xb3\xfd\xdf\xbdV\x8e\xa5D\x94\x99"

    root_private_key = ECDSA::Format::IntegerOctetString.decode root_key_binary
    expect(root_private_key).to eq root_private_key
    chain_code = described_class.chain_code_from_root_key root_private_key
    expect(chain_code).to eq ECDSA::Format::IntegerOctetString.decode hash2

    group = ECDSA::Group::Secp256k1
    root_public_key = group.new_point root_private_key
    root_public_key_binary = ECDSA::Format::PointOctetString.encode root_public_key
    expect(root_public_key_binary).to eq "\x04" \
      "^e'#&^.\x97\x96w\xe6n\xeeJ\x96\xca\xb2E\x92\xf5\rV\x7f\nA\xfd\xe6?\xf34\xa0\xf3" \
      "\xf2\xe2\x14[U\x81\x89\x00\x18\x7f\x1b\xe8\xe1/t@\x9c\xc9\xef\x89\xec\x9e\xeau\x9au\xea\x1e\xa9\xc8AC"

    chain_mod_binary = BitcoinAddressUtils.hash256 root_public_key_binary
    chain_mod = ECDSA::Format::IntegerOctetString.decode chain_mod_binary
    expect(chain_mod).to eq 0xd4066ff5ba05db7c5d3f918b680887039f5d9015bb6ae30aa102f7f9ea4e13a1
    chain_xor = chain_code ^ chain_mod
    expect(chain_xor).to eq 0xaa1d1b7f42ae0ec401cf71be1fcedac49890edadc2f250f77ebfa1774f0a8738

    expect(chain_xor).to eq 76944612602120663668233733213422248447651746424542828612141749501505642858296
    expect(root_private_key).to eq 42238466368027395791709102098298032482896745453794422710138600580195569884009

    field = ECDSA::PrimeField.new(group.order)
    private_key1 = field.mod chain_xor * root_private_key
    expect(private_key1).to eq 3903260867841405862171490321261292147560126636726504734354759859916446753435
    private_key1_binary = ECDSA::Format::IntegerOctetString.encode(private_key1, 32)
    expect(private_key1_binary).to eq "\x08\xa1*\xd8/\xf6\x14\xbd\xf7\xb98\xd4\x9d\x15%1E\xac\xc5\t-xw\xda\xccdBE\x1d\xe5\xe2\x9b"

    private_key1 = described_class.extend_chain root_private_key, chain_code
    private_key1_binary = ECDSA::Format::IntegerOctetString.encode(private_key1, 32)
    expect(private_key1_binary).to eq "\x08\xa1*\xd8/\xf6\x14\xbd\xf7\xb98\xd4\x9d\x15%1E\xac\xc5\t-xw\xda\xccdBE\x1d\xe5\xe2\x9b"
  end
end