Puppet::Type.newtype(:neutron_plugin_ovn) do

  ensurable

  newparam(:name, :namevar => true) do
    desc 'Section/setting name to manage from networking-ovn.ini'
    newvalues(/\S+\/\S+/)
  end

  newproperty(:value) do
    desc 'The value of the setting to be defined.'
    munge do |value|
      value = value.to_s.strip
      value.capitalize! if value =~ /^(true|false)$/i
      value
    end

  end

  newparam(:secret, :boolean => true) do
    desc 'Whether to hide the value from Puppet logs. Defaults to `false`.'
    newvalues(:true, :false)
    defaultto false
  end

  newparam(:ensure_absent_val) do
    desc 'A value that is specified as the value property will behave as if ensure => absent was specified'
    defaultto('<SERVICE DEFAULT>')
  end

  autorequire(:package) do
    'neutron-plugin-ovn'
  end

end
