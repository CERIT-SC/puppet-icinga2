class icinga2::install {

  $_allowed_hosts = lookup('icinga2::allowed_hosts', Array[String], 'first', ['127.0.0.1'])

  class { 'nrpe':
    allowed_hosts           => $_allowed_hosts,
    server_port             => 5666,
    nagios_plugins_package  => lookup('icinga2::nagios_plugins_package', Variant[Array[String],String], 'first', 'USE_DEFAULTS'), 
  }

  $_packages = lookup('icinga2::packages', Array[String], 'first', [])
  ensure_packages($_packages)
  
  concat { "/var/tmp/icinga2_service_resources":
    ensure  => present,
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
  }
  
  concat { "/var/tmp/icinga2_host_resources":
    ensure  => present,
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
  }
}
