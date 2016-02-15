Puppet::Type.newtype(:neutron_router_interface) do

  desc <<-EOT
    This is currently used to model the creation of
    neutron router interfaces.

    Router interfaces are an association between a router and a
    subnet.
  EOT

  ensurable

  newparam(:name, :namevar => true) do
    desc <<-EOT
       The name is used to derive the names of the subnet and router,
       using the format RouterName:SubnetName, for example to attach
       Subnet1 to Router1 you should name this resource Router1:Subnet1
    EOT
    newvalues(/^\S+:\S+$/)
  end

  newproperty(:id) do
    desc 'interface id. Read Only.'
    validate do |v|
      raise(Puppet::Error, 'This is a read only property')
    end
  end

  newproperty(:router_name) do
    desc 'router to which to attach this interface. Read Only. set with the name'
    validate do |v|
      raise(Puppet::Error, 'This is a read only property')
    end
  end

  newproperty(:subnet_name) do
    desc 'subnet to which to attach this interface. Read Only. set with the name'
    validate do |v|
      raise(Puppet::Error, 'This is a read only property')
    end
  end

  newproperty(:port) do
    desc 'An existing neutron port to which a router interface should be assigned'
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
