# Add openstacklib code to $LOAD_PATH so that we can load this during
# standalone compiles without error.
File.expand_path('../../../../openstacklib/lib', File.dirname(__FILE__)).tap { |dir| $LOAD_PATH.unshift(dir) unless $LOAD_PATH.include?(dir) }

require 'puppet/util/inifile'
require 'puppet/provider/openstack'
require 'puppet/provider/openstack/auth'
require 'puppet/provider/openstack/credentials'

class Puppet::Provider::Neutron < Puppet::Provider::Openstack

  extend Puppet::Provider::Openstack::Auth

  initvars

  def self.request(service, action, properties=nil)
    begin
      super
    rescue Puppet::Error::OpenstackAuthInputError => error
      neutron_request(service, action, error, properties)
    end
  end

  def self.neutron_request(service, action, error, properties=nil)
    warning('Usage of keystone_authtoken parameters is deprecated.')
    properties ||= []
    @credentials.username = neutron_credentials['username']
    @credentials.password = neutron_credentials['password']
    @credentials.project_name = neutron_credentials['project_name']
    @credentials.auth_url = auth_endpoint
    @credentials.user_domain_name = neutron_credentials['user_domain_name']
    @credentials.project_domain_name = neutron_credentials['project_domain_name']
    if neutron_credentials['region_name']
      @credentials.region_name = neutron_credentials['region_name']
    end
    raise error unless @credentials.set?
    Puppet::Provider::Openstack.request(service, action, properties, @credentials)
  end

  def self.conf_filename
    '/etc/neutron/neutron.conf'
  end

  def self.neutron_conf
    return @neutron_conf if @neutron_conf
    @neutron_conf = Puppet::Util::IniConfig::File.new
    @neutron_conf.read(conf_filename)
    @neutron_conf
  end

  def self.neutron_credentials
    @neutron_credentials ||= get_neutron_credentials
  end

  def neutron_credentials
    self.class.neutron_credentials
  end

  def self.get_neutron_credentials
    #needed keys for authentication
    auth_keys = ['auth_url', 'project_name', 'username', 'password']
    conf = neutron_conf
    if conf and conf['keystone_authtoken'] and
        auth_keys.all?{|k| !conf['keystone_authtoken'][k].nil?}
      creds = Hash[ auth_keys.map \
                   { |k| [k, conf['keystone_authtoken'][k].strip] } ]

      if !conf['keystone_authtoken']['region_name'].nil?
        creds['region_name'] = conf['keystone_authtoken']['region_name'].strip
      end

      if !conf['keystone_authtoken']['project_domain_name'].nil?
        creds['project_domain_name'] = conf['keystone_authtoken']['project_domain_name'].strip
      else
        creds['project_domain_name'] = 'Default'
      end

      if !conf['keystone_authtoken']['user_domain_name'].nil?
        creds['user_domain_name'] = conf['keystone_authtoken']['user_domain_name'].strip
      else
        creds['user_domain_name'] = 'Default'
      end

      return creds
    else
      raise(Puppet::Error, "File: #{conf_filename} does not contain all " +
            "required sections.  Neutron types will not work if neutron is not " +
            "correctly configured.")
    end
  end

  def self.get_auth_endpoint
    q = neutron_credentials
    "#{q['auth_url']}"
  end

  def self.auth_endpoint
    @auth_endpoint ||= get_auth_endpoint
  end

  def self.reset
    @neutron_conf        = nil
    @neutron_credentials = nil
    @auth_endpoint       = nil
  end

  def self.get_network_name(id)
    network = self.request('network', 'show', [id])
    return network[:name]
  end

  def self.get_subnet_name(id)
    subnet = self.request('subnet', 'show', [id])
    return subnet[:name]
  end

  def self.parse_subnet_id(value)
    fixed_ips = JSON.parse(value.gsub(/\\"/,'"').gsub('\'','"'))
    subnet_ids = []
    fixed_ips.each do |fixed_ip|
      subnet_ids << fixed_ip['subnet_id']
    end

    if subnet_ids.length > 1
      subnet_ids
    else
      subnet_ids.first
    end
  end

  def self.parse_availability_zone_hint(value)
    hints = JSON.parse(value.gsub(/\\"/,'"').gsub('\'','"'))
    if hints.length > 1
      hints
    else
      hints.first
    end
  end
end
