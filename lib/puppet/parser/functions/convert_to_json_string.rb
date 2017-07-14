module Puppet::Parser::Functions
  newfunction(:convert_to_json_string, :type => :rvalue) do |args|
    require 'json'
    value = args[0]
    if (value.kind_of? Array) && value.all? {|x| x.include? ":"}
      h = {}
      value.each do |s|
        k,v = s.split(/:/)
        h[k] = v
      end
      return h.to_json
    else
      return value.to_json
    end
  end
end
