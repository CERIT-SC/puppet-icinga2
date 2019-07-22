class icinga2 (
   Array  $groups     = [],
   String $ip_address = $facts['ipaddress'],
) {
  require icinga2::install
   
  class {'icinga2::api':
    users     => lookup('icinga2::user'),
    passwords => lookup('icinga2::password'),
    urls      => lookup('icinga2::url'),
  }

  icinga2::icinga2_host { $facts['fqdn']:
    ensure               => "present",
    check_command        => "hostalive",
    address              => $ip_address,
    groups               => $groups,
    vars                 => lookup({'name' => 'icinga2::host_vars', 'default_value' => {}}),
    templates            => ["generic-host"],
    enable_notifications => true,
  }


  $nrpe_commands = lookup('icinga2::nrpe_commands', Hash, 'hash', {})
  $notify_users  = lookup({'name' => 'icinga2::notify_users', 'default_value' => []})
  $enable_notifications = lookup({'name' => 'icinga2::enable_notifications', 'default_value' => false})
  $notification_templates = lookup({'name' => 'icinga2::notify_templates', 'default_value' => []})
  
  $nrpe_commands.each |$name, $attr| {
    nrpe::plugin { $name:
      args    => $attr['args'],
      plugin  => $attr['plugin'],
    }

    icinga2::icinga2_service { $name:
      check_command          => "nrpe",
      enable_notifications   => $enable_notifications,
      notification_users     => $notify_users,
      notification_templates => $notification_templates,
      vars                   => { "nrpe_port" => 5666, "nrpe_command" => $name },
    }
  }
}
