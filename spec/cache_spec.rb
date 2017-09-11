require_relative '../src/cache'


describe Cache do 
   context "With valid input" do 

      before(:all) do 
         @cache = Cache.instance 
         @cache.setMaxSize(3)
         @cache.wipeOut
      end 

      it "should expire items after their TTL" do        
         key = "key"
         ttl = 4
         @cache.set(key, 0, ttl, 3, "data")
         sleep(5)
         expect(@cache.hasKey? key).to be false 
      end      

      it "should replace items according to LRU algorithm" do
         [1,2,3].each do | elem | 
            key = "key#{elem}"
            data = "data#{elem}"
            @cache.set(key, 0, 4, 3, data) 
         end
         # LRU item is key 1
         @cache.gets("key1")
         # LRU item is key 2
         @cache.set("key4", 0, 4, 3, "data4")         
         expect(@cache.hasKey? "key2").to be false
      end  

   end 
end