# encoding: ASCII-8BIT

module DBTC
  def private_key_encode(private_key, compressed = true)
    if private_key.is_a?(String)
      data = private_key.dup.force_encoding('BINARY')
    else
      data = ECDSA::Format::IntegerOctetString.encode(private_key, 32)
    end
    if data.bytesize != 32
      raise "private key string should be 32 bytes, got #{private_key.size}"
    end
    data << "\x01" if compressed
    base58_check_encode 0x80, data
  end

  def private_key_decode(string)
    read_version, data = DBTC.base58_check_decode string
    if read_version != 0x80
      raise DecodeError, 'Private key has wrong version byte.'
    end
    if data.size < 32
      raise DecodeError, 'Private key has wrong size.'
    end
    private_key = ECDSA::Format::IntegerOctetString.decode data[0, 32]
    metadata = data[32..-1]
    case metadata
    when "\x01"
      compression = true
    when ""
      compression = false
    else
      raise DecodeError, 'Private key metadata unrecognized.'
    end
    [private_key, compression]
  end
end
