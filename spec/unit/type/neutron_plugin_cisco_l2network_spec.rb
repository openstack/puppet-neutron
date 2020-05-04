require 'puppet'
require 'puppet/type/neutron_plugin_cisco_l2network'

describe 'Puppet::Type.type(:neutron_plugin_cisco_l2network)' do

  before :each do
    @neutron_plugin_cisco_l2network = Puppet::Type.type(:neutron_plugin_cisco_l2network).new(:name => 'DEFAULT/foo', :value => 'bar')
  end

  it 'should autorequire the package that install the file' do
    catalog = Puppet::Resource::Catalog.new
    anchor = Puppet::Type.type(:anchor).new(:name => 'neutron::install::end')
    catalog.add_resource anchor, @neutron_plugin_cisco_l2network
    dependency = @neutron_plugin_cisco_l2network.autorequire
    expect(dependency.size).to eq(1)
    expect(dependency[0].target).to eq(@neutron_plugin_cisco_l2network)
    expect(dependency[0].source).to eq(anchor)
  end

end
