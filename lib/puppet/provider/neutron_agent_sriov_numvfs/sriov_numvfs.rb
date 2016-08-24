Puppet::Type.type(:neutron_agent_sriov_numvfs).provide(:sriov_numvfs) do
  desc <<-EOT
    The file /sys/class/net/<sriov_interface_name>/device/sriov_numvfs will be
    present when a physical PCIe device supports SR-IOV. A number written to
    this file will enable the specified number of VFs. This provider shall read
    the file and ensure that the value is zero, before writing the number of
    VFs that should be enabled. If the VFs needs to be disabled then we shall
    write a zero to this file.
  EOT

  def create
    if File.file?(sriov_numvfs_path)
      _set_numvfs
    else
      fail("#{sriov_numvfs_path} doesn't exist. Check if #{sriov_get_interface} is a valid network interface supporting SR-IOV")
    end
  end

  def destroy
    if File.file?(sriov_numvfs_path)
      File.write(sriov_numvfs_path,"0")
    end
  end

  def exists?
    if File.file?(sriov_numvfs_path)
      cur_value = File.read(sriov_numvfs_path)
      if cur_value.to_i == sriov_numvfs_value
        return true
      end
    end
    return false
  end

  def _set_numvfs
    # During an update, the content of file sriov_numvfs_path has to be set
    # to 0 (ZERO), before writing the actual value
    cur_value = File.read(sriov_numvfs_path)
    if cur_value != 0
      File.write(sriov_numvfs_path,"0")
    end
    File.write(sriov_numvfs_path,sriov_numvfs_value)
  end

  def sriov_numvfs_path
    "/sys/class/net/#{sriov_get_interface}/device/sriov_numvfs"
  end

  def sriov_get_interface
    resource[:name].split(':', 2).first
  end

  def sriov_numvfs_value
    resource[:name].split(':', 2).last.to_i
  end

end

