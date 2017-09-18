require_relative '../src/cache'

describe Cache do 
  context "With valid input" do 

    before(:all) do 
      @cache = Cache.instance 
      @cache.set_max_size(3)
      @cache.wipe_out
    end 

    it "should add a new key" do        
       key = "non_existing_key"
       @cache.replace(key, 0, 40, 10, "won´t store")        
       data = @cache.get_data              
       expect(@cache.has_key? key).to be false  
    end  

    it "it shouldn't add if there's already such key" do        
       key = "non_existing_key"
       @cache.replace(key, 0, 40, 10, "won´t store")        
       data = @cache.get_data              
       expect(@cache.has_key? key).to be false  
    end
      
  	it "should replace existing key" do        
       key = "non_existing_key"
       @cache.replace(key, 0, 40, 10, "won´t store")        
       data = @cache.get_data              
       expect(@cache.has_key? key).to be false  
    end  

    it "it shouldn't replace if there's no such key" do        
       key = "non_existing_key"
       @cache.replace(key, 0, 40, 10, "won´t store")        
       data = @cache.get_data              
       expect(@cache.has_key? key).to be false  
    end

  end   
end

