require 'puppet'
require 'puppet/type/neutron_plugin_cisco_credentials'

describe 'Puppet::Type.type(:neutron_plugin_cisco_credentials)' do

  before :each do
    @neutron_plugin_cisco_credentials = Puppet::Type.type(:neutron_plugin_cisco_credentials).new(:name => 'DEFAULT/foo', :value => 'bar')
  end

  it 'should autorequire the package that install the file' do
    catalog = Puppet::Resource::Catalog.new
    package = Puppet::Type.type(:package).new(:name => 'neutron-plugin-cisco')
    catalog.add_resource package, @neutron_plugin_cisco_credentials
    dependency = @neutron_plugin_cisco_credentials.autorequire
    expect(dependency.size).to eq(1)
    expect(dependency[0].target).to eq(@neutron_plugin_cisco_credentials)
    expect(dependency[0].source).to eq(package)
  end

end
