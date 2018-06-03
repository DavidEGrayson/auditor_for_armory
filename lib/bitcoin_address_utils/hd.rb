# encoding: ASCII-8BIT

module BitcoinAddressUtils
  # BIP32 - Hierarchical Deterministic Wallets
  # https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki
  #
  # Operates on extended keys, which are a two-element array, with the
  # first element be a private key (integer) or public key (ECDSA point),
  # and the second element being the 32-byte binary chain code string.
  module HD
    def self.basic_key_data(key)
      if key.is_a?(Integer)
        "\x00" + ECDSA::Format::IntegerOctetString.encode(key, 32)
      else
        ECDSA::Format::PointOctetString.encode(key, compression: true)
      end
    end

    def self.generate_master_key(seed)
      hmac = HMAC.sha512("Bitcoin seed", seed)
      left, chain_code = hmac[0...32], hmac[32...64]
      private_key = BinaryInteger.decode(left)
      if private_key >= BitcoinAddressUtils.ecdsa_group.order || private_key == 0
        return nil  # Invalid key, try another seed
      end
      [private_key, chain_code]
    end

    def self.child(key, i)
      if key[0].is_a?(Integer)
        child_private(key, i)
      else
        child_public(key, i)
      end
    end

    def self.child_private(key, i)
      if i >= (1 << 31)
        # hardened
        message = basic_key_data(key[0])
      else
        messsage = basic_key_data(public(key)[0])
      end
      message << ECDSA::Format::IntegerOctetString.encode(i, 4)
      hmac = HMAC.sha512(chain_code, message)
      left, chain_code = hmac[0...32], hmac[32...64]
      pk0 = BinaryInteger.decode(left)
      private_key = (pk0 + key[0]) % BitcoinAddressUtils.ecdsa_group.order
      if pk0 >= BitcoinAddressUtils.ecdsa_group.order || private_key == 0
        return nil  # Invalid key, try next i value
      end
      [private_key, chain_code]
    end

    def self.child_public(key, i)
      raise NotImplementedError
    end

    def self.public(key)
      if key[0].is_a?(Integer)
        private_key, chain_code = key
        public_key = BitcoinAddressUtils.ecdsa_group.new_point private_key
        [public_key, chain_code]
      else
        key
      end
    end

    def self.id(key)
      key = self.public(key)
      key_str = ECDSA::Format::PointOctetString.encode(public_key,
        compression: true)
      BitcoinAddressUtils.hash160 key_str
    end

    def self.fingerprint(key)
      id(key) & 0xFFFFFFFF
    end

    def self.encode(key, depth, parent_fingerprint, child_number)
      if key[0].is_a?(Integer)
        version = 0x0488ADE4  # mainnet private (xprv)
      else
        version = 0x0488B21E  # mainnet public (xpub)
      end
      data = (depth & 0xFF).chr('BINARY')
      data << ECDSA::Format::IntegerOctetString.encode(parent_fingerprint, 4)
      data << ECDSA::Format::IntegerOctetString.encode(child_number, 4)
      data << key[1]  # chain code
      data << basic_key_data(key[0])
      Base58Check.encode(version, data)
    end
  end
end
