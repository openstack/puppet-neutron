require 'spec_helper'
# this hack is required for now to ensure that the path is set up correctly
# to retrive the parent provider
$LOAD_PATH.push(
  File.join(
    File.dirname(__FILE__),
    '..',
    '..',
    'fixtures',
    'modules',
    'inifile',
    'lib')
)
require 'puppet/type/neutron_api_paste_ini'
describe 'Puppet::Type.type(:neutron_api_paste_ini)' do
  before :each do
    @neutron_api_paste_ini = Puppet::Type.type(:neutron_api_paste_ini).new(:name => 'DEFAULT/foo', :value => 'bar')
  end
  it 'should accept a valid value' do
    @neutron_api_paste_ini[:value] = 'bar'
    expect(@neutron_api_paste_ini[:value]).to eq('bar')
  end

  it 'should autorequire the package that install the file' do
    catalog = Puppet::Resource::Catalog.new
    package = Puppet::Type.type(:package).new(:name => 'neutron')
    catalog.add_resource package, @neutron_api_paste_ini
    dependency = @neutron_api_paste_ini.autorequire
    expect(dependency.size).to eq(1)
    expect(dependency[0].target).to eq(@neutron_api_paste_ini)
    expect(dependency[0].source).to eq(package)
  end

end
