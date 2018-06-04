# encoding: ASCII-8BIT

# BIP32 - Hierarchical Deterministic Wallets
# https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki

module DBTC
  # TODO: get rid of these key array arguments, split into two arguments

  # TODO: try to get rid of this
  def hd_basic_key_data(key)
    if key.is_a?(Integer)
      "\x00" + int_encode(key, 32)
    else
      ecdsa_public_encode(key)
    end
  end

  def hd_generate_master_key(seed)
    hmac = hmac_sha512("Bitcoin seed", seed)
    left, chain_code = hmac[0...32], hmac[32...64]
    private_key = int_decode(left)
    if private_key >= ecdsa_group_order || private_key == 0
      return nil  # Invalid key, try another seed
    end
    [private_key, chain_code]
  end

  def hd_child(key, i)
    if key[0].is_a?(Integer)
      child_private(key, i)
    else
      child_public(key, i)
    end
  end

  def hd_child_private(key, i)
    if i >= (1 << 31)
      # hardened
      message = hd_basic_key_data(key[0])
    else
      message = hd_basic_key_data(hd_public(key)[0])
    end
    message << int_encode(i, 4)
    hmac = hmac_sha512(key[1], message)
    left, chain_code = hmac[0...32], hmac[32...64]
    pk0 = DBTC.int_decode(left)
    private_key = (pk0 + key[0]) % ecdsa_group_order
    if pk0 >= ecdsa_group_order || private_key == 0
      return nil  # Invalid key, try next i value
    end
    [private_key, chain_code]
  end

  def hd_child_public(key, i)
    if i >= (1 << 31)
      raise "Cannot derive hardened HD keys without a private key."
    end
    message = ecdsa_public_encode(key[0])
    message << int_encode(i, 4)
    hmac = hmac_sha512(key[1], message)
    left, chain_code = hmac[0...32], hmac[32...64]
    pk0 = DBTC.int_decode(left)
    public_key = ecdsa_private_to_public(pk0) + key[0]
    if pk0 >= ecdsa_group_order || public_key.infinity?
      return nil  # Invalid key, try next i value
    end
    [public_key, chain_code]
  end

  def hd_public(key)
    if key[0].is_a?(Integer)
      private_key, chain_code = key
      public_key = ecdsa_private_to_public private_key
      [public_key, chain_code]
    else
      key
    end
  end

  def hd_id(key)
    key = hd_public(key)
    key_str = ecdsa_public_encode(key[0])
    hash160 key_str
  end

  def hd_fingerprint(key)
    hd_id(key)[0, 4]
  end

  def hd_encode(key, depth, parent_fingerprint, child_number)
    if key[0].is_a?(Integer)
      version = 0x0488ADE4  # mainnet private (xprv)
    else
      version = 0x0488B21E  # mainnet public (xpub)
    end
    data = (depth & 0xFF).chr('BINARY')
    data << parent_fingerprint
    data << int_encode(child_number, 4)
    data << key[1]  # chain code
    data << hd_basic_key_data(key[0])
    base58_check_encode(version, data)
  end
end
