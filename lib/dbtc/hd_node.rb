# Class that makes it much easier to use the heirarchical deterministic wallet
# functions provided by this library.
class DBTC::HDNode
  attr_accessor :private_key
  attr_writer :public_key
  attr_accessor :chain_code
  attr_accessor :depth
  attr_accessor :parent
  attr_accessor :child_number
  attr_writer :fingerprint

  def self.master(seed)
    node = new
    node.private_key, node.chain_code =
      DBTC.hd_generate_master_key(seed)
    node.depth = 0
    node.child_number = 0
    node
  end

  def public_key
    @public_key ||= DBTC.ecdsa_private_to_public(private_key)
  end

  def fingerprint
    @fingerprint ||= DBTC.hd_fingerprint(public_key)
  end

  def parent_fingerprint
    @parent ? @parent.fingerprint : "\x00\x00\x00\x00"
  end

  def xprv
    DBTC.hd_encode(private_key, chain_code, depth, parent_fingerprint,
      child_number)
  end

  def xpub
    DBTC.hd_encode(public_key, chain_code, depth, parent_fingerprint,
      child_number)
  end

  # Note: Caching of children would be nice.
  def child(i)
    child = self.class.new
    if private_key
      child.private_key, child.chain_code =
        DBTC.hd_child_private(private_key, chain_code, i)
    else
      child.public_key, child.chain_code =
        DBTC.hd_child_public(public_key, chain_code, i)
    end
    child.depth = depth + 1
    child.parent = self
    child.child_number = i
    child
  end

  def discard_private_key
    node = self.class.new
    node.public_key = public_key
    node.chain_code = chain_code
    node.depth = depth
    node.parent = parent
    node
  end
end
