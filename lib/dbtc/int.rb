# encoding: ASCII-8BIT

module DBTC
  def int_encode(integer, min_length = 0)
    string = ""
    while integer > 0
      integer, remainder = integer.divmod 256
      string << remainder
    end
    string.reverse.rjust(min_length, "\x00")
  end

  def int_decode(string)
    string.bytes.reduce(0) { |n, b| (n << 8) + b }
  end
end
