require 'puppet'
require 'spec_helper'
require 'puppet/provider/neutron_router/openstack'

provider_class = Puppet::Type.type(:neutron_router).provider(:openstack)

describe provider_class do

  let(:set_env) do
    ENV['OS_USERNAME']     = 'test'
    ENV['OS_PASSWORD']     = 'abc123'
    ENV['OS_PROJECT_NAME'] = 'test'
    ENV['OS_AUTH_URL']     = 'http://127.0.0.1:5000'
  end

  describe 'manage routers' do
    let :router_name do
      'router1'
    end

    let :router_attrs do
      {
        :name   => router_name,
        :ensure => 'present',
      }
    end

    let :resource do
      Puppet::Type::Neutron_router.new(router_attrs)
    end

    let :provider do
      provider_class.new(resource)
    end

    before :each do
      set_env
    end

    describe '#create' do
      context 'with defaults' do
        it 'creates router' do
          expect(provider_class).to receive(:openstack)
            .with('router', 'create', '--format', 'shell',
                  ['router1'])
            .and_return('admin_state_up="True"
availability_zone_hints="[]"
distributed="False"
external_gateway_info="None"
ha="True"
id="d73f453a-77ca-4843-977a-3af0fda8dfcb"
name="router1"
project_id="60f9544eb94c42a6b7e8e98c2be981b1"
status="ACTIVE"')
          provider.create
          expect(provider.exists?).to be_truthy
          expect(provider.admin_state_up).to eq('True')
          expect(provider.ha).to eq('True')
          expect(provider.distributed).to eq('False')
          expect(provider.status).to eq('ACTIVE')
        end
      end

      context 'with admin_state_up' do
        let :router_attrs do
          {
            :name           => router_name,
            :ensure         => 'present',
            :admin_state_up => 'False',
          }
        end
        it 'creates router' do
          expect(provider_class).to receive(:openstack)
            .with('router', 'create', '--format', 'shell',
                  ['router1', '--disable'])
            .and_return('admin_state_up="False"
availability_zone_hints="[]"
distributed="False"
external_gateway_info="None"
ha="True"
id="d73f453a-77ca-4843-977a-3af0fda8dfcb"
name="router1"
project_id="60f9544eb94c42a6b7e8e98c2be981b1"
status="ACTIVE"')
          provider.create
          expect(provider.exists?).to be_truthy
          expect(provider.admin_state_up).to eq('False')
        end
      end

      context 'with centralized' do
        let :router_attrs do
          {
            :name        => router_name,
            :ensure      => 'present',
            :distributed => 'False',
          }
        end
        it 'creates router' do
          expect(provider_class).to receive(:openstack)
            .with('router', 'create', '--format', 'shell',
                  ['router1', '--centralized'])
            .and_return('admin_state_up="True"
availability_zone_hints="[]"
distributed="False"
external_gateway_info="None"
ha="True"
id="d73f453a-77ca-4843-977a-3af0fda8dfcb"
name="router1"
project_id="60f9544eb94c42a6b7e8e98c2be981b1"
status="ACTIVE"')
          provider.create
          expect(provider.exists?).to be_truthy
          expect(provider.distributed).to eq('False')
        end
      end

      context 'with distributed' do
        let :router_attrs do
          {
            :name        => router_name,
            :ensure      => 'present',
            :distributed => 'True',
          }
        end
        it 'creates router' do
          expect(provider_class).to receive(:openstack)
            .with('router', 'create', '--format', 'shell',
                  ['router1', '--distributed'])
            .and_return('admin_state_up="True"
availability_zone_hints="[]"
distributed="True"
external_gateway_info="None"
ha="True"
id="d73f453a-77ca-4843-977a-3af0fda8dfcb"
name="router1"
project_id="60f9544eb94c42a6b7e8e98c2be981b1"
status="ACTIVE"')
          provider.create
          expect(provider.exists?).to be_truthy
          expect(provider.distributed).to eq('True')
        end
      end

      context 'with ha' do
        let :router_attrs do
          {
            :name   => router_name,
            :ensure => 'present',
            :ha     => 'True',
          }
        end
        it 'creates router' do
          expect(provider_class).to receive(:openstack)
            .with('router', 'create', '--format', 'shell',
                  ['router1', '--ha'])
            .and_return('admin_state_up="True"
availability_zone_hints="[]"
distributed="False"
external_gateway_info="None"
ha="True"
id="d73f453a-77ca-4843-977a-3af0fda8dfcb"
name="router1"
project_id="60f9544eb94c42a6b7e8e98c2be981b1"
status="ACTIVE"')
          provider.create
          expect(provider.exists?).to be_truthy
          expect(provider.ha).to eq('True')
        end
      end

      context 'with non-ha' do
        let :router_attrs do
          {
            :name   => router_name,
            :ensure => 'present',
            :ha     => 'False',
          }
        end
        it 'creates router' do
          expect(provider_class).to receive(:openstack)
            .with('router', 'create', '--format', 'shell',
                  ['router1', '--no-ha'])
            .and_return('admin_state_up="True"
availability_zone_hints="[]"
distributed="False"
external_gateway_info="None"
ha="False"
id="d73f453a-77ca-4843-977a-3af0fda8dfcb"
name="router1"
project_id="60f9544eb94c42a6b7e8e98c2be981b1"
status="ACTIVE"')
          provider.create
          expect(provider.exists?).to be_truthy
          expect(provider.ha).to eq('False')
        end
      end

      context 'with gateway_network_name' do
        let :router_attrs do
          {
            :name                 => router_name,
            :ensure               => 'present',
            :gateway_network_name => 'net1',
          }
        end
        it 'creates router' do
          expect(provider_class).to receive(:openstack)
            .with('router', 'create', '--format', 'shell',
                  ['router1'])
            .and_return('admin_state_up="True"
availability_zone_hints="[]"
distributed="False"
external_gateway_info="None"
ha="False"
id="d73f453a-77ca-4843-977a-3af0fda8dfcb"
name="router1"
project_id="60f9544eb94c42a6b7e8e98c2be981b1"
status="ACTIVE"')
          expect(provider_class).to receive(:openstack)
            .with('router', 'set', ['router1', '--external-gateway=net1'])
          expect(provider_class).to receive(:openstack)
            .with('router', 'show', '--format', 'shell',
                  ['router1'])
            .and_return('admin_state_up="True"
availability_zone_hints="[]"
distributed="False"
external_gateway_info="{\'network_id\': \'076520cc-b783-4cf5-a4a9-4cb5a5e93a9b\'}"
ha="False"
id="d73f453a-77ca-4843-977a-3af0fda8dfcb"
name="router1"
project_id="60f9544eb94c42a6b7e8e98c2be981b1"
status="ACTIVE"')
          provider.create
          expect(provider.exists?).to be_truthy
        end
      end
    end

    describe '#destroy' do
      it 'removes router' do
        expect(provider_class).to receive(:openstack)
          .with('router', 'delete', 'router1')
        provider.destroy
        expect(provider.exists?).to be_falsey
      end
    end

    describe '#flush' do
      context '.admin_state_up' do
        it 'updates router' do
          expect(provider_class).to receive(:openstack)
            .with('router', 'set', ['router1', '--disable'])
          provider.admin_state_up = 'False'
          provider.flush
          expect(provider_class).to receive(:openstack)
            .with('router', 'set', ['router1', '--enable'])
          provider.admin_state_up = 'True'
          provider.flush
        end
      end
      context '.distributed' do
        it 'updates router' do
          expect(provider_class).to receive(:openstack)
            .with('router', 'set', ['router1', '--distributed'])
          provider.distributed = 'True'
          provider.flush
          expect(provider_class).to receive(:openstack)
            .with('router', 'set', ['router1', '--centralized'])
          provider.distributed = 'False'
          provider.flush
        end
      end
      context '.ha' do
        it 'updates router' do
          expect(provider_class).to receive(:openstack)
            .with('router', 'set', ['router1', '--ha'])
          provider.ha = 'True'
          provider.flush
          expect(provider_class).to receive(:openstack)
            .with('router', 'set', ['router1', '--no-ha'])
          provider.ha = 'False'
          provider.flush
        end
      end
      context '.gateway_network_name' do
        it 'updates router' do
          expect(provider_class).to receive(:openstack)
            .with('router', 'set', ['router1', '--external-gateway=net1'])
          provider.gateway_network_name = 'net1'
          provider.flush
          expect(provider_class).to receive(:openstack)
            .with('router', 'unset', ['router1', '--external-gateway'])
          provider.gateway_network_name = ''
          provider.flush
        end
      end
    end

    describe '#instances' do
      it 'lists router' do
        expect(provider_class).to receive(:openstack)
          .with('router', 'list', '--quiet', '--format', 'csv', [])
          .and_return('"ID","Name","Status","State","Project","Distributed","HA"
"d73f453a-77ca-4843-977a-3af0fda8dfcb","router1","ACTIVE","True","60f9544eb94c42a6b7e8e98c2be981b1",True,False
"c3e93a5b-45ee-4029-b3a3-3331cb3e3f2a","router2","DOWN","False","60f9544eb94c42a6b7e8e98c2be981b1",False,True
')
        expect(provider_class).to receive(:openstack)
          .with('router', 'show', '--format', 'shell', 'd73f453a-77ca-4843-977a-3af0fda8dfcb')
          .and_return('admin_state_up="True"
availability_zone_hints="[]"
distributed="False"
external_gateway_info="None"
ha="True"
id="d73f453a-77ca-4843-977a-3af0fda8dfcb"
name="router1"
project_id="60f9544eb94c42a6b7e8e98c2be981b1"
status="ACTIVE"')
        expect(provider_class).to receive(:openstack)
          .with('router', 'show', '--format', 'shell', 'c3e93a5b-45ee-4029-b3a3-3331cb3e3f2a')
          .and_return('admin_state_up="False"
availability_zone_hints="[]"
distributed="True"
external_gateway_info="None"
ha="False"
id="c3e93a5b-45ee-4029-b3a3-3331cb3e3f2a"
name="router2"
project_id="60f9544eb94c42a6b7e8e98c2be981b1"
status="DOWN"')

        instances = provider_class.instances
        expect(instances.length).to eq(2)

        expect(instances[0].id).to eq('d73f453a-77ca-4843-977a-3af0fda8dfcb')
        expect(instances[0].name).to eq('router1')
        expect(instances[0].admin_state_up).to eq('True')
        expect(instances[0].ha).to eq('True')
        expect(instances[0].distributed).to eq('False')
        expect(instances[0].status).to eq('ACTIVE')

        expect(instances[1].id).to eq('c3e93a5b-45ee-4029-b3a3-3331cb3e3f2a')
        expect(instances[1].name).to eq('router2')
        expect(instances[1].admin_state_up).to eq('False')
        expect(instances[1].ha).to eq('False')
        expect(instances[1].distributed).to eq('True')
        expect(instances[1].status).to eq('DOWN')
      end
    end
  end
end
