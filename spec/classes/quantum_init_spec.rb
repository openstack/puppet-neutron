require 'spec_helper'

describe 'quantum' do

  let :params do
    { :package_ensure      => 'present',
      :verbose             => false,
      :debug               => false,
      :core_plugin         => 'quantum.plugins.linuxbridge.lb_quantum_plugin.LinuxBridgePluginV2',
      :rabbit_host         => '127.0.0.1',
      :rabbit_port         => 5672,
      :rabbit_hosts        => false,
      :rabbit_user         => 'guest',
      :rabbit_password     => 'guest',
      :rabbit_virtual_host => '/'
    }
  end

  shared_examples_for 'quantum' do

    context 'and if rabbit_host parameter is provided' do
      it_configures 'a quantum base installation'
    end

    context 'and if rabbit_hosts parameter is provided' do
      before do
        params.delete(:rabbit_host)
        params.delete(:rabbit_port)
      end

      context 'with one server' do
        before { params.merge!( :rabbit_hosts => ['127.0.0.1:5672'] ) }
        it_configures 'a quantum base installation'
        it_configures 'rabbit HA with a single virtual host'
      end

      context 'with multiple servers' do
        before { params.merge!( :rabbit_hosts => ['rabbit1:5672', 'rabbit2:5672'] ) }
        it_configures 'a quantum base installation'
        it_configures 'rabbit HA with multiple hosts'
      end
    end

    it_configures 'with syslog disabled'
    it_configures 'with syslog enabled'
    it_configures 'with syslog enabled and custom settings'
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
      should contain_quantum_config('AGENT/root_helper').with_value('sudo quantum-rootwrap /etc/quantum/rootwrap.conf')
    end
  end

  shared_examples_for 'rabbit HA with a single virtual host' do
    it 'in quantum.conf' do
      should_not contain_quantum_config('DEFAULT/rabbit_host')
      should_not contain_quantum_config('DEFAULT/rabbit_port')
      should contain_quantum_config('DEFAULT/rabbit_hosts').with_value( params[:rabbit_hosts] )
      should contain_quantum_config('DEFAULT/rabbit_ha_queues').with_value(true)
    end
  end

  shared_examples_for 'rabbit HA with multiple hosts' do
    it 'in quantum.conf' do
      should_not contain_quantum_config('DEFAULT/rabbit_host')
      should_not contain_quantum_config('DEFAULT/rabbit_port')
      should contain_quantum_config('DEFAULT/rabbit_hosts').with_value( params[:rabbit_hosts].join(',') )
      should contain_quantum_config('DEFAULT/rabbit_ha_queues').with_value(true)
    end
  end

  shared_examples_for 'with syslog disabled' do
    it { should contain_quantum_config('DEFAULT/use_syslog').with_value(false) }
  end

  shared_examples_for 'with syslog enabled' do
    before do
      params.merge!(
        :use_syslog => 'true'
      )
    end

    it do
      should contain_quantum_config('DEFAULT/use_syslog').with_value(true)
      should contain_quantum_config('DEFAULT/syslog_log_facility').with_value('LOG_USER')
    end
  end

  shared_examples_for 'with syslog enabled and custom settings' do
    before do
      params.merge!(
        :use_syslog    => 'true',
        :log_facility  => 'LOG_LOCAL0'
      )
    end

    it do
      should contain_quantum_config('DEFAULT/use_syslog').with_value(true)
      should contain_quantum_config('DEFAULT/syslog_log_facility').with_value('LOG_LOCAL0')
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
