require_relative 'bitcoin_address_utils/base58_integer'
require_relative 'bitcoin_address_utils/base58_binary'
require_relative 'bitcoin_address_utils/base58_check'
require_relative 'bitcoin_address_utils/address'
require_relative 'bitcoin_address_utils/base58_private_key'

module BitcoinAddressUtils
  def self.ecdsa_group
    ECDSA::Group::Secp256k1
  end
end
