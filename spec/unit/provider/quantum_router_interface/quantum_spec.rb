require 'puppet'
require 'spec_helper'
require 'puppet/provider/quantum_router_interface/quantum'

provider_class = Puppet::Type.type(:quantum_router_interface).
  provider(:quantum)

describe provider_class do

  let :interface_attrs do
    {
      :name            => 'router:subnet',
      :ensure          => 'present',
    }
  end

  describe 'when accessing attributes of an interface' do
    let :resource do
      Puppet::Type::Quantum_router_interface.new(interface_attrs)
    end

    let :provider do
      provider_class.new(resource)
    end

    it 'should return the correct router name' do
      provider.router_name.should eql('router')
    end

    it 'should return the correct subnet name' do
      provider.subnet_name.should eql('subnet')
    end

  end

end
