require 'puppet'
require 'puppet/type/neutron_subnet'

describe 'Puppet::Type.type(:neutron_subnet)' do
  it 'should not allow ipv6 settings with ip_version = 4' do
    expect{Puppet::Type.type(:neutron_subnet).new(
      :name => 'subnet',
      :network_name => 'net',
      :cidr => '2001:abcd::/64',
      :ip_version => '4',
      :ipv6_ra_mode => 'slaac'
    )}.to raise_error(Puppet::ResourceError)
  end

  it 'should allow ipv6 settings with ip_version = 6' do
    expect{Puppet::Type.type(:neutron_subnet).new(
      :name => 'subnet',
      :network_name => 'net',
      :cidr => '2001:abcd::/64',
      :ip_version => '6',
      :ipv6_ra_mode => 'slaac'
    )}.not_to raise_error
  end

end
