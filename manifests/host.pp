define icinga2::host (
   String            $address,
   String            $ensure,
   Optional[String]  $display_name         = $facts['fqdn'],
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
     require icinga2::api

     $_new_url = $::icinga2::api::new_url
#     $_attributes_to_set = [
#                             "address", "display_name", "groups",
#                             "templates", "vars", "check_command",
#                             "check_interval", "retry_interval",
#                             "check_timeout", "enable_active_checks",
#                             "enable_event_handler", "enable_notifications"
#                           ]

#     $_attributes_to_set.each |$_key| {
#       ensure_resource('icinga2::host_res', $_key, {})
#     }

 #    icinga2_host { $title:
 #      ensure               => $ensure,
 #      address              => $address,
 #      display_name         => $display_name,
 #      groups               => sort($groups),
 #      templates            => sort($templates),
 #      vars                 => $vars,
 #      check_command        => $check_command,
 #      check_interval       => $check_interval,
 #      check_timeout        => $check_timeout,
 #      enable_active_checks => $enable_active_checks,
 #      enable_event_handler => $enable_event_handler,
 #      enable_notifications => $enable_notification,
 #      url                  => $_new_url,
 #    }
 
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
 
     icinga2::create_object($title, "host", $arguments, $_new_url)
}
