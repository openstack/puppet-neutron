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

  autorequire(:package) do
    'neutron-plugin-nuage'
  end

end

