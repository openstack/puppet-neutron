$LOAD_PATH.push(
  File.join(
    File.dirname(__FILE__),
    '..',
    '..',
    '..',
    'fixtures',
    'modules',
    'inifile',
    'lib')
)
$LOAD_PATH.push(
  File.join(
    File.dirname(__FILE__),
    '..',
    '..',
    '..',
    'fixtures',
    'modules',
    'openstacklib',
    'lib')
)

require 'spec_helper'

provider_class = Puppet::Type.type(:neutron_agent_ovs).provider(:ini_setting)
describe provider_class do
  let(:resource ) do
    Puppet::Type::Neutron_agent_ovs.new({
      :name => 'DEFAULT/foo',
      :value => 'bar',
    })
  end

  let (:provider) { resource.provider }

  [ 'RedHat', 'Debian', 'Ubuntu' ].each do |os|
    context "on #{os} with default setting" do
      it 'it should fall back to default and use plugins/ml2/openvswitch_agent.ini' do
        Facter.fact(:operatingsystem).stubs(:value).returns("#{os}")
        expect(provider.section).to eq('DEFAULT')
        expect(provider.setting).to eq('foo')
        expect(provider.file_path).to eq('/etc/neutron/plugins/ml2/openvswitch_agent.ini')
      end
    end
  end
end
