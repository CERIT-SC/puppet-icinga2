class icinga2::api (
  Array[String] $users,
  Array[String] $passwords,
  Array[String] $urls,
) {
     $users.map |Integer $index, String $user| {
         $_last_char = inline_template('<%= @urls[@index][-1,1] %>')

         if $_last_char == "/" {
            regsubst($urls[$index], "^(.*):\/\/(.*)", "\1://${users[$index]}:${passwords[$index]}@\2v1/objects/")
         } else {
            regsubst($urls[$index], "^(.*):\/\/(.*)", "\1://${users[$index]}:${passwords[$index]}@\2/v1/objects/")
         }
     }
     
     $_new_urls = $users
}
