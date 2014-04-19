require_relative 'decode_error'

# https://en.bitcoin.it/wiki/Base58Check_encoding
module BitcoinAddressUtils
  module Base58Check
    def self.decode(string)
      str = BitcoinAddressUtils::Base58Binary.decode string
      if str[-4, 4] != checksum(str[0, str.size - 4])
        raise DecodeError, "Invalid checksum."
      end
      version = str[0].ord
      payload = str[1, str.size - 5]
      [version, payload]
    end

    # @param version (Intger) A number between 0 and 255 and probably from https://en.bitcoin.it/wiki/List_of_address_prefixes
    # @praam payload (String) The data to encode.
    def self.encode(version, payload)
      raise ArgumentError "Invalid version." if !(0..255).include?(version)
      version_byte = version.chr('BINARY')
      payload = payload.dup.force_encoding('BINARY')
      data = version_byte + payload
      BitcoinAddressUtils::Base58Binary.encode data + checksum(data)
    end
    
    def self.checksum(data)
      BitcoinAddressUtils.double_sha256(data)[0, 4]
    end
  end
end