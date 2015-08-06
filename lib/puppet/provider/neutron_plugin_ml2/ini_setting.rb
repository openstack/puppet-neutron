Puppet::Type.type(:neutron_plugin_ml2).provide(
  :ini_setting,
  :parent => Puppet::Type.type(:openstack_config).provider(:ini_setting)
) do

  def file_path
    '/etc/neutron/plugins/ml2/ml2_conf.ini'
  end

end
