Puppet::Type.newtype(:neutron_plugin_cisco_db_conn) do

  ensurable

  newparam(:name, :namevar => true) do
    desc 'Section/setting name to manage from plugins/cisco/db_conn.ini'
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

  autorequire(:file) do
    ['/etc/neutron/plugins/cisco']
  end

  autorequire(:package) do
    'neutron-plugin-cisco'
  end

end
