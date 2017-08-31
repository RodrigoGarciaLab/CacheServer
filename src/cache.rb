require_relative 'dataItem'
require_relative 'output'
require 'singleton'

class Cache
  include Singleton 

  def initialize()
    @@data   = Hash.new # almacena informacion
    @@times  = Hash.new # almacena tiempo de expiracion
    @@CASIds = Hash.new # almacena ids unicos
    @@index  = 0
    @@max_size = 0
  end    

  def setMaxSize(max_size)
    @@max_size = max_size
  end
  
  def print
    expire!
    puts @@data
    puts @@times
  end   
  @@output = Output.instance

  def set(key, flags, ttl, bytesSize, value)  

    data[key] = DataItem.new(flags, bytesSize, value)
    times[key] = [Time.now, ttl]
    casIds[key] = index
    index += 1
    self.class.class_variable_set(:@@index,index)
    return @@output.stored
  end

  def add(key, flags, ttl, bytesSize, value)
    data = self.class.class_variable_get(:@@data)
    if !data.key? key
      set(key, flags, ttl, bytesSize, value)
      return output.stored
    else
      return @@output.notStored
    end
  end

  def replace(key, flags, ttl, bytesSize, value)
    data = self.class.class_variable_get(:@@data)
    if data.key? key
      set(key, flags, ttl, bytesSize, value)
      return @@output.stored
    else
      return @@output.notStored
    end
  end

  def append(key,bytesSize,value)
    data = self.class.class_variable_get(:@@data)
    if data.key? key
      data[key].append(bytesSize,value) 
      return @@output.stored
    else
      return @@output.notStored
    end
  end

  def prepend(key,bytesSize,value)
    data = self.class.class_variable_get(:@@data)
    if data.key? key
      data[key].prepend(bytesSize,value) 
      return @@output.stored
    else
      return @@output.notStored
    end
  end 

   def cas(key, flags, ttl, bytesSize, unique_cas_token, value)
    data = self.class.class_variable_get(:@@data)
    times = self.class.class_variable_get(:@@times)
    casIds = self.class.class_variable_get(:@@CASIds)
    if casIds.key? key
      if casIds[key] == unique_cas_token
        set(key, flags, ttl, bytesSize, value)
      else
        return @@output.exists
      end
    else
      return @@output.notFound
    end
  end 


  def get(*keys)
    output = ""
    datolo =""
    keys.each do |key|
      datolo = data[key].value
      output << @@output.value << " " << key << " " << data[key].flags.to_s << " " << data[key].size.to_s <<  @@output.eol
      output << data[key].value.join(",") << @@output.eol
    end
    output << @@output.end
    return output, datolo
  end

  def gets(*keys)   
    output = ""
    keys.each do |key|
      output << key << " " << data[key].flags.to_s << " " 
      output << data[key].size.to_s  << " " << casIds[key].to_s <<  @@output.eol
      output << data[key].value.join(",") << @@output.eol
    end
    output << @@output.end
  end

  def expire!
    timed = self.class.class_variable_get(:@@times)
    data = self.class.class_variable_get(:@@data)
    casIds = self.class.class_variable_get(:@@CASIds)
    timed.each do |key, times|
      if expired?(key)
        data.delete(key)
        timed.delete(key)
        casIds.delete(key)
      end
    end
    self
  end

  def expired?(key)
    times = self.class.class_variable_get(:@@times)
    return true unless times.has_key?(key)
    time, ttl = times[key]
    if ttl > 60*60*24*30 # if it`s more than 30 days, it`s unix time
      return Time.now.to_i > ttl
    else
      Time.now - time > ttl
    end
  end

  # def self.before(*names)
  #   names.each do |name|
  #     m = instance_method(name)
  #     define_method(name) do |*args, &block|  
  #       yield
  #       m.bind(self).(*args, &block)
  #     end
  #   end
  # end

  #before(*instance_methods) { expire!} # este metodo lo tengo que llamar al principio de cada otro metodo

end