require 'spec_helper'

describe 'neutron::wsgi::uwsgi' do

  shared_examples 'neutron::wsgi::uwsgi' do
    context 'with default parameters' do
      it {
        should contain_class('neutron::deps')
      }

      it {
        is_expected.to contain_neutron_api_uwsgi_config('uwsgi/processes').with_value(facts[:os_workers])
        is_expected.to contain_neutron_api_uwsgi_config('uwsgi/threads').with_value('32')
        is_expected.to contain_neutron_api_uwsgi_config('uwsgi/listen').with_value('100')
      }
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts({
          :os_workers => 8,
        }))
      end
      it_behaves_like 'neutron::wsgi::uwsgi'
    end
  end
end
