class quantum::plugins::openvswitch (
  $uplink_interfaces    = ['br-virtual:eth1'],
  $plugin_settings      = {},
  $controller           = true
) {
  include "quantum::params"

  if !$controller {
    $package = $::quantum::params::ovs_package_agent
    $package_require = Service[$::quantum::params::ovs_service]
  } else {
    $package = $::quantum::params::ovs_package_server
    $package_require = [Class['quantum'], Service[$::quantum::params::ovs_service]]
  }

  class {
    "vswitch":
      provider => ovs
  }

  $bridge_int = $plugin_settings["integration_bridge"] ? { default => "br-int" }
  vs_bridge {$bridge_int:
    external_ids => "bridge-id=$bridge_int",
    ensure       => present
  }

  define bridge() {
    $mapping = split($name, ":")
    $bridge = $mapping[1]

    vs_bridge {$bridge:
      ensure       => present,
      external_ids => "bridge-id=${bridge}"
    }
  }

  $bm_string = $plugin_settings["bridge_mappings"] ? { default => "default:br-virtual"}
  $bm_list = split($bm_string, ",")
  bridge{$bm_list: }

  define port() {
    $mapping = split($name, ":")
    vs_port {$mapping[1]:
      ensure => present,
      bridge => $mapping[0]
    }
  }
  port{$uplink_interfaces: }

  package { "quantum-plugin-openvswitch":
    name    => $package,
    ensure  => latest,
    require => $package_require
  }

  File {
    require => Package['quantum-plugin-openvswitch'],
  }
  file { $::quantum::params::quantum_ovs_plugin_ini: }

  if $openvswitch_settings {
    multini($::quantum::params::quantum_ovs_plugin_ini, $openvswitch_settings)
  }

  service { 'quantum-ovs-service-agent':
    name    => $::quantum::params::ovs_service_agent,
    enable  => true,
    ensure  => running,
    require => [Package[$package]]
  }

  Ini_setting<| tag == $::quantum::params::quantum_ovs_plugin_ini_tag |> ~> Service['quantum-ovs-service-agent']
}
