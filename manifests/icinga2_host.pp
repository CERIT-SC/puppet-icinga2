define icinga2::icinga2_host (
   String            $address,
   String            $ensure,
   Optional[String]  $display_name         = $facts['fqdn'],
   Optional[Array]   $groups               = [],
   Optional[Array]   $templates            = [],
   Optional[Hash]    $vars                 = {},
   Optional[String]  $check_command        = "hostalive",
   Optional[Float]   $check_interval       = 300.0,
   Optional[Float]   $retry_interval       = 60.0,
   Optional[Float]   $check_timeout        = 30.0,
   Optional[Boolean] $enable_active_checks = true,
   Optional[Boolean] $enable_event_handler = true,
   Optional[Boolean] $enable_notifications = false,
) {
    $_attributes_to_set = [
                            "address", "display_name", "groups",
                            "templates", "vars", "check_command",
                            "check_interval", "retry_interval",
                            "check_timeout", "enable_active_checks",
                            "enable_event_handler", "enable_notifications"
                          ]
                          
    unless defined(Concat['/var/tmp/icinga2_host_resources']) {
      concat { "/var/tmp/icinga2_host_resources":
        ensure  => present,
        mode    => '0644',
        owner   => 'root',
        group   => 'root',
      }
    }
    
    $_attributes_to_set.each |$_key| {
      ensure_resource('icinga2::host_res', $_key, {})
    }

    icinga2_host { $title:
      ensure               => $ensure,
      address              => $address,
      display_name         => $display_name,
      groups               => sort($groups),
      templates            => sort($templates),
      vars                 => $vars,
      check_command        => $check_command,
      check_interval       => $check_interval,
      check_timeout        => $check_timeout,
      enable_active_checks => $enable_active_checks,
      enable_event_handler => $enable_event_handler,
      enable_notifications => $enable_notification,
      url                  => $::icinga2::api::_new_urls[0],
    }
}
