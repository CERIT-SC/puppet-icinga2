class icinga2::install {

  $_allowed_hosts = lookup('icinga2::allowed_hosts', Array[String], 'first', ['127.0.0.1'])
  
  class { 'nrpe':
    allowed_hosts => $_allowed_hosts,
    server_port   => 5669,
  }
}
