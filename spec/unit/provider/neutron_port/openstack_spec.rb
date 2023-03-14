require 'puppet'
require 'spec_helper'
require 'puppet/provider/neutron_port/openstack'

provider_class = Puppet::Type.type(:neutron_port).provider(:openstack)

describe provider_class do

  let(:set_env) do
    ENV['OS_USERNAME']     = 'test'
    ENV['OS_PASSWORD']     = 'abc123'
    ENV['OS_PROJECT_NAME'] = 'test'
    ENV['OS_AUTH_URL']     = 'http://127.0.0.1:5000'
  end

  describe 'manage ports' do
    let :port_name do
      'port1'
    end

    let :port_attrs do
      {
        :ensure       => 'present',
        :name         => port_name,
        :network_name => 'net1',
      }
    end

    let :resource do
      Puppet::Type::Neutron_port.new(port_attrs)
    end

    let :provider do
      provider_class.new(resource)
    end

    before :each do
      set_env
    end

    describe '#create' do
      context 'with defaults' do
        it 'creates port' do
          expect(provider_class).to receive(:openstack)
            .with('port', 'create', '--format', 'shell',
                  ['port1', '--network=net1'])
            .and_return('admin_state_up="True"
allowed_address_pairs="[]"
binding_host_id=""
binding_profile="{}"
device_id=""
device_owner=""
fixed_ips="[{\'subnet_id\': \'dd5e0ef1-2c88-4b0b-ba08-7df65be87963\', \'ip_address\': \'10.0.0.2\'}]"
id="5222573b-314d-45f9-b6bd-299288ba667a"
mac_address="fa:16:3e:45:3c:10"
name="port1"
network_id="076520cc-b783-4cf5-a4a9-4cb5a5e93a9b"
project_id="60f9544eb94c42a6b7e8e98c2be981b1"
security_groups="f1f0c3a3-9f2c-46b9-b2a5-b97d9a87bd7e"
status="ACTIVE"')
          expect(provider_class).to receive(:openstack)
            .with('network', 'show', '--format', 'shell',
                  ['076520cc-b783-4cf5-a4a9-4cb5a5e93a9b'])
            .and_return('id="076520cc-b783-4cf5-a4a9-4cb5a5e93a9b"
name="net1"')
          expect(provider_class).to receive(:openstack)
            .with('subnet', 'show', '--format', 'shell',
                  ['dd5e0ef1-2c88-4b0b-ba08-7df65be87963'])
            .and_return('id="dd5e0ef1-2c88-4b0b-ba08-7df65be87963"
name="subnet1"')
          provider.create
          expect(provider.exists?).to be_truthy
          expect(provider.admin_state_up).to eq('True')
          expect(provider.ip_address).to eq('10.0.0.2')
          expect(provider.network_name).to eq('net1')
          expect(provider.subnet_id).to eq('dd5e0ef1-2c88-4b0b-ba08-7df65be87963')
          expect(provider.subnet_name).to eq('subnet1')
        end
      end

      context 'with admin_state_up' do
        let :port_attrs do
          {
            :ensure         => 'present',
            :name           => port_name,
            :network_name   => 'net1',
            :admin_state_up => 'False',
          }
        end

        it 'creates port' do
          expect(provider_class).to receive(:openstack)
            .with('port', 'create', '--format', 'shell',
                  ['port1', '--network=net1', '--disable'])
            .and_return('admin_state_up="False"
allowed_address_pairs="[]"
binding_host_id=""
binding_profile="{}"
device_id=""
device_owner=""
fixed_ips="[{\'subnet_id\': \'dd5e0ef1-2c88-4b0b-ba08-7df65be87963\', \'ip_address\': \'10.0.0.2\'}]"
id="5222573b-314d-45f9-b6bd-299288ba667a"
mac_address="fa:16:3e:45:3c:10"
name="port1"
network_id="076520cc-b783-4cf5-a4a9-4cb5a5e93a9b"
project_id="60f9544eb94c42a6b7e8e98c2be981b1"
security_groups="f1f0c3a3-9f2c-46b9-b2a5-b97d9a87bd7e"
status="ACTIVE"')
          expect(provider_class).to receive(:openstack)
            .with('network', 'show', '--format', 'shell',
                  ['076520cc-b783-4cf5-a4a9-4cb5a5e93a9b'])
            .and_return('id="076520cc-b783-4cf5-a4a9-4cb5a5e93a9b"
name="net1"')
          expect(provider_class).to receive(:openstack)
            .with('subnet', 'show', '--format', 'shell',
                  ['dd5e0ef1-2c88-4b0b-ba08-7df65be87963'])
            .and_return('id="dd5e0ef1-2c88-4b0b-ba08-7df65be87963"
name="subnet1"')
          provider.create
          expect(provider.exists?).to be_truthy
          expect(provider.admin_state_up).to eq('False')
          expect(provider.ip_address).to eq('10.0.0.2')
          expect(provider.network_name).to eq('net1')
          expect(provider.subnet_id).to eq('dd5e0ef1-2c88-4b0b-ba08-7df65be87963')
          expect(provider.subnet_name).to eq('subnet1')
        end
      end

      context 'with subnet' do
        let :port_attrs do
          {
            :ensure       => 'present',
            :name         => port_name,
            :network_name => 'net1',
            :subnet_name  => 'subnet1',
          }
        end

        it 'creates port' do
          expect(provider_class).to receive(:openstack)
            .with('port', 'create', '--format', 'shell',
                  ['port1', '--network=net1',
                   '--fixed-ip subnet=subnet1'])
            .and_return('admin_state_up="True"
allowed_address_pairs="[]"
binding_host_id=""
binding_profile="{}"
device_id=""
device_owner=""
fixed_ips="[{\'subnet_id\': \'dd5e0ef1-2c88-4b0b-ba08-7df65be87963\', \'ip_address\': \'10.0.0.2\'}]"
id="5222573b-314d-45f9-b6bd-299288ba667a"
mac_address="fa:16:3e:45:3c:10"
name="port1"
network_id="076520cc-b783-4cf5-a4a9-4cb5a5e93a9b"
project_id="60f9544eb94c42a6b7e8e98c2be981b1"
security_groups="f1f0c3a3-9f2c-46b9-b2a5-b97d9a87bd7e"
status="ACTIVE"')
          expect(provider_class).to receive(:openstack)
            .with('network', 'show', '--format', 'shell',
                  ['076520cc-b783-4cf5-a4a9-4cb5a5e93a9b'])
            .and_return('id="076520cc-b783-4cf5-a4a9-4cb5a5e93a9b"
name="net1"')
          expect(provider_class).to receive(:openstack)
            .with('subnet', 'show', '--format', 'shell',
                  ['dd5e0ef1-2c88-4b0b-ba08-7df65be87963'])
            .and_return('id="dd5e0ef1-2c88-4b0b-ba08-7df65be87963"
name="subnet1"')
          provider.create
          expect(provider.exists?).to be_truthy
          expect(provider.admin_state_up).to eq('True')
          expect(provider.ip_address).to eq('10.0.0.2')
          expect(provider.network_name).to eq('net1')
          expect(provider.subnet_id).to eq('dd5e0ef1-2c88-4b0b-ba08-7df65be87963')
          expect(provider.subnet_name).to eq('subnet1')
        end
      end

      context 'with binding profile' do
        let :port_attrs do
          {
            :ensure          => 'present',
            :name            => port_name,
            :binding_host_id => 'myhost',
            :binding_profile => {'key1' => 'val1'},
            :network_name    => 'net1',
          }
        end

        it 'creates port' do
          expect(provider_class).to receive(:openstack)
            .with('port', 'create', '--format', 'shell',
                  ['port1', '--network=net1', '--host=myhost',
                   '--binding-profile key1=val1'])
            .and_return('admin_state_up="True"
allowed_address_pairs="[]"
binding_host_id="myhost"
binding_profile="{\'key1\': \'val1\'}"
device_id=""
device_owner=""
fixed_ips="[{\'subnet_id\': \'dd5e0ef1-2c88-4b0b-ba08-7df65be87963\', \'ip_address\': \'10.0.0.2\'}]"
id="5222573b-314d-45f9-b6bd-299288ba667a"
mac_address="fa:16:3e:45:3c:10"
name="port1"
network_id="076520cc-b783-4cf5-a4a9-4cb5a5e93a9b"
project_id="60f9544eb94c42a6b7e8e98c2be981b1"
security_groups="f1f0c3a3-9f2c-46b9-b2a5-b97d9a87bd7e"
status="ACTIVE"')
          expect(provider_class).to receive(:openstack)
            .with('network', 'show', '--format', 'shell',
                  ['076520cc-b783-4cf5-a4a9-4cb5a5e93a9b'])
            .and_return('id="076520cc-b783-4cf5-a4a9-4cb5a5e93a9b"
name="net1"')
          expect(provider_class).to receive(:openstack)
            .with('subnet', 'show', '--format', 'shell',
                  ['dd5e0ef1-2c88-4b0b-ba08-7df65be87963'])
            .and_return('id="dd5e0ef1-2c88-4b0b-ba08-7df65be87963"
name="subnet1"')
          provider.create
          expect(provider.exists?).to be_truthy
          expect(provider.ip_address).to eq('10.0.0.2')
          expect(provider.network_name).to eq('net1')
          expect(provider.subnet_id).to eq('dd5e0ef1-2c88-4b0b-ba08-7df65be87963')
          expect(provider.subnet_name).to eq('subnet1')
        end
      end

    end

    describe '#destroy' do
      it 'removes port' do
        expect(provider_class).to receive(:openstack)
          .with('port', 'delete', 'port1')
        provider.destroy
        expect(provider.exists?).to be_falsey
      end
    end

    describe '#flush' do
      context 'admin_state_up' do
        it 'updates port' do
          expect(provider_class).to receive(:openstack)
            .with('port', 'set', ['port1', '--disable'])
          provider.admin_state_up = 'False'
          provider.flush

          expect(provider_class).to receive(:openstack)
            .with('port', 'set', ['port1', '--enable'])
          provider.admin_state_up = 'True'
          provider.flush
        end
      end
    end

    describe '#list' do
      it 'lists ports' do
        expect(provider_class).to receive(:openstack)
          .with('port', 'list', '--quiet', '--format', 'csv', [])
          .and_return('"ID","Name","MAC Address","Fixed IP Addresses","Status"
"5222573b-314d-45f9-b6bd-299288ba667a","port1","fa:16:3e:45:3c:10","[{\'subnet_id\': \'dd5e0ef1-2c88-4b0b-ba08-7df65be87963\', \'ip_address\': \'10.0.0.2\'}]","ACTIVE"
"c880affb-b15e-4632-b5e7-3adba6e3ab35","port2","fa:16:3e:45:3c:11","[{\'subnet_id\': \'0da7a631-0f8f-4e51-8b1c-7a29d0d4f7b5\', \'ip_address\': \'10.0.1.2\'}]","DOWN"
')

        expect(provider_class).to receive(:openstack)
          .with('port', 'show', '--format', 'shell', '5222573b-314d-45f9-b6bd-299288ba667a')
          .and_return('admin_state_up="True"
allowed_address_pairs="[]"
binding_host_id=""
binding_profile="{}"
device_id=""
device_owner=""
fixed_ips="[{\'subnet_id\': \'dd5e0ef1-2c88-4b0b-ba08-7df65be87963\', \'ip_address\': \'10.0.0.2\'}]"
id="5222573b-314d-45f9-b6bd-299288ba667a"
mac_address="fa:16:3e:45:3c:10"
name="port1"
network_id="076520cc-b783-4cf5-a4a9-4cb5a5e93a9b"
project_id="60f9544eb94c42a6b7e8e98c2be981b1"
security_groups="f1f0c3a3-9f2c-46b9-b2a5-b97d9a87bd7e"
status="ACTIVE"')
        expect(provider_class).to receive(:openstack)
          .with('network', 'show', '--format', 'shell', ['076520cc-b783-4cf5-a4a9-4cb5a5e93a9b'])
          .and_return('name="net1"')
        expect(provider_class).to receive(:openstack)
          .with('subnet', 'show', '--format', 'shell', ['dd5e0ef1-2c88-4b0b-ba08-7df65be87963'])
          .and_return('name="subnet1"')

        expect(provider_class).to receive(:openstack)
          .with('port', 'show', '--format', 'shell', 'c880affb-b15e-4632-b5e7-3adba6e3ab35')
          .and_return('admin_state_up="False"
allowed_address_pairs="[]"
binding_host_id=""
binding_profile="{}"
device_id=""
device_owner=""
fixed_ips="[{\'subnet_id\': \'0da7a631-0f8f-4e51-8b1c-7a29d0d4f7b5\', \'ip_address\': \'10.0.1.2\'}]"
id="c880affb-b15e-4632-b5e7-3adba6e3ab35"
mac_address="fa:16:3e:45:3c:11"
name="port2"
network_id="34e8f42b-89db-4a5b-92db-76ca7073414d"
project_id="60f9544eb94c42a6b7e8e98c2be981b1"
security_groups="f1f0c3a3-9f2c-46b9-b2a5-b97d9a87bd7e"
status="DOWN"')
        expect(provider_class).to receive(:openstack)
          .with('network', 'show', '--format', 'shell', ['34e8f42b-89db-4a5b-92db-76ca7073414d'])
          .and_return('name="net2"')
        expect(provider_class).to receive(:openstack)
          .with('subnet', 'show', '--format', 'shell', ['0da7a631-0f8f-4e51-8b1c-7a29d0d4f7b5'])
          .and_return('name="subnet2"')

        instances = provider_class.instances
        expect(instances.length).to eq(2)

        expect(instances[0].id).to eq('5222573b-314d-45f9-b6bd-299288ba667a')
        expect(instances[0].name).to eq('port1')
        expect(instances[0].network_id).to eq('076520cc-b783-4cf5-a4a9-4cb5a5e93a9b')
        expect(instances[0].network_name).to eq('net1')
        expect(instances[0].subnet_id).to eq('dd5e0ef1-2c88-4b0b-ba08-7df65be87963')
        expect(instances[0].subnet_name).to eq('subnet1')
        expect(instances[0].status).to eq('ACTIVE')
        expect(instances[0].admin_state_up).to eq('True')
        expect(instances[0].project_id).to eq('60f9544eb94c42a6b7e8e98c2be981b1')

        expect(instances[1].id).to eq('c880affb-b15e-4632-b5e7-3adba6e3ab35')
        expect(instances[1].name).to eq('port2')
        expect(instances[1].network_id).to eq('34e8f42b-89db-4a5b-92db-76ca7073414d')
        expect(instances[1].network_name).to eq('net2')
        expect(instances[1].subnet_id).to eq('0da7a631-0f8f-4e51-8b1c-7a29d0d4f7b5')
        expect(instances[1].subnet_name).to eq('subnet2')
        expect(instances[1].status).to eq('DOWN')
        expect(instances[1].admin_state_up).to eq('False')
        expect(instances[0].project_id).to eq('60f9544eb94c42a6b7e8e98c2be981b1')
      end
    end
  end
end
