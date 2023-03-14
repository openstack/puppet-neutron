Puppet::Type.newtype(:neutron_network) do

  ensurable

  newparam(:name, :namevar => true) do
    desc 'Symbolic name for the network'
    newvalues(/.*/)
  end

  newproperty(:id) do
    desc 'The unique id of the network'
    validate do |v|
      raise(Puppet::Error, 'This is a read only property')
    end
  end

  newproperty(:admin_state_up) do
    desc 'The administrative status of the network'
    newvalues(/(t|T)rue/, /(f|F)alse/)
    defaultto 'True'
    munge do |v|
      v.to_s.capitalize
    end
  end

  newproperty(:shared) do
    desc 'Whether this network should be shared across all tenants or not'
    newvalues(/(t|T)rue/, /(f|F)alse/)
    defaultto 'False'
    munge do |v|
      v.to_s.capitalize
    end
  end

  newparam(:project_name) do
    desc 'The name of the project which will own the network.'
  end

  newproperty(:project_id) do
    desc 'A uuid identifying the project which will own the network.'
  end

  newproperty(:provider_network_type) do
    desc 'The physical mechanism by which the virtual network is realized.'
    newvalues(:flat, :vlan, :local, :gre, :l3_ext, :vxlan)
  end

  newproperty(:provider_physical_network) do
    desc <<-EOT
      The name of the physical network over which the virtual network
      is realized for flat and VLAN networks.
    EOT
    newvalues(/\S+/)
  end

  newproperty(:provider_segmentation_id) do
    desc 'Identifies an isolated segment on the physical network.'
    munge do |v|
      Integer(v)
    end
  end

  newproperty(:router_external) do
    desc 'Whether this router will route traffic to an external network'
    newvalues(/(t|T)rue/, /(f|F)alse/)
    defaultto 'False'
    munge do |v|
      v.to_s.capitalize
    end
  end

  newproperty(:availability_zone_hint) do
    desc 'The availability zone hint to provide the scheduler'
  end

  newproperty(:mtu) do
    desc 'Set network mtu'
    newvalues(/\d+/)
    munge do |v|
      Integer(v)
    end
  end

  # Require the neutron-server service to be running
  autorequire(:anchor) do
    ['neutron::service::end']
  end

  autorequire(:keystone_tenant) do
    [self[:project_name]] if self[:project_name]
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
