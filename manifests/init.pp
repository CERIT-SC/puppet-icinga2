class icinga2 {
  include icinga2::install

  icinga2::host{ $facts['fqdn']: 
    check_command        => "hostalive",
    address              => $facts['ipaddress'],
    templates            => ["generic-host"],
    enable_notifications => true,
  }
}
