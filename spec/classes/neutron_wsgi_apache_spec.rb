require 'spec_helper'

describe 'neutron::wsgi::apache' do
  shared_examples 'apache serving neutron with mod_wsgi' do
    context 'with default parameters' do
      it { should contain_class('neutron::params') }
      it { should contain_openstacklib__wsgi__apache('neutron_wsgi').with(
        :bind_port                   => 9696,
        :group                       => 'neutron',
        :path                        => '/',
        :priority                    => 10,
        :servername                  => facts[:fqdn],
        :ssl                         => false,
        :threads                     => 1,
        :user                        => 'neutron',
        :workers                     => facts[:os_workers],
        :wsgi_daemon_process         => 'neutron',
        :wsgi_process_group          => 'neutron',
        :wsgi_script_dir             => platform_params[:wsgi_script_path],
        :wsgi_script_file            => 'app',
        :wsgi_script_source          => platform_params[:wsgi_script_source],
        :custom_wsgi_process_options => {},
        :headers                     => nil,
        :request_headers             => nil,
        :access_log_file             => nil,
        :access_log_pipe             => nil,
        :access_log_syslog           => nil,
        :access_log_format           => nil,
        :error_log_file              => nil,
        :error_log_pipe              => nil,
        :error_log_syslog            => nil,
      )}
    end

    context 'when overriding parameters' do
      let :params do
        {
          :servername                => 'dummy.host',
          :bind_host                 => '10.42.51.1',
          :port                      => 12345,
          :ssl                       => true,
          :wsgi_process_display_name => 'neutron',
          :workers                   => 37,
          :custom_wsgi_process_options => {
            'python_path' => '/my/python/path',
          },
          :headers                   => ['set X-XSS-Protection "1; mode=block"'],
          :request_headers           => ['set Content-Type "application/json"'],
        }
      end
      it { should contain_class('neutron::params') }
      it { should contain_openstacklib__wsgi__apache('neutron_wsgi').with(
        :bind_host                   => '10.42.51.1',
        :bind_port                   => 12345,
        :group                       => 'neutron',
        :path                        => '/',
        :servername                  => 'dummy.host',
        :ssl                         => true,
        :threads                     => 1,
        :user                        => 'neutron',
        :workers                     => 37,
        :wsgi_daemon_process         => 'neutron',
        :wsgi_process_display_name   => 'neutron',
        :wsgi_process_group          => 'neutron',
        :wsgi_script_dir             => platform_params[:wsgi_script_path],
        :wsgi_script_file            => 'app',
        :wsgi_script_source          => platform_params[:wsgi_script_source],
        :headers                     => ['set X-XSS-Protection "1; mode=block"'],
        :request_headers             => ['set Content-Type "application/json"'],
        :custom_wsgi_process_options => {
          'python_path' => '/my/python/path',
        },
      )}
    end

    context 'with custom access logging' do
      let :params do
        {
          :access_log_format => 'foo',
          :access_log_syslog => 'syslog:local0',
          :error_log_syslog  => 'syslog:local1',
        }
      end

      it { should contain_openstacklib__wsgi__apache('neutron_wsgi').with(
        :access_log_format => params[:access_log_format],
        :access_log_syslog => params[:access_log_syslog],
        :error_log_syslog  => params[:error_log_syslog],
      )}
    end

    context 'with access_log_file' do
      let :params do
        {
          :access_log_file => '/path/to/file',
        }
      end

      it { should contain_openstacklib__wsgi__apache('neutron_wsgi').with(
        :access_log_file => params[:access_log_file],
      )}
    end

    context 'with access_log_pipe' do
      let :params do
        {
          :access_log_pipe => 'pipe',
        }
      end

      it { should contain_openstacklib__wsgi__apache('neutron_wsgi').with(
        :access_log_pipe => params[:access_log_pipe],
      )}
    end

    context 'with error_log_file' do
      let :params do
        {
          :error_log_file => '/path/to/file',
        }
      end

      it { should contain_openstacklib__wsgi__apache('neutron_wsgi').with(
        :error_log_file => params[:error_log_file],
      )}
    end

    context 'with error_log_pipe' do
      let :params do
        {
          :error_log_pipe => 'pipe',
        }
      end

      it { should contain_openstacklib__wsgi__apache('neutron_wsgi').with(
        :error_log_pipe => params[:error_log_pipe],
      )}
    end
  end

  on_supported_os({
    :supported_os   => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts({
          :os_workers     => 8,
          :concat_basedir => '/var/lib/puppet/concat',
          :fqdn           => 'some.host.tld'
        }))
      end

      let(:platform_params) do
        case facts[:osfamily]
        when 'Debian'
          {
            :wsgi_script_path   => '/usr/lib/cgi-bin/neutron',
            :wsgi_script_source => '/usr/bin/neutron-api'
          }
        when 'RedHat'
          {
            :wsgi_script_path   => '/var/www/cgi-bin/neutron',
            :wsgi_script_source => '/usr/bin/neutron-api'
          }

        end
      end
      it_behaves_like 'apache serving neutron with mod_wsgi'
    end
  end
end
