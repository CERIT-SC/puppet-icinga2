class icinga2::api (
  String $user,
  String $password,
  String $url,
) {
     $_last_char = inline_template('<%= @url[-1,1] %>')

     if $_last_char == "/" {
        $new_url = regsubst($url, "^(.*):\/\/(.*)", "\1://${user}:${password}@\2v1/objects/")
     } else {
        $new_url = regsubst($url, "^(.*):\/\/(.*)", "\1://${user}:${password}@\2/v1/objects/")
     }
     
     file { 'icinga2_url':
       path    => "/var/tmp/icinga2_url",
       mode    => "0700",
       content => $new_url,
     }
}
