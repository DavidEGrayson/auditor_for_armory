      if version.ord != 0x80
        raise "This doesn't look like a private key; version byte is %#x." % version.ord
      end
