require 'puppet'
require 'puppet/type/neutron_agent_vpp'

describe 'Puppet::Type.type(:neutron_agent_vpp)' do

  before :each do
    @neutron_agent_vpp = Puppet::Type.type(:neutron_agent_vpp).new(:name => 'DEFAULT/foo', :value => 'bar')
  end

  it 'should autorequire the package that install the file' do
    catalog = Puppet::Resource::Catalog.new
    anchor = Puppet::Type.type(:anchor).new(:name => 'neutron::install::end')
    catalog.add_resource anchor, @neutron_agent_vpp
    dependency = @neutron_agent_vpp.autorequire
    expect(dependency.size).to eq(1)
    expect(dependency[0].target).to eq(@neutron_agent_vpp)
    expect(dependency[0].source).to eq(anchor)
  end

end
