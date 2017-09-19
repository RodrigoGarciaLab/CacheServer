require_relative '../src/cache'

describe Cache do 
  context "With valid input" do 

    before(:all) do 
      @cache = Cache.instance 
      @cache.set_max_size(3)
      @key = "key"
      @cache.set(@key, 0, 0, 12, "won't expire")
    end 

    it "should add a new key" do        
      key = "non_existing_key"
      @cache.add(key, 0, 40, 8, "new data")
      expect(@cache.has_key? key).to be true  
    end  

    it "it shouldn't add if there's already such key" do        
      @cache.add(@key, 0, 40, 10, "won't add")        
      data = @cache.get_data 
      old_value = data[@key].value            
      expect(old_value == "won't add").to be false  
    end

    it "should replace existing key" do  
      @cache.replace(@key, 0, 40, 10, "replaced")        
      data = @cache.get_data              
      expect(data[@key].value.join(",") == "replaced").to be true 
      expect(@cache.has_key? @key).to be true   
    end  

    it "it shouldn't replace if there's no such key" do
      key = "new_key"
      @cache.replace(key, 0, 40, 10, "won't replace")        
      expect(@cache.has_key? key).to be false  
    end

  end   
end

