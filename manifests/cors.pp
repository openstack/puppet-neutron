# == Class: neutron::cors
#
# Configure the neutron cors
#
# === Parameters
#
# [*allowed_origin*]
#   (Optional) Indicate whether this resource may be shared with the domain
#   received in the requests "origin" header.
#   (string value)
#   Defaults to $facts['os_service_default'].
#
# [*allow_credentials*]
#   (Optional) Indicate that the actual request can include user credentials.
#   (boolean value)
#   Defaults to $facts['os_service_default'].
#
# [*expose_headers*]
#   (Optional) Indicate which headers are safe to expose to the API.
#   (list value)
#   Defaults to $facts['os_service_default'].
#
# [*max_age*]
#   (Optional) Maximum cache age of CORS preflight requests.
#   (integer value)
#   Defaults to $facts['os_service_default'].
#
# [*allow_methods*]
#   (Optional) Indicate which methods can be used during the actual request.
#   (list value)
#   Defaults to $facts['os_service_default'].
#
# [*allow_headers*]
#   (Optional) Indicate which header field names may be used during the actual
#   request.
#   (list value)
#   Defaults to $facts['os_service_default'].
#
class neutron::cors (
  $allowed_origin    = $facts['os_service_default'],
  $allow_credentials = $facts['os_service_default'],
  $expose_headers    = $facts['os_service_default'],
  $max_age           = $facts['os_service_default'],
  $allow_methods     = $facts['os_service_default'],
  $allow_headers     = $facts['os_service_default'],
) {
  include neutron::deps

  oslo::cors { 'neutron_config':
    allowed_origin    => $allowed_origin,
    allow_credentials => $allow_credentials,
    expose_headers    => $expose_headers,
    max_age           => $max_age,
    allow_methods     => $allow_methods,
    allow_headers     => $allow_headers,
  }
}
