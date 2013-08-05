Puppet::Type.newtype(:neutron_router_interface) do

  desc <<-EOT
    This is currently used to model the creation of
    neutron router interfaces.

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
    ['neutron-server']
  end

  autorequire(:neutron_router) do
    self[:name].split(':', 2).first
  end

  autorequire(:neutron_subnet) do
    self[:name].split(':', 2).last
  end

end
