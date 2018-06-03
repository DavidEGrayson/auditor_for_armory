require 'digest'
require 'ecdsa'

require_relative 'bitcoin_address_utils/base58_integer'
require_relative 'bitcoin_address_utils/base58_binary'
require_relative 'bitcoin_address_utils/base58_check'
require_relative 'bitcoin_address_utils/address'
require_relative 'bitcoin_address_utils/base58_private_key'
require_relative 'bitcoin_address_utils/hmac'

module BitcoinAddressUtils
  def self.ecdsa_group
    ECDSA::Group::Secp256k1
  end

  def self.hash256(string)
    Digest::SHA256.digest Digest::SHA256.digest string
  end

  def self.hash160(string)
    Digest::RMD160.digest Digest::SHA256.digest string
  end
end
