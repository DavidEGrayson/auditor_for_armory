require_relative 'bitcoin_address_utils/address'

module BitcoinAddressUtils
  def self.ecdsa_group
    ECDSA::Group::Secp256k1
  end
end
