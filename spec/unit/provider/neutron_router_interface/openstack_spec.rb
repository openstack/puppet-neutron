require 'puppet'
require 'spec_helper'
require 'puppet/provider/neutron_router_interface/openstack'

provider_class = Puppet::Type.type(:neutron_router_interface).provider(:openstack)

describe provider_class do

  let(:set_env) do
    ENV['OS_USERNAME']     = 'test'
    ENV['OS_PASSWORD']     = 'abc123'
    ENV['OS_PROJECT_NAME'] = 'test'
    ENV['OS_AUTH_URL']     = 'http://127.0.0.1:5000'
  end

  describe 'manage networks' do
    let :interface_name do
      'router1:subnet1'
    end

    let :interface_attrs do
      {
        :name   => interface_name,
        :ensure => 'present',
      }
    end

    let :resource do
      Puppet::Type::Neutron_router_interface.new(interface_attrs)
    end

    let :provider do
      provider_class.new(resource)
    end

    before :each do
      set_env
    end

    describe '#create' do
      context 'with defaults' do
        it 'creates router interface' do
          expect(provider_class).to receive(:openstack)
            .with('router', 'add subnet', ['router1', 'subnet1'])
          provider.create
          expect(provider.exists?).to be_truthy
        end
      end

      context 'with port' do
        let :interface_attrs do
          {
            :name   => interface_name,
            :ensure => 'present',
            :port   => 'port1',
          }
        end
        it 'creates router interface' do
          expect(provider_class).to receive(:openstack)
            .with('router', 'add port', ['router1', 'port1'])
          provider.create
          expect(provider.exists?).to be_truthy
        end
      end
    end

    describe '#destroy' do
      context 'with defaults' do
        it 'removes router interface' do
          expect(provider_class).to receive(:openstack)
            .with('router', 'remove subnet', ['router1', 'subnet1'])
          provider.destroy
          expect(provider.exists?).to be_falsey
        end
      end
      context 'with port' do
        let :interface_attrs do
          {
            :name   => interface_name,
            :ensure => 'present',
            :port   => 'port1',
          }
        end
        it 'removes router interface' do
          expect(provider_class).to receive(:openstack)
            .with('router', 'remove port', ['router1', 'port1'])
          provider.destroy
          expect(provider.exists?).to be_falsey
        end
      end
    end

    describe '#instances' do
      it 'lists router interfaces' do
        expect(provider_class).to receive(:openstack)
          .with('subnet', 'list', '--quiet', '--format', 'csv', [])
          .and_return('"ID","Name","Network","Subnet"
"dd5e0ef1-2c88-4b0b-ba08-7df65be87963","subnet1","076520cc-b783-4cf5-a4a9-4cb5a5e93a9b","10.0.0.0/24",
"0da7a631-0f8f-4e51-8b1c-7a29d0d4f7b5","subnet2","34e8f42b-89db-4a5b-92db-76ca7073414d","10.0.1.0/24",
')
        expect(provider_class).to receive(:openstack)
          .with('router', 'list', '--quiet', '--format', 'csv', [])
          .and_return('"ID","Name","Status","State","Project","Distributed","HA"
"d73f453a-77ca-4843-977a-3af0fda8dfcb","router1","ACTIVE","True","60f9544eb94c42a6b7e8e98c2be981b1",True,False
"c3e93a5b-45ee-4029-b3a3-3331cb3e3f2a","router2","ACTIVE","True","60f9544eb94c42a6b7e8e98c2be981b1",True,False
')
        expect(provider_class).to receive(:openstack)
          .with('port', 'list', '--quiet', '--format', 'csv', ['--router', 'd73f453a-77ca-4843-977a-3af0fda8dfcb'])
          .and_return('"ID","Name","MAC Address","Fixed IP Addresses","Status"
"5222573b-314d-45f9-b6bd-299288ba667a","port1","fa:16:3e:45:3c:10","[{\'subnet_id\': \'dd5e0ef1-2c88-4b0b-ba08-7df65be87963\', \'ip_address\': \'10.0.0.1\'}]","ACTIVE"')
        expect(provider_class).to receive(:openstack)
          .with('port', 'list', '--quiet', '--format', 'csv', ['--router', 'c3e93a5b-45ee-4029-b3a3-3331cb3e3f2a'])
          .and_return('"ID","Name","MAC Address","Fixed IP Addresses","Status"
"c880affb-b15e-4632-b5e7-3adba6e3ab35","port2","fa:16:3e:45:3c:11","[{\'subnet_id\': \'0da7a631-0f8f-4e51-8b1c-7a29d0d4f7b5\', \'ip_address\': \'10.0.1.1\'}]","ACTIVE"')

        instances = provider_class.instances
        expect(instances.length).to eq(2)

        expect(instances[0].name).to eq('router1:subnet1')
        expect(instances[0].id).to eq('5222573b-314d-45f9-b6bd-299288ba667a')
        expect(instances[0].port).to eq('port1')
        expect(instances[1].name).to eq('router2:subnet2')
        expect(instances[1].id).to eq('c880affb-b15e-4632-b5e7-3adba6e3ab35')
        expect(instances[1].port).to eq('port2')
      end
    end
  end
end
