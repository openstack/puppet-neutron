require 'puppet'
require 'spec_helper'
require 'puppet/provider/neutron_agent_sriov_numvfs/sriov_numvfs'

provider_class = Puppet::Type.type(:neutron_agent_sriov_numvfs).
  provider(:sriov_numvfs)

describe provider_class do

  let :numvfs_conf do
    {
      :name            => 'eth0:10',
      :ensure          => 'present',
    }
  end

  describe 'when setting the attributes' do
    let :resource do
      Puppet::Type::Neutron_agent_sriov_numvfs.new(numvfs_conf)
    end

    let :provider do
      provider_class.new(resource)
    end

    it 'should return the correct interface name' do
      expect(provider.sriov_get_interface).to eql('eth0')
    end

    it 'should return the correct numvfs value' do
      expect(provider.sriov_numvfs_value).to eql(10)
    end

  end

end
