require 'puppet'
require 'puppet/type/neutron_plugin_ml2'

describe 'Puppet::Type.type(:neutron_plugin_ml2)' do

  before :each do
    @neutron_plugin_ml2 = Puppet::Type.type(:neutron_plugin_ml2).new(:name => 'DEFAULT/foo', :value => 'bar')
  end

  it 'should autorequire the package that install the file' do
    catalog = Puppet::Resource::Catalog.new
    package = Puppet::Type.type(:package).new(:name => 'neutron-plugin-ml2')
    catalog.add_resource package, @neutron_plugin_ml2
    dependency = @neutron_plugin_ml2.autorequire
    expect(dependency.size).to eq(1)
    expect(dependency[0].target).to eq(@neutron_plugin_ml2)
    expect(dependency[0].source).to eq(package)
  end

end
