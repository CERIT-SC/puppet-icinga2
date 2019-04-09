require 'rest-client'
require 'json'


Puppet::Functions.create_function(:'icinga2::create_object') do

  dispatch :create_object do
     param 'String', :nameOfObject
     param 'String', :typeOfObject
     param 'Hash',   :arguments
     param 'String', :url
  end

  def create_object(nameOfObject, typeOfObject, arguments, url)
     if typeOfObject == "host"
        arguments['attrs']['groups'].each do |hostgroup|
           check_hostgroup(hostgroup, url)
        end
        check_host(nameOfObject, arguments, url)
     elsif typeOfObject == "service"
        check_service(nameOfObject, arguments, url)
        if arguments['attrs']['enable_notifications']
           notify_arguments = {"attrs" => arguments['notification'], "templates" => arguments['notification_templates']}
           hostname         = arguments['hostname']
           check_notify(hostname, nameOfObject, notify_arguments, url)
        end
     else
        fail "Unknown type of object. Get type: #{typeOfObject}"
     end
  end

  dispatch :check_host do
     param 'String', :hostname
     param 'Hash',   :arguments
     param 'String',  :url
  end

  def check_host(hostname, arguments, url)
     arguments.delete("hostgroup")
     suffix = "hosts/#{hostname}"
     result = get("hosts", hostname, url)

     if result.empty?
         update(suffix, arguments, "put")
     elsif result[0]['attrs']['groups'].sort != arguments['attrs']['groups'].sort
         delete(suffix, url)
         update(suffix, arguments, "put", url)
     else
         update(suffix, arguments, "post", url)
     end
  end


  dispatch :check_hostgroup do
     param 'String', :hostgroup
     param 'String', :url
  end

  def check_hostgroup(hostgroup, url) 
     suffix = "hostgroups/#{hostgroup}"
     result = get("hostgroups", hostgroup, url)

     if result.empty?
        attributes = {"attr" => {"display_name" => hostgroup}}
        update(suffix, attributes, "put", url)
     end
  end

  dispatch :check_service do
     param 'String', :service
     param 'Hash',   :arguments
     param 'String', :url
  end

  def check_service(service, arguments, url)
     hostname = arguments["hostname"]
     arguments.delete("hostname")
     suffix = "services/#{hostname}!#{service}"
     result = get("services", "#{hostname}!#{service}", url)

     if result.empty?
         update(suffix, arguments, "put", url)
     else
         update(suffix, arguments, "post", url)    
     end 
  end


  dispatch :check_notify do
     param 'String',  :hostname
     param 'String',  :servicename
     param 'Hash',    :arguments
     param 'String',  :url
  end

  def check_notify(hostname, servicename, arguments, url)
     suffix = "notifications/#{hostname}!#{servicename}!#{servicename}-notification"
     result = get("notifications", "#{hostname}!#{servicename}!#{servicename}-notification", url)
     
     if result.empty?
         update(suffix, arguments, "put", url)
     else
         update(suffix, arguments, "post", url)    
     end 

  end

  dispatch :delete do
     param 'String', :suffix
     param 'String', :url
  end

  def delete(suffix, url)
    url += (suffix + "?cascade=1")      
    RestClient::Request.execute(:url => url, :method => :delete, :verify_ssl => false, :timeout => 10, :headers => {"Accept" => "application/json"})
  end

  dispatch :update do
     param 'String', :suffix
     param 'Hash',   :arguments
     param 'String', :method
     param 'String', :url
  end

  def update(suffix, arguments, method, url)
     url += suffix
     RestClient::Request.execute(:url => url, :method => method, :verify_ssl => false, :timeout => 10, :payload => arguments.to_json, :headers => {"Accept" => "application/json"})
  end

  dispatch :get do
     param 'String', :suffix
     param 'String', :name
     param 'String', :url
  end

  def get(suffix, name, url) 
     url   += suffix
     result = RestClient::Request.execute(:url => url, :method => :get, :timeout => 10, :verify_ssl => false) 
     result = JSON.parse( result )     
     return result['results'].select{|item| item['name'] == name}
  end
end
