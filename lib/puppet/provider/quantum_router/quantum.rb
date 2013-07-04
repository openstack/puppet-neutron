require File.join(File.dirname(__FILE__), '..','..','..',
                  'puppet/provider/quantum')

Puppet::Type.type(:quantum_router).provide(
  :quantum,
  :parent => Puppet::Provider::Quantum
) do
  desc <<-EOT
    Quantum provider to manage quantum_router type.

    Assumes that the quantum service is configured on the same host.
  EOT

  commands :quantum => 'quantum'

  mk_resource_methods

  def self.instances
    list_quantum_resources('router').collect do |id|
      attrs = get_quantum_resource_attrs('router', id)
      new(
        :ensure                    => :present,
        :name                      => attrs['name'],
        :id                        => attrs['id'],
        :admin_state_up            => attrs['admin_state_up'],
        :external_gateway_info     => attrs['external_gateway_info'],
        :status                    => attrs['status'],
        :tenant_id                 => attrs['tenant_id']
      )
    end
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
    opts = Array.new

    if @resource[:admin_state_up] == 'False'
      opts << '--admin-state-down'
    end

    if @resource[:tenant_name]
      tenant_id = self.class.get_tenant_id(model.catalog,
                                           @resource[:tenant_name])
      opts << "--tenant_id=#{tenant_id}"
    elsif @resource[:tenant_id]
      opts << "--tenant_id=#{@resource[:tenant_id]}"
    end

    results = auth_quantum("router-create", '--format=shell',
                           opts, resource[:name])

    if results =~ /Created a new router:/
      attrs = self.class.parse_creation_output(results)
      @property_hash = {
        :ensure                    => :present,
        :name                      => resource[:name],
        :id                        => attrs['id'],
        :admin_state_up            => attrs['admin_state_up'],
        :external_gateway_info     => attrs['external_gateway_info'],
        :status                    => attrs['status'],
        :tenant_id                 => attrs['tenant_id'],
      }

      if @resource[:gateway_network_name]
        results = auth_quantum('router-gateway-set',
                               @resource[:name],
                               @resource[:gateway_network_name])
        if results =~ /Set gateway for router/
          attrs = self.class.get_quantum_resource_attrs('router',
                                                        @resource[:name])
          @property_hash[:external_gateway_info] = \
            attrs['external_gateway_info']
        else
          fail(<<-EOT
did not get expected message on setting router gateway, got #{results}
EOT
               )
        end
      end
    else
      fail("did not get expected message on router creation, got #{results}")
    end
  end

  def destroy
    auth_quantum('router-delete', name)
    @property_hash[:ensure] = :absent
  end

  def gateway_network_name
    if @gateway_network_name == nil and gateway_network_id
      Puppet::Type.type('quantum_network').instances.each do |instance|
        if instance.provider.id == gateway_network_id
          @gateway_network_name = instance.provider.name
        end
      end
    end
    @gateway_network_name
  end

  def gateway_network_name=(value)
    if value == ''
      auth_quantum('router-gateway-clear', name)
    else
      auth_quantum('router-gateway-set', name, value)
    end
  end

  def parse_gateway_network_id(external_gateway_info_)
    match_data = /\{"network_id": "(.*)"\}/.match(external_gateway_info_)
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
    auth_quantum('router-update', "--admin-state-up=#{value}", name)
  end

end
