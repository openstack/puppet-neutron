Puppet::Type.newtype(:neutron_plugin_nuage) do

  ensurable

  newparam(:name, :namevar => true) do
    desc 'Section/setting name to manage for nuage/plugin.ini'
    newvalues(/\S+\/\S+/)
  end

  newproperty(:value) do
    desc 'The value of the settings to be defined.'
    munge do |value|
      value = value.to_s.strip
      value.capitalize! if value =~ /^(true|false)$/i
      value
    end
  end

  newparam(:ensure_absent_val) do
    desc 'A value that is specified as the value property will behave as if ensure => absent was specified'
    defaultto('<SERVICE DEFAULT>')
  end

  autorequire(:package) do
    'neutron-plugin-nuage'
  end

  autorequire(:file) do
    '/etc/neutron/plugins/nuage/plugin.ini'
  end

end

