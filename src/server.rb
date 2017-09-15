require_relative 'cache'
require_relative 'method_parameters'
require_relative 'constants'
require 'socket'
require 'json'

class Server

	def initialize(ip, port, cache_max_size, msg_max_size)
		@cache   	  = Cache.instance  	
		@server  	  = TCPServer.open(ip, port)
		@clients 	  = Hash.new
    @client_id  = 0
		
		@msg_max_size = msg_max_size
		@cache.set_max_size(cache_max_size)
		
		@params_amounts      = MethodsParameters::PARAMETERS_AMOUNTS	
		@public_commands     = MethodsParameters::PARAMETERS_AMOUNTS.keys	
		@strg_commands_names = MethodsParameters.get_storage_commands	
		@byte_size_pos       = MethodsParameters::BYTE_SIZE_POS
		run
	end

	def run
		loop do
			Thread.start(@server.accept) do |client|
				
        @thread_variables = Thread.current              

				loop do					  
          # variables accessible only from inside the thread
          @thread_variables[:out_msg]  = "" 
          @thread_variables[:no_reply] = false  
          @thread_variables[:is_storage]  = false  
          @thread_variables[:parameters]  = Array.new

					in_msg = client.recv(@msg_max_size).chomp					
					if in_msg.strip. == "quit" #mejorar
						break
					end			
          p in_msg		
					parse_input(client, in_msg)
				end
				client.puts "Closing memcached. Bye!"
				client.close
				Thread.kill
			end
		end
	end

  def get_client_id
    @client_id += 1
  end
  
	def is_number? string
	  true if Integer(string) rescue false
	end

	def args_numeric?(args)
		args.all? {|arg| is_number? arg} 
	end

	def request_data(client, cmd_name)
		client.write "Now send the data you want to store" # then request data block 
		
		byte_size   = @thread_variables[:parameters][@byte_size_pos[cmd_name]]	
  	#string_data = getData(client, @msg_max_size) # 
  	data = get_data(client, byte_size) #-> DUDA CONCEPTUAL
  	# data 		= JSON.parse(string_data)	
  	# data 		= data[0..byte_size-1]	
  	@thread_variables[:parameters].push(data)	
  end

	def get_data(client, byte_size)
		peek = client.recv(@msg_max_size, Socket::MSG_PEEK) 
  	data = client.recv(byte_size)	
  	
  	if peek.bytesize > byte_size # clean buffer
    	rest = []
    	while true													
    	  partial_data = client.recv(@msg_max_size)							  
    	  if partial_data.length < @msg_max_size
    	    break
    	  end
    	  rest << partial_data
    	end
		end	
		data			      	
	end

	def valid_keys?(keys)
		keys.all? {|key| valid_key? key}
	end

	def valid_key?(key)		
		special = "?<>',?[]}{=-)(*&^%$#`~{}"
		regex   = /[#{special.gsub(/./){|char| "\\#{char}"}}]/
		!(key =~ regex) && key.length <= 250
	end

	def valid_command?(cmd_name)
		!cmd_name.nil? && (@public_commands.include? cmd_name)
	end

  def correct_length?(cmd_name, parameters)
    required_amount = @params_amounts[cmd_name].first

    if parameters.length == required_amount # check if the amount of parameters is the same as expected and if it includes noreply.      		
      correct = true
      @thread_variables[:no_reply] = false      		
    else
      if (parameters.length == required_amount + 1) and (parameters[parameters.length-1] == "noreply")
        correct = true
        @thread_variables[:no_reply] = true
      else      			
        correct = false
        @thread_variables[:no_reply] = false
      end
    end
    return correct
  end

  def correct_type?(key, string_args)    	
  	correct = false    	

  	if !valid_key? key	
			@thread_variables[:out_msg] = "#{Constants::CLIENT_ERROR} : #{key} is not a valid key."
		else	  				      		
  		if !args_numeric?(string_args) 			      			
  			@thread_variables[:out_msg] = "#{Constants::CLIENT_ERROR} : #{cmd_name} parameters must be integers (except key)."	      				      			
  		else	      			   		
    		numeric_args = string_args.map(&:to_i) # now i know parameters are integers, i convert them
    		@thread_variables[:parameters] 	 = key, *numeric_args
    		correct      = true
    	end
    end
    return correct
	end

	def correct_parameters?(cmd_name, parameters)		
		correct = false 	

		if @strg_commands_names.include? cmd_name #if its a storage command, check if the amount and type of parameters
      
			@thread_variables[:is_storage]  = true			
			if !correct_length?(cmd_name, parameters) 	
      			
				@thread_variables[:out_msg] = "#{Constants::CLIENT_ERROR} : #{cmd_name} should have exactly #{required_amount.to_s} parameters."
			else
        
				if @thread_variables[:no_reply]
					key, *string_args, no_reply = parameters
				else
					key, *string_args = parameters
				end			
        
				correct = correct_type?(key, string_args)	 				    		
		  end
		else # retrieval commands, just have to check if the keys are valid
			if valid_keys?(parameters)
        @thread_variables[:parameters] = parameters
				correct = true
			else
				@thread_variables[:out_msg] = "#{Constants::CLIENT_ERROR} : At least one of the keys supplied is not a valid."
			end
		end
		return correct
	end

  def parse_input(client, str_params)
    parameters = str_params.split
    cmd_name   = parameters.shift #[0]    
    
    if !valid_command?(cmd_name)   	
      client.write Constants::error
    else	
      if correct_parameters?(cmd_name, parameters)        
        if @thread_variables[:is_storage]           
          request_data(client, cmd_name) 
        end   
        @thread_variables[:out_msg] = @cache.send(cmd_name, *@thread_variables[:parameters])								
      end   
      if !@thread_variables[:no_reply]
        client.write @thread_variables[:out_msg]	
      else
        client.write "no reply"
      end		
    end	    
  end

end