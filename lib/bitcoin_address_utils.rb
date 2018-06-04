require_relative 'bitcoin_address_utils/address'
require_relative 'bitcoin_address_utils/base58_private_key'

module BitcoinAddressUtils
  def self.ecdsa_group
    ECDSA::Group::Secp256k1
  end
end
