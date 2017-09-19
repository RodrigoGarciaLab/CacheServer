require_relative '../src/cache'
require_relative '../src/constants'

describe Cache do 
   context "With valid input" do 

      before(:all) do 
         @cache = Cache.instance 
         @cache.set_max_size(3)
         @cache.wipe_out
      end 

      it "should set a new key" do        
         key = "testKey"
         @cache.set(key, 0, 400, 6, "middle")           
         expect(@cache.has_key? key).to be true 
      end   

      it "should return the correct message" do  
         key = "testKey"
         out_msg = @cache.set(key, 0, 400, 6, "middle")
         expect(out_msg == Constants::STORED).to be true 
      end  

      it "should append to existing key" do        
         key = "testKey"
         @cache.append(key, 4, "after") 
         data = @cache.get_data       
         value = data[key].value.join(",")
         expect(value == "middle,after").to be true 
      end  

      it "should prepend to existing key" do        
         key = "testKey"
         msg = @cache.prepend(key, 6, "before")        
         data = @cache.get_data       
         value = data[key].value.join(",")
         expect(value == "before,middle,after").to be true  
      end 
   end 
end