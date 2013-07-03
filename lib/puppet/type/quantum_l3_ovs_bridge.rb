Puppet::Type.newtype(:quantum_l3_ovs_bridge) do

  ensurable

  newparam(:name, :namevar => true) do
    desc 'Symbolic name for the ovs bridge'
    newvalues(/.*/)
  end

  newparam(:subnet_name) do
    desc 'Name of the subnet that will use the bridge as gateway'
  end

  autorequire(:service) do
    ['quantum-server']
  end

  autorequire(:vs_bridge) do
    [self[:name]]
  end

  autorequire(:quantum_subnet) do
    [self[:subnet_name]] if self[:subnet_name]
  end

end
