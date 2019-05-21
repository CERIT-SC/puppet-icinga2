define icinga2::icinga2_service (
   String            $check_command,
   Optional[Array]   $templates                = [],
   Optional[Hash]    $vars                     = {},
   Optional[Integer] $check_interval           = 300,
   Optional[Integer] $retry_interval           = 60,
   Optional[Integer] $check_timeout            = 30,
   Optional[Boolean] $enable_notifications     = false,
   Optional[Array]   $notification_user_groups = [],
   Optional[Array]   $notification_users       = [],
   Optional[Array]   $notification_templates   = [],
) {
     require icinga2::api

     $_new_url    = $::icinga2::api::new_url
     $_argumments = { "attrs" => {
                       "vars"                 => $vars,
                       "check_command"        => $check_command,
                       "check_interval"       => $check_interval,
                       "retry_interval"       => $retry_interval,
                       "check_timeout"        => $check_timeout,
                       "enable_notifications" => $enable_notifications,
                    },
     }

     $_filtered_argumments = $_argumments['attrs'].filter |$k, $v| { $v != undef }
     $arguments = { "hostname" => $facts['fqdn'], "attrs" => $_filtered_argumments, "templates" => $templates,
                    "notification" => { "user_groups" => $notification_user_groups, "users" => $notification_users },
                    "notification_templates" => $notification_templates
                  }

     icinga2::create_object($title, "service", $arguments, $_new_url)
}
