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

    it 'should use specified host/port/protocol in the auth endpoint' do
      conf = {'keystone_authtoken' => credential_hash}
      klass.expects(:neutron_conf).returns(conf)
      expect(klass.get_auth_endpoint).to eq(auth_endpoint)
    end

    it 'should find region_name if specified' do
      conf = {
        'keystone_authtoken' => credential_hash,
        'DEFAULT' => { 'nova_region_name' => 'REGION_NAME' }
      }
      klass.expects(:neutron_conf).returns(conf)
      klass.neutron_credentials['nova_region_name'] == 'REGION_NAME'
    end

  end

  describe 'when invoking the neutron cli' do

    it 'should set auth credentials in the environment' do
      authenv = {
        :OS_AUTH_URL    => auth_endpoint,
        :OS_USERNAME    => credential_hash['admin_user'],
        :OS_TENANT_NAME => credential_hash['admin_tenant_name'],
        :OS_PASSWORD    => credential_hash['admin_password'],
      }
      klass.expects(:get_neutron_credentials).with().returns(credential_hash)
      klass.expects(:withenv).with(authenv)
      klass.auth_neutron('test_retries')
    end

    it 'should set region in the environment if needed' do
      authenv = {
        :OS_AUTH_URL    => auth_endpoint,
        :OS_USERNAME    => credential_hash['admin_user'],
        :OS_TENANT_NAME => credential_hash['admin_tenant_name'],
        :OS_PASSWORD    => credential_hash['admin_password'],
        :OS_REGION_NAME => 'REGION_NAME',
      }

      cred_hash = credential_hash.merge({'nova_region_name' => 'REGION_NAME'})
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
        bla-bla-bla

        [{"id": "net1"},{"id": "net2"}]
      EOT
      klass.expects(:auth_neutron).returns(output)
      result = klass.list_neutron_resources('foo')
      expect(result).to eql(['net1', 'net2'])
    end

    it 'should return empty list when there are no neutron resources' do
      output = <<-EOT
        bla-bla-bla

        []

        bla-bla
      EOT
      klass.stubs(:auth_neutron).returns(output)
      result = klass.list_neutron_resources('foo')
      expect(result).to eql([])
    end

    it 'should return empty respons when there are no neutron resources' do
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
      output = <<-EOT
        bla-bla-bla

        [{"Field": "admin_state_up", "Value": true}]
      EOT
      klass.expects(:auth_neutron).returns(output)
      result = klass.get_neutron_resource_attrs('foo', 'id')
      expect(result).to eql({"admin_state_up" => "True"})
    end

    it 'should parse multi-valued attributes into a key-list pair' do
      output = <<-EOT
        bla-bla-bla

        [{"Field": "subnets", "Value": "subnet1\\nsubnet2\\nsubnet3"}]
      EOT
      klass.expects(:auth_neutron).returns(output)
      result = klass.get_neutron_resource_attrs('foo', 'id')
      expect(result).to eql({"subnets" => ['subnet1', 'subnet2', 'subnet3']})
    end

  end

  describe 'when listing router ports' do

    let :router do
      'router1'
    end

    it 'should handle an empty port list' do
      klass.expects(:auth_neutron).with('router-port-list',
                                        '--format=json',
                                        router)
      result = klass.list_router_ports(router)
      expect(result).to eql([])
    end

    it 'should handle several ports' do
      output = '''
        [
            {
                "id": "1345e576-a21f-4c2e-b24a-b245639852ab",
                "name": "",
                "mac_address": "fa:16:3e:e3:e6:38",
                "fixed_ips": "{\"subnet_id\": \"839a1d2d-2c6e-44fb-9a2b-9b011dce8c2f\", \"ip_address\": \"10.0.0.1\"}"
            },
            {
                "id": "de0dc526-02b2-467c-9832-2c3dc69ac2b4",
                "name": "",
                "mac_address": "fa:16:3e:f6:b5:72",
                "fixed_ips": "{\"subnet_id\": \"e4db0abd-276a-4f69-92ea-8b9e4eacfd43\", \"ip_address\": \"172.24.4.226\"}"
            }
        ]
      '''
      expected =
       [{ "name"=>"",
          "subnet_id"=>"839a1d2d-2c6e-44fb-9a2b-9b011dce8c2f",
          "id"=>"1345e576-a21f-4c2e-b24a-b245639852ab",
          "mac_address"=>"fa:16:3e:e3:e6:38"},
        { "name"=>"",
          "subnet_id"=>"e4db0abd-276a-4f69-92ea-8b9e4eacfd43",
          "id"=>"de0dc526-02b2-467c-9832-2c3dc69ac2b4",
          "mac_address"=>"fa:16:3e:f6:b5:72"}]
      klass.expects(:auth_neutron).
        with('router-port-list', '--format=json', router).
        returns(output)
      result = klass.list_router_ports(router)
      expect(result).to eql(expected)
    end


    it 'should handle empty fixed_ips field' do
      output = '''
        [
            {
                "id": "1345e576-a21f-4c2e-b24a-b245639852ab",
                "name": "",
                "mac_address": "fa:16:3e:e3:e6:38",
                "fixed_ips": ""
            }
        ]
      '''
      expected =
       [{ "name"=>"",
          "id"=>"1345e576-a21f-4c2e-b24a-b245639852ab",
          "mac_address"=>"fa:16:3e:e3:e6:38"}]
      klass.expects(:auth_neutron).
        with('router-port-list', '--format=json', router).
        returns(output)
      result = klass.list_router_ports(router)
      expect(result).to eql(expected)
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

  describe 'should parse valid json output, covered by garbage' do

    it 'should parse valid output into a list of hashes' do
      data = '''
        /usr/lib/python2.7/dist-packages/urllib3/util/ssl_.py:90: InsecurePlatformWarning: A true SSLContext object is not available. This prevents urllib3 from configuring SSL appropriately and may cause certain SSL connections to fail. For more information, see https://urllib3.readthedocs.org/en/latest/security.html#insecureplatformwarning.
          InsecurePlatformWarning
        /usr/lib/python2.7/dist-packages/urllib3/connection.py:251: SecurityWarning: Certificate has no `subjectAltName`, falling back to check for a `commonName` for now. This feature is being removed by major browsers and deprecated by RFC 2818. (See https://github.com/shazow/urllib3/issues/497 for details.)
          SecurityWarning
        [{"Field": "allocation_pools", "Value": "{\"start\": \"192.168.111.2\", \"end\": \"192.168.111.254\"}"}, {"Field": "cidr", "Value": "192.168.111.0/24"},
        {"Field": "dns_nameservers", "Value": "8.8.4.4\n8.8.8.8"}, {"Field": "enable_dhcp", "Value": true}, {"Field": "gateway_ip", "Value": "192.168.111.1"}, {"Field": "host_routes", "Value": ""}, {"Field": "id", "Value": "b87fbfd1-0e52-4ab6-8987-286ef0912d1f"}, {"Field": "ip_version", "Value": 4}, {"Field": "ipv6_address_mode", "Value": ""}, {"Field": "ipv6_ra_mode", "Value": ""},
        {"Field": "XXX", "Value":
        [1,
        2,3]},
        {"Field": "name", "Value": "net04__subnet"}, {"Field": "network_id", "Value": "d70b399b-668b-4861-b092-4876ec65df60"}, {"Field": "subnetpool_id", "Value": ""}, {"Field": "tenant_id", "Value": "2764315d0ec24a07bf3773057aa51142"}]
        xxx yyy zz
        eof
      '''
      expected = [
        {"Field"=>"allocation_pools", "Value"=>"{\"start\": \"192.168.111.2\", \"end\": \"192.168.111.254\"}"},
        {"Field"=>"cidr", "Value"=>"192.168.111.0/24"},
        {"Field"=>"dns_nameservers", "Value"=>"8.8.4.4\n8.8.8.8"},
        {"Field"=>"enable_dhcp", "Value"=>true},
        {"Field"=>"gateway_ip", "Value"=>"192.168.111.1"},
        {"Field"=>"host_routes", "Value"=>""},
        {"Field"=>"id", "Value"=>"b87fbfd1-0e52-4ab6-8987-286ef0912d1f"},
        {"Field"=>"ip_version", "Value"=>4},
        {"Field"=>"ipv6_address_mode", "Value"=>""},
        {"Field"=>"ipv6_ra_mode", "Value"=>""},
        {"Field"=>"XXX", "Value"=>[1, 2, 3]},
        {"Field"=>"name", "Value"=>"net04__subnet"},
        {"Field"=>"network_id", "Value"=>"d70b399b-668b-4861-b092-4876ec65df60"},
        {"Field"=>"subnetpool_id", "Value"=>""},
        {"Field"=>"tenant_id", "Value"=>"2764315d0ec24a07bf3773057aa51142"}]
      expect(klass.find_and_parse_json(data)).to eq(expected)
    end
  end

  describe 'should parse valid json output, and convert booleans to idempotent strings' do
    it 'boolean values should converted to capitalized strings' do
      output = '''
        [{"Field": "allocation_pools", "Value": "{\"start\": \"192.168.111.2\", \"end\": \"192.168.111.254\"}"}, {"Field": "cidr", "Value": "192.168.111.0/24"},
        {"Field": "dns_nameservers", "Value": "8.8.4.4\n8.8.8.8"}, {"Field": "enable_dhcp", "Value": true}, {"Field": "gateway_ip", "Value": "192.168.111.1"}, {"Field": "host_routes", "Value": ""}, {"Field": "id", "Value": "b87fbfd1-0e52-4ab6-8987-286ef0912d1f"}, {"Field": "ip_version", "Value": 4}, {"Field": "ipv6_address_mode", "Value": ""}, {"Field": "ipv6_ra_mode", "Value": ""},
        {"Field": "YYY", "Value": false}]
      '''
      klass.stubs(:auth_neutron).returns(output)
      result = klass.get_neutron_resource_attrs 'foo', nil
      expect(result['enable_dhcp']).to eql('True')
      expect(result['YYY']).to eql('False')
    end

    it 'stringifyed boolean values should converted to capitalized strings' do
      output = '''
        [{"Field": "allocation_pools", "Value": "{\"start\": \"192.168.111.2\", \"end\": \"192.168.111.254\"}"}, {"Field": "cidr", "Value": "192.168.111.0/24"},
        {"Field": "dns_nameservers", "Value": "8.8.4.4\n8.8.8.8"}, {"Field": "enable_dhcp", "Value": "True"}, {"Field": "gateway_ip", "Value": "192.168.111.1"}, {"Field": "host_routes", "Value": ""}, {"Field": "id", "Value": "b87fbfd1-0e52-4ab6-8987-286ef0912d1f"}, {"Field": "ip_version", "Value": 4}, {"Field": "ipv6_address_mode", "Value": ""}, {"Field": "ipv6_ra_mode", "Value": ""},
        {"Field": "YYY", "Value": "false"}]
      '''
      klass.stubs(:auth_neutron).returns(output)
      result = klass.get_neutron_resource_attrs 'foo', nil
      expect(result['enable_dhcp']).to eql('True')
      expect(result['YYY']).to eql('False')
    end
  end

end
