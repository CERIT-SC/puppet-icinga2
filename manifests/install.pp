class icinga2::install {
  package { 'Resource rest-client on the puppetserver':
    ensure   => "latest",
    name     => 'rest-client',
    provider => puppetserver_gem,
  }
}
