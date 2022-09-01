require 'spec_helper_acceptance'

describe 'basic neutron' do

  context 'default parameters' do

    it 'should work with no errors' do
      pp= <<-EOS
      include openstack_integration
      include openstack_integration::repos
      include openstack_integration::apache
      include openstack_integration::rabbitmq
      include openstack_integration::mysql
      include openstack_integration::memcached
      include openstack_integration::keystone
      include openstack_integration::neutron

      neutron_network { 'mtutest':
        mtu => 1000,
      }
      EOS


      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    describe port(9696) do
      it { is_expected.to be_listening }
    end

    describe 'test Neutron OVS agent bridges' do
      it 'should list OVS bridges' do
        command("ovs-vsctl show") do |r|
          expect(r.stdout).to match(/br-int/)
          expect(r.stdout).to match(/br-tun/)
        end
      end
    end

  end
end
