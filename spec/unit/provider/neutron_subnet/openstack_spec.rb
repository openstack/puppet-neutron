require 'puppet'
require 'spec_helper'
require 'puppet/provider/neutron_subnet/openstack'

provider_class = Puppet::Type.type(:neutron_subnet).provider(:openstack)

describe provider_class do

  let(:set_env) do
    ENV['OS_USERNAME']     = 'test'
    ENV['OS_PASSWORD']     = 'abc123'
    ENV['OS_PROJECT_NAME'] = 'test'
    ENV['OS_AUTH_URL']     = 'http://127.0.0.1:5000'
  end

  describe 'manage subnets' do
    let :subnet_name do
      'subnet1'
    end

    let :subnet_attrs do
      {
        :ensure       => 'present',
        :name         => subnet_name,
        :network_name => 'net1',
        :cidr         => '10.0.0.0/24',
      }
    end

    let :resource do
      Puppet::Type::Neutron_subnet.new(subnet_attrs)
    end

    let :provider do
      provider_class.new(resource)
    end

    before :each do
      set_env
    end

    describe '#create' do
      context 'with defaults' do
        it 'creates subnet' do
          expect(provider_class).to receive(:openstack)
            .with('subnet', 'create', '--format', 'shell',
                  ['subnet1', '--dhcp', '--network=net1',
                   '--subnet-range=10.0.0.0/24'])
            .and_return('allocation_pools="[{\'start\': \'10.0.0.2\', \'end\': \'10.0.0.254\'}]"
cidr="10.0.0.0/24"
description=""
dns_nameservers="[]"
enable_dhcp="True"
host_routes="[]"
id="dd5e0ef1-2c88-4b0b-ba08-7df65be87963"
ip_version="4"
ipv6_address_mode="None"
ipv6_ra_mode="None"
name="subnet1"
network_id="076520cc-b783-4cf5-a4a9-4cb5a5e93a9b"
project_id="60f9544eb94c42a6b7e8e98c2be981b1"')
          expect(provider_class).to receive(:openstack)
            .with('network', 'show', '--format', 'shell',
                  ['076520cc-b783-4cf5-a4a9-4cb5a5e93a9b'])
            .and_return('id="076520cc-b783-4cf5-a4a9-4cb5a5e93a9b"
name="net1"')
          provider.create
          expect(provider.exists?).to be_truthy
          expect(provider.allocation_pools).to eq(['start=10.0.0.2,end=10.0.0.254'])
          expect(provider.host_routes).to eq([])
          expect(provider.network_name).to eq('net1')
        end
      end

      context 'with params' do
        let :subnet_attrs do
          {
            :ensure           => 'present',
            :name             => subnet_name,
            :network_name     => 'net1',
            :cidr             => '10.0.0.0/24',
            :ip_version       => '4',
            :gateway_ip       => '10.0.0.1',
            :enable_dhcp      => 'False',
            :allocation_pools => 'start=10.0.0.2,end=10.0.0.10',
            :dns_nameservers  => '8.8.8.8',
            :host_routes      => 'destination=10.0.1.0/24,nexthop=10.0.0.1',
          }
        end
        it 'creates subnet' do
          expect(provider_class).to receive(:openstack)
            .with('subnet', 'create', '--format', 'shell',
                  ['subnet1', '--ip-version=4',
                   '--gateway=10.0.0.1', '--no-dhcp',
                   '--allocation-pool=start=10.0.0.2,end=10.0.0.10',
                   '--dns-nameserver=8.8.8.8',
                   '--host-route=destination=10.0.1.0/24,nexthop=10.0.0.1',
                   '--network=net1',
                   '--subnet-range=10.0.0.0/24'])
            .and_return('allocation_pools="[{\'start\': \'10.0.0.2\', \'end\': \'10.0.0.10\'}]"
cidr="10.0.0.0/24"
description=""
dns_nameservers="[\'8.8.8.8\']"
enable_dhcp="False"
host_routes="[{\'destination\': \'10.0.1.0/24\', \'nexthop\': \'10.0.0.1\'}]"
id="dd5e0ef1-2c88-4b0b-ba08-7df65be87963"
ip_version="4"
ipv6_address_mode="None"
ipv6_ra_mode="None"
name="subnet1"
network_id="076520cc-b783-4cf5-a4a9-4cb5a5e93a9b"
project_id="60f9544eb94c42a6b7e8e98c2be981b1"')
          expect(provider_class).to receive(:openstack)
            .with('network', 'show', '--format', 'shell',
                  ['076520cc-b783-4cf5-a4a9-4cb5a5e93a9b'])
            .and_return('id="076520cc-b783-4cf5-a4a9-4cb5a5e93a9b"
name="net1"')
          provider.create
          expect(provider.exists?).to be_truthy
          expect(provider.allocation_pools).to eq(['start=10.0.0.2,end=10.0.0.10'])
          expect(provider.host_routes).to eq(['destination=10.0.1.0/24,nexthop=10.0.0.1'])
          expect(provider.network_name).to eq('net1')
        end
      end

      context 'with ipv6' do
        let :subnet_attrs do
          {
            :ensure           => 'present',
            :name             => subnet_name,
            :network_name     => 'net1',
            :cidr             => '2001:abcd::/64',
            :ip_version       => '6',
            :gateway_ip       => '2001:abcd::1',
            :allocation_pools => 'start=2001:abcd::2,end=2001:abcd::ffff:ffff:ffff:fffe',
            :dns_nameservers  => '2001:4860:4860::8888',
            :host_routes      => 'destination=2001:abcd:0:1::/64,nexthop=2001:abcd::1',
          }
        end

        it 'creates ipv6 subnet' do
          expect(provider_class).to receive(:openstack)
            .with('subnet', 'create', '--format', 'shell',
                  ['subnet1', '--ip-version=6',
                   '--gateway=2001:abcd::1', '--dhcp',
                   '--allocation-pool=start=2001:abcd::2,end=2001:abcd::ffff:ffff:ffff:fffe',
                   '--dns-nameserver=2001:4860:4860::8888',
                   '--host-route=destination=2001:abcd:0:1::/64,nexthop=2001:abcd::1',
                   '--network=net1',
                   '--subnet-range=2001:abcd::/64'])
            .and_return('allocation_pools="[{\'start\': \'2001:abcd::2\', \'end\': \'2001:abcd::ffff:ffff:ffff:fffe\'}]"
cird="2001:abcd::/64"
description=""
dns_nameservers="[\'2001:4860:4860::8888\']"
enable_dhcp="True"
host_routes="[{\'destination\': \'2001:abcd:0:1::/64\', \'nexthop\': \'2001:abcd::1\'}]"
id="dd5e0ef1-2c88-4b0b-ba08-7df65be87963"
ip_version="6"
ipv6_address_mode="None"
ipv6_ra_mode="None"
name="subnet1"
network_id="076520cc-b783-4cf5-a4a9-4cb5a5e93a9b"
project_id="60f9544eb94c42a6b7e8e98c2be981b1"')
          expect(provider_class).to receive(:openstack)
            .with('network', 'show', '--format', 'shell',
                  ['076520cc-b783-4cf5-a4a9-4cb5a5e93a9b'])
            .and_return('id="076520cc-b783-4cf5-a4a9-4cb5a5e93a9b"
name="net1"')
          provider.create
          expect(provider.exists?).to be_truthy
          expect(provider.allocation_pools).to eq(['start=2001:abcd::2,end=2001:abcd::ffff:ffff:ffff:fffe'])
          expect(provider.host_routes).to eq(['destination=2001:abcd:0:1::/64,nexthop=2001:abcd::1'])
          expect(provider.network_name).to eq('net1')
        end
      end
    end

    describe '#destroy' do
      it 'removes subnet' do
        expect(provider_class).to receive(:openstack)
          .with('subnet', 'delete', 'subnet1')
        provider.destroy
        expect(provider.exists?).to be_falsey
      end
    end

    describe '#flush' do
      context 'gateway_ip' do
        it 'updates subnet' do
          expect(provider_class).to receive(:openstack)
            .with('subnet', 'set', ['subnet1', '--gateway=10.0.0.1'])
          provider.gateway_ip = '10.0.0.1'
          provider.flush

          expect(provider_class).to receive(:openstack)
            .with('subnet', 'set', ['subnet1', '--gateway=none'])
          provider.gateway_ip = ''
          provider.flush
        end
      end
      context '.enable_dhcp' do
        it 'updates subnet' do
          expect(provider_class).to receive(:openstack)
            .with('subnet', 'set', ['subnet1', '--no-dhcp'])
          provider.enable_dhcp = 'False'
          provider.flush

          expect(provider_class).to receive(:openstack)
            .with('subnet', 'set', ['subnet1', '--dhcp'])
          provider.enable_dhcp = 'True'
          provider.flush
        end
      end
      context '.allocation_pools' do
        it 'updates subnet' do
          expect(provider_class).to receive(:openstack)
            .with('subnet', 'set', ['subnet1', '--no-allocation-pool'])
          expect(provider_class).to receive(:openstack)
            .with('subnet', 'set', ['subnet1', '--allocation-pool=start=10.0.0.2,end=10.0.0.10'])
          provider.allocation_pools = 'start=10.0.0.2,end=10.0.0.10'
          provider.flush
        end
      end
      context '.dns_nameservers' do
        it 'updates subnet' do
          expect(provider_class).to receive(:openstack)
            .with('subnet', 'set', ['subnet1', '--no-dns-nameservers'])
          expect(provider_class).to receive(:openstack)
            .with('subnet', 'set', ['subnet1', '--dns-nameserver=8.8.8.8'])
          provider.dns_nameservers = '8.8.8.8'
          provider.flush
        end
      end
    end

    describe '#instances' do
      it 'lists subnets' do
        expect(provider_class).to receive(:openstack)
          .with('subnet', 'list', '--quiet', '--format', 'csv', [])
          .and_return('"ID","Name","Network","Subnet"
"dd5e0ef1-2c88-4b0b-ba08-7df65be87963","subnet1","076520cc-b783-4cf5-a4a9-4cb5a5e93a9b","10.0.0.0/24",
"0da7a631-0f8f-4e51-8b1c-7a29d0d4f7b5","subnet2","34e8f42b-89db-4a5b-92db-76ca7073414d","10.0.1.0/24",
')

        expect(provider_class).to receive(:openstack)
          .with('subnet', 'show', '--format', 'shell', 'dd5e0ef1-2c88-4b0b-ba08-7df65be87963')
          .and_return('allocation_pools="[{\'start\': \'10.0.0.2\', \'end\': \'10.0.0.254\'}]"
cidr="10.0.0.0/24"
description=""
dns_nameservers="[]"
enable_dhcp="True"
gateway_ip="10.0.0.1"
host_routes="[]"
id="dd5e0ef1-2c88-4b0b-ba08-7df65be87963"
ip_version="4"
ipv6_address_mode="None"
ipv6_ra_mode="None"
name="subnet1"
network_id="076520cc-b783-4cf5-a4a9-4cb5a5e93a9b"
project_id="60f9544eb94c42a6b7e8e98c2be981b1"')
        expect(provider_class).to receive(:openstack)
          .with('network', 'show', '--format', 'shell', ['076520cc-b783-4cf5-a4a9-4cb5a5e93a9b'])
          .and_return('name="net1"')

        expect(provider_class).to receive(:openstack)
          .with('subnet', 'show', '--format', 'shell', '0da7a631-0f8f-4e51-8b1c-7a29d0d4f7b5')
          .and_return('allocation_pools="[{\'start\': \'10.0.1.2\', \'end\': \'10.0.1.254\'}]"
cidr="10.0.1.0/24"
description=""
dns_nameservers="[]"
enable_dhcp="False"
gateway_ip="10.0.1.1"
host_routes="[]"
id="0da7a631-0f8f-4e51-8b1c-7a29d0d4f7b5"
ip_version="4"
ipv6_address_mode="None"
ipv6_ra_mode="None"
name="subnet2"
network_id="34e8f42b-89db-4a5b-92db-76ca7073414d"
project_id="60f9544eb94c42a6b7e8e98c2be981b1"')
        expect(provider_class).to receive(:openstack)
          .with('network', 'show', '--format', 'shell', ['34e8f42b-89db-4a5b-92db-76ca7073414d'])
          .and_return('name="net2"')

        instances = provider_class.instances
        expect(instances.length).to eq(2)

        expect(instances[0].id).to eq('dd5e0ef1-2c88-4b0b-ba08-7df65be87963')
        expect(instances[0].name).to eq('subnet1')
        expect(instances[0].ip_version).to eq('4')
        expect(instances[0].network_id).to eq('076520cc-b783-4cf5-a4a9-4cb5a5e93a9b')
        expect(instances[0].network_name).to eq('net1')
        expect(instances[0].cidr).to eq('10.0.0.0/24')
        expect(instances[0].gateway_ip).to eq('10.0.0.1')
        expect(instances[0].allocation_pools).to eq(['start=10.0.0.2,end=10.0.0.254'])
        expect(instances[0].enable_dhcp).to eq('True')
        expect(instances[0].tenant_id).to eq('60f9544eb94c42a6b7e8e98c2be981b1')

        expect(instances[1].id).to eq('0da7a631-0f8f-4e51-8b1c-7a29d0d4f7b5')
        expect(instances[1].name).to eq('subnet2')
        expect(instances[1].ip_version).to eq('4')
        expect(instances[1].network_id).to eq('34e8f42b-89db-4a5b-92db-76ca7073414d')
        expect(instances[1].network_name).to eq('net2')
        expect(instances[1].gateway_ip).to eq('10.0.1.1')
        expect(instances[1].cidr).to eq('10.0.1.0/24')
        expect(instances[1].allocation_pools).to eq(['start=10.0.1.2,end=10.0.1.254'])
        expect(instances[1].enable_dhcp).to eq('False')
        expect(instances[1].tenant_id).to eq('60f9544eb94c42a6b7e8e98c2be981b1')
      end
    end
  end
end
