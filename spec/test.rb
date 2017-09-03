require_relative '../src/dataItem'
require_relative '../src/cache'

max_size = 100
c = Cache.instance
c.setMaxSize(max_size)
puts c.set("key", 0, 4, 3, "value")
puts c.append("key", 5, "after")
puts c.prepend("key", 32, "before")
puts c.set("key2", 0, 4, 3, "value222")
puts c.set("key3", 0, 4, 3, "valu333e")
puts c.set("key4", 0, 4, 3, "val443ue")
c.print