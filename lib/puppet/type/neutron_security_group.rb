# neutron_security_group type
#
# == Parameters
#  [*name*]
#    Name for the security group
#    Required
#
#  [*id*]
#    Unique ID (integer or UUID) for the security group.
#    Optional
#
#  [*description*]
#    Description of the security group.
#    Optional
#
#  [*project*]
#    Project of the security group.
#    Optional
#
#  [*project_domain*]
#    Project domain of the security group.
#    Optional
#
require 'puppet'

Puppet::Type.newtype(:neutron_security_group) do

  @doc = "Manage creation of neutron security group"

  ensurable

  autorequire(:neutron_config) do
    ['auth_uri', 'project_name', 'username', 'password']
  end

  # Require the neutron-server service to be running
  autorequire(:service) do
    ['neutron-server']
  end

  newparam(:name, :namevar => true) do
    desc 'Name for the security group'
    validate do |value|
      if not value.is_a? String
        raise ArgumentError, "name parameter must be a String"
      end
      unless value =~ /^[a-zA-Z0-9\-\._]+$/
        raise ArgumentError, "#{value} is not a valid name"
      end
    end
  end

  newparam(:id) do
    desc 'Unique ID (integer or UUID) for the security group.'
  end

  newparam(:description) do
    desc 'Description of the security group.'
  end

  newparam(:project) do
    desc 'Project of the security group.'
  end

  newparam(:project_domain) do
    desc 'Project domain of the security group.'
  end

  validate do
    unless self[:name]
      raise(ArgumentError, 'Name must be set')
    end
  end

end

