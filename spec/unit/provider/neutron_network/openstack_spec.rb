require 'puppet'
require 'spec_helper'
require 'puppet/provider/neutron_network/openstack'

provider_class = Puppet::Type.type(:neutron_network).provider(:openstack)

describe provider_class do

  let(:set_env) do
    ENV['OS_USERNAME']     = 'test'
    ENV['OS_PASSWORD']     = 'abc123'
    ENV['OS_PROJECT_NAME'] = 'test'
    ENV['OS_AUTH_URL']     = 'http://127.0.0.1:5000'
  end

  describe 'manage networks' do
    let :net_name do
      'net1'
    end

    let :net_attrs do
      {
        :name   => net_name,
        :ensure => 'present',
      }
    end

    let :resource do
      Puppet::Type::Neutron_network.new(net_attrs)
    end

    let :provider do
      provider_class.new(resource)
    end

    before :each do
      set_env
    end

    describe '#create' do
      context 'with defaults' do
        it 'creates network' do
          expect(provider_class).to receive(:openstack)
            .with('network', 'create', '--format', 'shell',
                  ['net1'])
            .and_return('admin_state_up="True"
availability_zone_hints="[]"
id="076520cc-b783-4cf5-a4a9-4cb5a5e93a9b"
project_id="60f9544eb94c42a6b7e8e98c2be981b1"
router_external="False"
shared="False"
mtu="1500"')
          provider.create
          expect(provider.exists?).to be_truthy
          expect(provider.admin_state_up).to eq('True')
          expect(provider.project_id).to eq('60f9544eb94c42a6b7e8e98c2be981b1')
          expect(provider.router_external).to eq('False')
          expect(provider.shared).to eq('False')
          expect(provider.mtu).to eq('1500')
        end
      end

      context 'with admin_state_up' do
        let :net_attrs do
          {
            :name           => net_name,
            :ensure         => 'present',
            :admin_state_up => 'False',
          }
        end

        it 'creates network' do
          expect(provider_class).to receive(:openstack)
            .with('network', 'create', '--format', 'shell',
                  ['net1', '--disable'])
            .and_return('admin_state_up="False"
availability_zone_hints="[]"
id="076520cc-b783-4cf5-a4a9-4cb5a5e93a9b"
project_id="60f9544eb94c42a6b7e8e98c2be981b1"
router_external="False"
shared="False"
mtu="1500"')
          provider.create
          expect(provider.exists?).to be_truthy
          expect(provider.admin_state_up).to eq('False')
        end
      end

      context 'with shared' do
        let :net_attrs do
          {
            :name   => net_name,
            :ensure => 'present',
            :shared => 'True',
          }
        end

        it 'creates network' do
          expect(provider_class).to receive(:openstack)
            .with('network', 'create', '--format', 'shell',
                  ['net1', '--share'])
            .and_return('admin_state_up="True"
availability_zone_hints="[]"
id="076520cc-b783-4cf5-a4a9-4cb5a5e93a9b"
project_id="60f9544eb94c42a6b7e8e98c2be981b1"
router_external="False"
shared="True"
mtu="1500"')
          provider.create
          expect(provider.exists?).to be_truthy
          expect(provider.shared).to eq('True')
        end
      end

      context 'with project_name' do
        let :net_attrs do
          {
            :name         => net_name,
            :ensure       => 'present',
            :project_name => 'openstack',
          }
        end

        it 'creates network' do
          expect(provider_class).to receive(:openstack)
            .with('network', 'create', '--format', 'shell',
                  ['net1', '--project=openstack'])
            .and_return('admin_state_up="True"
availability_zone_hints="[]"
id="076520cc-b783-4cf5-a4a9-4cb5a5e93a9b"
project_id="60f9544eb94c42a6b7e8e98c2be981b1"
router_external="False"
shared="False"
mtu="1500"')
          provider.create
          expect(provider.exists?).to be_truthy
        end
      end

      context 'with provider_network' do
        let :net_attrs do
          {
            :name                      => net_name,
            :ensure                    => 'present',
            :provider_network_type     => 'vlan',
            :provider_physical_network => 'datacentre',
            :provider_segmentation_id  => 10,
          }
        end

        it 'creates network' do
          expect(provider_class).to receive(:openstack)
            .with('network', 'create', '--format', 'shell',
                  ['net1', '--provider-network-type=vlan',
                   '--provider-physical-network=datacentre',
                   '--provider-segmentation-id=10'])
            .and_return('admin_state_up="True"
availability_zone_hints="[]"
id="076520cc-b783-4cf5-a4a9-4cb5a5e93a9b"
project_id="60f9544eb94c42a6b7e8e98c2be981b1"
provider_network_type="vlan"
provider_physical_network="datacentre"
provider_segmentation_id="10"
router_external="False"
shared="False"
mtu="1500"')
          provider.create
          expect(provider.exists?).to be_truthy
          expect(provider.provider_network_type).to eq('vlan')
          expect(provider.provider_physical_network).to eq('datacentre')
          expect(provider.provider_segmentation_id).to eq('10')
        end
      end

      context 'with router_external' do
        let :net_attrs do
          {
            :name            => net_name,
            :ensure          => 'present',
            :router_external => 'True',
          }
        end

        it 'creates network' do
          expect(provider_class).to receive(:openstack)
            .with('network', 'create', '--format', 'shell',
                  ['net1', '--external'])
            .and_return('admin_state_up="True"
availability_zone_hints="[]"
id="076520cc-b783-4cf5-a4a9-4cb5a5e93a9b"
project_id="60f9544eb94c42a6b7e8e98c2be981b1"
router_external="True"
shared="False"
mtu="1500"')
          provider.create
          expect(provider.exists?).to be_truthy
          expect(provider.router_external).to eq('True')
        end
      end

      context 'with mtu' do
        let :net_attrs do
          {
            :name => net_name,
            :mtu  => 9000,
          }
        end

        it 'creates network' do
          expect(provider_class).to receive(:openstack)
            .with('network', 'create', '--format', 'shell',
                  ['net1', '--mtu=9000'])
            .and_return('admin_state_up="True"
availability_zone_hints="[]"
id="076520cc-b783-4cf5-a4a9-4cb5a5e93a9b"
project_id="60f9544eb94c42a6b7e8e98c2be981b1"
router_external="True"
shared="False"
mtu="9000"')
          provider.create
          expect(provider.exists?).to be_truthy
          expect(provider.mtu).to eq('9000')
        end
      end
    end

    describe '#destroy' do
      it 'removes network' do
        expect(provider_class).to receive(:openstack)
          .with('network', 'delete', 'net1')
        provider.destroy
        expect(provider.exists?).to be_falsey
      end
    end

    describe '#flush' do
      context '.admin_state_up' do
        it 'updates network' do
          expect(provider_class).to receive(:openstack)
            .with('network', 'set', ['net1', '--disable'])
          provider.admin_state_up = 'False'
          provider.flush

          expect(provider_class).to receive(:openstack)
            .with('network', 'set', ['net1', '--enable'])
          provider.admin_state_up = 'True'
          provider.flush
        end
      end

      context '.shared' do
        it 'updates network' do
          expect(provider_class).to receive(:openstack)
            .with('network', 'set', ['net1', '--share'])
          provider.shared = 'True'
          provider.flush

          expect(provider_class).to receive(:openstack)
            .with('network', 'set', ['net1', '--no-share'])
          provider.shared = 'False'
          provider.flush
        end
      end

      context '.router_external' do
        it 'updates network' do
          expect(provider_class).to receive(:openstack)
            .with('network', 'set', ['net1', '--external'])
          provider.router_external = 'True'
          provider.flush

          expect(provider_class).to receive(:openstack)
            .with('network', 'set', ['net1', '--internal'])
          provider.router_external = 'False'
          provider.flush
        end
      end

      context '.mtu' do
        it 'updates mtu' do
          expect(provider_class).to receive(:openstack)
            .with('network', 'set', ['net1', '--mtu=1490'])
          provider.mtu = 1490
          provider.flush
        end
      end
    end

    describe '#instances' do
      it 'lists networks' do
        expect(provider_class).to receive(:openstack)
          .with('network', 'list', '--quiet', '--format', 'csv', [])
          .and_return('"ID","Name","Subnets"
"076520cc-b783-4cf5-a4a9-4cb5a5e93a9b","net1","[\'dd5e0ef1-2c88-4b0b-ba08-7df65be87963\']",
"34e8f42b-89db-4a5b-92db-76ca7073414d","net2","[\'0da7a631-0f8f-4e51-8b1c-7a29d0d4f7b5\']",
')
        expect(provider_class).to receive(:openstack)
          .with('network', 'show', '--format', 'shell',
                '076520cc-b783-4cf5-a4a9-4cb5a5e93a9b')
          .and_return('admin_state_up="True"
availability_zone_hints="[]"
id="076520cc-b783-4cf5-a4a9-4cb5a5e93a9b"
project_id="60f9544eb94c42a6b7e8e98c2be981b1"
router_external="False"
shared="False"
mtu="1500"')
        expect(provider_class).to receive(:openstack)
          .with('network', 'show', '--format', 'shell',
                '34e8f42b-89db-4a5b-92db-76ca7073414d')
          .and_return('admin_state_up="False"
availability_zone_hints="[]"
id="34e8f42b-89db-4a5b-92db-76ca7073414d"
project_id="60f9544eb94c42a6b7e8e98c2be981b1"
router_external="True"
shared="True"
mtu="9000"')

        instances = provider_class.instances
        expect(instances.length).to eq(2)

        expect(instances[0].id).to eq('076520cc-b783-4cf5-a4a9-4cb5a5e93a9b')
        expect(instances[0].name).to eq('net1')
        expect(instances[0].admin_state_up).to eq('True')
        expect(instances[0].router_external).to eq('False')
        expect(instances[0].project_id).to eq('60f9544eb94c42a6b7e8e98c2be981b1')
        expect(instances[0].shared).to eq('False')
        expect(instances[0].mtu).to eq('1500')

        expect(instances[1].id).to eq('34e8f42b-89db-4a5b-92db-76ca7073414d')
        expect(instances[1].name).to eq('net2')
        expect(instances[1].admin_state_up).to eq('False')
        expect(instances[1].project_id).to eq('60f9544eb94c42a6b7e8e98c2be981b1')
        expect(instances[1].router_external).to eq('True')
        expect(instances[1].shared).to eq('True')
        expect(instances[1].mtu).to eq('9000')
      end
    end
  end
end
