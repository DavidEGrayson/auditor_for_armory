require 'digest'

# Based on https://github.com/etotheipi/BitcoinArmory/blob/4d1b24d053b7ba29bf435513822d05a453e40a30/extras/sss.py

module AuditorForArmory
  module SixteenEasyBytes
    def self.decode(string)
      string = string.dup.force_encoding('BINARY').strip.gsub(' ','')
      raise ArgumentError, "wrong length: #{string.size}" if string.size != 36
      b18 = decode_easy(string)
      b16 = b18[0,16]
      chk = b18[16, 2]
      verify_checksum(b16, chk) or raise 'bad checksum'
    end
    
    def self.verify_checksum(payload, checksum)
      # TODO: implement the same fixing that Armory has
    
      hash = Digest::SHA256.digest(Digest::SHA256.digest(payload))
      if hash.start_with?(checksum)
        payload
      else
        nil
      end
    end
    
    EasyChars = %w{ a s d f g h j k w e r t u i o n }
    
    def self.decode_easy(string)
      values = string.each_char.map do|c|
        EasyChars.index(c) or raise ArgumentError, "Invalid character #{c.inspect}."
      end
      
      bytes = values.each_slice(2).map do |v1, v2|
        (v1 * 16 + v2).chr('BINARY')
      end
      
      bytes.join
    end
  end
end