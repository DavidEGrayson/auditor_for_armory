# encoding: ASCII-8BIT

require 'digest'

module BitcoinAddressUtils
  module HMAC
    def self.xor(s1, s2)
      if s1.bytesize != s2.bytesize
        raise ArgumentError, "Cannot XOR strings of different sizes"
      end
      r = ""
      s1.bytesize.times do |i|
        r.concat s1.getbyte(i) ^ s2.getbyte(i)
      end
      r
    end

    def self.sha512(key, message)
      block_size = 512 / 8
      hash = Digest::SHA512.method(:digest)
      key = hash.(key) if key.size > block_size
      key << "\x00" * (block_size - key.size)
      inkey = HMAC.xor(key, "\x36" * block_size)
      hash1 = hash.(inkey + message)
      outkey = HMAC.xor(key, "\x5C" * block_size)
      hash.(outkey + hash1)
    end
  end
end
