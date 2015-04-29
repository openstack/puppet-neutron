require 'spec_helper_acceptance'

describe 'basic neutron' do

  context 'default parameters' do

    it 'should work with no errors' do
      pp= <<-EOS
      Exec { logoutput => 'on_failure' }

      include ::apt
      apt::source { 'trusty-updates-kilo':
        location          => 'http://ubuntu-cloud.archive.canonical.com/ubuntu/',
        release           => 'trusty-updates',
        required_packages => 'ubuntu-cloud-keyring',
        repos             => 'kilo/main',
        trusted_source    => true,
      } ~>
      exec { '/usr/bin/apt-get -y dist-upgrade':
        refreshonly => true,
      }
      Apt::Source['trusty-updates-kilo'] -> Package<| |>

      class { '::mysql::server': }

      class { '::rabbitmq':
        delete_guest_user => true,
        erlang_cookie     => 'secrete',
      }

      rabbitmq_vhost { '/':
        provider => 'rabbitmqctl',
        require  => Class['rabbitmq'],
      }

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

      # Keystone resources, needed by Neutron to run
      class { '::keystone::db::mysql':
        password => 'keystone',
      }
      class { '::keystone':
        verbose             => true,
        debug               => true,
        database_connection => 'mysql://keystone:keystone@127.0.0.1/keystone',
        admin_token         => 'admin_token',
        enabled             => true,
      }
      class { '::keystone::roles::admin':
        email    => 'test@example.tld',
        password => 'a_big_secret',
      }
      class { '::keystone::endpoint':
        public_url => "https://${::fqdn}:5000/",
        admin_url  => "https://${::fqdn}:35357/",
      }

      # Neutron resources
      class { '::neutron':
        rabbit_user           => 'neutron',
        rabbit_password       => 'an_even_bigger_secret',
        rabbit_host           => '127.0.0.1',
        allow_overlapping_ips => true,
        core_plugin           => 'neutron.plugins.ml2.plugin.Ml2Plugin',
      }
      class { '::neutron::db::mysql':
        password => 'a_big_secret',
      }
      class { '::neutron::keystone::auth':
        password => 'a_big_secret',
      }
      class { '::neutron::server':
        database_connection => 'mysql://neutron:a_big_secret@127.0.0.1/neutron?charset=utf8',
        auth_password       => 'a_big_secret',
        identity_uri        => 'http://127.0.0.1:35357/',
      }
      class { '::neutron::client': }
      class { '::neutron::quota': }
      class { '::neutron::agents::dhcp': }
      class { '::neutron::agents::l3': }
      class { '::neutron::agents::lbaas': }
      class { '::neutron::agents::metering': }
      class { '::neutron::agents::ml2::ovs':
        enable_tunneling => true,
        local_ip         => '127.0.0.1',
      }
      class { '::neutron::plugins::ml2': }
      EOS


      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

  end
end
