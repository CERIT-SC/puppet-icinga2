define icinga2::host (
   String            $address,
   Optional[String]  $display_name         = "",
   Optional[Array]   $groups               = [],
   Optional[Array]   $templates            = [],
   Optional[Hash]    $vars                 = {},
   Optional[String]  $check_command        = "hostalive",
   Optional[Integer] $check_interval       = 300,
   Optional[Integer] $retry_interval       = 60,
   Optional[Integer] $check_timeout        = 30,
   Optional[Boolean] $enable_active_checks = true,
   Optional[Boolean] $enable_event_handler = true,
   Optional[Boolean] $enable_notifications = false,
) {
     $_argumments = { "attrs"                 => {
                       "address"              => $address,
                       "display_name"         => $display_name,
                       "vars"                 => $vars,
                       "check_command"        => $check_command,
                       "check_interval"       => $check_interval,
                       "retry_interval"       => $retry_interval,
                       "check_timeout"        => $check_timeout,
                       "enable_active_checks" => $enable_active_checks,
                       "enable_event_handler" => $enable_event_handler,
                       "enable_notifications" => $enable_notifications,
                       "groups"               => $groups,
                    },
     }
     
     $_filtered_argumments = $_argumments['attrs'].filter |$k, $v| { $v != undef or $v != "" }
     $arguments = { "attrs" => $_filtered_argumments, "templates" => $templates }

     icinga2::create_object($title, "host", $arguments)
}
