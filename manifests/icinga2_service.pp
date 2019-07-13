define icinga2::icinga2_service (
   String            $check_command,
   Optional[Array]   $templates                = [],
   Optional[Hash]    $vars                     = {},
   Optional[Float]   $check_interval           = 300.0,
   Optional[Float]   $retry_interval           = 60.0,
   Optional[Float]   $check_timeout            = 30.0,
   Optional[Boolean] $enable_notifications     = false,
   Optional[Array]   $notification_user_groups = [],
   Optional[Array]   $notification_users       = [],
   Optional[Array]   $notification_templates   = [],
) {
    $_new_urls    = $::icinga2::api::_new_urls
    $_attributes_to_set = [
                            "check_command", "templates", "vars",
                            "check_interval", "retry_interval", "check_timeout",
                            "enable_notifications", "notification_user_groups", "display_name",
                            "notification_users", "notification_templates", 
                          ]

    $_attributes_to_set.each |$_key| {
      ensure_resource('icinga2::service_res', $_key, {})
    }

    $_name_of_service = "${::fqdn}!${title}"

    icinga2_service { $_name_of_service:
      check_command            => $check_command,
      templates                => $templates,
      vars                     => $vars,
      display_name             => $title,
      check_interval           => $check_interval,
      retry_interval           => $retry_interval,
      check_timeout            => $check_timeout,
      enable_notifications     => $enable_notifications,
      notification_user_groups => $notification_user_groups,
      notification_users       => $notification_users,
      notification_templates   => $notification_templates,
      url                      => $_new_urls,
      require                  => Icinga2_host[$::fqdn],
    }
}
