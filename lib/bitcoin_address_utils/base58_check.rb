require_relative 'decode_error'

# https://en.bitcoin.it/wiki/Base58Check_encoding
module BitcoinAddressUtils
  module Base58Check
    def self.decode(string)
      bignum = base58_decode string  
      str = ECDSA::Format::IntegerOctetString.encode(bignum, 38)
      version = str[0]
      payload = str[1, str.size - 5]
      if version.ord != 0x80
        raise "This doesn't look like a private key; version byte is %#x." % version.ord
      end
      checksum = base58check_checksum version + payload
      raise DecodeError, "Invalid checksum; data might be corrupt." if str[-4, 4] != checksum
      payload
    end

    # @param version (Intger) A number between 0 and 255 and probably from https://en.bitcoin.it/wiki/List_of_address_prefixes
    # @praam payload (String) The data to encode.
    def self.encode(version, payload)
      raise ArgumentError "Invalid version." if !(0..255).include?(version)
      version_byte = version.chr('BINARY')
      checksum = checksum(version_byte + payload)
      BitcoinAddressUtils::Base58Binary.encode version_byte + payload + checksum
    end
    
    def self.checksum(data)
      BitcoinAddressUtils.double_sha256(data)[0, 4]
    end
  end
end