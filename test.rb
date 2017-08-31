require_relative 'dataItem'
require_relative 'modularized'
require "yaml"
c = Cache.instance
# puts c.set("key", 0, 4, 3, "value")
# puts c.append("key", 5, "after")
# puts c.prepend("key", 32, "before")
# puts c.set("key2", 0, 4, 3, "value222")
# puts c.set("key3", 0, 4, 3, "valu333e")
# puts c.set("key4", 0, 4, 3, "val443ue")
# puts c.gets("key","key4","key3")#{}"key2","key3","key4")
d = DataItem.new(0,3,5)
puts d
# hw_bytes = d.bytes
# => [72, 101, 108, 108, 111, 44, 32, 119, 111, 114, 108, 100]
serialized_object = Marshal::dump(d)
hw_bytes = serialized_object.bytes
c.set("key", 0, 4, 3, hw_bytes)
a = c.get("key")

newSerialized =  a[1][0].pack("c*")
newItem = Marshal::load(newSerialized)
puts newItem
newItem.append(3,3)
puts newItem