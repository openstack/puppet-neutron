require 'puppet'
require 'puppet/type/neutron_agent_linuxbridge'

describe 'Puppet::Type.type(:neutron_agent_linuxbridge)' do

  before :each do
    @neutron_agent_linuxbridge = Puppet::Type.type(:neutron_agent_linuxbridge).new(:name => 'DEFAULT/foo', :value => 'bar')
  end

  it 'should autorequire the package that install the file' do
    catalog = Puppet::Resource::Catalog.new
    anchor = Puppet::Type.type(:anchor).new(:name => 'neutron::install::end')
    catalog.add_resource anchor, @neutron_agent_linuxbridge
    dependency = @neutron_agent_linuxbridge.autorequire
    expect(dependency.size).to eq(1)
    expect(dependency[0].target).to eq(@neutron_agent_linuxbridge)
    expect(dependency[0].source).to eq(anchor)
  end

end
