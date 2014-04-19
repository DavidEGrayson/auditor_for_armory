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
      raise "Invalid checksum; data might be corrupt." if str[-4, 4] != checksum
      payload
    end

    def self.encode(version, payload)
      checksum = checksum(version + payload)
      BitcoinAddressUtils::Base58Binary.encode version + payload + checksum
    end
    
    def self.checksum(data)
      BitcoinAddressUtils.double_sha256(data)[0, 4]
    end
  end
end