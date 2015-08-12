require 'puppet'
require 'puppet/type/neutron_vpnaas_agent_config'

describe 'Puppet::Type.type(:neutron_vpnaas_agent_config)' do

  before :each do
    @neutron_vpnaas_agent_config = Puppet::Type.type(:neutron_vpnaas_agent_config).new(:name => 'DEFAULT/foo', :value => 'bar')
  end

  it 'should autorequire the package that install the file' do
    catalog = Puppet::Resource::Catalog.new
    package1 = Puppet::Type.type(:package).new(:name => 'neutron')
    package2 = Puppet::Type.type(:package).new(:name => 'neutron-vpnaas-agent')
    catalog.add_resource package1, package2, @neutron_vpnaas_agent_config
    dependency = @neutron_vpnaas_agent_config.autorequire
    expect(dependency.size).to eq(2)
    expect(dependency[0].target).to eq(@neutron_vpnaas_agent_config)
    expect(dependency[0].source).to eq(package1)
    expect(dependency[1].target).to eq(@neutron_vpnaas_agent_config)
    expect(dependency[1].source).to eq(package2)
  end

end
