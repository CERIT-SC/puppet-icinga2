class icinga2 {

  icinga2::host{ $facts['fqdn']: 
    check_command        => "hostalive",
    address              => $facts['ipaddress'],
    templates            => ["generic-host"],
    enable_notifications => true,
  }
}
