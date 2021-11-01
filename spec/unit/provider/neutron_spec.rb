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
      klass.expects(:neutron_conf).returns(conf)
      expect do
        klass.neutron_credentials
      end.to raise_error(Puppet::Error, credential_error)
    end

    it 'should fail if config does not have keystone_authtoken section.' do
      conf = {'foo' => 'bar'}
      klass.expects(:neutron_conf).returns(conf)
      expect do
        klass.neutron_credentials
      end.to raise_error(Puppet::Error, credential_error)
    end

    it 'should fail if config does not contain all auth params' do
      conf = {'keystone_authtoken' => {'invalid_value' => 'foo'}}
      klass.expects(:neutron_conf).returns(conf)
      expect do
       klass.neutron_credentials
      end.to raise_error(Puppet::Error, credential_error)
    end


  end

  describe 'when invoking the neutron cli' do

    it 'should set auth credentials in the environment' do
      authenv = {
        :OS_AUTH_URL            => credential_hash['auth_url'],
        :OS_USERNAME            => credential_hash['username'],
        :OS_PROJECT_NAME        => credential_hash['project_name'],
        :OS_PASSWORD            => credential_hash['password'],
        :OS_PROJECT_DOMAIN_NAME => credential_hash['project_domain_name'],
        :OS_USER_DOMAIN_NAME    => credential_hash['user_domain_name'],
      }
      klass.expects(:get_neutron_credentials).with().returns(credential_hash)
      klass.expects(:withenv).with(authenv)
      klass.auth_neutron('test_retries')
    end

    it 'should set region in the environment if needed' do
      authenv = {
        :OS_AUTH_URL            => credential_hash['auth_url'],
        :OS_USERNAME            => credential_hash['username'],
        :OS_PROJECT_NAME        => credential_hash['project_name'],
        :OS_PASSWORD            => credential_hash['password'],
        :OS_REGION_NAME         => 'REGION_NAME',
        :OS_PROJECT_DOMAIN_NAME => credential_hash['project_domain_name'],
        :OS_USER_DOMAIN_NAME    => credential_hash['user_domain_name'],
      }

      cred_hash = credential_hash.merge({'region_name' => 'REGION_NAME'})
      klass.expects(:get_neutron_credentials).with().returns(cred_hash)
      klass.expects(:withenv).with(authenv)
      klass.auth_neutron('test_retries')
    end

    ['[Errno 111] Connection refused',
     '400-{\'message\': \'\'}',
     '(HTTP 400)',
     '503 Service Unavailable',
     '504 Gateway Time-out',
     'Maximum attempts reached',
     'Unauthorized: bad credentials',
     'Max retries exceeded'].reverse.each do |valid_message|
      it "should retry when neutron cli returns with error #{valid_message}" do
        klass.expects(:get_neutron_credentials).with().returns({})
        klass.expects(:sleep).with(2).returns(nil)
        klass.expects(:neutron).twice.with(['test_retries']).raises(
          Puppet::ExecutionFailure, valid_message).then.returns('')
        klass.auth_neutron('test_retries')
      end
    end

  end

  describe 'when listing neutron resources' do

    it 'should exclude the column header' do
      output = <<-EOT
id
net1
net2
      EOT
      klass.expects(:auth_neutron).returns(output)
      result = klass.list_neutron_resources('foo')
      expect(result).to eql(['net1', 'net2'])
    end

    it 'should return empty list when there are no neutron resources' do
      output = <<-EOT
      EOT
      klass.stubs(:auth_neutron).returns(output)
      result = klass.list_neutron_resources('foo')
      expect(result).to eql([])
    end

    it 'should fail if resources list is nil' do
      klass.stubs(:auth_neutron).returns(nil)
      expect do
        klass.list_neutron_resources('foo')
      end.to raise_error(Puppet::Error, exec_error)
    end

  end

  describe 'when retrieving attributes for neutron resources' do

    it 'should parse single-valued attributes into a key-value pair' do
      klass.expects(:auth_neutron).returns('admin_state_up="True"')
      result = klass.get_neutron_resource_attrs('foo', 'id')
      expect(result).to eql({"admin_state_up" => 'True'})
    end

    it 'should parse multi-valued attributes into a key-list pair' do
      output = <<-EOT
subnets="subnet1
subnet2
subnet3"
      EOT
      klass.expects(:auth_neutron).returns(output)
      result = klass.get_neutron_resource_attrs('foo', 'id')
      expect(result).to eql({"subnets" => ['subnet1', 'subnet2', 'subnet3']})
    end

  end

  describe 'when parsing creation output' do

    it 'should parse valid output into a hash' do
      data = <<-EOT
Created a new network:
admin_state_up="True"
id="5f9cbed2-d31c-4e9c-be92-87229acb3f69"
name="foo"
tenant_id="3056a91768d948d399f1d79051a7f221"
      EOT
      expected = {
        'admin_state_up' => 'True',
        'id'             => '5f9cbed2-d31c-4e9c-be92-87229acb3f69',
        'name'           => 'foo',
        'tenant_id'      => '3056a91768d948d399f1d79051a7f221',
      }
      expect(klass.parse_creation_output(data)).to eq(expected)
    end

  end

  describe 'garbage in the csv output' do
    it '#list_neutron_resources' do
      output = <<-EOT
/usr/lib/python2.7/dist-packages/urllib3/util/ssl_.py:90: InsecurePlatformWarning: A true SSLContext object is not available. This prevents urllib3 from configuring SSL appropriately and may cause certain SSL connections to fail. For more information, see https://urllib3.readthedocs.org/en/latest/security.html#insecureplatformwarning.
  InsecurePlatformWarning
id
4a305398-d806-46c5-a6aa-dcd6a4a99330
      EOT
      klass.expects(:auth_neutron).
        with('subnet-list', '--format=csv', '--column=id', '--quote=none').
        returns(output)
      expected = ['4a305398-d806-46c5-a6aa-dcd6a4a99330']
      result = klass.list_neutron_resources('subnet')
      expect(result).to eql(expected)
    end
  end
end
