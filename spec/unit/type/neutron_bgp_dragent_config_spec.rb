require 'puppet'
require 'puppet/type/neutron_bgp_dragent_config'

describe 'Puppet::Type.type(:neutron_bgp_dragent_config)' do

  before :each do
    @neutron_bgp_dragent_config = Puppet::Type.type(:neutron_bgp_dragent_config).new(:name => 'DEFAULT/foo', :value => 'bar')
  end

  it 'should autorequire the package that install the file' do
    catalog = Puppet::Resource::Catalog.new
    package1 = Puppet::Type.type(:package).new(:name => 'neutron-dynamic-routing')
    package2 = Puppet::Type.type(:package).new(:name => 'neutron-bgp-dragent')
    catalog.add_resource package1, package2, @neutron_bgp_dragent_config
    dependency = @neutron_bgp_dragent_config.autorequire
    expect(dependency.size).to eq(2)
    expect(dependency[0].target).to eq(@neutron_bgp_dragent_config)
    expect(dependency[0].source).to eq(package1)
    expect(dependency[1].target).to eq(@neutron_bgp_dragent_config)
    expect(dependency[1].source).to eq(package2)
  end

end
