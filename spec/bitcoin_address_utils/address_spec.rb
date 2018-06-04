# encoding: ASCII-8BIT
require 'spec_helper'

describe 'address' do
  describe 'encoded_private_key_to_address' do
    it 'converts the private key from the wiki (compression off)' do
      # Source: https://en.bitcoin.it/wiki/Private_key#Base_58_Wallet_Import_format
      private_key = '5Kb8kLf9zgWQnogidDA76MzPL6TsZZY36hWXMssSzNydYXYB9KF'
      address = encoded_private_key_to_address private_key
      expect(address).to eq '1CC3X2gu58d6wXUWMffpuzN9JAfTUWu4Kj'
    end

    it 'converts the private key from the wiki (compression on)' do
      # Source: https://bitcointalk.org/index.php?topic=129652.msg1697154#msg1697154
      private_key = 'KyvGbxRUoofdw3TNydWn2Z78dBHSy2odn1d3wXWN2o3SAtccFNJL'
      address = encoded_private_key_to_address private_key
      expect(address).to eq '1JMsC6fCtYWkTjPPdDrYX3we2aBrewuEM3'
    end
  end
end
