require 'rest-client'
require 'json'

#TYPY a vsetky vetvy if , kontrola nil -> zmenit na hostgroup
Puppet::Functions.create_function(:'create_object') do
  def create_object(nameOfObject, typeOfObject, arguments)
     if typeOfObject == "host"
        arguments['attrs']['groups'].each do |hostgroup|
           check_hostgroup(hostgroup)
        end
        check_host(nameOfObject, arguments)
     elsif typeOfObject == "service"
        check_service(nameOfObject, arguments)
        if arguments['attrs']['enable_notifications']
           notify_arguments = {"attrs" => arguments['notification'], "templates" => arguments['notification_templates']}
           hostname         = arguments['hostname']
           check_notify(hostname, nameOfObject, notify_arguments)
        end
     else
        fail "Unknown type of object. Get type: #{typeOfObject}"
     end
  end

  def check_host(hostname, arguments)
     arguments.delete("hostgroup")
     suffix = "hosts/#{hostname}"
     result = get("hosts", hostname)

     if result.nil?
         update(suffix, arguments, "put")
     elsif result[0]['attrs']['groups'].sort != arguments['attrs']['groups'].sort
         delete(suffix)
         update(suffix, arguments, "put")
     else
         update(suffix, arguments, "post")
     end
  end


  def check_hostgroup(hostgroup) 
     suffix = "hostgroups/#{hostgroup}"
     result = get("hostgroups", hostgroup)

     if result.nil?
        attributes = {"attr" => {"display_name" => hostgroup}}
        update(suffix, attributes, "put")
     end
  end

  def check_service(service, arguments)
     hostname = arguments["hostname"]
     arguments.delete("hostname")
     suffix = "services/#{hostname}!#{service}"
     result = get("services", "#{hostname}!#{service}")

     if result.nil?
         update(suffix, arguments, "put")
     else
         update(suffix, arguments, "post")    
     end 
  end

  def check_notify(hostname, servicename, arguments)
     suffix = "notifications/#{hostname}!#{servicename}!#{servicename}-notification"
     result = get("notifications", "#{hostname}!#{servicename}!#{servicename}-notification")
     
     if result.nil?
         update(suffix, arguments, "put")
     else
         update(suffix, arguments, "post")    
     end 

  end

  def delete(suffix)
    url = format( 'https://apicerit:7OjByrydjus~@147.251.7.9:5665/v1/objects/%s?cascade=1', suffix)      
    RestClient::Request.execute(:url => url, :method => :delete, :verify_ssl => false, :timeout => 10, :headers => {"Accept" => "application/json"})
  end

  def update(suffix, arguments, method)
     url = format( 'https://apicerit:7OjByrydjus~@147.251.7.9:5665/v1/objects/%s', suffix)
     #verify_ssl 
     r = RestClient::Request.execute(:url => url, :method => method, :verify_ssl => false, :timeout => 10, :payload => arguments.to_json ,:headers => {"Accept" => "application/json"})
     # TODO CHECK RETURN CODE
  end

  def get(suffix, name) 
     url    = format( 'https://apicerit:7OjByrydjus~@147.251.7.9:5665/v1/objects/%s', suffix)
     result = RestClient::Request.execute(:url => url, :method => :get, :timeout => 10, :verify_ssl => false) 
     result = JSON.parse( result )     
     return result['results'].select{|item| item['name'] == name}
  end
end
