# encoding: ASCII-8BIT
require 'spec_helper'

# Some test cases in this came from https://bitcointalk.org/index.php?topic=129652.msg1697154#msg1697154

describe BitcoinAddressUtils::Base58PrivateKey do
  let(:base58_private_key_compressed_k) do
    'KyvGbxRUoofdw3TNydWn2Z78dBHSy2odn1d3wXWN2o3SAtccFNJL'
  end
  
  pending '.encode' do
  
  end
  
  describe '.decode' do
    it 'can decode a compressed private key starting with K' do
      private_key = described_class.decode base58_private_key_compressed_k
      
    end
  end
  
  pending '.decode_to_public_key' do
    
  end
end