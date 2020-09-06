Puppet::Type.type(:neutron_api_paste_ini).provide(
  :ini_setting,
  :parent => Puppet::Type.type(:openstack_config).provider(:ini_setting)
) do

  def section
    resource[:name].split('/', 2).first
  end

  def setting
    resource[:name].split('/', 2).last
  end

  def separator
    '='
  end

  def self.file_path
    '/etc/neutron/api-paste.ini'
  end

end
