require 'spec_helper'

describe 'neutron::db::mysql' do
  let :pre_condition do
    'include mysql::server'
  end

  let :params do
    {
      :password => 'neutronpass',
    }
  end

  shared_examples 'neutron::db::mysql' do
    context 'with only required params' do
      it { should contain_openstacklib__db__mysql('neutron').with(
        :user     => 'neutron',
        :password => 'neutronpass',
        :host     => '127.0.0.1',
        :charset  => 'utf8',
        :collate  => 'utf8_general_ci',
       ) }
    end

    context "overriding allowed_hosts param to array" do
      let :params do
        {
          :password      => 'neutronpass',
          :allowed_hosts => ['127.0.0.1','%'],
        }
      end

      it { should contain_openstacklib__db__mysql('neutron').with(
        :user          => 'neutron',
        :password      => 'neutronpass',
        :host          => '127.0.0.1',
        :charset       => 'utf8',
        :collate       => 'utf8_general_ci',
        :allowed_hosts => ['127.0.0.1','%'],
      ) }  
    end

    context "overriding allowed_hosts param to string" do
      let :params do
        {
          :password      => 'neutronpass2',
          :allowed_hosts => '192.168.1.1',
        }
      end

      it { should contain_openstacklib__db__mysql('neutron').with(
          :user          => 'neutron',
          :password      => 'neutronpass2',
          :host          => '127.0.0.1',
          :charset       => 'utf8',
          :collate       => 'utf8_general_ci',
          :allowed_hosts => '192.168.1.1',
      )}
    end

    context "overriding allowed_hosts param equals to host param " do
      let :params do
        {
          :password     => 'neutronpass2',
          :allowed_hosts => '127.0.0.1',
        }
      end

      it { should contain_openstacklib__db__mysql('neutron').with(
          :user          => 'neutron',
          :password      => 'neutronpass2',
          :host          => '127.0.0.1',
          :charset       => 'utf8',
          :collate       => 'utf8_general_ci',
          :allowed_hosts => '127.0.0.1',
      )}

    end  
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      it_behaves_like 'neutron::db::mysql'
    end
  end
end
