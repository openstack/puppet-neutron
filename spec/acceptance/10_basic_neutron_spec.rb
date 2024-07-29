require 'spec_helper_acceptance'

describe 'basic neutron' do

  context 'default parameters' do

    it 'should work with no errors' do
      pp= <<-EOS
      include openstack_integration
      include openstack_integration::repos
      include openstack_integration::apache
      include openstack_integration::rabbitmq
      include openstack_integration::mysql
      include openstack_integration::memcached
      include openstack_integration::keystone
      include openstack_integration::neutron

      neutron_network { 'private':
        mtu => 1000,
      }
      neutron_subnet { 'private-subnet':
        cidr         => '192.168.100.0/24',
        ip_version   => '4',
        network_name => 'private',
      }
      neutron_network { 'flat':
        router_external           => true,
        provider_network_type     => 'flat',
        provider_physical_network => 'external',
      }
      neutron_subnet { 'flat-subnet':
        cidr             => '172.24.5.0/24',
        ip_version       => '4',
        allocation_pools => ['start=172.24.5.10,end=172.24.5.200'],
        gateway_ip       => '172.24.5.1',
        enable_dhcp      => false,
        network_name     => 'flat',
      }
      neutron_network { 'vlan':
        provider_network_type     => 'vlan',
        provider_physical_network => 'external',
        provider_segmentation_id  => 100,
      }
      neutron_subnet { 'vlan-subnet':
        cidr             => '172.24.6.0/24',
        ip_version       => '4',
        allocation_pools => ['start=172.24.6.10,end=172.24.6.200'],
        gateway_ip       => '172.24.6.1',
        enable_dhcp      => false,
        network_name     => 'vlan',
      }
      # TODO(tkajinam): Fix broken idempotency caused by gateway_network_name
      #neutron_router { 'router':
      #  gateway_network_name => 'flat',
      #}
      #neutron_router_interface { 'router:private':
      #}
      EOS


      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    describe port(9696) do
      it { is_expected.to be_listening }
    end

    describe 'test Neutron OVS agent bridges' do
      it 'should list OVS bridges' do
        command("ovs-vsctl show") do |r|
          expect(r.stdout).to match(/br-int/)
          expect(r.stdout).to match(/br-tun/)
        end
      end
    end

  end
end
