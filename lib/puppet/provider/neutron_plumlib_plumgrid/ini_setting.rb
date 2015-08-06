Puppet::Type.type(:neutron_plumlib_plumgrid).provide(
  :ini_setting,
  :parent => Puppet::Type.type(:openstack_config).provider(:ini_setting)
) do

  def file_path
    '/etc/neutron/plugins/plumgrid/plumlib.ini'
  end

end
