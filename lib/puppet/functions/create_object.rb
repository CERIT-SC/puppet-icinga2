require 'rest-client'
require 'json'

Puppet::Functions.create_function(:'create_object') do
  def create_object(nameOfObject, typeOfObject, arguments)
     if typeOfObject == "host"
        hostgroup = arguments["hostgroup"]
        check_hostgroup(hostgroup)
        check_host(nameOfObject, arguments)
     elsif typeOfObject == "service"
        notify_arguments = {"attrs" => arguments['notification'], "templates" => arguments['notification_templates']}
        hostname         = arguments['hostname']
        check_service(nameOfObject, arguments)
        check_notify(hostname, nameOfObject, notify_arguments)
     end
  end

  def check_host(hostname, arguments)
     arguments.delete("hostgroup")
     suffix = "hosts/#{hostname}"
     result = get("hosts", hostname)

     if result
         update(suffix, arguments, "put")
     else
         update(suffix, arguments, "post")       
     end
  end

  def check_hostgroup(host_group) 
     suffix = "hostgroups/#{host_group}"
     result = get("hostgroups", host_group)

     if result
        attributes = {"attr" => {"display_name" => host_group}}
        update(suffix, attributes, "put")
     end
  end

  def check_service(service, arguments)
     hostname = arguments["hostname"]
     arguments.delete("hostname")
     suffix = "services/#{hostname}!#{service}"
     result = get("services", "#{hostname}!#{service}")

     if result
         update(suffix, arguments, "put")
     else
         update(suffix, arguments, "post")    
     end 
  end

  def check_notify(hostname, servicename, arguments)
     suffix = "notifications/#{hostname}!#{servicename}!#{servicename}-notification"
     result = get("notifications", "#{hostname}!#{servicename}!#{servicename}-notification")
     if result
         update(suffix, arguments, "put")
     else
         update(suffix, arguments, "post")    
     end 

  end

  def update(suffix, arguments, method)
     url = format( 'https://apicerit:7OjByrydjus~@147.251.7.9:5665/v1/objects/%s', suffix)
     r = RestClient::Request.execute(:url => url, :method => method, :verify_ssl => false, :payload => arguments.to_json ,:headers => {"Accept" => "application/json"})
     # TODO CHECK RETURN CODE
  end

  def get(suffix, name) 
     url    = format( 'https://apicerit:7OjByrydjus~@147.251.7.9:5665/v1/objects/%s', suffix)
     result = RestClient::Request.execute(:url => url, :method => :get, :verify_ssl => false) 
     result = JSON.parse( result )     
     tmp = result['results'].select{|item| item['name'] == name}
     return tmp.length == 0 
  end
end
