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
        check_host(nameOfObject, arguments.clone, url)
     elsif typeOfObject == "service"
        check_service(nameOfObject, arguments.clone, url)
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
     param 'String', :url
  end

  def check_host(hostname, arguments, url)
     arguments.delete("hostgroup")
     object_url = url + "hosts/#{hostname}"
     result     = get(hostname, url + "hosts")

     if result.empty?
         update(arguments, "put", object_url)
     elsif result[0]['attrs']['groups'].sort != arguments['attrs']['groups'].sort
         delete(object_url + "?cascade=1")
         update(arguments, "put", object_url)
     else
         update(arguments, "post", object_url)
     end
  end


  dispatch :check_hostgroup do
     param 'String', :hostgroup
     param 'String', :url
  end

  def check_hostgroup(hostgroup, url) 
     object_url = url + "hostgroups/#{hostgroup}"
     result     = get(hostgroup, url + "hostgroups")

     if result.empty?
        attributes = {"attr" => {"display_name" => hostgroup}}
        update(attributes, "put", object_url)
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
     object_url =  url + "services/#{hostname}!#{service}"
     result     = get("#{hostname}!#{service}", url + "services")

     if result.empty?
         update(arguments, "put", object_url)
     else
         update(arguments, "post", object_url)    
     end 
  end


  dispatch :check_notify do
     param 'String',  :hostname
     param 'String',  :servicename
     param 'Hash',    :arguments
     param 'String',  :url
  end

  def check_notify(hostname, servicename, arguments, url)
     object_url = url + "notifications/#{hostname}!#{servicename}!#{servicename}-notification"
     result     = get("#{hostname}!#{servicename}!#{servicename}-notification", url + "notifications")
     
     if result.empty?
         update(arguments, "put", object_url)
     else
         update(arguments, "post", object_url)    
     end 

  end

  dispatch :delete do
     param 'String', :url
  end

  def delete(url)
    begin
      RestClient::Request.execute(:url => url, :method => "delete", :verify_ssl => false, :timeout => 10, :headers => {"Accept" => "application/json"})
    rescue Errno::ECONNREFUSED => error
      return
    end
  end

  dispatch :update do
     param 'String', :method
     param 'String', :url
     param 'Hash',   :arguments
  end

  def update(arguments, method, url)
    begin
      RestClient::Request.execute(:url => url, :method => method, :verify_ssl => false, :timeout => 10, :payload => arguments.to_json, :headers => {"Accept" => "application/json"})
    rescue Errno::ECONNREFUSED => error
      return
    end
  end

  dispatch :get do
     param 'String', :name
     param 'String', :url
  end

  def get(name, url) 
    begin
      result = RestClient::Request.execute(:url => url, :method => :get, :timeout => 10, :verify_ssl => false)
    rescue Errno::ECONNREFUSED => error
      return []
    end
    result = JSON.parse(result)     
    return result['results'].select{|item| item['name'] == name}
  end
end
