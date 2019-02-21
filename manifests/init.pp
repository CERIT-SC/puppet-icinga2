class icinga2 (
   Array $groups  = [],
) {
  include icinga2::install

  icinga2::host{ $facts['fqdn']:
    check_command        => "hostalive",
    address              => $facts['ipaddress'],
    groups               => $groups,
    templates            => ["generic-host"],
    enable_notifications => true,
  }


  $nrpe_commands = lookup('icinga2::nrpe_commands', Hash, 'hash', {})

  $nrpe_commands.each |$name, $attr| {
    nrpe::plugin { $name:
      args    => $attr['args'],
      plugin  => $attr['plugin'],
    }

    icinga2::service { $name:
      check_command => "nrpe",
      vars          => { "nrpe_port" => 5669, "nrpe_command" => $name },
    }
  }
}
