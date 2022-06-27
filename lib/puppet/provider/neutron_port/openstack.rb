require File.join(File.dirname(__FILE__), '..','..','..',
                  'puppet/provider/neutron')

Puppet::Type.type(:neutron_port).provide(
  :openstack,
  :parent => Puppet::Provider::Neutron
) do
  desc <<-EOT
    Neutron provider to manage neutron_port type.

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
    list = request('port', 'list').collect do |attrs|
      port = request('port', 'show', attrs[:id])
      port[:name] = port[:id] if port[:name].empty?
      new(
        :ensure          => :present,
        :name            => port[:name],
        :id              => port[:id],
        :status          => port[:status],
        :tenant_id       => port[:project_id],
        :project_id      => port[:project_id],
        :network_id      => port[:network_id],
        :network_name    => get_network_name(port[:network_id]),
        :admin_state_up  => port[:admin_state_up],
        :subnet_id       => parse_subnet_id(port[:fixed_ips]),
        :subnet_name     => get_subnet_name(parse_subnet_id(port[:fixed_ips])),
        :ip_address      => parse_ip_address(port[:fixed_ips]),
        :binding_profile => parse_binding_profile_interface_name(port[:binding_profile]),
        :binding_host_id => port[:binding_host_id],
      )
    end
    self.do_not_manage = false
    list
  end

  def self.prefetch(resources)
    ports = instances
    resources.keys.each do |name|
      if provider = ports.find{ |net| net.name == name }
        resources[name].provider = provider
      end
    end
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def create
    if self.class.do_not_manage
      fail("Not managing Neutron_port[#{@resource[:name]}] due to earlier Neutron API failures.")
    end

    opts = [@resource[:name]]

    if @resource[:network_name]
      opts << "--network=#{@resource[:network_name]}"
    elsif @resource[:network_id]
      opts << "--network=#{@resource[:network_id]}"
    end

    if @resource[:admin_state_up] == 'False'
      opts << '--disable'
    end

    if @resource[:ip_address]
      Array(resource[:ip_address]).each do |ip|
        opts << "--fixed-ip ip_address=#{ip}"
      end
    end

    if @resource[:subnet_name]
      Array(resource[:subnet_name]).each do |subnet|
        opts << "--fixed-ip subnet=#{subnet}"
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

    if @resource[:binding_host_id]
      opts << "--host=#{@resource[:binding_host_id]}"
    end

    if @resource[:binding_profile]
      @resource[:binding_profile].each do |k,v|
        opts << "--binding-profile #{k}=#{v}"
      end
    end

    port = self.class.request('port', 'create', opts)
    @property_hash = {
      :ensure          => :present,
      :name            => port[:name],
      :id              => port[:id],
      :status          => port[:status],
      :tenant_id       => port[:project_id],
      :project_id      => port[:project_id],
      :network_id      => port[:network_id],
      :network_name    => self.class.get_network_name(port[:network_id]),
      :admin_state_up  => port[:admin_state_up],
      :subnet_id       => self.class.parse_subnet_id(port[:fixed_ips]),
      :subnet_name     => self.class.get_subnet_name(self.class.parse_subnet_id(port[:fixed_ips])),
      :ip_address      => self.class.parse_ip_address(port[:fixed_ips]),
      :binding_profile => self.class.parse_binding_profile_interface_name(port[:binding_profile]),
      :binding_host_id => port[:binding_host_id],
    }
  end

  def flush
    if !@property_flush.empty?
      opts = [@resource[:name]]

      if @property_flush.has_key?(:admin_state_up)
        if @property_flush[:admin_state_up] == 'False'
          opts << '--disable'
        else
          opts << '--enable'
        end
      end

      if @property_flush.has_key?(:shared)
        if @property_flush[:shared] == 'False'
          opts << '--no-share'
        else
          opts << '--share'
        end
      end

      if @property_flush.has_key?(:router_external)
        if @property_flush[:router_external] == 'False'
          opts << '--internal'
        else
          opts << '--external'
        end
      end

      if @property_flush.has_key?(:availability_zone_hint)
        opts << "--availability-zone-hint=#{@property_flush[:availability_zone_hint]}"
      end

      self.class.request('port', 'set', opts)
      @property_flush.clear
    end
  end

  def destroy
    if self.class.do_not_manage
      fail("Not managing Neutron_port[#{@resource[:name]}] due to earlier Neutron API failures.")
    end
    self.class.request('port', 'delete', @resource[:name])
    @property_hash.clear
    @property_hash[:ensure] = :absent
  end

  def self.parse_ip_address(value)
    fixed_ips = JSON.parse(value.gsub(/\\"/,'"').gsub('\'','"'))
    ips = []
    fixed_ips.each do |fixed_ip|
      ips << fixed_ip['ip_address']
    end

    if ips.length > 1
      ips
    else
      ips.first
    end
  end

  def self.parse_binding_profile_interface_name(value)
    profile = JSON.parse(value.gsub(/\\"/,'"').gsub('\'','"'))
    profile['interface_name']
  end

  [
    :admin_state_up,
  ].each do |attr|
    define_method(attr.to_s + "=") do |value|
      if self.class.do_not_manage
        fail("Not managing Neutron_port[#{@resource[:name]}] due to earlier Neutron API failures.")
      end
      @property_flush[attr] = value
    end
  end

  [
    :network_id,
    :subnet_id,
    :ip_address,
    :project_id,
    :project_name,
    :tenant_id,
    :tenant_name,
  ].each do |attr|
    define_method(attr.to_s + "=") do |value|
      fail("Property #{attr.to_s} does not support being updated")
    end
  end

end
