require 'puppet'
require 'puppet/type/ironic_neutron_agent_config'

describe 'Puppet::Type.type(:ironic_neutron_agent_config)' do

  before :each do
    @ironic_neutron_agent_config = Puppet::Type.type(:ironic_neutron_agent_config).new(:name => 'DEFAULT/foo', :value => 'bar')
  end

  it 'should autorequire the package that install the file' do
    catalog = Puppet::Resource::Catalog.new
    package = Puppet::Type.type(:package).new(:name => 'python2-ironic-neutron-agent')
    catalog.add_resource package, @ironic_neutron_agent_config
    dependency = @ironic_neutron_agent_config.autorequire
    expect(dependency.size).to eq(1)
    expect(dependency[0].target).to eq(@ironic_neutron_agent_config)
    expect(dependency[0].source).to eq(package)
  end

end
