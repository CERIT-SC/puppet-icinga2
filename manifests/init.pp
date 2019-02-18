class icinga2 (
   Array  $nrpe_commands = [],
   String $host_ip_address = "127.0.0.1,
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

    $_name_of_check = $item["name"]

    icinga2::service { "${_name_of_check}":
      check_command => "nrpe",
      vars          => { "nrpe_port" => 5669, "nrpe_command" => $item['name'] },
    }
  }
}
