require 'puppet'
require 'spec_helper'
require 'puppet/provider/quantum'
require 'tempfile'

describe Puppet::Provider::Quantum do

  def klass
    described_class
  end

  let :credential_hash do
    {
      'auth_host'         => '192.168.56.210',
      'auth_port'         => '35357',
      'auth_protocol'     => 'https',
      'admin_tenant_name' => 'admin_tenant',
      'admin_user'        => 'admin',
      'admin_password'    => 'password',
    }
  end

  let :auth_endpoint do
    'https://192.168.56.210:35357/v2.0/'
  end

  let :credential_error do
    /Quantum types will not work/
  end

  after :each do
    klass.reset
  end

  describe 'when determining credentials' do

    it 'should fail if config is empty' do
      conf = {}
      klass.expects(:quantum_conf).returns(conf)
      expect do
        klass.quantum_credentials
      end.to raise_error(Puppet::Error, credential_error)
    end

    it 'should fail if config does not have keystone_authtoken section.' do
      conf = {'foo' => 'bar'}
      klass.expects(:quantum_conf).returns(conf)
      expect do
        klass.quantum_credentials
      end.to raise_error(Puppet::Error, credential_error)
    end

    it 'should fail if config does not contain all auth params' do
      conf = {'keystone_authtoken' => {'invalid_value' => 'foo'}}
      klass.expects(:quantum_conf).returns(conf)
      expect do
       klass.quantum_credentials
      end.to raise_error(Puppet::Error, credential_error)
    end

    it 'should use specified host/port/protocol in the auth endpoint' do
      conf = {'keystone_authtoken' => credential_hash}
      klass.expects(:quantum_conf).returns(conf)
      klass.get_auth_endpoint.should == auth_endpoint
    end

  end

  describe 'when invoking the quantum cli' do

    it 'should set auth credentials in the environment' do
      authenv = {
        :OS_AUTH_URL    => auth_endpoint,
        :OS_USERNAME    => credential_hash['admin_user'],
        :OS_TENANT_NAME => credential_hash['admin_tenant_name'],
        :OS_PASSWORD    => credential_hash['admin_password'],
      }
      klass.expects(:get_quantum_credentials).with().returns(credential_hash)
      klass.expects(:withenv).with(authenv)
      klass.auth_quantum('test_retries')
    end

    ['[Errno 111] Connection refused',
     '(HTTP 400)'].reverse.each do |valid_message|
      it "should retry when quantum cli returns with error #{valid_message}" do
        klass.expects(:get_quantum_credentials).with().returns({})
        klass.expects(:sleep).with(10).returns(nil)
        klass.expects(:quantum).twice.with(['test_retries']).raises(
          Exception, valid_message).then.returns('')
        klass.auth_quantum('test_retries')
      end
    end

  end

  describe 'when listing quantum resources' do

    it 'should exclude the column header' do
      output = <<-EOT
        id
        net1
        net2
      EOT
      klass.expects(:auth_quantum).returns(output)
      result = klass.list_quantum_resources('foo')
      result.should eql(['net1', 'net2'])
    end

  end

  describe 'when retrieving attributes for quantum resources' do

    it 'should parse single-valued attributes into a key-value pair' do
      klass.expects(:auth_quantum).returns('admin_state_up="True"')
      result = klass.get_quantum_resource_attrs('foo', 'id')
      result.should eql({"admin_state_up" => 'True'})
    end

    it 'should parse multi-valued attributes into a key-list pair' do
      output = <<-EOT
subnets="subnet1
subnet2"
      EOT
      klass.expects(:auth_quantum).returns(output)
      result = klass.get_quantum_resource_attrs('foo', 'id')
      result.should eql({"subnets" => ['subnet1', 'subnet2']})
    end

  end

end
