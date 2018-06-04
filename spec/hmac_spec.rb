# encoding: ASCII-8BIT

require 'spec_helper'
require 'openssl'

describe 'hmac' do
  specify 'test case 1' do
    key = "\x01\x02\x03\x04\x05"
    message = "Chancellor on brink of second bailout for banks"
    expected = OpenSSL::HMAC.digest("SHA512", key, message)
    actual = hmac_sha512(key, message)
    expect(actual).to eq expected
  end
end
