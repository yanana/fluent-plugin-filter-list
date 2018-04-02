# -*- coding: utf-8 -*-

require 'test_helper'
require 'ipaddr'
require 'ip'

class IPTest < Minitest::Test
  include IP

  def test_that_prefix_is_correct
    ip1 = IP.new("192.168.1.0/24")
    ip2 = IP.new("192.168.1.0/28")
    ip3 = IP.new("192.168.1.0/32")

    assert_equal(ip1.subnet, 24)
    assert_equal(ip2.subnet, 28)
    assert_equal(ip3.subnet, 32)
  end
end
