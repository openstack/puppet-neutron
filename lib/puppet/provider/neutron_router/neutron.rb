require File.join(File.dirname(__FILE__), '..','..','..',
                  'puppet/provider/neutron')

Puppet::Type.type(:neutron_router).provide(
  :neutron,
  :parent => Puppet::Provider::Neutron
) do
  desc <<-EOT
    Neutron provider to manage neutron_router type.

    Assumes that the neutron service is configured on the same host.
  EOT

  mk_resource_methods

  def self.do_not_manage
    @do_not_manage
  end

  def self.do_not_manage=(value)
    @do_not_manage = value
  end

  def self.instances
    self.do_not_manage = true
    list = list_neutron_resources('router').collect do |id|
      attrs = get_neutron_resource_attrs('router', id)
      new(
        :ensure                    => :present,
        :name                      => attrs['name'],
        :id                        => attrs['id'],
        :admin_state_up            => attrs['admin_state_up'],
        :external_gateway_info     => attrs['external_gateway_info'],
        :status                    => attrs['status'],
        :distributed               => attrs['distributed'],
        :ha                        => attrs['ha'],
        :tenant_id                 => attrs['tenant_id'],
        :availability_zone_hint    => attrs['availability_zone_hint']
      )
    end
    self.do_not_manage = false
    list
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
    if self.class.do_not_manage
      fail("Not managing Neutron_router[#{@resource[:name]}] due to earlier Neutron API failures.")
    end

    opts = Array.new

    if @resource[:admin_state_up] == 'False'
      opts << '--admin-state-down'
    end

    if @resource[:tenant_name]
      tenant_id = self.class.get_tenant_id(@resource.catalog,
                                           @resource[:tenant_name])
      opts << "--tenant_id=#{tenant_id}"
    elsif @resource[:tenant_id]
      opts << "--tenant_id=#{@resource[:tenant_id]}"
    end

    if @resource[:distributed]
      opts << "--distributed=#{@resource[:distributed]}"
    end

    if @resource[:ha]
      opts << "--ha=#{@resource[:ha]}"
    end

    if @resource[:availability_zone_hint]
      opts << "--availability-zone-hint=#{@resource[:availability_zone_hint]}"
    end

    results = auth_neutron("router-create", '--format=shell',
                           opts, resource[:name])

    attrs = self.class.parse_creation_output(results)
    @property_hash = {
      :ensure                    => :present,
      :name                      => resource[:name],
      :id                        => attrs['id'],
      :admin_state_up            => attrs['admin_state_up'],
      :external_gateway_info     => attrs['external_gateway_info'],
      :status                    => attrs['status'],
      :tenant_id                 => attrs['tenant_id'],
      :availability_zone_hint    => attrs['availability_zone_hint']
    }

    if @resource[:gateway_network_name]
      results = auth_neutron('router-gateway-set',
                             @resource[:name],
                             @resource[:gateway_network_name])
      attrs = self.class.get_neutron_resource_attrs('router',
                                                    @resource[:name])
      @property_hash[:external_gateway_info] = \
        attrs['external_gateway_info']
    end
  end

  def destroy
    if self.class.do_not_manage
      fail("Not managing Neutron_router[#{@resource[:name]}] due to earlier Neutron API failures.")
    end
    auth_neutron('router-delete', name)
    @property_hash[:ensure] = :absent
  end

  def gateway_network_name
    if @gateway_network_name == nil and gateway_network_id
      Puppet::Type.type('neutron_network').instances.each do |instance|
        if instance.provider.id == gateway_network_id
          @gateway_network_name = instance.provider.name
        end
      end
    end
    @gateway_network_name
  end

  def gateway_network_name=(value)
    if self.class.do_not_manage
      fail("Not managing Neutron_router[#{@resource[:name]}] due to earlier Neutron API failures.")
    end
    if value == ''
      auth_neutron('router-gateway-clear', name)
    else
      auth_neutron('router-gateway-set', name, value)
    end
  end

  def parse_gateway_network_id(external_gateway_info_)
    match_data = /\{"network_id": "(.*?)"/.match(external_gateway_info_.gsub(/\\"/,'"'))
    if match_data
      match_data[1]
    else
      ''
    end
  end

  def gateway_network_id
    @gateway_network_id ||= parse_gateway_network_id(external_gateway_info)
  end

  def admin_state_up=(value)
    if self.class.do_not_manage
      fail("Not managing Neutron_router[#{@resource[:name]}] due to earlier Neutron API failures.")
    end
    set_admin_state_up(value)
  end

  def set_admin_state_up(value)
    auth_neutron('router-update', "--admin-state-up=#{value}", name)
  end

  def distributed=(value)
    if self.class.do_not_manage
      fail("Not managing Neutron_router[#{@resource[:name]}] due to earlier Neutron API failures.")
    end
    results = auth_neutron("router-show", '--format=shell', resource[:name])
    attrs = self.class.parse_creation_output(results)
    set_admin_state_up(false)
    auth_neutron('router-update', "--distributed=#{value}", name)
    if attrs['admin_state_up'] == 'True'
      set_admin_state_up(true)
    end
  end

  def ha=(value)
    if self.class.do_not_manage
      fail("Not managing Neutron_router[#{@resource[:name]}] due to earlier Neutron API failures.")
    end
    results = auth_neutron("router-show", '--format=shell', resource[:name])
    attrs = self.class.parse_creation_output(results)
    set_admin_state_up(false)
    auth_neutron('router-update', "--ha=#{value}", name)
    if attrs['admin_state_up'] == 'True'
      set_admin_state_up(true)
    end
  end

  def availability_zone_hint=(value)
    if self.class.do_not_manage
      fail("Not managing Neutron_router[#{@resource[:name]}] due to earlier Neutron API failures.")
    end
    results = auth_neutron("router-show", '--format=shell', resource[:name])
    attrs = self.class.parse_creation_output(results)
    set_admin_state_up(false)
    auth_neutron('router-update', "--availability-zone-hint=#{value}", name)
    if attrs['admin_state_up'] == 'True'
      set_admin_state_up(true)
    end
  end
end
