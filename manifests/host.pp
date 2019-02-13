define icinga2::host (
   Optional[String]  $hostgroup            = undef,
   Optional[Array]   $templates            = [], 
   String            $address              = undef,
   Optional[Hash]    $vars                 = undef,
   Optional[String]  $check_command        = "hostalive",
   Optional[Integer] $check_interval       = undef,
   Optional[Integer] $retry_interval       = undef,
   Optional[Integer] $check_timeout        = undef,
   Optional[Boolean] $enable_active_checks = undef,
   Optional[Boolean] $enable_event_handler = undef,
   Optional[Boolean] $enable_notifications = undef,
) {
  
  if ($templates == undef or $templates.size == 0) and ($check_command == undef) {
     fail("Attribute templates or check_command must be specified")
  } else {
     $_argumments = { "attrs" => {
                       "address"              => $address,
                       "vars"                 => $vars,
                       "check_command"        => $check_command,
                       "check_interval"       => $check_interval,
                       "retry_interval"       => $retry_interval,
                       "check_timeout"        => $check_timeout,
                       "enable_active_checks" => $enable_active_checks,
                       "enable_event_handler" => $enable_event_handler,
                       "enable_notifications" => $enable_notifications,
                   },
     }
     
     $_filter_argumments = $_argumments['attrs'].filter |$k, $v| { $v != undef }
     $arguments = { "hostgroup" => $hostgroup, "attrs" => $_filter_argumments, "templates" => $templates }

     create_object($title, "host", $arguments)
  }
}
