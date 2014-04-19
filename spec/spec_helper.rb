$LOAD_PATH << 'lib'
require 'auditor_for_armory'

# TODO: make a utility to find the first address in an Armory wallet,
#  given the wallet ID and the set of all known addresses.
#  Critical code from Armory is:
#    newWltID = binary_to_base58((ADDRBYTE + first.getAddr160()[:5])[::-1])

class String
  def hex_inspect
    '"' + each_byte.map { |b| '\x%02x' % b }.join + '"'
  end
end