require_relative '../src/dataItem'
require_relative '../src/cache'

c = Cache.instance
c.setMaxSize(100)
data_item = DataItem.new(0,3,5)
puts data_item
serialized_object = Marshal::dump(data_item)
hw_bytes = serialized_object.unpack("c*")

out = c.set("key", 0, 50, 10, hw_bytes)
p out
out = c.get("key")
bytes = out.split("\r\n")[1].split(",")
bytes = bytes.map(&:to_i)

newSerialized =  bytes.pack("c*")
newItem = Marshal::load(newSerialized)
puts newItem
newItem.append(3,3)
puts newItem
