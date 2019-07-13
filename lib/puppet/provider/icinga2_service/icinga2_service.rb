require 'puppet/resource_api'
require 'puppet'
require 'rest-client'
require 'json'

class Puppet::Provider::Icinga2Service::Icinga2Service

  SETTABLEATTRIBUTES ||= FileTest.exist?("/var/tmp/icinga2_service_resources") ? File.read("/var/tmp/icinga2_service_resources").split("\n").freeze : []

  def get(context, name)
    return []
  end

  def myGet(name, url)
    result   = []
    tmpHash  = {}
    serviceInfo      = getInformation(name, url + "services")
    notificationName = name + "!" + name.split("!")[1] + "-notification"
    notificationInfo = getInformation(notificationName, url + "notifications")

    if serviceInfo.empty?
      tmpHash = {:name => name, :ensure => "absent"}
    else
      if !notificationInfo.empty?
        serviceInfo[0]['attrs']["notification_templates"]   = notificationInfo[0]['attrs']["templates"]
        serviceInfo[0]['attrs']["notification_users"]       = notificationInfo[0]['attrs']["users"]
        serviceInfo[0]['attrs']["notification_user_groups"] = notificationInfo[0]['attrs']["user_groups"]
      else
        serviceInfo[0]['attrs']["notification_templates"]   = []
        serviceInfo[0]['attrs']["notification_users"]       = []
        serviceInfo[0]['attrs']["notification_user_groups"] = []
      end

      tmpHash[:ensure] = "present"
      tmpHash[:name]   = name
      serviceInfo[0]['attrs'].each do |nameOfAttribute, valueOfAttribute|

        next if SETTABLEATTRIBUTES.empty?
        
        if SETTABLEATTRIBUTES.include?(nameOfAttribute)
            if nameOfAttribute == "templates"
              currentTemplates = valueOfAttribute.select do |template|
                   template != name.split("!")[1]
              end
              tmpHash[nameOfAttribute.to_sym] = currentTemplates.sort
            else
              tmpHash[nameOfAttribute.to_sym] = valueOfAttribute
            end
        end
      end
    end

    result.push(tmpHash)
    return result
  end
  
  
  def set(context, changes)
    changes.each do |name, change|
      change[:should][:url].each do |url|
        is = myGet(name, url)[0]
        context.type.check_schema(is) unless change.key?(:is)

        should = change[:should]
        raise 'SimpleProvider cannot be used with a Type that is not ensurable' unless context.type.ensurable?

        should = { name: name, ensure: 'absent' } if should.nil?

        name_hash = if context.type.namevars.length > 1
                      # pass a name_hash containing the values of all namevars
                      name_hash = { title: name }
                      context.type.namevars.each do |namevar|
                        name_hash[namevar] = change[:should][namevar]
                      end
                      name_hash
                    else
                      name
                    end

        if is[:ensure].to_s == 'absent' && should[:ensure].to_s == 'present'
          context.creating(name) do
            create(context, name_hash, should.clone, url)
          end
        elsif is[:ensure].to_s == 'present' && should[:ensure].to_s == 'present'
          context.updating(name) do
            update(context, name_hash, is, should.clone, url)
          end
        elsif is[:ensure].to_s == 'present' && should[:ensure].to_s == 'absent'
          context.deleting(name) do
            delete(context, name_hash, "services", url)
          end
        end
      end
    end
  end

  
  def getInformation(name, url)
    begin
       result = RestClient::Request.execute(:url => url, :method => "get", :verify_ssl => false, :timeout => 10, :headres => {"Accept" => "application/json"})
    rescue Errno::ECONNREFUSED, Errno::ENETUNREACH, RestClient::RequestTimeout => error
       return []
    end
    result = JSON.parse(result)
    return result['results'].select{ |item| item['name'] == name }
  end


  def createNotification(name, attributes, url)
    notificationName = name + "!" + name.split("!")[1] + "-notification"
    url = url + "notifications/#{notificationName}"
    begin
       RestClient::Request.execute(:url => url, :method => "put", :verify_ssl => false, :timeout => 10, :payload => attributes.to_json, :headers => {"Accept" => "application/json"})
    rescue Errno::ECONNREFUSED, Errno::ENETUNREACH, RestClient::RequestTimeout => error
       return 
    end
  end


 def deleteUselessAttributes(attributes)                                                                                                                                                           
     attributes.delete(:notification_users)                                                                                                                                                         
     attributes.delete(:notification_templates)                                                                                                                                                     
     attributes.delete(:notification_user_groups)                                                                                                                                                  
     attributes.delete(:name)                                                                                                                                                                       
     attributes.delete(:ensure)                                                                                                                                                                     
     attributes.delete(:templates)                                                                                                                                                                  
     attributes.delete(:url)                                                                                                                                                                        
  end               

  
  def create(context, name, should, url)
    notificationData = {"attrs" => {"user_groups" => should[:notification_user_groups], "users" => should[:notification_users]}, "templates" => should[:notification_templates]}
    begin                                                                                                                              
       serviceUrl = url + "services/#{name}"
       templates = should[:templates]
       deleteUselessAttributes(should)
       attributes = {"attrs" => should, "templates" => templates}
       RestClient::Request.execute(:url => serviceUrl, :method => "put", :verify_ssl => false, :timeout => 10, :payload => attributes.to_json, :headers => {"Accept" => "application/json"})
    rescue Errno::ECONNREFUSED, Errno::ENETUNREACH, RestClient::RequestTimeout => error
      return
    end

    if should[:enable_notifications] == true
       createNotification(name, notificationData, url)
    end
  end
  
  
  def update(context, name, is, should, url)
    if (is[:notification_users] != should[:notification_users]) || (is[:notification_user_groups] != should[:notification_user_groups]) || (is[:notification_templates] != should[:notification_templates])

       notificationName = name + "!" + name.split("!")[1] + "-notification"
       notificationData = {"attrs" => {"user_groups" => should[:notification_user_groups], "users" => should[:notification_users]}, "templates" => should[:notification_templates]}

       if is[:notification_users] != [] || is[:notification_user_groups] != [] || is[:notification_templates] != []
          delete(context, notificationName, "notifications", url)  # DELETE NOTIFICATION ONLY IF EXISTS
       end

       if should[:enable_notifications] == true
          createNotification(notificationName, notificationData, url) # CREATE NOTIFICATION ONLY IF IS ENABLED
       end
    end

    should.delete("notification_users")
    should.delete("notification_user_groups")
    should.delete("notification_templates")

    begin
       url = url + "services/#{name}"
       templates = should[:templates]
       should.delete("templates")
       attributes = {"attrs" => should, "templates" => templates}
       RestClient::Request.execute(:url => url, :method => "post", :verify_ssl => false, :timeout => 10, :payload => attributes.to_json, :headers => {"Accept" => "application/json"})
    rescue Errno::ECONNREFUSED, Errno::ENETUNREACH, RestClient::RequestTimeout => error
      return
    end
  end
  

  def delete(context, name, object, url)
    url = url + "#{object}/#{name}?cascade=1"
    begin
       RestClient::Request.execute(:url => url, :method => "delete", :verify_ssl => false, :timeout => 10, :headers => {"Accept" => "application/json"})
    rescue Errno::ECONNREFUSED, Errno::ENETUNREACH, RestClient::RequestTimeout => error
      return
    end
  end
end

