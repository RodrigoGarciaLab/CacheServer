require_relative '../src/methodParameters'
require_relative '../src/cache'
 @saved_keys = []
def randomCommands
	length = 2
	if @saved_keys.length > 0
		saved_key = @saved_keys.sample
		other_saved_key = @saved_keys.sample
		length = 6
	end
	random_index = rand(0..length)
	require_data = random_index > 4 ? false : true
	random_key = rand(36**8).to_s(36)
	case random_index
		when 0			
			@saved_keys.push(random_key)
			inputMsg = "set #{random_key} 0 0 15" 
		when 1
			inputMsg = "set #{random_key} should fail 15"
		when 2
			inputMsg ="set #{random_key} 0 10 12"
		when 3		
			inputMsg ="append #{random_key} 5"
		when 4	
			inputMsg ="prepend #{random_key} 4"
		when 5
			inputMsg ="get #{saved_key} should fail 15"
		when 6
			inputMsg ="get #{saved_key} #{other_saved_key} should fail 15"			
		else
			"it shouldn`t be anything else"
	end
	return inputMsg, require_data
end

a, b = randomCommands
p a
p b