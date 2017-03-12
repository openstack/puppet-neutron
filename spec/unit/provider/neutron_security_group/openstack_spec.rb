require 'puppet'
require 'spec_helper'
require 'puppet/provider/neutron_security_group/openstack'

provider_class = Puppet::Type.type(:neutron_security_group).provider(:openstack)

describe provider_class do

  let(:set_env) do
    ENV['OS_USERNAME']     = 'admin'
    ENV['OS_PASSWORD']     = 'password'
    ENV['OS_PROJECT_NAME'] = 'admin_tenant'
    ENV['OS_AUTH_URL']     = 'https://192.168.56.210:35357/v2.0/'
  end

  before(:each) do
    set_env
  end

  describe 'managing security group' do
    let(:sec_group_attrs) do
      {
        :name           => 'example',
        :id             => '593db854-a47d-411e-a894-66bf90959768',
        :description    => 'test',
        :project        => '1a2b3c',
        :project_domain => 'Default',
        :ensure         => 'present',
      }
    end

    let :resource do
      Puppet::Type::Neutron_security_group.new(sec_group_attrs)
    end

    let(:provider) do
      provider_class.new(resource)
    end

    describe '#create' do
      it 'creates security group' do
        provider.class.stubs(:openstack)
                      .with('security group', 'list', ['--all'])
                      .returns('"ID", "Name", "Description", "Project"')
        provider.class.stubs(:openstack)
            .with('security group', 'create', 'shell', ['example', 'description', 'test', 'project', '1a2b3c', 'project_domain', 'Default'])
                .returns('created_at="2017-03-15T09:32:03Z"
description="test"
headers=""
id="593db854-a47d-411e-a894-66bf90959768"
name="example"
project_id="1a2b3c"
project_id="1a2b3c"
revision_number="1"
rules="created_at=\'2017-03-15T09:32:03Z\', direction=\'egress\', ethertype=\'IPv4\', id=\'cf462eac-821e-4583-8e91-3294d5be5cce\', project_id=\'1a2b3c\', revision_number=\'1\', updated_at=\'2017-03-15T09:32:03Z\'
created_at=\'2017-03-15T09:32:03Z\', direction=\'egress\', ethertype=\'IPv6\', id=\'afac00e8-4fec-4a1e-8faa-43e2278a0d79\', project_id=\'1a2b3c\', revision_number=\'1\', updated_at=\'2017-03-15T09:32:03Z\'"
updated_at="2017-03-15T09:32:03Z"')
      end
    end

    describe '#destroy' do
      it 'removes security group' do
        provider_class.expects(:openstack)
          .with('security group', 'delete', '593db854-a47d-411e-a894-66bf90959768')
        provider.instance_variable_set(:@property_hash, sec_group_attrs)
        provider.destroy
        expect(provider.exists?).to be_falsey
      end
    end
  end
end
