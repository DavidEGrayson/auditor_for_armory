# encoding: ASCII-8BIT

require 'digest'

module DBTC
  def hash256(string)
    Digest::SHA256.digest Digest::SHA256.digest string
  end

  def hash160(string)
    Digest::RMD160.digest Digest::SHA256.digest string
  end

  def xor(s1, s2)
    if s1.bytesize != s2.bytesize
      raise ArgumentError, "Cannot XOR strings of different sizes"
    end
    r = ""
    s1.bytesize.times do |i|
      r.concat s1.getbyte(i) ^ s2.getbyte(i)
    end
    r
  end

  # https://tools.ietf.org/html/rfc2104
  def hmac_sha512(key, message)
    block_size = 128
    hash = Digest::SHA512.method(:digest)
    key = hash.(key) if key.size > block_size
    key << "\x00" * (block_size - key.size)
    ikey = xor(key, "\x36" * block_size)
    hash1 = hash.(ikey + message)
    okey = xor(key, "\x5C" * block_size)
    hash.(okey + hash1)
  end
end
