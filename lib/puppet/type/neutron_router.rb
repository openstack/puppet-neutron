Puppet::Type.newtype(:neutron_router) do

  ensurable

  newparam(:name, :namevar => true) do
    desc 'Symbolic name for the router'
    newvalues(/.*/)
  end

  newproperty(:id) do
    desc 'The unique id of the router'
    validate do |v|
      raise(Puppet::Error, 'This is a read only property')
    end
  end

  newproperty(:admin_state_up) do
    desc 'The administrative status of the router'
    newvalues(/(t|T)rue/, /(f|F)alse/, true, false)
    munge do |v|
      v.to_s.downcase.to_sym
    end
  end

  newproperty(:external_gateway_info) do
    desc <<-EOT
      External network that this router connects to for gateway services
      (e.g., NAT).
    EOT
    validate do |v|
      raise(Puppet::Error, 'This is a read only property')
    end
  end

  newproperty(:gateway_network_name) do
    desc <<-EOT
      The name of the external network that this router connects to
      for gateway services (e.g. NAT).
    EOT
  end

  newproperty(:gateway_network_id) do
    desc <<-EOT
      The uuid of the external network that this router connects to
      for gateway services (e.g. NAT).
    EOT
    validate do |v|
      raise(Puppet::Error, 'This is a read only property')
    end
  end

  newproperty(:status) do
    desc 'Whether the router is currently operational or not.'
    validate do |v|
      raise(Puppet::Error, 'This is a read only property')
    end
  end

  newparam(:project_name) do
    desc 'The name of the project which will own the router.'
  end

  newproperty(:project_id) do
    desc 'A uuid identifying the project which will own the router.'
  end

  autorequire(:anchor) do
    ['neutron::service::end']
  end

  autorequire(:keystone_tenant) do
    [self[:project_name]] if self[:project_name]
  end

  autorequire(:neutron_network) do
    [self[:gateway_network_name]] if self[:gateway_network_name]
  end

  newproperty(:distributed) do
    desc 'Is router distributed or not, default depends on DVR state.'
    newvalues(/(t|T)rue/, /(f|F)alse/, true, false)
    munge do |v|
      v.to_s.downcase.to_sym
    end
  end

  newproperty(:ha) do
    desc 'Is router of HA type or not, default depends on L3 HA state.'
    newvalues(/(t|T)rue/, /(f|F)alse/, true, false)
    munge do |v|
      v.to_s.downcase.to_sym
    end
  end

  newproperty(:availability_zone_hint) do
    desc 'The availability zone hint to provide the scheduler'
  end

  validate do
    if self[:ensure] != :present
      return
    end

    if self[:project_id] && self[:project_name]
      raise(Puppet::Error, <<-EOT
Please provide a value for only one of project_name and project_id.
EOT
            )
    end
  end

end
