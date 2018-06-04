# encoding: ASCII-8BIT

# BIP32 - Hierarchical Deterministic Wallets
# https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki

module DBTC
  def hd_generate_master_key(seed)
    hmac = hmac_sha512("Bitcoin seed", seed)
    left, chain_code = hmac[0...32], hmac[32...64]
    private_key = int_decode(left)
    if private_key >= ecdsa_group_order || private_key == 0
      return nil  # Invalid key, try another seed
    end
    [private_key, chain_code]
  end

  def hd_child_private(private_key, chain_code, i)
    if i >= (1 << 31)
      # hardened
      message = "\x00" + int_encode(private_key, 32)
    else
      message = ecdsa_public_encode(ecdsa_private_to_public(private_key))
    end
    message << int_encode(i, 4)
    hmac = hmac_sha512(chain_code, message)
    left, new_chain_code = hmac[0...32], hmac[32...64]
    pk0 = DBTC.int_decode(left)
    new_private_key = (pk0 + private_key) % ecdsa_group_order
    if pk0 >= ecdsa_group_order || new_private_key == 0
      return nil  # Invalid key, try next i value
    end
    [new_private_key, new_chain_code]
  end

  def hd_child_public(public_key, chain_code, i)
    if i >= (1 << 31)
      raise "Cannot derive hardened HD keys without a private key."
    end
    message = ecdsa_public_encode(public_key)
    message << int_encode(i, 4)
    hmac = hmac_sha512(chain_code, message)
    left, chain_code = hmac[0...32], hmac[32...64]
    pk0 = DBTC.int_decode(left)
    public_key = ecdsa_private_to_public(pk0) + public_key
    if pk0 >= ecdsa_group_order || public_key.infinity?
      return nil  # Invalid key, try next i value
    end
    [public_key, chain_code]
  end

  def hd_fingerprint(public_key)
    hash160(ecdsa_public_encode(public_key))[0, 4]
  end

  def hd_encode(key, chain_code, depth, parent_fingerprint, child_number)
    if key.is_a?(Integer)
      version = 0x0488ADE4  # mainnet private (xprv)
    else
      version = 0x0488B21E  # mainnet public (xpub)
    end
    data = (depth & 0xFF).chr('BINARY')
    data << parent_fingerprint
    data << int_encode(child_number, 4)
    data << chain_code
    if key.is_a?(Integer)
      data << "\x00" + int_encode(key, 32)
    else
      data << ecdsa_public_encode(key)
    end
    base58_check_encode(version, data)
  end
end
