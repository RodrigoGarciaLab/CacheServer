require_relative '../src/dataItem'
require_relative '../src/cache'
c = Cache.instance
c.set("key", 0, 4, 3, "data")
c.print
#sleep(5)
a = c.get("key")
c.print
puts a