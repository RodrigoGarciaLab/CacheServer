require_relative '../src/dataItem'
require_relative '../src/cache'

c = Cache.instance
c.setMaxSize(4)
c.set("key1", 0, 4, 3, "data1")
c.set("key2", 0, 4, 3, "data2")
c.set("key3", 0, 4, 3, "data3")
c.set("key4", 0, 4, 3, "data4")
p c.gets("key1")
c.set("key5", 0, 4, 3, "data5")
c.printKeys
c.printCas