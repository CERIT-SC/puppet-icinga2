define icinga2::service (
   Optional[Array]   $templates                = [],
   Optional[Hash]    $vars                     = undef,
   Optional[String]  $check_command            = "ping",
   Optional[Integer] $check_interval           = undef,
   Optional[Integer] $retry_interval           = undef,
   Optional[Integer] $check_timeout            = undef,
   Optional[Boolean] $enable_notifications     = undef,
   Optional[Array]   $notification_user_groups = undef,
   Optional[Array]   $notification_users       = undef,
   Optional[Array]   $notification_templates   = undef,
) {

  if ($templates == undef or $templates.size == 0) and ($check_command == undef) {
     fail("Attribute templates or check_command must be specified")
  } elsif ($notification_user_groups == undef and $notification_users == undef and $enable_notifications == true) {
     fail("Atribute notification_user_groups or notification_users must be specified if you want notifications")
  } else {
     $_argumments = { "attrs" => {
                       "vars"                 => $vars,
                       "check_command"        => $check_command,
                       "check_interval"       => $check_interval,
                       "retry_interval"       => $retry_interval,
                       "check_timeout"        => $check_timeout,
                       "enable_notifications" => $enable_notifications,
                   },
     }

     $_filter_argumments = $_argumments['attrs'].filter |$k, $v| { $v != undef }
     $arguments = { "hostname" => $fatcs['fqdn'], "attrs" => $_filter_argumments, "templates" => $templates,
                    "notification" => { "user_groups" => $notification_user_groups, "users" => $notification_users },
                    "notification_templates" => $notification_templates
                  }

     create_object($title, "service", $arguments)
  }
}

