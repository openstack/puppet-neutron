require File.join(File.dirname(__FILE__), '..','..','..',
                  'puppet/provider/neutron')

Puppet::Type.type(:neutron_subnet).provide(
  :openstack,
  :parent => Puppet::Provider::Neutron
) do
  desc <<-EOT
    Neutron provider to manage neutron_subnet type.

    Assumes that the neutron service is configured on the same host.
  EOT

  @credentials = Puppet::Provider::Openstack::CredentialsV3.new

  mk_resource_methods

  def initialize(value={})
    super(value)
    @property_flush = {}
  end

  def self.do_not_manage
    @do_not_manage
  end

  def self.do_not_manage=(value)
    @do_not_manage = value
  end

  def self.instances
    self.do_not_manage = true
    list = request('subnet', 'list').collect do |attrs|
      subnet = request('subnet', 'show', attrs[:id])
      new(
        :ensure            => :present,
        :name              => attrs[:name],
        :id                => attrs[:id],
        :cidr              => subnet[:cidr],
        :ip_version        => subnet[:ip_version],
        :ipv6_ra_mode      => subnet[:ipv6_ra_mode],
        :ipv6_address_mode => subnet[:ipv6_address_mode],
        :gateway_ip        => parse_gateway_ip(subnet[:gateway_ip]),
        :allocation_pools  => parse_allocation_pool(subnet[:allocation_pools]),
        :host_routes       => parse_host_routes(subnet[:host_routes]),
        :dns_nameservers   => parse_dns_nameservers(subnet[:dns_nameservers]),
        :enable_dhcp       => subnet[:enable_dhcp],
        :network_id        => subnet[:network_id],
        :network_name      => get_network_name(subnet[:network_id]),
        :tenant_id         => subnet[:project_id],
        :project_id        => subnet[:project_id],
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
    return [] if values.empty? or values == '[]'
    values = values.gsub('[', '').gsub(']', '')
    for value in Array(values)
      allocation_pool = JSON.parse(value.gsub(/\\"/,'"').gsub('\'','"'))
      start_ip = allocation_pool['start']
      end_ip = allocation_pool['end']
      allocation_pools << "start=#{start_ip},end=#{end_ip}"
    end
    return allocation_pools
  end

  def self.parse_host_routes(values)
    host_routes = []
    return [] if values.empty? or values == '[]'
    values = values.gsub('[', '').gsub(']', '')
    for value in Array(values)
      host_route = JSON.parse(value.gsub(/\\"/,'"').gsub('\'','"'))
      nexthop = host_route['nexthop']
      destination = host_route['destination']
      host_routes << "destination=#{destination},nexthop=#{nexthop}"
    end
    return host_routes
  end

  def self.parse_dns_nameservers(values)
    if values.is_a? String
        values = values.gsub('\'','').gsub('[', '').gsub(']', '')
                       .gsub(',', '').split(' ')
    end
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

    opts = [@resource[:name]]

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
        opts << '--gateway=none'
      else
        opts << "--gateway=#{@resource[:gateway_ip]}"
      end
    end

    if @resource[:enable_dhcp] == 'False'
      opts << "--no-dhcp"
    else
      opts << "--dhcp"
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
      opts << "--project=#{@resource[:tenant_name]}"
    elsif @resource[:tenant_id]
      opts << "--project=#{@resource[:tenant_id]}"
    elsif @resource[:project_name]
      opts << "--project=#{@resource[:project_name]}"
    elsif @resource[:project_id]
      opts << "--project=#{@resource[:project_id]}"
    end

    if @resource[:network_name]
      opts << "--network=#{@resource[:network_name]}"
    elsif @resource[:network_id]
      opts << "--network=#{@resource[:network_id]}"
    end

    opts << "--subnet-range=#{@resource[:cidr]}"

    subnet = self.class.request('subnet', 'create', opts)
    @property_hash = {
      :ensure            => :present,
      :name              => subnet[:name],
      :id                => subnet[:id],
      :cidr              => subnet[:cidr],
      :ip_version        => subnet[:ip_version],
      :ipv6_ra_mode      => subnet[:ipv6_ra_mode],
      :ipv6_address_mode => subnet[:ipv6_address_mode],
      :gateway_ip        => self.class.parse_gateway_ip(subnet[:gateway_ip]),
      :allocation_pools  => self.class.parse_allocation_pool(subnet[:allocation_pools]),
      :host_routes       => self.class.parse_host_routes(subnet[:host_routes]),
      :dns_nameservers   => self.class.parse_dns_nameservers(subnet[:dns_nameservers]),
      :enable_dhcp       => subnet[:enable_dhcp],
      :network_id        => subnet[:network_id],
      :network_name      => self.class.get_network_name(subnet[:network_id]),
      :tenant_id         => subnet[:project_id],
      :project_id        => subnet[:project_id],
    }
  end

  def flush
    if !@property_flush.empty?
      opts = [@resource[:name]]
      clear_opts = [@resource[:name]]

      if @property_flush.has_key?(:gateway_ip)
        if @property_flush[:gateway_ip] == ''
          opts << '--gateway=none'
        else
          opts << "--gateway=#{@property_flush[:gateway_ip]}"
        end
      end

      if @property_flush.has_key?(:enable_dhcp)
        if @property_flush[:enable_dhcp] == 'False'
          opts << '--no-dhcp'
        else
          opts << '--dhcp'
        end
      end

      if @property_flush.has_key?(:allocation_pools)
        clear_opts << '--no-allocation-pool'
        Array(@property_flush[:allocation_pools]).each do |allocation_pool|
          opts << "--allocation-pool=#{allocation_pool}"
        end
      end

      if @property_flush.has_key?(:dns_nameservers)
        clear_opts << '--no-dns-nameservers'
        Array(@property_flush[:dns_nameservers]).each do |nameserver|
          opts << "--dns-nameserver=#{nameserver}"
        end
      end

      if @property_flush.has_key?(:host_routes)
        clear_opts << '--no-host-route'
        Array(@property_flush[:host_routes]).each do |host_route|
          opts << "--host-route=#{host_route}"
        end
      end

      if clear_opts.length > 1
        self.class.request('subnet', 'set', clear_opts)
      end
      if opts.length > 1
        self.class.request('subnet', 'set', opts)
      end
      @property_flush.clear
    end
  end

  def destroy
    if self.class.do_not_manage
      fail("Not managing Neutron_subnet[#{@resource[:name]}] due to earlier Neutron API failures.")
    end
    self.class.request('subnet', 'delete', @resource[:name])
    @property_hash.clear
    @property_hash[:ensure] = :absent
  end

  [
    :gateway_ip,
    :enable_dhcp,
    :allocation_pools,
    :dns_nameservers,
    :host_routes,
  ].each do |attr|
    define_method(attr.to_s + "=") do |value|
      if self.class.do_not_manage
        fail("Not managing Neutron_network[#{@resource[:name]}] due to earlier Neutron API failures.")
      end
      @property_flush[attr] = value
    end
  end

  [
   :cidr,
   :ip_version,
   :ipv6_ra_mode,
   :ipv6_address_mode,
   :network_id,
   :tenant_id,
   :tenant_name,
   :project_id,
   :project_name,
  ].each do |attr|
    define_method(attr.to_s + "=") do |value|
      fail("Property #{attr.to_s} does not support being updated")
    end
  end

end
