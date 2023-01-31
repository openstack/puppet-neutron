require 'puppet'
require 'spec_helper'
require 'puppet/provider/neutron_l3_ovs_bridge/neutron'

provider_class = Puppet::Type.type(:neutron_l3_ovs_bridge).provider(:neutron)

describe provider_class do

  let :resource do
    Puppet::Type::Neutron_l3_ovs_bridge.new(
      :name        => 'br-ex',
      :subnet_name => 'subnet1'
    )
  end

  let :provider do
    provider_class.new(resource)
  end


  describe 'when retrieving bridge ip addresses' do

    it 'should return an empty array for no matches' do
      expect(provider).to receive(:ip).and_return('')
      expect(provider.bridge_ip_addresses).to eql []
    end

    it 'should return an array of addresses if matches are found' do
      output = <<-EOT
122: br-ex: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UNKNOWN
    link/ether d2:95:15:80:b5:4f brd ff:ff:ff:ff:ff:ff
    inet 172.24.4.225/28 scope global br-ex
    inet6 fe80::d095:15ff:fe80:b54f/64 scope link
       valid_lft forever preferred_lft forever
EOT
      expect(provider).to receive(:ip).and_return(output)
      expect(provider.bridge_ip_addresses).to eql ['172.24.4.225/28']
    end

  end

  describe 'when checking if the l3 bridge exists' do

    it 'should return true if the gateway ip is present' do
      expect(provider).to receive(:bridge_ip_addresses).and_return(['a'])
      expect(provider).to receive(:gateway_ip).and_return('a')
      expect(provider.exists?).to eql true
    end

  end

end
