require_relative '../src/cache'

describe Cache do 
  context "With valid input" do 

    before(:all) do 
      @cache = Cache.instance 
      @cache.set_max_size(3)
      @flags = 0
      @size  = 4
      @data  = "data"
    end 

    it "get should return only the word 'END' when there's no such key" do        
      key = "non_existing_key"      
      out_msg = @cache.get(key)            
      expect(out_msg == Constants::END_STRING).to be true  
    end 

    it "get should return the correct output" do        
      key   = "new_key" 
      @cache.set(key,@flags,0,@size,@data)   
      out_msg      = @cache.get(key)   
      expected_msg = "#{Constants::VALUE} #{key} #{@flags} #{@size}#{Constants::EOL}#{@data}#{Constants::EOL}#{Constants::END_STRING}"      
      expect(out_msg == expected_msg).to be true  
    end 

    it "gets should return the correct output" do        
      key   = "newer_key"   
      @cache.set(key,0,0,@size,@data) 
      expected_id  = 2 # since it's the second key ever stored
      out_msg      = @cache.gets(key)       
      expected_msg = "#{Constants::VALUE} #{key} #{@flags} #{@size} #{expected_id}#{Constants::EOL}#{@data}#{Constants::EOL}#{Constants::END_STRING}"      
      expect(out_msg == expected_msg).to be true  
    end 

  end   
end

