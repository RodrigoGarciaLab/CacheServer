  def getters(keys)
    p keys
    output = String.new
    
    keys.each do |key|        
      output << yield
    end
    output << "Constants::END_STRING"
  end
  def get(keys)
    getters(keys){ " end "}
  end

  def gets(keys) 
    getters(keys){ " end2 "}
  end
  keys = [1,2,3]
  p get(keys)
  p gets(keys)