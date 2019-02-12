class icinga2 {

  icinga2::host{ $fqdn: 
    hostgroup     => "TEST-PUPPET",
    check_command => "check_vzdy_ok",
    templates     => ["generic-host"],
    vars          => {"vars.tmp" => "asd" , "vars.example" => "asdsad" },
    enable_notifications => true,
  }


  icinga2::service{ "testService-API2":
    enable_notifications     => true,
    notification_user_groups => ["icingaadmins"],
    notification_templates   => ["mail-service-notification"],
  }
}
