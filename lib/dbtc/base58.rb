# https://en.bitcoin.it/wiki/Base58Check_encoding
# https://en.bitcoin.it/wiki/List_of_address_prefixes
module DBTC
  Base58Chars =
    '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz'.split('')

  def base58_int_encode(integer)
    raise ArgumentError, 'Integer to encode is negative.' if integer < 0

    string = ''
    while integer > 0
      integer, remainder = integer.divmod 58
      string << Base58Chars[remainder]
    end
    string.reverse
  end

  def base58_int_decode(string)
    string = string.dup.force_encoding('BINARY')
    string.each_char.reduce(0) do |result, char|
      value = Base58Chars.index(char)
      if !value
        raise DecodeError,
          "Character is not valid in base 58: #{char.inspect}."
      end
      result * 58 + value
    end
  end

  def base58_encode(string)
    string = string.dup.force_encoding('BINARY') # TODO: remove
    leading_zeros_count = string.match(/\A(\0*)/)[1].size
    number = int_decode(string)
    '1' * leading_zeros_count + base58_int_encode(number)
  end

  def base58_decode(string)
    string = string.dup.force_encoding('BINARY') # TODO: remove
    leading_ones_count = string.match(/\A(1*)/)[1].size
    number = base58_int_decode(string)
    "\x00" * leading_ones_count + int_encode(number)
  end

  def checksum(data)
    hash256(data)[0, 4]
  end

  def base58_check_decode(string)
    str = base58_decode(string)
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

  def base58_check_encode(version, payload)
    if version >= 0 && version < 256 && version != 4
      vstr = version.chr('BINARY')
    elsif version >= 0x04000000 && version < 0x05000000
      vstr = ECDSA::Format::IntegerOctetString.encode(version, 4)
    else
      raise ArgumentError, "Invalid version: #{version.inspect}."
    end
    data = vstr + payload
    base58_encode data + checksum(data)
  end
end
