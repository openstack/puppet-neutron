Puppet::Type.newtype(:quantum_plugin_cisco_credentials) do

  ensurable

  newparam(:name, :namevar => true) do
    desc 'Section/setting name to manage from credentials.ini'
    newvalues(/\S+\/\S+/)
  end

  autorequire(:file) do
    ['/etc/quantum/plugins/cisco']
  end

  newproperty(:value) do
    desc 'The value of the setting to be defined.'
    munge do |value|
      value = value.to_s.strip
      value.capitalize! if value =~ /^(true|false)$/i
      value
    end
  end
end
