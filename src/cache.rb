require 'byebug'
require_relative 'dataItem'
require_relative 'output'
require 'singleton'

class Cache

  include Singleton 

  def initialize()    
    @data      = Hash.new  # stores information
    @exp_times = Hash.new  # stores expire times
    @cas_ids   = Hash.new  # stores unique Ids
    @index     = 0 
    @max_size  = 0
    @output    = Output.instance 
  end    

  def setMaxSize(max_size)
    @max_size = max_size
  end     

  # BEGIN STORAGE COMMANDS

  def set(key, *args) #flags, ttl, bytesSize, value)  
    if args.length != 4
      return @output.client_error
    end
    p getMaxSize
    @data.delete(key) 
    @data[key]      = DataItem.new(args[0], args[2], args[3])
    @exp_times[key] = [Time.now, args[2]]   
    @cas_ids[key]   = @index #get
    @index += 1
    p "ahpora si"
    if @data.length > @max_size
      toDeletekey = @data.first[0]
      @data.delete(toDeletekey) # From Ruby 1.9 Hash is ordered so the first element is the oldest one
      @exp_times.delete(toDeletekey)
      @cas_ids.delete(toDeletekey)
    end    
    return @output.stored
  end  

  def add(key, flags, ttl, bytesSize, value)
    if !@data.key? key
      set(key, flags, ttl, bytesSize, value)
      return @output.stored
    else
      return @output.notStored
    end
  end

  def replace(key, flags, ttl, bytesSize, value)
    if @data.key? key
      set(key, flags, ttl, bytesSize, value)
      return @output.stored
    else
      return @output.notStored
    end
  end

  def append(key,bytesSize,value)
    if @data.key? key
      modifyCAS(key)
      lruReOrder(key)
      @data[key].append(bytesSize,value) 
      return @output.stored
    else
      return @output.notStored
    end
  end   

  def prepend(key,bytesSize,value)
    if @data.key? key
      modifyCAS(key)
      lruReOrder(key)
      @data[key].prepend(bytesSize,value)       
      return @output.stored
    else
      return @output.notStored
    end
  end 

  def cas(key, flags, ttl, bytesSize, unique_cas_token, value)
    if @cas_ids.key? key
      if @cas_ids[key] == unique_cas_token
        set(key, flags, ttl, bytesSize, value)
      else
        return @output.exists
      end
    else
      return @output.notFound
    end
  end 

  # BEGIN RETRIEVAL COMMANDS

  def get(*keys)
    output = ""
    keys.each do |key|
      next if !@data.key? key
      lruReOrder(key)  
      output << generateOutput(key) 
    end
    output << @output.end
    return output
  end

  def gets(*keys)   
    output = ""
    keys.each do |key|
      next if !@data.key? key
      lruReOrder(key)  
      output << generateOutputCAS(key)
    end
    output << @output.end
  end

  # DELETE COMMAND

  def delete(key)
    @data.delete(key) # From Ruby 1.9 Hash is ordered so the first element is the oldest one
    @exp_times.delete(key)
    @cas_ids.delete(key)
  end

  # BEGIN AUX FUNCTIONS
  def getAutoIncrementId  
    @index += 1
  end

  def generateOutput(key)
    @output.value << " " << key << " " << @data[key].flags.to_s << " " << @data[key].size.to_s <<  @output.eol << @data[key].value.join(",") << @output.eol
  end

  def generateOutputCAS(key)
    @output.value << " " << key << " " << @data[key].flags.to_s << " " << @data[key].size.to_s << " " << @cas_ids[key].to_s <<  @output.eol << @data[key].value.join(",") << @output.eol
  end

  def lruReOrder(key) # deletes and adds the accessed key to keep the Hash ordered according to LRU algorithm
    value = @data.delete(key)
    @data[key] = value
  end

  def modifyCAS(key)
    @cas_ids[key] = getAutoIncrementId
  end

  def expire!
    @exp_times.each do |key, exp_times|
      if expired?(key)
        @data.delete(key)
        @exp_times.delete(key)
        @cas_ids.delete(key)
      end
    end
    self
  end

  def expired?(key)
    return true unless @exp_times.has_key?(key)
    time, ttl = @exp_times[key]
    if ttl > 60*60*24*30 # if it`s more than 30 days, it`s unix time
      return Time.now.to_i > ttl
    else
      Time.now - time > ttl
    end
  end

  # This piece of code makes every other method call "expire!" before starting,
  # to make sure the Cache is updated
  self.instance_methods.each do |name|
    next if name.to_s.include? ("expire")
    m = instance_method(name)
    define_method(name) do |*args, &block|  
      expire!
      m.bind(self).(*args, &block)
    end
  end

  def getMaxSize
    @max_size
  end

  def printKeys
    p @data.keys 
  end

  def printCas
    p @cas_ids
  end

  def first
    p @data.first
  end

  def print
    puts @exp_times
  end  

end