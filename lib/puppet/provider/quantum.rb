require 'csv'
require 'puppet/util/inifile'

class Puppet::Provider::Quantum < Puppet::Provider

  def self.conf_filename
    '/etc/quantum/quantum.conf'
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

  def self.quantum_credentials
    @quantum_credentials ||= get_quantum_credentials
  end

  def self.get_quantum_credentials
    auth_keys = ['auth_host', 'auth_port', 'auth_protocol',
                 'admin_tenant_name', 'admin_user', 'admin_password']
    conf = quantum_conf
    if conf and conf['keystone_authtoken'] and
        auth_keys.all?{|k| !conf['keystone_authtoken'][k].nil?}
      return Hash[ auth_keys.map \
                   { |k| [k, conf['keystone_authtoken'][k].strip] } ]
    else
      raise(Puppet::Error, "File: #{conf_filename} does not contain all \
required sections.  Quantum types will not work if quantum is not \
correctly configured.")
    end
  end

  def quantum_credentials
    self.class.quantum_credentials
  end

  def self.auth_endpoint
    @auth_endpoint ||= get_auth_endpoint
  end

  def self.get_auth_endpoint
    q = quantum_credentials
    "#{q['auth_protocol']}://#{q['auth_host']}:#{q['auth_port']}/v2.0/"
  end

  def self.quantum_conf
    return @quantum_conf if @quantum_conf
    @quantum_conf = Puppet::Util::IniConfig::File.new
    @quantum_conf.read(conf_filename)
    @quantum_conf
  end

  def self.auth_quantum(*args)
    q = quantum_credentials
    authenv = {
      :OS_AUTH_URL    => self.auth_endpoint,
      :OS_USERNAME    => q['admin_user'],
      :OS_TENANT_NAME => q['admin_tenant_name'],
      :OS_PASSWORD    => q['admin_password']
    }
    begin
      withenv authenv do
        quantum(args)
      end
    rescue Exception => e
      if (e.message =~ /\[Errno 111\] Connection refused/) or
          (e.message =~ /\(HTTP 400\)/)
        sleep 10
        withenv authenv do
          quantum(args)
        end
      else
       raise(e)
      end
    end
  end

  def auth_quantum(*args)
    self.class.auth_quantum(args)
  end

  def self.reset
    @quantum_conf        = nil
    @quantum_credentials = nil
  end

  def self.list_quantum_resources(type)
    ids = []
    list = auth_quantum("#{type}-list", '--format=csv',
                        '--column=id', '--quote=none')
    (list.split("\n")[1..-1] || []).compact.collect do |line|
      ids << line.strip
    end
    return ids
  end

  def self.get_quantum_resource_attrs(type, id)
    attrs = {}
    net = auth_quantum("#{type}-show", '--format=shell', id)
    last_key = nil
    (net.split("\n") || []).compact.collect do |line|
      if line.include? '='
        k, v = line.split('=', 2)
        attrs[k] = v.gsub(/\A"|"\Z/, '')
        last_key = k
      else
        # Handle the case of a list of values
        v = line.gsub(/\A"|"\Z/, '')
        attrs[last_key] = [attrs[last_key], v]
      end
    end
    return attrs
  end

  def self.list_quantum_extensions
    exts = []
    begin
      list = auth_quantum('ext-list', '--format=csv',
                          '--column=alias', '--quote=none')
    rescue => e
      if (e.message =~ /Quantum types will not work/)
        # Silently return no features if configuration is not
        # available so that feature definition doesn't break
        # autoload.
        return exts
      end
      raise
    end
    (list.split("\n")[1..-1] || []).compact.collect do |line|
      exts << line.strip
    end
    return exts
  end

  def self.list_router_ports(router_name_or_id)
    results = []
    cmd_output = auth_quantum("router-port-list",
                              '--format=csv',
                              router_name_or_id)
    if ! cmd_output
      return results
    end

    headers = nil
    CSV.parse(cmd_output) do |row|
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

  def self.get_tenant_id(tenant_name)
    tenant = Puppet::Type.type('keystone_tenant').instances.find do |i|
      i.provider.name == tenant_name
    end
    if tenant
      return tenant.provider.id
    else
      fail("Unable to find tenant for name #{tenant_name}")
    end
  end

end
