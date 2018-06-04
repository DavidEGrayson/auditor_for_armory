# encoding: ASCII-8BIT

# https://en.bitcoin.it/wiki/Technical_background_of_Bitcoin_addresses

module DBTC
  def encoded_private_key_to_address(string)
    private_key, compression = private_key_decode(string)
    private_key_to_address(private_key, compression)
  end

  def private_key_to_address(private_key, compression = true)
    public_key = ecdsa_private_to_public(private_key)
    public_key_to_address(public_key, compression)
  end

  def public_key_to_address(public_key, compression = true)
    string = ECDSA::Format::PointOctetString.encode(public_key,
      compression: compression)
    encoded_public_key_to_address(string)
  end

  def encoded_public_key_to_address(string)
    version = 0
    hash = DBTC.hash160(string)
    base58_check_encode version, hash
  end
end
