Puppet::Functions.create_function(:convert_cert_to_string) do
  dispatch :convert_cert_to_string do
    param 'String', :cert_file
  end

  def convert_cert_to_string(cert_file)
    unless File.file?(cert_file)
      raise puppet::ParseError, "Certificate file not found: #{cert_file}"
    end
    text=File.readlines(cert_file)
    cert_string = ''
    text.each do |line|
      unless line.include? '-----'
        cert_string += line.strip
      end
    end
    return cert_string
  end
end
