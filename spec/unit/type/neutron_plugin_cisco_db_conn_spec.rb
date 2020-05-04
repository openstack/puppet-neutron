require 'puppet'
require 'puppet/type/neutron_plugin_cisco_db_conn'

describe 'Puppet::Type.type(:neutron_plugin_cisco_db_conn)' do

  before :each do
    @neutron_plugin_cisco_db_conn = Puppet::Type.type(:neutron_plugin_cisco_db_conn).new(:name => 'DEFAULT/foo', :value => 'bar')
  end

  it 'should autorequire the package that install the file' do
    catalog = Puppet::Resource::Catalog.new
    anchor = Puppet::Type.type(:anchor).new(:name => 'neutron::install::end')
    catalog.add_resource anchor, @neutron_plugin_cisco_db_conn
    dependency = @neutron_plugin_cisco_db_conn.autorequire
    expect(dependency.size).to eq(1)
    expect(dependency[0].target).to eq(@neutron_plugin_cisco_db_conn)
    expect(dependency[0].source).to eq(anchor)
  end

end
