Puppet::Type.type(:neutron_api_config).provide(
  :ini_setting,
  :parent => Puppet::Type.type(:openstack_config).provider(:ini_setting)
) do

  def file_path
    '/etc/neutron/api-paste.ini'
  end

end
