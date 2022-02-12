Puppet::Type.newtype(:neutron_port) do
  desc <<-EOT
    This is currently used to model the creation of neutron ports.

    Ports are used when associating a network and a router interface.
  EOT

  ensurable

  newparam(:name, :namevar => true) do
    desc 'Symbolic name for the port'
    newvalues(/.*/)
  end

  newproperty(:id) do
    desc 'The unique id of the port'
    validate do |v|
      raise(Puppet::Error, 'This is a read only property')
    end
  end

  newproperty(:admin_state_up) do
    desc 'The administrative status of the router'
    newvalues(/(t|T)rue/, /(f|F)alse/)
    munge do |v|
      v.to_s.capitalize
    end
  end

  newproperty(:network_name) do
    desc <<-EOT
      The name of the network that this port is assigned to on creation.
    EOT
  end

  newproperty(:network_id) do
    desc <<-EOT
      The uuid of the network that this port is assigned to on creation.
    EOT
    validate do |v|
      raise(Puppet::Error, 'This is a read only property')
    end
  end

  newproperty(:subnet_name) do
    desc 'A subnet to which the port is assigned on creation.'
  end

  newproperty(:subnet_id) do
    desc <<-EOT
      The uuid of the subnet on which this ports ip exists.
    EOT
    validate do |v|
      raise(Puppet::Error, 'This is a read only property')
    end
  end

  newproperty(:ip_address) do
    desc 'A static ip address given to the port on creation.'
  end

  newproperty(:status) do
    desc 'Whether the port is currently operational or not.'
    validate do |v|
      raise(Puppet::Error, 'This is a read only property')
    end
  end

  newparam(:project_name) do
    desc 'The name of the project which will own the port.'
  end

  newproperty(:project_id) do
    desc 'A uuid identifying the project which will own the port.'
  end

  newparam(:tenant_name) do
    desc 'The name of the tenant which will own the port.(DEPRECATED)'
  end

  newproperty(:tenant_id) do
    desc 'A uuid identifying the tenant which will own the port.(DEPRECATED)'
  end

  newproperty(:binding_host_id) do
    desc 'A uuid identifying the host where we will bind the port.'
  end

  newproperty(:binding_profile) do
    desc 'A dictionary the enables the application running on the host
          to pass and receive VIF port-specific information to the plug-in.'
    validate do |value|
      unless value.class == Hash
        raise ArgumentError, "Binding profile is not a valid dictionary"
      end
    end
  end

  autorequire(:anchor) do
    ['neutron::service::end']
  end

  autorequire(:keystone_tenant) do
    if self[:tenant_name]
      [self[:tenant_name]]
    else
      [self[:project_name]] if self[:project_name]
    end
  end

  autorequire(:neutron_network) do
    [self[:network_name]]
  end

  autorequire(:neutron_subnet) do
    [self[:subnet_name]] if self[:subnet_name]
  end

  validate do
    if self[:tenant_id]
      warning('The tenant_id property is deprecated. Use project_id.')
    end
    if self[:tenant_name]
      warning('The tenant_name property is deprecated. Use project_id.')
    end

    project_id = self[:tenant_id] or self[:project_id]
    project_name = self[:tenant_name] or self[:project_name]
    if project_id && project_name
      raise(Puppet::Error, <<-EOT
Please provide a value for only one of project_name and project_id.
EOT
            )
    end

    if self[:ip_address] && self[:subnet_name]
      raise(Puppet::Error, 'Please provide a value for only one of ip_address and subnet_name.')
    end
  end

end
