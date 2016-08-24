Puppet::Type.newtype(:neutron_agent_sriov_numvfs) do

  ensurable

  newparam(:name) do
    desc "sriov_numvfs conf as <physical_network>:<number_of_vfs> format"
    newvalues(/^[a-z0-9-_]+:[0-9]+$/)
  end

end

