class DataItem
   attr_accessor :value, :size, :flags
   
   def initialize(flags, size, value)
   	  @flags = flags
   	  @size  = size
      @value = [value]         
   end

   def append(newSize, newValue)
      @value.push(newValue)
      @size += newSize
   end

   def prepend(newSize, newValue)
      @value.unshift(newValue)
      @size += newSize
   end

   def to_s
    "{flag:#{@flags}, size:#{@size}, value:#{@value}}\n"
    #'{ "flags": #{@flags} , "size": #{@size}, "value": #{@value} }\n'
  end
end