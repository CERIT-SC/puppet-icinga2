define icinga2::host (
   Optional[Array]   $groups               = [],
   Optional[Array]   $templates            = [], 
   String            $address,
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
     
     $_filtered_argumments = $_argumments['attrs'].filter |$k, $v| { $v != undef }
     $arguments = { "attrs" => $_filtered_argumments, "templates" => $templates }

     icinga2::create_object($title, "host", $arguments)
}
