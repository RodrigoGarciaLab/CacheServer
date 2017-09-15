require_relative 'data_item'
require_relative 'constants'
require 'singleton'

class Cache

  include Singleton 

  def initialize()    
    @data      = Hash.new  # stores information
    @exp_times = Hash.new  # stores expire times
    @cas_ids   = Hash.new  # stores unique Ids
    @index     = 0 
    @max_size  = 0
    
  end    

  def set_max_size(max_size)
    @max_size = max_size
  end     

  # BEGIN STORAGE COMMANDS

  def set(key, flags, ttl, bytes_size, value) 
    @data.delete(key) 
    @data[key]      = DataItem.new(flags, bytes_size, value)
    @exp_times[key] = [Time.now.to_i, ttl]   
    @cas_ids[key]   = get_autoincrement_id 

    if @data.length > @max_size
      to_delete_key = @data.first[0]
      @data.delete(to_delete_key) # From Ruby 1.9 Hash is ordered so the first element is the oldest one
      @exp_times.delete(to_delete_key)
      @cas_ids.delete(to_delete_key)
    end    
    return Constants::STORED
  end  

  def add(key, flags, ttl, bytes_size, value)
    if !@data.key? key
      set(key, flags, ttl, bytes_size, value)      
    else
      return Constants::NOT_STORED
    end
  end

  def replace(key, flags, ttl, bytes_size, value)
    if @data.key? key
      set(key, flags, ttl, bytes_size, value)
    else
      return Constants::NOT_STORED
    end
  end

  def append(key, bytes_size, value)
    if @data.key? key
      modify_CAS(key)
      lru_reorder(key)
      @data[key].append(bytes_size, value)       
      return Constants::STORED
    else
      return Constants::NOT_STORED
    end
  end   

  def prepend(key, bytes_size, value)
    if @data.key? key
      modify_CAS(key)
      lru_reorder(key)
      @data[key].prepend(bytes_size, value)       
      return Constants::STORED
    else
      return Constants::NOT_STORED
    end
  end 

  def cas(key, flags, ttl, bytes_size, unique_cas_token, value)
    if @cas_ids.key? key
      if @cas_ids[key] == unique_cas_token
        set(key, flags, ttl, bytes_size, value)
      else
        return Constants::EXISTS
      end
    else
      return Constants::NOT_FOUND
    end
  end 

  # BEGIN RETRIEVAL COMMANDS
  def getters(keys)
    output = String.new
    keys.each do |key|
      next if !@data.key? key
      lru_reorder(key)  
      output << yield(key)
    end
    output << Constants::END_STRING
  end

  def get(*keys)
    getters(keys){|key| generate_output(key)}
  end

  def gets(*keys)
    getters(keys){|key| generate_output_CAS(key)}    
  end

  # DELETE COMMAND
  def delete(key)
    @data.delete(key)
    @exp_times.delete(key)
    @cas_ids.delete(key)
  end

  # BEGIN AUX FUNCTIONS
  def hasKey? key
    @data.key? key
  end

  def wipe_out # not 
    @data.each do |key|
      @data.delete(key)
      @exp_times.delete(key)
      @cas_ids.delete(key)      
    end  
  end 

  def get_autoincrement_id  
    @index += 1
  end

  def generate_output(key)
    out = "#{Constants::VALUE} #{key} #{@data[key].flags.to_s} #{@data[key].size.to_s}#{Constants::EOL}#{@data[key].value.join(",")}#{Constants::EOL}"
  end

  def generate_output_CAS(key)
    out = "#{Constants::VALUE} #{key} #{@data[key].flags.to_s} #{@data[key].size.to_s} #{@cas_ids[key].to_s}#{Constants::EOL}#{@data[key].value.join(",")}#{Constants::EOL}"
  end

  def lru_reorder(key) # deletes and adds the accessed key to keep the Hash ordered according to LRU algorithm
    value = @data.delete(key)
    @data[key] = value
  end

  def modify_CAS(key)
    @cas_ids[key] = get_autoincrement_id
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
    time_then, ttl = @exp_times[key]
    if ttl == 0 #if ttl is zero it never expires
      return false
    end
    if ttl > 60*60*24*30 # if it`s more than 30 days, it`s unix time
      return Time.now.to_i > ttl
    else
      Time.now.to_i > time_then + ttl
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

  def get_max_size
    @max_size
  end

  def print_data
    p @data 
  end

  def print_keys
    p @data.keys 
  end

  def print_CAS
    p @cas_ids
  end  

  def print_times
    p @exp_times
  end  

  private :expire!, :expired?, :modify_CAS, :get_autoincrement_id
  private :generate_output, :generate_output_CAS, :lru_reorder

end