class icinga2 {

  icinga2::host{ $fatcs['fqdn']: 
    check_command        => "hostalive",
    address              => $fatcs['ipaddress'],
    templates            => ["generic-host"],
    enable_notifications => true,
  }
}
