require File.join(File.dirname(__FILE__), '..','..','..',
                  'puppet/provider/neutron')

Puppet::Type.type(:neutron_router).provide(
  :openstack,
  :parent => Puppet::Provider::Neutron
) do
  desc <<-EOT
    Neutron provider to manage neutron_router type.

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
    list = request('router', 'list').collect do |attrs|
      router = request('router', 'show', attrs[:id])
      new(
        :ensure                 => :present,
        :name                   => attrs[:name],
        :id                     => attrs[:id],
        :admin_state_up         => router[:admin_state_up],
        :external_gateway_info  => router[:external_gateway_info],
        :status                 => router[:status],
        :distributed            => router[:distributed],
        :ha                     => router[:ha],
        :tenant_id              => router[:project_id],
        :availability_zone_hint => parse_availability_zone_hint(router[:availability_zone_hints])
      )
    end
    self.do_not_manage = false
    list
  end

  def self.prefetch(resources)
    routers = instances
    resources.keys.each do |name|
      if provider = routers.find{ |router| router.name == name }
        resources[name].provider = provider
      end
    end
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def create
    if self.class.do_not_manage
      fail("Not managing Neutron_router[#{@resource[:name]}] due to earlier Neutron API failures.")
    end

    opts = [@resource[:name]]

    if @resource[:admin_state_up] == 'False'
      opts << '--disable'
    end

    if @resource[:tenant_name]
      opts << "--project=#{@resource[:tenant_name]}"
    elsif @resource[:tenant_id]
      opts << "--project=#{@resource[:tenant_id]}"
    end

    if @resource[:distributed]
      if @resource[:distributed] == 'False'
        opts << '--centralized'
      else
        opts << '--distributed'
      end
    end

    if @resource[:ha]
      if @resource[:ha] == 'False'
        opts << '--no-ha'
      else
        opts << '--ha'
      end
    end

    if @resource[:availability_zone_hint]
      opts << \
        "--availability-zone-hint=#{@resource[:availability_zone_hint]}"
    end

    router = self.class.request('router', 'create', opts)

    if @resource[:gateway_network_id]
      self.class.request('router', 'set',
                         [@resource[:name],
                          "--external-gateway=#{@resource[:gateway_network_id]}"])
      router = self.class.request('router', 'show', [@resource[:name]])
    elsif @resource[:gateway_network_name]
      self.class.request('router', 'set',
                         [@resource[:name],
                          "--external-gateway=#{@resource[:gateway_network_name]}"])
      router = self.class.request('router', 'show', [@resource[:name]])
    end

    @property_hash = {
      :ensure                 => :present,
      :name                   => router[:name],
      :id                     => router[:id],
      :admin_state_up         => router[:admin_state_up],
      :external_gateway_info  => router[:external_gateway_info],
      :status                 => router[:status],
      :distributed            => router[:distributed],
      :ha                     => router[:ha],
      :tenant_id              => router[:project_id],
      :availability_zone_hint => self.class.parse_availability_zone_hint(router[:availability_zone_hints])
    }
  end

  def flush
    if !@property_flush.empty?
      opts = [@resource[:name]]
      clear_opts = [@resource[:name]]

      if @property_flush.has_key?(:admin_state_up)
        if @property_flush[:admin_state_up] == 'False'
          opts << '--disable'
        else
          opts << '--enable'
        end
      end

      if @property_flush.has_key?(:distributed)
        if @property_flush[:distributed] == 'False'
          opts << '--centralized'
        else
          opts << '--distributed'
        end
      end

      if @property_flush.has_key?(:gateway_network_id)
        if @property_flush[:gateway_network_id] == ''
          clear_opts << '--external-gateway'
        else
          opts << "--external-gateway=#{@property_flush[:gateway_network_id]}"
        end
      elsif @property_flush.has_key?(:gateway_network_name)
        if @property_flush[:gateway_network_name] == ''
          clear_opts << '--external-gateway'
        else
          opts << "--external-gateway=#{@property_flush[:gateway_network_name]}"
        end
      end

      if @property_flush.has_key?(:ha)
        if @property_flush[:ha] == 'False'
          opts << '--no-ha'
        else
          opts << '--ha'
        end
      end

      if clear_opts.length > 1
        self.class.request('router', 'unset', clear_opts)
      end
      if opts.length > 1
        self.class.request('router', 'set', opts)
      end
      @property_flush.clear
    end
  end

  def destroy
    if self.class.do_not_manage
      fail("Not managing Neutron_router[#{@resource[:name]}] due to earlier Neutron API failures.")
    end
    self.class.request('router', 'delete', @resource[:name])
    @property_flush.clear
    @property_flush[:ensure] = :absent
  end

  [
    :admin_state_up,
    :gateway_network_id,
    :gateway_network_name,
    :distributed,
    :ha,
  ].each do |attr|
    define_method(attr.to_s + "=") do |value|
      if self.class.do_not_manage
        fail("Not managing Neutron_router[#{@resource[:name]}] due to earlier Neutron API failures.")
      end
      @property_flush[attr] = value
    end
  end

  [
    :availability_zone_hint,
    :tenant_id,
    :tenant_name,
  ].each do |attr|
    define_method(attr.to_s + "=") do |value|
      fail("Property #{attr.to_s} does not support being updated")
    end
  end

end
