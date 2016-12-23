require 'puppet'
require 'puppet/type/neutron_rootwrap_config'

describe 'Puppet::Type.type(:neutron_rootwrap_config)' do

  before :each do
    @neutron_rootwrap_config = Puppet::Type.type(:neutron_rootwrap_config).new(:name => 'DEFAULT/foo', :value => 'bar')
  end

  it 'should autorequire the package that install the file' do
    catalog = Puppet::Resource::Catalog.new
    package = Puppet::Type.type(:package).new(:name => 'neutron-common')
    catalog.add_resource package, @neutron_rootwrap_config
    dependency = @neutron_rootwrap_config.autorequire
    expect(dependency.size).to eq(1)
    expect(dependency[0].target).to eq(@neutron_rootwrap_config)
    expect(dependency[0].source).to eq(package)
  end

end
