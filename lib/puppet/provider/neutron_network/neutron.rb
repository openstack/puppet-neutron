require File.join(File.dirname(__FILE__), '..','..','..',
                  'puppet/provider/neutron')

Puppet::Type.type(:neutron_network).provide(
  :neutron,
  :parent => Puppet::Provider::Neutron
) do
  desc <<-EOT
    Neutron provider to manage neutron_network type.

    Assumes that the neutron service is configured on the same host.
  EOT

  mk_resource_methods

  def self.neutron_type
    'net'
  end

  def self.do_not_manage
    @do_not_manage
  end

  def self.do_not_manage=(value)
    @do_not_manage = value
  end

  def self.instances
    self.do_not_manage = true
    list = list_neutron_resources(neutron_type).collect do |id|
      attrs = get_neutron_resource_attrs(neutron_type, id)
      new(
        :ensure                    => :present,
        :name                      => attrs['name'],
        :id                        => attrs['id'],
        :admin_state_up            => attrs['admin_state_up'],
        :provider_network_type     => attrs['provider:network_type'],
        :provider_physical_network => attrs['provider:physical_network'],
        :provider_segmentation_id  => attrs['provider:segmentation_id'],
        :router_external           => attrs['router:external'],
        :shared                    => attrs['shared'],
        :tenant_id                 => attrs['tenant_id'],
        :availability_zone_hint    => attrs['availability_zone_hint']
      )
    end
    self.do_not_manage = false
    list
  end

  def self.prefetch(resources)
    networks = instances
    resources.keys.each do |name|
      if provider = networks.find{ |net| net.name == name }
        resources[name].provider = provider
      end
    end
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def create
    if self.class.do_not_manage
      fail("Not managing Neutron_network[#{@resource[:name]}] due to earlier Neutron API failures.")
    end

    network_opts = Array.new

    if @resource[:shared] =~ /true/i
      network_opts << '--shared'
    end

    if @resource[:tenant_name]
      tenant_id = self.class.get_tenant_id(@resource.catalog,
                                           @resource[:tenant_name])
      network_opts << "--tenant_id=#{tenant_id}"
    elsif @resource[:tenant_id]
      network_opts << "--tenant_id=#{@resource[:tenant_id]}"
    end

    if @resource[:provider_network_type]
      network_opts << \
        "--provider:network_type=#{@resource[:provider_network_type]}"
    end

    if @resource[:provider_physical_network]
      network_opts << \
        "--provider:physical_network=#{@resource[:provider_physical_network]}"
    end

    if @resource[:provider_segmentation_id]
      network_opts << \
        "--provider:segmentation_id=#{@resource[:provider_segmentation_id]}"
    end

    if @resource[:router_external] == 'True'
      network_opts << '--router:external'
    end

    if @resource[:availability_zone_hint]
      network_opts << \
        "--availability-zone-hint=#{@resource[:availability_zone_hint]}"
    end

    results = auth_neutron('net-create', '--format=shell',
                           network_opts, resource[:name])

    attrs = self.class.parse_creation_output(results)
    @property_hash = {
      :ensure                    => :present,
      :name                      => resource[:name],
      :id                        => attrs['id'],
      :admin_state_up            => attrs['admin_state_up'],
      :provider_network_type     => attrs['provider:network_type'],
      :provider_physical_network => attrs['provider:physical_network'],
      :provider_segmentation_id  => attrs['provider:segmentation_id'],
      :router_external           => attrs['router:external'],
      :shared                    => attrs['shared'],
      :tenant_id                 => attrs['tenant_id'],
      :availability_zone_hint    => attrs['availability_zone_hint']
    }
  end

  def destroy
    if self.class.do_not_manage
      fail("Not managing Neutron_network[#{@resource[:name]}] due to earlier Neutron API failures.")
    end
    auth_neutron('net-delete', name)
    @property_hash[:ensure] = :absent
  end

  def admin_state_up=(value)
    if self.class.do_not_manage
      fail("Not managing Neutron_network[#{@resource[:name]}] due to earlier Neutron API failures.")
    end
    auth_neutron('net-update', "--admin_state_up=#{value}", name)
  end

  def shared=(value)
    if self.class.do_not_manage
      fail("Not managing Neutron_network[#{@resource[:name]}] due to earlier Neutron API failures.")
    end
    auth_neutron('net-update', "--shared=#{value}", name)
  end

  def router_external=(value)
    if self.class.do_not_manage
      fail("Not managing Neutron_network[#{@resource[:name]}] due to earlier Neutron API failures.")
    end
    if value == 'False'
      auth_neutron('net-update', "--router:external=#{value}", name)
    else
      auth_neutron('net-update', "--router:external", name)
    end
  end

  def availability_zone_hint=(value)
    if self.class.do_not_manage
      fail("Not managing Neutron_network[#{@resource[:name]}] due to earlier Neutron API failures.")
    end
    auth_neutron('net-update', "--availability-zone-hint=#{value}", name)
  end

  [
   :provider_network_type,
   :provider_physical_network,
   :provider_segmentation_id,
   :tenant_id,
  ].each do |attr|
     define_method(attr.to_s + "=") do |value|
       fail("Property #{attr.to_s} does not support being updated")
     end
  end

end
