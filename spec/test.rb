require_relative '../src/cache'

@cache = Cache.instance 
@cache.set_max_size(3)
# @cache.wipe_out

p "should set a new key"         
key = "testKey"
@out_msg = @cache.set(key, 0, 400, 6, "middle")          

p "should return the correct message"   
p @out_msg
p (@out_msg == "STORED\r\n")
