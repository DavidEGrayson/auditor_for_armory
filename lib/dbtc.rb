require 'digest'
require 'ecdsa'
require_relative 'dbtc/hd'
require_relative 'dbtc/int'
require_relative 'dbtc/hash'

module DBTC
  extend self

  # Raising instance of this class as an exception indicates that
  # the data being decoded was invalid, but does not necessarily
  # indicate a bug in the program, unlike most other exceptions
  # because it is possible the data being decoded is coming from
  # an untrusted source.
  class DecodeError < StandardError
  end
end
