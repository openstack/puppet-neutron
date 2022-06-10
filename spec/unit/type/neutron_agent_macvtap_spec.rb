require 'puppet'
require 'puppet/type/neutron_agent_macvtap'

describe 'Puppet::Type.type(:neutron_agent_macvtap)' do

  before :each do
    @neutron_agent_macvtap = Puppet::Type.type(:neutron_agent_macvtap).new(:name => 'DEFAULT/foo', :value => 'bar')
  end

  it 'should autorequire the package that install the file' do
    catalog = Puppet::Resource::Catalog.new
    anchor = Puppet::Type.type(:anchor).new(:name => 'neutron::install::end')
    catalog.add_resource anchor, @neutron_agent_macvtap
    dependency = @neutron_agent_macvtap.autorequire
    expect(dependency.size).to eq(1)
    expect(dependency[0].target).to eq(@neutron_agent_macvtap)
    expect(dependency[0].source).to eq(anchor)
  end

end
