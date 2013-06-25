Puppet::Type.newtype(:quantum_router_interface) do

  desc <<-EOT
    This is currently used to model the creation of
    quantum router interfaces.

    Router interfaces are an association between a router and a
    subnet.
  EOT

  ensurable

  newparam(:name, :namevar => true) do
    newvalues(/^\S+:\S+$/)
  end

  newproperty(:id) do
    validate do |v|
      raise(Puppet::Error, 'This is a read only property')
    end
  end

  newproperty(:router_name) do
    validate do |v|
      raise(Puppet::Error, 'This is a read only property')
    end
  end

  newproperty(:subnet_name) do
    validate do |v|
      raise(Puppet::Error, 'This is a read only property')
    end
  end

  autorequire(:service) do
    ['quantum-server']
  end

  autorequire(:quantum_router) do
    self[:name].split(':', 2).first
  end

  autorequire(:quantum_subnet) do
    self[:name].split(':', 2).last
  end

end
