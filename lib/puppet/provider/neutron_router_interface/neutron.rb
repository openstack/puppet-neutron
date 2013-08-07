require File.join(File.dirname(__FILE__), '..','..','..',
                  'puppet/provider/neutron')

Puppet::Type.type(:neutron_router_interface).provide(
  :neutron,
  :parent => Puppet::Provider::Neutron
) do
  desc <<-EOT
    Neutron provider to manage neutron_router_interface type.

    Assumes that the neutron service is configured on the same host.

    It is not possible to manage an interface for the subnet used by
    the gateway network, and such an interface will appear in the list
    of resources ('puppet resource [type]').  Attempting to manage the
    gateway interfae will result in an error.

  EOT

  commands :neutron => 'neutron'

  mk_resource_methods

  def self.instances
    subnet_name_hash = {}
    Puppet::Type.type('neutron_subnet').instances.each do |instance|
      subnet_name_hash[instance.provider.id] = instance.provider.name
    end
    instances_ = []
    Puppet::Type.type('neutron_router').instances.each do |instance|
      list_router_ports(instance.provider.id).each do |port_hash|
        router_name = instance.provider.name
        subnet_name = subnet_name_hash[port_hash['subnet_id']]
        name = "#{router_name}:#{subnet_name}"
        instances_ << new(
            :ensure                    => :present,
            :name                      => name,
            :id                        => port_hash['id']
            )
      end
    end
    return instances_
  end

  def self.prefetch(resources)
    instances_ = instances
    resources.keys.each do |name|
      if provider = instances_.find{ |instance| instance.name == name }
        resources[name].provider = provider
      end
    end
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def create
    results = auth_neutron("router-interface-add", '--format=shell',
                           resource[:name].split(':', 2))

    if results =~ /Added interface.* to router/
      @property_hash = {
        :ensure => :present,
        :name   => resource[:name],
      }
    else
      fail("did not get expected message on interface addition, got #{results}")
    end
  end

  def router_name
    name.split(':', 2).first
  end

  def subnet_name
    name.split(':', 2).last
  end

  def id
    # TODO: Need to look this up for newly-added resources since it is
    # not returned on creation
  end

  def destroy
    auth_neutron('router-interface-delete', router_name, subnet_name)
    @property_hash[:ensure] = :absent
  end

end
