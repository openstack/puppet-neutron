require 'spec_helper'

describe 'neutron::db::mysql' do

  let :pre_condition do
    'include mysql::server'
  end

  let :params do
    {
      :password => 'passw0rd',
    }
  end

  let :facts do
    {
      :osfamily => 'Debian',
    }
  end

  describe 'with only required params' do
    it { is_expected.to contain_openstacklib__db__mysql('neutron').with(
      :user          => 'neutron',
      :password_hash => '*74B1C21ACE0C2D6B0678A5E503D2A60E8F9651A3',
      :host          => '127.0.0.1',
      :charset       => 'utf8',
      :collate       => 'utf8_general_ci',
     ) }
  end

  describe "overriding allowed_hosts param to array" do
    let :params do
      {
        :password       => 'neutronpass',
        :allowed_hosts  => ['127.0.0.1','%'],
      }
    end

    it { is_expected.to contain_openstacklib__db__mysql('neutron').with(
      :user          => 'neutron',
      :password_hash => '*E7D4FEBBE0A141B5E4B413EAF85CCB49746A2497',
      :host          => '127.0.0.1',
      :charset       => 'utf8',
      :collate       => 'utf8_general_ci',
      :allowed_hosts => ['127.0.0.1','%'],
    ) }

  end

  describe "overriding allowed_hosts param to string" do
    let :params do
      {
        :password       => 'neutronpass2',
        :allowed_hosts  => '192.168.1.1',
      }
    end

    it { is_expected.to contain_openstacklib__db__mysql('neutron').with(
        :user          => 'neutron',
        :password_hash => '*32C4202C8C2D4430442B55CCA765BD47D5D2E1A2',
        :host          => '127.0.0.1',
        :charset       => 'utf8',
        :collate       => 'utf8_general_ci',
        :allowed_hosts => '192.168.1.1',
    ) }

  end

  describe "overriding allowed_hosts param equals to host param " do
    let :params do
      {
        :password       => 'neutronpass2',
        :allowed_hosts  => '127.0.0.1',
      }
    end

    it { is_expected.to contain_openstacklib__db__mysql('neutron').with(
        :user          => 'neutron',
        :password_hash => '*32C4202C8C2D4430442B55CCA765BD47D5D2E1A2',
        :host          => '127.0.0.1',
        :charset       => 'utf8',
        :collate       => 'utf8_general_ci',
        :allowed_hosts => '127.0.0.1',
    ) }

  end

end

