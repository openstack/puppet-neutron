Puppet::Type.newtype(:neutron_vpnaas_service_config) do

  ensurable

  newparam(:name, :namevar => true) do
    desc 'Section/setting name to manage from neutron_vpnaas.conf'
    newvalues(/\S+\/\S+/)
  end

  newproperty(:value, :array_matching => :all) do
    desc 'The value of the setting to be defined.'
    def insync?(is)
      return true if @should.empty?
      return false unless is.is_a? Array
      return false unless is.length == @should.length
      # we don't care about the order of items in array, hence
      # it is necessary to override insync
      return (
        is & @should == is or
        is & @should.map(&:to_s) == is
      )
    end

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
    'neutron-vpnaas-agent'
  end

end
