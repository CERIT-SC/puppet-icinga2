class icinga2 (
   Array $groups  = [],
) {
  include icinga2::install
   
  class {'icinga2::api':
    user     => lookup('icinga2::user'),
    password => lookup('icinga2::password'),
    url      => lookup('icinga2::url'),
  }

  icinga2::icinga2_host { $facts['fqdn']:
    ensure               => "present",
    check_command        => "hostalive",
    address              => $facts['ipaddress'],
    groups               => $groups,
    templates            => ["generic-host"],
    enable_notifications => true,
  }


  $nrpe_commands = lookup('icinga2::nrpe_commands', Hash, 'hash', {})
  $notify_users  = lookup('icinga2::notify_users')

  $nrpe_commands.each |$name, $attr| {
    nrpe::plugin { $name:
      args    => $attr['args'],
      plugin  => $attr['plugin'],
    }

    icinga2::icinga2_service { $name:
      check_command        => "nrpe",
      enable_notifications => true,
      notification_users   => $notify_users,
      vars                 => { "nrpe_port" => 5666, "nrpe_command" => $name },
    }
  }
}
