$LOAD_PATH << 'lib'
require 'auditor-for-armory'

class String
  def hex_inspect
    '"' + each_byte.map { |b| '\x%02x' % b }.join + '"'
  end
end