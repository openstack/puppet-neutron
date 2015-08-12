require 'puppet'
require 'puppet/type/neutron_agent_ovs'

describe 'Puppet::Type.type(:neutron_agent_ovs)' do

  before :each do
    @neutron_agent_ovs = Puppet::Type.type(:neutron_agent_ovs).new(:name => 'DEFAULT/foo', :value => 'bar')
  end

  it 'should autorequire the package that install the file' do
    catalog = Puppet::Resource::Catalog.new
    package = Puppet::Type.type(:package).new(:name => 'neutron-ovs-agent')
    catalog.add_resource package, @neutron_agent_ovs
    dependency = @neutron_agent_ovs.autorequire
    expect(dependency.size).to eq(1)
    expect(dependency[0].target).to eq(@neutron_agent_ovs)
    expect(dependency[0].source).to eq(package)
  end

end
