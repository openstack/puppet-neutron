require 'puppet'
require 'puppet/type/neutron_plugin_midonet'

describe 'Puppet::Type.type(:neutron_plugin_midonet)' do

  before :each do
    @neutron_plugin_midonet = Puppet::Type.type(:neutron_plugin_midonet).new(:name => 'DEFAULT/foo', :value => 'bar')
  end

  it 'should autorequire the package that install the file' do
    catalog = Puppet::Resource::Catalog.new
    package = Puppet::Type.type(:package).new(:name => 'python-networking-midonet')
    catalog.add_resource package, @neutron_plugin_midonet
    dependency = @neutron_plugin_midonet.autorequire
    expect(dependency.size).to eq(1)
    expect(dependency[0].target).to eq(@neutron_plugin_midonet)
    expect(dependency[0].source).to eq(package)
  end

end
