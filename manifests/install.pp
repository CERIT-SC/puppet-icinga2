class icinga2::install {
  
  class { 'nrpe':
    allowed_hosts => [$icinga2::host_ip_address],
    server_port    => 5669,
  }
}
