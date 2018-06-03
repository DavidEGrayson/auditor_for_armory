require_relative 'decode_error'

# https://en.bitcoin.it/wiki/Base58Check_encoding
module BitcoinAddressUtils
  module Base58Check
    def self.decode(string)
      str = BitcoinAddressUtils::Base58Binary.decode string
      if str.size < 5
        raise DecodeError,
          "Decoded string not long enough: expected at least 5 bytes, " \
          "got #{str.size}."
      end
      if str[-4, 4] != checksum(str[0, str.size - 4])
        raise DecodeError, "Invalid checksum."
      end
      if str.getbyte(0) == 4
        version = ECDSA::Format::IntegerOctetString.decode str[0, 4]
        payload = str[4, str.size - 8]
      else
        version = str.getbyte(0)
        payload = str[1, str.size - 5]
      end
      [version, payload]
    end

    # @param version (Intger) A number between 0 and 255 and probably from
    #   https://en.bitcoin.it/wiki/List_of_address_prefixes
    # @praam payload (String) The data to encode.
    def self.encode(version, payload)
      if version >= 0 && version < 256 && version != 4
        vstr = version.chr('BINARY')
      elsif version >= 0x04000000 && version < 0x05000000
        vstr = ECDSA::Format::IntegerOctetString.encode(version, 4)
      else
        raise ArgumentError, "Invalid version: #{version.inspect}."
      end
      data = vstr + payload
      BitcoinAddressUtils::Base58Binary.encode data + checksum(data)
    end

    def self.checksum(data)
      BitcoinAddressUtils.hash256(data)[0, 4]
    end
  end
end
