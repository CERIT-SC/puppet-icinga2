define icinga2::service_res (
) {
  concat::fragment { "icinga2_service_${title}":
    target  => "/var/tmp/icinga2_service_resources",
    content => "${title}\n",
    require => Concat['/var/tmp/icinga2_service_resources']
  }
}

