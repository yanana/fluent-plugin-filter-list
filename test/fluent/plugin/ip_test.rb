require 'test_helper'
require 'ipaddr'
require 'ip'

class IPTest < Minitest::Test
  include IP

  def test_that_prefix_is_correct
    [
      [IP.new('192.168.1.0/24'), 24],
      [IP.new('10.9.8.240/28'), 28],
      [IP.new('192.168.1.0/32'), 32]
    ].each do |ip, subnet|
      assert_equal(subnet, ip.subnet)
    end
  end

  def test_to_binary
    [
      [IP.new('192.168.1.0/24'), '110000001010100000000001'],
      [IP.new('10.9.8.240/28'), '0000101000001001000010001111'],
      [IP.new('43.90.0.0/16'), '0010101101011010']
    ].each do |ip, binary|
      assert_equal(binary, ip.to_binary)
    end
  end
end
