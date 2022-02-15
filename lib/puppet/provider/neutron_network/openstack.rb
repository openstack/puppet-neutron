require File.join(File.dirname(__FILE__), '..','..','..',
                  'puppet/provider/neutron')

Puppet::Type.type(:neutron_network).provide(
  :openstack,
  :parent => Puppet::Provider::Neutron
) do
  desc <<-EOT
    Neutron provider to manage neutron_network type.

    Assumes that the neutron service is configured on the same host.
  EOT

  @credentials = Puppet::Provider::Openstack::CredentialsV3.new

  mk_resource_methods

  def initialize(value={})
    super(value)
    @property_flush = {}
  end

  def self.do_not_manage
    @do_not_manage
  end

  def self.do_not_manage=(value)
    @do_not_manage = value
  end

  def self.instances
    self.do_not_manage = true
    list = request('network', 'list').collect do |attrs|
      network = request('network', 'show', attrs[:id])
      new(
        :ensure                    => :present,
        :name                      => attrs[:name],
        :id                        => attrs[:id],
        :admin_state_up            => network[:admin_state_up],
        :provider_network_type     => network[:provider_network_type],
        :provider_physical_network => network[:provider_physical_network],
        :provider_segmentation_id  => network[:provider_segmentation_id],
        :router_external           => network[:router_external],
        :shared                    => network[:shared],
        :tenant_id                 => network[:project_id],
        :project_id                => network[:project_id],
        :availability_zone_hint    => parse_availability_zone_hint(network[:availability_zone_hints])
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

    opts = [@resource[:name]]

    if @resource[:shared] =~ /true/i
      opts << '--share'
    end

    if @resource[:admin_state_up] == 'False'
      opts << '--disable'
    end

    if @resource[:tenant_name]
      opts << "--project=#{@resource[:tenant_name]}"
    elsif @resource[:tenant_id]
      opts << "--project=#{@resource[:tenant_id]}"
    elsif @resource[:project_name]
      opts << "--project=#{@resource[:project_name]}"
    elsif @resource[:project_id]
      opts << "--project=#{@resource[:project_id]}"
    end

    if @resource[:provider_network_type]
      opts << \
        "--provider-network-type=#{@resource[:provider_network_type]}"
    end

    if @resource[:provider_physical_network]
      opts << \
        "--provider-physical-network=#{@resource[:provider_physical_network]}"
    end

    if @resource[:provider_segmentation_id]
      opts << \
        "--provider-segmentation-id=#{@resource[:provider_segmentation_id]}"
    end

    if @resource[:router_external] == 'True'
      opts << '--external'
    end

    if @resource[:availability_zone_hint]
      Array(@resource[:availability_zone_hint]).each do |hint|
        opts << "--availability-zone-hint=#{hint}"
      end
    end

    network = self.class.request('network', 'create', opts)
    @property_hash = {
      :ensure                    => :present,
      :name                      => network[:name],
      :id                        => network[:id],
      :admin_state_up            => network[:admin_state_up],
      :provider_network_type     => network[:provider_network_type],
      :provider_physical_network => network[:provider_physical_network],
      :provider_segmentation_id  => network[:provider_segmentation_id],
      :router_external           => network[:router_external],
      :shared                    => network[:shared],
      :tenant_id                 => network[:project_id],
      :project_id                => network[:project_id],
      :availability_zone_hint    => self.class.parse_availability_zone_hint(network[:availability_zone_hints])
    }
  end

  def flush
    if !@property_flush.empty?
      opts = [@resource[:name]]

      if @property_flush.has_key?(:admin_state_up)
        if @property_flush[:admin_state_up] == 'False'
          opts << '--disable'
        else
          opts << '--enable'
        end
      end

      if @property_flush.has_key?(:shared)
        if @property_flush[:shared] == 'False'
          opts << '--no-share'
        else
          opts << '--share'
        end
      end

      if @property_flush.has_key?(:router_external)
        if @property_flush[:router_external] == 'False'
          opts << '--internal'
        else
          opts << '--external'
        end
      end

      self.class.request('network', 'set', opts)
      @property_flush.clear
    end
  end

  def destroy
    if self.class.do_not_manage
      fail("Not managing Neutron_network[#{@resource[:name]}] due to earlier Neutron API failures.")
    end
    self.class.request('network', 'delete', @resource[:name])
    @property_hash.clear
    @property_hash[:ensure] = :absent
  end

  [
    :admin_state_up,
    :shared,
    :router_external,
  ].each do |attr|
    define_method(attr.to_s + "=") do |value|
      if self.class.do_not_manage
        fail("Not managing Neutron_network[#{@resource[:name]}] due to earlier Neutron API failures.")
      end
      @property_flush[attr] = value
    end
  end

  [
    :availability_zone_hint,
    :provider_network_type,
    :provider_physical_network,
    :provider_segmentation_id,
    :tenant_id,
    :tenant_name,
    :project_id,
    :project_name,
  ].each do |attr|
    define_method(attr.to_s + "=") do |value|
      fail("Property #{attr.to_s} does not support being updated")
    end
  end

end
