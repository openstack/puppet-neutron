require 'spec_helper'

describe 'neutron::db::postgresql' do
  shared_examples 'neutron::db::postgresql' do
    let :req_params do
      { :password => 'neutronpass' }
    end

    let :pre_condition do
      'include postgresql::server'
    end

    context 'with only required parameters' do
      let :params do
        req_params
      end

      it { is_expected.to contain_openstacklib__db__postgresql('neutron').with(
        :user       => 'neutron',
        :password   => 'neutronpass',
        :dbname     => 'neutron',
        :encoding   => nil,
        :privileges => 'ALL',
      )}
    end

  end

  on_supported_os({
    :supported_os   => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge(OSDefaults.get_facts({
          :processorcount => 8,
          :concat_basedir => '/var/lib/puppet/concat'
        }))
      end

      it_behaves_like 'neutron::db::postgresql'
    end
  end
end
