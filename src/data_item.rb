class DataItem
   attr_accessor :value, :size, :flags
   
   def initialize(flags, size, value)
   	  @flags = flags
   	  @size  = size
      @value = [value]         
   end

   def append(new_size, new_value)
      @value.push(new_value)
      @size += new_size
   end

   def prepend(new_size, new_value)
      @value.unshift(new_value)
      @size += new_size
   end

   def to_s
    "{flag:#{@flags}, size:#{@size}, value:#{@value}}\n"
  end
end