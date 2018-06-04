require 'ecdsa'

module DBTC
  def ecdsa_group
    ECDSA::Group::Secp256k1
  end

  def ecdsa_group_order
    ecdsa_group.order
  end

  def ecdsa_private_to_public(private_key)
    ecdsa_group.new_point(private_key)
  end

  def ecdsa_public_encode(public_key, compression = true)
    ECDSA::Format::PointOctetString.encode(public_key,
      compression: compression)
  end
end
