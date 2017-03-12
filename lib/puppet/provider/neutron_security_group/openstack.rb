require File.join(File.dirname(__FILE__), '..','..','..',
                  'puppet/provider/neutron')

Puppet::Type.type(:neutron_security_group).provide(
  :openstack,
  :parent => Puppet::Provider::Neutron
) do
  desc <<-EOT
     Manage Neutron security group
  EOT

  @credentials = Puppet::Provider::Openstack::CredentialsV3.new

  def initialize(value={})
    super(value)
  end

  def create
    opts = [@resource[:name]]
    (opts << '--id' << @resource[:id]) if @resource[:id]
    (opts << '--description' << @resource[:description]) if @resource[:description]
    (opts << '--project' << @resource[:project]) if @resource[:project]
    (opts << '--project-domain' << @resource[:project_domain]) if @resource[:project_domain]
    @property_hash = self.class.request('security group', 'create', opts)
    @property_hash[:ensure] = :present
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def destroy
    self.class.request('security group', 'delete', @property_hash[:id])
  end

  mk_resource_methods

  def id=(value)
    fail('id is read only')
  end

  def description=(value)
    fail('description is read only')
  end

  def project=(value)
    fail('project is read only')
  end

  def project_domain=(value)
    fail('project_domain is read only')
  end

  def self.instances
    request('security group', 'list', ['--all']).collect do |attrs|
      new(
          :ensure         => :present,
          :name           => attrs[:name],
          :id             => attrs[:id],
          :description    => attrs[:description],
          :project        => attrs[:project],
          :project_domain => attrs[:project_domain]
      )
    end
  end

  def self.prefetch(resources)
    sec_groups = instances
    resources.keys.each do |name|
      if provider = sec_groups.find{ |sg| sg.name == name }
        resources[name].provider = provider
      end
    end
  end

end
