require 'puppet/provider/openstack'
require 'puppet/provider/openstack/auth'
require 'puppet/provider/openstack/credentials'

class Puppet::Provider::Neutron < Puppet::Provider::Openstack

  extend Puppet::Provider::Openstack::Auth

  initvars

  def self.get_network_name(id)
    network = self.request('network', 'show', [id])
    return network[:name]
  end

  def self.get_subnet_name(id)
    subnet = self.request('subnet', 'show', [id])
    return subnet[:name]
  end

  def self.parse_subnet_id(value)
    fixed_ips = parse_python_list(value)
    subnet_ids = []
    fixed_ips.each do |fixed_ip|
      subnet_ids << fixed_ip['subnet_id']
    end
    # TODO(tkajinam): Support multiple values
    subnet_ids.first
  end

  def self.parse_availability_zone_hint(value)
    hints = parse_python_list(value)
    # TODO(tkajinam): Support multiple values
    hints.first
  end

  def self.parse_boolean(value)
    if value.nil?
      nil
    else
      value.downcase.chomp == 'true' ? :true : :false
    end
  end
end
