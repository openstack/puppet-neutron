require File.join(File.dirname(__FILE__), '..','..','..',
                  'puppet/provider/neutron')

Puppet::Type.type(:neutron_router_interface).provide(
  :openstack,
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

  @credentials = Puppet::Provider::Openstack::CredentialsV3.new

  mk_resource_methods

  def initialize(value={})
    super(value)
  end

  def self.do_not_manage
    @do_not_manage
  end

  def self.do_not_manage=(value)
    @do_not_manage = value
  end

  def self.instances
    self.do_not_manage = true
    subnet_name_hash = {}
    request('subnet', 'list').each do |subnet|
      subnet_name_hash[subnet[:id]] = subnet[:name]
    end

    instances_ = []
    request('router', 'list').each do |router|
      request('port', 'list', ['--router', router[:id]]).each do |port|
        subnet_id_ = parse_subnet_id(port[:fixed_ip_addresses])
        subnet_name_ = subnet_name_hash[subnet_id_]
        router_name_ = router[:name]
        name_ = "#{router_name_}:#{subnet_name_}"
        instances_ << new(
          :ensure => :present,
          :name   => name_,
          :id     => port[:id],
          :port   => port[:name]
        )
      end
    end
    self.do_not_manage = false
    return instances_
  end

  def self.prefetch(resources)
    interfaces = instances
    resources.keys.each do |name|
      if provider = interfaces.find{ |interface| interface.name == name }
        resources[name].provider = provider
      end
    end
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def create
    router, subnet = name.split(':', 2)
    port = resource[:port]
    if port
      self.class.request('router', 'add port', [router, port])
    else
      self.class.request('router', 'add subnet', [router, subnet])
    end
    @property_hash = {
      :ensure => :present,
      :name   => resource[:name]
    }
  end

  def destroy
    if self.class.do_not_manage
      fail("Not managing Neutron_router_interface[#{@resource[:name]}] due to earlier Neutron API failures.")
    end
    router, subnet = name.split(':', 2)
    port = resource[:port]
    if port
      self.class.request('router', 'remove port', [router, port])
    else
      self.class.request('router', 'remove subnet', [router, subnet])
    end
    @property_hash.clear
    @property_hash[:ensure] = :absent
  end

  def router_name
    name.split(':', 2).first
  end

  def subnet_name
    name.split(':', 2).last
  end

end
