# encoding: ASCII-8BIT

if ENV['COVERAGE'] == 'Y'
  require 'simplecov'
  SimpleCov.start
end

$LOAD_PATH << 'lib'
require 'auditor_for_armory'

require 'dbtc'
include DBTC

# TODO: would be useful to put this in the library
class String
  def hex_inspect
    '"' + each_byte.map { |b| '\x%02x' % b }.join + '"'
  end
end

# TODO: would be useful to put this in the library
# Note: Does not validate the input at all
def hex_to_binary(str)
  r = ""
  0.step(str.size - 2, 2) do |i|
    r.concat(str[i, 2].hex)
  end
  r
end

