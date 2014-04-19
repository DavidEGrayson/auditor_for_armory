require 'digest'
require 'ecdsa'

require_relative 'bitcoin_address_utils/binary_integer'
require_relative 'bitcoin_address_utils/base58_integer'
require_relative 'bitcoin_address_utils/base58_binary'
require_relative 'bitcoin_address_utils/base58_check'
require_relative 'bitcoin_address_utils/address'

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

def private_key_decode(string)
  data = base58check_decode string
  data.force_encoding('binary')
  data = data[0, data.size - 1]  # remove trailing "\x01" byte, not sure why it is there
  raise "Expected private key to be 32 bytes." if data.size != 32
  ECDSA::Format::IntegerOctetString.decode(data)
end

# Print out the bitcoin address corresponding to this private key, assuming that
# the *compressed* version of the public key was used to make the address.
def inspect_private_key(private_key)
  public_key = BitcoinAddressUtils.ecdsa_group.generator.multiply_by_scalar private_key
  puts bitcoin_address public_key, true
end