require 'puppet/resource_api'
require 'puppet'
require 'rest-client'
require 'json'

class Puppet::Provider::Icinga2Host::Icinga2Host 

  SETTABLEATTRIBUTES ||= FileTest.exist?("/var/tmp/icinga2_host_resources") ? File.read("/var/tmp/icinga2_host_resources").split("\n").freeze : []

  def get(context, name)
    result   = []
    tmpHash  = {}
    hostInfo = getInformation(name[0][:name], name[0][:url] + "hosts")

    if hostInfo.empty?
      tmpHash = { :name => name[0][:name], :url => name[0][:url], :ensure => "absent" }
    else
      tmpHash[:ensure] = "present"
      tmpHash[:name]   = name[0][:name]
      tmpHash[:url]    = name[0][:url]
      hostInfo[0]['attrs'].each do |nameOfAttribute, valueOfAttribute|

        next if SETTABLEATTRIBUTES.empty?
        
        if SETTABLEATTRIBUTES.include?(nameOfAttribute)
          if nameOfAttribute == "groups"
            tmpHash[nameOfAttribute.to_sym] = valueOfAttribute.sort  # TENTO IF KOLI ZOTREDENIU PRVKOV V POLI
          elsif nameOfAttribute == "templates"  # UZIVATEL NEZADAVA TEMPLATE S TYM ISTYM MENOM AKO STROJ. ALE ICINGA HEJ
            currentTemplates = valueOfAttribute.select do |template|
               template != name[0][:name]
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
    #CHANGE SOMETHING? WHAT IS FIRST??
    changes.each do |name, change|
      is = if context.type.feature?('simple_get_filter')
        change.key?(:is) ? change[:is] : (get(context, name) || []).find { |r| r[:name] == name[0][:name] }
      else
        change.key?(:is) ? change[:is] : (get(context) || []).find { |r| r[:name] == name[0][:name] }
      end
      context.type.check_schema(is) unless change.key?(:is)

      should = change[:should]
      raise 'SimpleProvider cannot be used with a Type that is not ensurable' unless context.type.ensurable?

      is = { name: name[0][:name], ensure: 'absent' } if is.nil?
      should = { name: name[0][:name], ensure: 'absent' } if should.nil?
      name_hash = if context.type.namevars.length > 1
                    # pass a name_hash containing the values of all namevars
                    name_hash = {}
                    context.type.namevars.each do |namevar|
                        name_hash[namevar] = change[:should][namevar]
                    end
                    name_hash
                  else
                    name
                  end

      if is[:ensure].to_s == 'absent' && should[:ensure].to_s == 'present'
        context.creating(name[:name]) do
          create(context, name_hash, should.clone)
        end
      elsif is[:ensure].to_s == 'present' && should[:ensure].to_s == 'present'
        #context.updating(name[:name]) do
          #update(context, name_hash, is, should.clone)
        #end
        puts "I would update this node. But I wont."
      elsif is[:ensure].to_s == 'present' && should[:ensure].to_s == 'absent'
        #context.deleting(name[:name]) do
          #delete(context, name_hash)
        #end
        puts "I would delete this node. But I wont."
      end
    end
  end

  
  def checkHostGroup(hostgroup, url)
    isThereGroup = getInformation(hostgroup, url + "hostgroups")
    
    if isThereGroup.empty?
       objectUrl = url + "hostgroups/#{hostgroup}"
       attributes = {"attr" => {"display_name" => hostgroup}}
       begin
          RestClient::Request.execute(:url => objectUrl, :method => "put", :verify_ssl => false, :timeout => 10, :payload => attributes.to_json, :headers => {"Accept" => "application/json"})
       rescue Errno::ECONNREFUSED, Errno::ENETUNREACH, RestClient::RequestTimeout => error
          return
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

  
  def create(context, name, should)
    should[:groups].each do |group|
       checkHostGroup(group, name[:url])
    end

    begin
       url = name[:url] + "hosts/#{name[:name]}"
       templates = should[:templates]
       removeUselessAttributes(should)
       attributes = {"attrs" => should, "templates" => templates}
       RestClient::Request.execute(:url => url, :method => "put", :verify_ssl => false, :timeout => 10, :payload => attributes.to_json, :headers => {"Accept" => "application/json"})
    rescue Errno::ECONNREFUSED, Errno::ENETUNREACH, RestClient::RequestTimeout => error
      return
    end
  end
  
  def removeUselessAttributes(attributes, removeGroups = false)
      attributes.delete(:templates)
      attributes.delete(:name)
      attributes.delete(:ensure)
      attributes.delete(:url)
      if removeGroups
        attributes.delete(:groups)
      end
  end
  
  def update(context, name, is, should)
    method = "post"
    if is[:groups] != should[:groups]
       delete(context, name)
       should[:groups].each do |group| #IS THERE NEW GROUP?
          checkHostGroup(group, name[:url])
       end
       method = "put"
    end

    begin
       url = name[:url] + "hosts/#{name[:name]}"
       templates = should[:templates]
       removeUselessAttributes(should, method == "post" ? true : false) 
       attributes = {"attrs" => should, "templates" => templates}
       RestClient::Request.execute(:url => url, :method => method, :verify_ssl => false, :timeout => 10, :payload => attributes.to_json, :headers => {"Accept" => "application/json"})
    rescue Errno::ECONNREFUSED, Errno::ENETUNREACH, RestClient::RequestTimeout => error
      return
    end
  end
  

  def delete(context, name)
    url = name[:url] + "hosts/#{name[:name]}?cascade=1"
    begin
       RestClient::Request.execute(:url => url, :method => "delete", :verify_ssl => false, :timeout => 10, :headers => {"Accept" => "application/json"})
    rescue Errno::ECONNREFUSED, Errno::ENETUNREACH, RestClient::RequestTimeout => error
      return
    end
  end
end
