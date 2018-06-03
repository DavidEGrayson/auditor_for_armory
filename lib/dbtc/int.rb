module DBTC
  # TODO: add optional length argument
  def int_encode(integer)
    raise ArgumentError, 'Integer to encode is negative.' if integer < 0
    string = ''.force_encoding('BINARY')
    while integer > 0
      integer, remainder = integer.divmod 256
      string << remainder.chr
    end
    string.reverse
  end

  def int_decode(string)
    string.bytes.reduce(0) { |n, b| (n << 8) + b }
  end
end
