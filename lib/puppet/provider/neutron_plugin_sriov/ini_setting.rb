Puppet::Type.type(:neutron_plugin_sriov).provide(
  :ini_setting,
  :parent => Puppet::Type.type(:openstack_config).provider(:ini_setting)
) do

  def file_path
    '/etc/neutron/plugins/ml2/ml2_conf_sriov.ini'
  end

end
