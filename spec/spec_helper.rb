if ENV['COVERAGE'] == 'Y'
  require 'simplecov'
  SimpleCov.start
end

$LOAD_PATH << 'lib'
require 'auditor_for_armory'

class String
  def hex_inspect
    '"' + each_byte.map { |b| '\x%02x' % b }.join + '"'
  end
end
