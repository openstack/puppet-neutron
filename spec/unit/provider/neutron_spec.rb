require 'puppet'
require 'spec_helper'
require 'puppet/provider/neutron'
require 'tempfile'

describe Puppet::Provider::Neutron do

  def klass
    described_class
  end

  let :credential_hash do
    {
      'project_name'        => 'admin_tenant',
      'username'            => 'admin',
      'password'            => 'password',
      'auth_url'            => 'https://192.168.56.210:5000/v3/',
      'project_domain_name' => 'Default',
      'user_domain_name'    => 'Default',
    }
  end

  let :credential_error do
    /Neutron types will not work/
  end

  let :exec_error do
    /Neutron or Keystone API is not available/
  end

  after :each do
    klass.reset
  end

  describe 'when determining credentials' do

    it 'should fail if config is empty' do
      conf = {}
      expect(klass).to receive(:neutron_conf).and_return(conf)
      expect do
        klass.neutron_credentials
      end.to raise_error(Puppet::Error, credential_error)
    end

    it 'should fail if config does not have keystone_authtoken section.' do
      conf = {'foo' => 'bar'}
      expect(klass).to receive(:neutron_conf).and_return(conf)
      expect do
        klass.neutron_credentials
      end.to raise_error(Puppet::Error, credential_error)
    end

    it 'should fail if config does not contain all auth params' do
      conf = {'keystone_authtoken' => {'invalid_value' => 'foo'}}
      expect(klass).to receive(:neutron_conf).and_return(conf)
      expect do
       klass.neutron_credentials
      end.to raise_error(Puppet::Error, credential_error)
    end
  end
end
