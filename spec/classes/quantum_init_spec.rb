require 'spec_helper'

describe 'quantum' do

  let :params do
    { :package_ensure      => 'present',
      :verbose             => false,
      :debug               => false,
      :core_plugin         => 'quantum.plugins.linuxbridge.lb_quantum_plugin.LinuxBridgePluginV2',
      :rabbit_host         => '127.0.0.1',
      :rabbit_port         => 5672,
      :rabbit_user         => 'guest',
      :rabbit_password     => 'guest',
      :rabbit_virtual_host => '/'
    }
  end

  shared_examples_for 'quantum' do

    context 'and if rabbit_host parameter is provided' do
      it_configures 'a quantum base installation'
      it_configures 'rabbit without HA support (with backward compatibility)'
    end

    context 'and if rabbit_hosts parameter is provided' do
      before do
        params.delete(:rabbit_host)
        params.delete(:rabbit_port)
      end

      context 'with one server' do
        before { params.merge!( :rabbit_hosts => ['127.0.0.1:5672'] ) }
        it_configures 'a quantum base installation'
        it_configures 'rabbit without HA support (without backward compatibility)'
      end

      context 'with multiple servers' do
        before { params.merge!( :rabbit_hosts => ['rabbit1:5672', 'rabbit2:5672'] ) }
        it_configures 'a quantum base installation'
        it_configures 'rabbit with HA support'
      end
    end
  end

  shared_examples_for 'a quantum base installation' do

    it { should include_class('quantum::params') }

    it 'configures quantum configuration folder' do
      should contain_file('/etc/quantum/').with(
        :ensure  => 'directory',
        :owner   => 'root',
        :group   => 'quantum',
        :mode    => '0750',
        :require => 'Package[quantum]'
      )
    end

    it 'configures quantum configuration file' do
      should contain_file('/etc/quantum/quantum.conf').with(
        :owner   => 'root',
        :group   => 'quantum',
        :mode    => '0640',
        :require => 'Package[quantum]'
      )
    end

    it 'installs quantum package' do
      should contain_package('quantum').with(
        :ensure => 'present',
        :name   => platform_params[:common_package_name]
      )
    end

    it 'configures credentials for rabbit' do
      should contain_quantum_config('DEFAULT/rabbit_userid').with_value( params[:rabbit_user] )
      should contain_quantum_config('DEFAULT/rabbit_password').with_value( params[:rabbit_password] )
      should contain_quantum_config('DEFAULT/rabbit_virtual_host').with_value( params[:rabbit_virtual_host] )
    end

    it 'configures quantum.conf' do
      should contain_quantum_config('DEFAULT/verbose').with_value( params[:verbose] )
      should contain_quantum_config('DEFAULT/bind_host').with_value('0.0.0.0')
      should contain_quantum_config('DEFAULT/bind_port').with_value('9696')
      should contain_quantum_config('DEFAULT/auth_strategy').with_value('keystone')
      should contain_quantum_config('DEFAULT/core_plugin').with_value( params[:core_plugin] )
      should contain_quantum_config('DEFAULT/base_mac').with_value('fa:16:3e:00:00:00')
      should contain_quantum_config('DEFAULT/mac_generation_retries').with_value(16)
      should contain_quantum_config('DEFAULT/dhcp_lease_duration').with_value(120)
      should contain_quantum_config('DEFAULT/allow_bulk').with_value(true)
      should contain_quantum_config('DEFAULT/allow_overlapping_ips').with_value(false)
      should contain_quantum_config('DEFAULT/control_exchange').with_value('quantum')
      should contain_quantum_config('DEFAULT/root_helper').with_value('sudo quantum-rootwrap /etc/quantum/rootwrap.conf')
    end
  end

  shared_examples_for 'rabbit without HA support (with backward compatibility)' do
    it 'in quantum.conf' do
      should contain_quantum_config('DEFAULT/rabbit_host').with_value( params[:rabbit_host] )
      should contain_quantum_config('DEFAULT/rabbit_port').with_value( params[:rabbit_port] )
      should contain_quantum_config('DEFAULT/rabbit_hosts').with_value( "#{params[:rabbit_host]}:#{params[:rabbit_port]}" )
      should contain_quantum_config('DEFAULT/rabbit_ha_queues').with_value(false)
    end
  end

  shared_examples_for 'rabbit without HA support (without backward compatibility)' do
    it 'in quantum.conf' do
      should contain_quantum_config('DEFAULT/rabbit_host').with_ensure('absent')
      should contain_quantum_config('DEFAULT/rabbit_port').with_ensure('absent')
      should contain_quantum_config('DEFAULT/rabbit_hosts').with_value( params[:rabbit_hosts].join(',') )
      should contain_quantum_config('DEFAULT/rabbit_ha_queues').with_value(false)
    end
  end

  shared_examples_for 'rabbit with HA support' do
    it 'in quantum.conf' do
      should contain_quantum_config('DEFAULT/rabbit_host').with_ensure('absent')
      should contain_quantum_config('DEFAULT/rabbit_port').with_ensure('absent')
      should contain_quantum_config('DEFAULT/rabbit_hosts').with_value( params[:rabbit_hosts].join(',') )
      should contain_quantum_config('DEFAULT/rabbit_ha_queues').with_value(true)
    end
  end


  context 'on Debian platforms' do
    let :facts do
      { :osfamily => 'Debian' }
    end

    let :platform_params do
      { :common_package_name => 'quantum-common' }
    end

    it_configures 'quantum'
  end

  context 'on RedHat platforms' do
    let :facts do
      { :osfamily => 'RedHat' }
    end

    let :platform_params do
      { :common_package_name => 'openstack-quantum' }
    end

    it_configures 'quantum'
  end
end
