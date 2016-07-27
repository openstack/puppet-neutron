require 'json'
require File.join(File.dirname(__FILE__), '..','..','..',
                  'puppet/provider/neutron')

Puppet::Type.type(:neutron_subnet).provide(
  :neutron,
  :parent => Puppet::Provider::Neutron
) do
  desc <<-EOT
    Neutron provider to manage neutron_subnet type.

    Assumes that the neutron service is configured on the same host.
  EOT

  mk_resource_methods

  def self.neutron_type
    'subnet'
  end

  def self.do_not_manage
    @do_not_manage
  end

  def self.do_not_manage=(value)
    @do_not_manage = value
  end

  def self.instances
    self.do_not_manage = true
    list = list_neutron_resources(neutron_type).collect do |id|
      attrs = get_neutron_resource_attrs(neutron_type, id)
      new(
        :ensure                    => :present,
        :name                      => attrs['name'],
        :id                        => attrs['id'],
        :cidr                      => attrs['cidr'],
        :ip_version                => attrs['ip_version'],
        :ipv6_ra_mode              => attrs['ipv6_ra_mode'],
        :ipv6_address_mode         => attrs['ipv6_address_mode'],
        :gateway_ip                => parse_gateway_ip(attrs['gateway_ip']),
        :allocation_pools          => parse_allocation_pool(attrs['allocation_pools']),
        :host_routes               => parse_host_routes(attrs['host_routes']),
        :dns_nameservers           => parse_dns_nameservers(attrs['dns_nameservers']),
        :enable_dhcp               => attrs['enable_dhcp'],
        :network_id                => attrs['network_id'],
        :tenant_id                 => attrs['tenant_id']
      )
    end
    self.do_not_manage = false
    list
  end

  def self.prefetch(resources)
    subnets = instances
    resources.keys.each do |name|
      if provider = subnets.find{ |subnet| subnet.name == name }
        resources[name].provider = provider
      end
    end
  end

  def self.parse_gateway_ip(value)
    return '' if value.nil?
    return value
  end

  def self.parse_allocation_pool(values)
    allocation_pools = []
    return [] if values.empty?
    for value in Array(values)
      allocation_pool = JSON.parse(value.gsub(/\\"/,'"'))
      start_ip = allocation_pool['start']
      end_ip = allocation_pool['end']
      allocation_pools << "start=#{start_ip},end=#{end_ip}"
    end
    return allocation_pools
  end

  def self.parse_host_routes(values)
    host_routes = []
    return [] if values.empty?
    for value in Array(values)
      host_route = JSON.parse(value.gsub(/\\"/,'"'))
      nexthop = host_route['nexthop']
      destination = host_route['destination']
      host_routes << "nexthop=#{nexthop},destination=#{destination}"
    end
    return host_routes
  end

  def self.parse_dns_nameservers(values)
    # just enforce that this is actually an array
    return Array(values)
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def create
    if self.class.do_not_manage
      fail("Not managing Neutron_subnet[#{@resource[:name]}] due to earlier Neutron API failures.")
    end

    opts = ["--name=#{@resource[:name]}"]

    if @resource[:ip_version]
      opts << "--ip-version=#{@resource[:ip_version]}"
    end

    if @resource[:ipv6_ra_mode]
      opts << "--ipv6-ra-mode=#{@resource[:ipv6_ra_mode]}"
    end

    if @resource[:ipv6_address_mode]
      opts << "--ipv6-address-mode=#{@resource[:ipv6_address_mode]}"
    end

    if @resource[:gateway_ip]
      if @resource[:gateway_ip] == ''
        opts << '--no-gateway'
      else
        opts << "--gateway-ip=#{@resource[:gateway_ip]}"
      end
    end

    if @resource[:enable_dhcp] == 'False'
      opts << "--disable-dhcp"
    else
      opts << "--enable-dhcp"
    end

    if @resource[:allocation_pools]
      Array(@resource[:allocation_pools]).each do |allocation_pool|
        opts << "--allocation-pool=#{allocation_pool}"
      end
    end

    if @resource[:dns_nameservers]
      Array(@resource[:dns_nameservers]).each do |nameserver|
        opts << "--dns-nameserver=#{nameserver}"
      end
    end

    if @resource[:host_routes]
      Array(@resource[:host_routes]).each do |host_route|
        opts << "--host-route=#{host_route}"
      end
    end

    if @resource[:tenant_name]
      tenant_id = self.class.get_tenant_id(@resource.catalog,
                                           @resource[:tenant_name])
      opts << "--tenant_id=#{tenant_id}"
    elsif @resource[:tenant_id]
      opts << "--tenant_id=#{@resource[:tenant_id]}"
    end

    if @resource[:network_name]
      opts << resource[:network_name]
    elsif @resource[:network_id]
      opts << resource[:network_id]
    end

    results = auth_neutron('subnet-create', '--format=shell',
                           opts, resource[:cidr])

    attrs = self.class.parse_creation_output(results)
    @property_hash = {
      :ensure                    => :present,
      :name                      => resource[:name],
      :id                        => attrs['id'],
      :cidr                      => attrs['cidr'],
      :ip_version                => attrs['ip_version'],
      :ipv6_ra_mode              => attrs['ipv6_ra_mode'],
      :ipv6_address_mode         => attrs['ipv6_address_mode'],
      :gateway_ip                => self.class.parse_gateway_ip(attrs['gateway_ip']),
      :allocation_pools          => self.class.parse_allocation_pool(attrs['allocation_pools']),
      :host_routes               => self.class.parse_host_routes(attrs['host_routes']),
      :dns_nameservers           => self.class.parse_dns_nameservers(attrs['dns_nameservers']),
      :enable_dhcp               => attrs['enable_dhcp'],
      :network_id                => attrs['network_id'],
      :tenant_id                 => attrs['tenant_id'],
    }
  end

  def destroy
    if self.class.do_not_manage
      fail("Not managing Neutron_subnet[#{@resource[:name]}] due to earlier Neutron API failures.")
    end
    auth_neutron('subnet-delete', name)
    @property_hash[:ensure] = :absent
  end

  def gateway_ip=(value)
    if self.class.do_not_manage
      fail("Not managing Neutron_subnet[#{@resource[:name]}] due to earlier Neutron API failures.")
    end
    if value == ''
      auth_neutron('subnet-update', '--no-gateway', name)
    else
      auth_neutron('subnet-update', "--gateway-ip=#{value}", name)
    end
  end

  def enable_dhcp=(value)
    if self.class.do_not_manage
      fail("Not managing Neutron_subnet[#{@resource[:name]}] due to earlier Neutron API failures.")
    end
    if value == 'False'
      auth_neutron('subnet-update', "--disable-dhcp", name)
    else
      auth_neutron('subnet-update', "--enable-dhcp", name)
    end
  end

  def allocation_pools=(values)
    if self.class.do_not_manage
      fail("Not managing Neutron_subnet[#{@resource[:name]}] due to earlier Neutron API failures.")
    end
    unless values.empty?
      opts = ["#{name}", "--allocation-pool"]
      for value in values
        opts << value
      end
      auth_neutron('subnet-update', opts)
    end
  end

  def dns_nameservers=(values)
    if self.class.do_not_manage
      fail("Not managing Neutron_subnet[#{@resource[:name]}] due to earlier Neutron API failures.")
    end
    unless values.empty?
      opts = ["#{name}", "--dns-nameservers", "list=true"]
      for value in values
        opts << value
      end
      auth_neutron('subnet-update', opts)
    end
  end

  def host_routes=(values)
    if self.class.do_not_manage
      fail("Not managing Neutron_subnet[#{@resource[:name]}] due to earlier Neutron API failures.")
    end
    unless values.empty?
      opts = ["#{name}", "--host-routes", "type=dict", "list=true"]
      for value in values
        opts << value
      end
      auth_neutron('subnet-update', opts)
    end
  end

  [
   :cidr,
   :ip_version,
   :ipv6_ra_mode,
   :ipv6_address_mode,
   :network_id,
   :tenant_id,
  ].each do |attr|
     define_method(attr.to_s + "=") do |value|
       fail("Property #{attr.to_s} does not support being updated")
     end
  end

end
