define icinga2::host_res (
) {
  concat::fragment { "icinga2_host_${title}":
    target  => "/var/tmp/icinga2_host_resources",
    content => "${title}\n",
  }
} 
