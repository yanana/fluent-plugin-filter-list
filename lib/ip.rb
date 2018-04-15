module IP
  require 'ipaddr'
  class IP
    attr_reader :subnet

    # This constructor accepts both CIDR-notated IP and also exact IP.
    def initialize(ip)
      @address = IPAddr.new(ip)
      @subnet = 32 - Math.log2(@address.to_range.to_a.size).round
    end

    def to_binary
      binary = @address.to_i.to_s(2).rjust(32, '0')
      binary.slice(0, @subnet)
    end
  end
end
