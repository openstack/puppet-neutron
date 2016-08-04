require 'csv'
require 'puppet/util/inifile'

class Puppet::Provider::Neutron < Puppet::Provider

  initvars
  commands :neutron => 'neutron'

  def self.conf_filename
    '/etc/neutron/neutron.conf'
  end

  def self.withenv(hash, &block)
    saved = ENV.to_hash
    hash.each do |name, val|
      ENV[name.to_s] = val
    end

    yield
  ensure
    ENV.clear
    saved.each do |name, val|
      ENV[name] = val
    end
  end

  def self.neutron_credentials
    @neutron_credentials ||= get_neutron_credentials
  end

  def self.get_neutron_credentials
    auth_keys = ['project_name', 'username', 'password', 'auth_url']
    conf = neutron_conf
    if conf and conf['keystone_authtoken'] and
        !conf['keystone_authtoken']['password'].nil? and
        auth_keys.all?{|k| !conf['keystone_authtoken'][k].nil?}
      creds = Hash[ auth_keys.map \
                   { |k| [k, conf['keystone_authtoken'][k].strip] } ]
      if !conf['keystone_authtoken']['region_name'].nil?
        creds['region_name'] = conf['keystone_authtoken']['region_name'].strip
      end
      return creds
    else
      raise(Puppet::Error, "File: #{conf_filename} does not contain all \
required sections.  Neutron types will not work if neutron is not \
correctly configured.")
    end
  end

  def neutron_credentials
    self.class.neutron_credentials
  end

  def self.neutron_conf
    return @neutron_conf if @neutron_conf
    @neutron_conf = Puppet::Util::IniConfig::File.new
    @neutron_conf.read(conf_filename)
    @neutron_conf
  end

  def self.auth_neutron(*args)
    q = neutron_credentials
    authenv = {
      :OS_AUTH_URL     => q['auth_url'],
      :OS_USERNAME     => q['username'],
      :OS_PROJECT_NAME => q['project_name'],
      :OS_PASSWORD     => q['password']
    }
    if q.key?('region_name')
      authenv[:OS_REGION_NAME] = q['region_name']
    end
    rv = nil
    timeout = 10
    end_time = Time.now.to_i + timeout
    loop do
      begin
        withenv authenv do
          rv = neutron(args)
        end
        break
      rescue Puppet::ExecutionFailure => e
        if ! e.message =~ /(\(HTTP\s+400\))|
              (400-\{\'message\'\:\s+\'\'\})|
              (\[Errno 111\]\s+Connection\s+refused)|
              (503\s+Service\s+Unavailable)|
              (504\s+Gateway\s+Time-out)|
              (\:\s+Maximum\s+attempts\s+reached)|
              (Unauthorized\:\s+bad\s+credentials)|
              (Max\s+retries\s+exceeded)/
          raise(e)
        end
        current_time = Time.now.to_i
        if current_time > end_time
          break
        else
          wait = end_time - current_time
          notice("Unable to complete neutron request due to non-fatal error: \"#{e.message}\". Retrying for #{wait} sec.")
        end
        sleep(2)
        # Note(xarses): Don't remove, we know that there is one of the
        # Recoverable erros above, So we will retry a few more times
      end
    end
    return rv
  end

  def auth_neutron(*args)
    self.class.auth_neutron(args)
  end

  def self.reset
    @neutron_conf        = nil
    @neutron_credentials = nil
  end

  def self.list_neutron_resources(type)
    ids = []
    list = cleanup_csv_with_id(auth_neutron("#{type}-list", '--format=csv',
                                            '--column=id', '--quote=none'))
    if list.nil?
      raise(Puppet::ExecutionFailure, "Can't retrieve #{type}-list because Neutron or Keystone API is not available.")
    end

    (list.split("\n")[1..-1] || []).compact.collect do |line|
      ids << line.strip
    end
    return ids
  end

  def self.get_neutron_resource_attrs(type, id)
    attrs = {}
    net = auth_neutron("#{type}-show", '--format=shell', id)
    if net.nil?
      raise(Puppet::ExecutionFailure, "Can't retrieve #{type}-show because Neutron or Keystone API is not available.")
    end

    last_key = nil
    (net.split("\n") || []).compact.collect do |line|
      if line.include? '='
        k, v = line.split('=', 2)
        attrs[k] = v.gsub(/\A"|"\Z/, '')
        last_key = k
      else
        # Handle the case of a list of values
        v = line.gsub(/\A"|"\Z/, '')
        attrs[last_key] = [attrs[last_key], v].flatten
      end
    end
    return attrs
  end

  def self.list_router_ports(router_name_or_id)
    results = []
    cmd_output = auth_neutron("router-port-list",
                              '--format=csv',
                              router_name_or_id)
    if ! cmd_output
      return results
    end

    headers = nil
    CSV.parse(cleanup_csv(cmd_output)) do |row|
      if headers == nil
        headers = row
      else
        result = Hash[*headers.zip(row).flatten]
        match_data = /.*"subnet_id": "(.*)", .*/.match(result['fixed_ips'])
        if match_data
          result['subnet_id'] = match_data[1]
        end
        results << result
      end
    end
    return results
  end

  def self.get_tenant_id(catalog, name, domain='Default')
    instance_type = 'keystone_tenant'
    instance = catalog.resource("#{instance_type.capitalize!}[#{name}]")
    if ! instance
      instance = Puppet::Type.type(instance_type).instances.find do |i|
        # We need to check against the Default domain name because of
        # https://review.openstack.org/#/c/226919/ which changed the naming
        # format for the tenant to include ::<Domain name>. This should be
        # removed when we drop the resource without a domain name.
        # TODO(aschultz): remove ::domain lookup as part of M-cycle
        i.provider.name == name || i.provider.name == "#{name}::#{domain}"
      end
    end
    if instance
      return instance.provider.id
    else
      fail("Unable to find #{instance_type} for name #{name}")
    end
  end

  def self.parse_creation_output(data)
    hash = {}
    data.split("\n").compact.each do |line|
      if line.include? '='
        hash[line.split('=').first] = line.split('=', 2)[1].gsub(/\A"|"\Z/, '')
      end
    end
    hash
  end

  def self.cleanup_csv(text)
    # Ignore warnings - assume legitimate output starts with a double quoted
    # string.  Errors will be caught and raised prior to this
    text = text.split("\n").drop_while { |line| line !~ /^\".*\"/ }.join("\n")
    "#{text}\n"
  end

  def self.cleanup_csv_with_id(text)
    return nil if text.nil?
    text = text.split("\n").drop_while { |line| line !~ /^\s*id$/ }.join("\n")
    "#{text}\n"
  end
end
