require 'puppet/resource_api'
require 'puppet/resource_api/simple_provider'
require 'puppet'
require 'rest-client'
require 'json'

class Puppet::Provider::Icinga2Host::Icinga2Host 

  SETTABLEATTRIBUTES ||= FileTest.exist?("/var/tmp/icinga2_host_resources") ? File.read("/var/tmp/icinga2_host_resources").split("\n").freeze : []

  def get(context, name, url)
    result   = []
    tmpHash  = {}
    hostInfo = getInformation(name, url + "hosts")

    if hostInfo.empty?
      tmpHash = {:name => name, :ensure => "absent"}
    else
      tmpHash[:ensure] = "present"
      tmpHash[:name]   = name
      tmpHash[:url]    = url
      hostInfo[0]['attrs'].each do |nameOfAttribute, valueOfAttribute|
        next if SETTABLEATTRIBUTES.empty?  #TODO MOZNO BREAK NAMIESTO NEXT
        if SETTABLEATTRIBUTES.include?(nameOfAttribute)
          if nameOfAttribute == "groups"
            tmpHash[nameOfAttribute.to_sym] = valueOfAttribute.sort 
          elsif nameOfAttribute == "templates"
            currentTemplates = valueOfAttribute.select do |template|
               template != name
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
      url = change[:should][:url]
      is = if context.type.feature?('simple_get_filter')
        change.key?(:is) ? change[:is] : (get(context, name, url) || []).find { |r| r[:name] == name }
      else
        change.key?(:is) ? change[:is] : (get(context) || []).find { |r| r[:name] == name }
      end
      context.type.check_schema(is) unless change.key?(:is)
  
      should = change[:should]
      raise 'SimpleProvider cannot be used with a Type that is not ensurable' unless context.type.ensurable?
  
      is = { name: name, ensure: 'absent' } if is.nil?
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
          create(context, name_hash, should)
        end
      elsif is[:ensure].to_s == 'present' && should[:ensure].to_s == 'present'
        context.updating(name) do
          update(context, name_hash, is, should)
        end
      elsif is[:ensure].to_s == 'present' && should[:ensure].to_s == 'absent'
        context.deleting(name) do
          delete(context, name_hash, is[:url])
        end
      end
    end
  end

  
  def checkHostGroup(hostgroup, url)
    isThereGroup = getInformation(hostgroup, url + "hostgroups")
    
    if isThereGroup.empty?
       objectUrl = url + "hostgroups/#{hostgroup}"
       attributes = {"attr" => {"display_name" => hostgroup}}
       RestClient::Request.execute(:url => objectUrl, :method => "put", :verify_ssl => false, :timeout => 10, :payload => attributes.to_json, :headers => {"Accept" => "application/json"})
    end
  end


  def getInformation(name, url)
    begin
       result = RestClient::Request.execute(:url => url, :method => "get", :verify_ssl => false, :timeout => 10, :headres => {"Accept" => "application/json"})
    rescue => error
       raise("Something happend: #{error}")
    end
    result = JSON.parse(result)
    return result['results'].select{|item| item['name'] == name}
  end

  
  def create(context, name, should)
    url = should[:url]
    should.delete("url")
    should[:groups].each do |group|
       checkHostGroup(group, url)
    end

    begin
       url = url + "hosts/#{name}"
       templates = should[:templates]
       should.delete("templates")
       attributes = {"attrs" => should, "templates" => templates}
       RestClient::Request.execute(:url => url, :method => "put", :verify_ssl => false, :timeout => 10, :payload => attributes.to_json, :headers => {"Accept" => "application/json"})
    rescue => error
       raise("Something happend: #{error}")
    end
  end
  
  
  def update(context, name, is, should)
    url = should[:url]
    should.delete("url")
    method = "post"
    if is[:groups] != should[:groups]
       delete(context, name, url)
       should[:groups].each do |group| #IS THERE NEW GROUP?
          checkHostGroup(group, url)
       end
       method = "put"
    end

    begin
       url = url + "hosts/#{name}"
       templates = should[:templates]
       should.delete("templates")
       attributes = {"attrs" => should, "templates" => templates}
       RestClient::Request.execute(:url => url, :method => method, :verify_ssl => false, :timeout => 10, :payload => attributes.to_json, :headers => {"Accept" => "application/json"})
    rescue => error
      raise("Something happend: #{error}")
    end
  end
  

  def delete(context, name, url)
    url = url + "hosts/#{name}?cascade=1"
    begin
       RestClient::Request.execute(:url => url, :method => "delete", :verify_ssl => false, :timeout => 10, :headers => {"Accept" => "application/json"})
    rescue => error
       raise("Something happend: #{error}")
    end
  end
end
