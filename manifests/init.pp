class icinga2 (
   Array $nrpe_commands = [],
) {
  include icinga2::install

  icinga2::host{ $facts['fqdn']:
    check_command        => "hostalive",
    address              => $facts['ipaddress'],
    templates            => ["generic-host"],
    enable_notifications => true,
  }


  $nrpe_commands.each |$item| {
    nrpe::plugin { $item['name']:
      args    => $item['args'],
      plugin  => $item['plugin'],
    }

    icinga2::service { $item['name']:
      check_command => "nrpe",
      vars          => { "nrpe_port" => 5669, "nrpe_command" => $item['name'] },
    }
  }
}
