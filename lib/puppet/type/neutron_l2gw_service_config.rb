Puppet::Type.newtype(:neutron_l2gw_service_config) do

  ensurable

  newparam(:name, :namevar => true) do
    desc 'Section/setting name to manage from networking_l2gw.conf'
    newvalues(/\S+\/\S+/)
  end

  newproperty(:value, :array_matching => :all) do
    desc 'The value of the setting to be defined.'
    def insync?(is)
      return true if @should.empty?
      return false unless is.is_a? Array
      return false unless is.length == @should.length
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

  autorequire(:anchor) do
    ['neutron::install::end']
  end

end
