require 'puppet'
require 'puppet/type/neutron_plugin_plumgrid'

describe 'Puppet::Type.type(:neutron_plugin_plumgrid)' do

  before :each do
    @neutron_plugin_plumgrid = Puppet::Type.type(:neutron_plugin_plumgrid).new(:name => 'DEFAULT/foo', :value => 'bar')
  end

  it 'should autorequire the package that install the file' do
    catalog = Puppet::Resource::Catalog.new
    package = Puppet::Type.type(:package).new(:name => 'neutron-plugin-plumgrid')
    catalog.add_resource package, @neutron_plugin_plumgrid
    dependency = @neutron_plugin_plumgrid.autorequire
    expect(dependency.size).to eq(1)
    expect(dependency[0].target).to eq(@neutron_plugin_plumgrid)
    expect(dependency[0].source).to eq(package)
  end

end
