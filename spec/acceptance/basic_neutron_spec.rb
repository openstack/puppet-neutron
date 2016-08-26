require 'spec_helper_acceptance'

describe 'basic neutron' do

  context 'default parameters' do

    it 'should work with no errors' do
      pp= <<-EOS
      include ::openstack_integration
      include ::openstack_integration::repos
      include ::openstack_integration::rabbitmq
      include ::openstack_integration::mysql
      include ::openstack_integration::keystone

      rabbitmq_user { 'neutron':
        admin    => true,
        password => 'an_even_bigger_secret',
        provider => 'rabbitmqctl',
        require  => Class['rabbitmq'],
      }

      rabbitmq_user_permissions { 'neutron@/':
        configure_permission => '.*',
        write_permission     => '.*',
        read_permission      => '.*',
        provider             => 'rabbitmqctl',
        require              => Class['rabbitmq'],
      }
      Rabbitmq_user_permissions['neutron@/'] -> Service<| tag == 'neutron-service' |>

      # Neutron resources
      class { '::neutron':
        rabbit_user           => 'neutron',
        rabbit_password       => 'an_even_bigger_secret',
        rabbit_host           => '127.0.0.1',
        allow_overlapping_ips => true,
        core_plugin           => 'ml2',
        debug                 => true,
        service_plugins       => ['router', 'metering'],
      }
      class { '::neutron::db::mysql':
        password => 'a_big_secret',
      }
      class { '::neutron::keystone::auth':
        password => 'a_big_secret',
      }
      class { '::neutron::plugins::ml2':
        type_drivers         => ['vxlan'],
        tenant_network_types => ['vxlan'],
        mechanism_drivers    => ['openvswitch'],
      }
      class { '::neutron::server':
        database_connection => 'mysql+pymysql://neutron:a_big_secret@127.0.0.1/neutron?charset=utf8',
        password            => 'a_big_secret',
        auth_url            => 'http://127.0.0.1:35357/',
        sync_db             => true,
        service_providers   => [
          'LOADBALANCERV2:Haproxy:neutron_lbaas.drivers.haproxy.plugin_driver.HaproxyOnHostPluginDriver'
        ],
      }
      class { '::neutron::client': }
      class { '::neutron::quota': }
      class { '::neutron::agents::dhcp': debug => true }
      class { '::neutron::agents::l3': debug => true }
      class { '::neutron::agents::lbaas':
        debug => true,
      }
      class { '::neutron::agents::metering': debug => true }
      class { '::neutron::agents::ml2::ovs':
        local_ip         => '127.0.0.1',
        tunnel_types     => ['vxlan'],
        # Prior to Newton, the neutron-openvswitch-agent used 'ovs-ofctl' of_interface driver by default.
        # In Newton, 'of_interface' defaults to 'native'.
        # This mostly eliminates spawning ovs-ofctl and improves performance a little.
        # Current openstack-selinux does not allow the Ryu controller to listen on 6633 port.
        # So in the meantime, let's use old interface:
        of_interface     => 'ovs-ofctl',
        ovsdb_interface  => 'vsctl',
      }
      class { '::neutron::services::lbaas::haproxy': }
      class { '::neutron::services::lbaas::octavia': }
      EOS


      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    describe 'test Neutron OVS agent bridges' do
      it 'should list OVS bridges' do
        shell("ovs-vsctl show") do |r|
          expect(r.stdout).to match(/br-int/)
          expect(r.stdout).to match(/br-tun/)
        end
      end
    end

  end
end
