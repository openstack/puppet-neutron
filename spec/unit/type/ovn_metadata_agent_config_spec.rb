require 'puppet'
require 'puppet/type/ovn_metadata_agent_config'

describe 'Puppet::Type.type(:ovn_metadata_agent_config)' do

  before :each do
    @ovn_metadata_agent_config = Puppet::Type.type(:ovn_metadata_agent_config).new(:name => 'DEFAULT/foo', :value => 'bar')
  end

  it 'should autorequire the package that install the file' do
    catalog = Puppet::Resource::Catalog.new
    package = Puppet::Type.type(:package).new(:name => 'networking-ovn-metadata-agent')
    catalog.add_resource package, @ovn_metadata_agent_config
    dependency = @ovn_metadata_agent_config.autorequire
    expect(dependency.size).to eq(1)
    expect(dependency[0].target).to eq(@ovn_metadata_agent_config)
    expect(dependency[0].source).to eq(package)
  end

end
