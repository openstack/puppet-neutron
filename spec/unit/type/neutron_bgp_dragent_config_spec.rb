require 'puppet'
require 'puppet/type/neutron_bgp_dragent_config'

describe 'Puppet::Type.type(:neutron_bgp_dragent_config)' do

  before :each do
    @neutron_bgp_dragent_config = Puppet::Type.type(:neutron_bgp_dragent_config).new(:name => 'DEFAULT/foo', :value => 'bar')
  end

  it 'should autorequire the package that install the file' do
    catalog = Puppet::Resource::Catalog.new
    anchor = Puppet::Type.type(:anchor).new(:name => 'neutron::install::end')
    catalog.add_resource anchor, @neutron_bgp_dragent_config
    dependency = @neutron_bgp_dragent_config.autorequire
    expect(dependency.size).to eq(1)
    expect(dependency[0].target).to eq(@neutron_bgp_dragent_config)
    expect(dependency[0].source).to eq(anchor)
  end

end
