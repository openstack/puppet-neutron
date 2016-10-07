require File.join(File.dirname(__FILE__), '..','..','..',
                  'puppet/provider/neutron')

Puppet::Type.type(:neutron_l3_agent_config).provide(
  :ini_setting,
  :parent => Puppet::Type.type(:openstack_config).provider(:ini_setting)
) do

  def self.file_path
    '/etc/neutron/l3_agent.ini'
  end

  # added for backwards compatibility with older versions of inifile
  def file_path
    self.class.file_path
  end

  def to_uuid(name)
    neutron = Puppet::Provider::Neutron.new
    neutron.auth_neutron('router-show', "#{name}",
                         '--format=value', '--column=id').chop
  end

  def from_uuid(uuid)
    neutron = Puppet::Provider::Neutron.new
    neutron.auth_neutron('router-show', "#{uuid}",
                         '--format=value', '--column=name').chop
  end

end
