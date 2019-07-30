# Install dependencies onto the server
#
# @summary  This class will install the Rest-client gem onto the server and perform
#           a reboot of the server.
#
# @example Declaring the class
#   include icinga2::server
#
# @param [String] rest_client_version A specific release version of Rest client to install
# @param [Type[Resource]] puppetserver_service  The name of the puppetserver service to reboot
class icinga2::server(
  String $rest_client_version = '1.8.0',
  String $api_version         = 'latest',
  Type[Resource] $puppetserver_service = $facts['pe_server_version'] ? {
    /./     => Service['pe-puppetserver'],
    default => Service['puppetserver']
  },
) {
    package { 'Rest client on the puppetserver':
      ensure   => $rest_client_version,
      name     => 'rest-client',
      provider => puppetserver_gem,
    }
    
    package { 'Resource API on the puppetserver':
      ensure   => $api_version,
      name     => 'puppet-resource_api',
      provider => puppetserver_gem,
    }

    Package['Rest client on the puppetserver'] ~> $puppetserver_service
}
