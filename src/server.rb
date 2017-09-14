require 'socket'
require_relative 'cache'
require_relative 'method_parameters'
require 'json'

class Server

	def initialize(ip,port,cache_max_size,msg_max_size)
		@cache   	  = Cache.instance  	
		@server  	  = TCPServer.open(ip, port)
		@clients 	  = Hash.new
		@output 	  = Output.instance 
		@msg_max_size = msg_max_size
		@cache.setMaxSize(cache_max_size)


		@params  		   = MethodsParameters.instance
		@params_amounts    = @params.getParametersAmounts	 #att accessor	
		@public_commands   = @params_amounts.keys	
		@strg_commands_names = @params.getStorageCommands	
		@byte_size_pos     = @params.getByteSizePos
		run
	end

	def run
		loop do
			Thread.start(@server.accept) do |client|
				p "llega cliente"
				loop do					
					in_msg = client.recv(@msg_max_size).chomp					
					if in_msg.strip. == "quit" #mejorar
						break
					end					
					parse_input(client, in_msg)
				end
				client.puts "Closing memcached. Bye!"
				client.close
				Thread.kill
			end
		end
	end

	def is_number? string
	  true if Integer(string) rescue false
	end

	def args_numeric?(args)
		args.all? {|arg| is_number? arg} 
	end

	def request_data(client,cmd_name,parameters)
		client.write "Now send the data you want to store" # then request data block 
		
		byte_size   = parameters[@byte_size_pos[cmd_name]]	
      	#string_data = getData(client,@msg_max_size) # 
      	data = get_data(client,byte_size) #-> DUDA CONCEPTUAL
      	# data 		= JSON.parse(string_data)	
      	# data 		= data[0..byte_size-1]	
      	parameters.push(data)	
    end

	def get_data(client, byte_size)
		peek =  client.recv(@msg_max_size,Socket::MSG_PEEK) 
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
		regex = /[#{special.gsub(/./){|char| "\\#{char}"}}]/
		!(key =~ regex) && key.length <= 250
	end

	def valid_command?(cmd_name)
		!cmd_name.nil? && (@public_commands.include? cmd_name)
	end

	def correct_length?(cmd_name,parameters)
		required_amount = @params_amounts[cmd_name].first
      	if parameters.length == required_amount # check if the amount of parameters is the same as expected and if it includes noreply.      		
      		correct = true
      		no_reply = false      		
      	else
      		if (parameters.length == required_amount + 1) and (parameters[parameters.length-1] == "noreply")
      			correct = true
      			no_reply = true
      		else      			
      			correct = false
      			no_reply = false
      		end
      	end
      	return correct,no_reply
    end

    def correct_type?(key, string_args)
    	out_msg = "correct"
    	correct = false    	
    	if !valid_key? key	
  			out_msg = "#{@output.client_error} : #{key} is not a valid key."
  		else	  				      		
      		if !args_numeric?(string_args) 			      			
      			out_msg = "#{@output.client_error} : #{cmd_name} parameters must be integers (except key)."	      				      			
      		else	      			   		
	      		numeric_args = string_args.map(&:to_i) # now i know parameters are integers, i convert them
	      		parameters 	 = key , *numeric_args
	      		correct      = true
	      	end
	    end
	    return correct, parameters, out_msg
	end

	def correct_parameters?(cmd_name,parameters)
		storage  = false
		correct       = false 
		no_reply_bool = false
		out_msg       = "correct"

		if @strg_commands_names.include? cmd_name #if its a storage command, check if the amount and type of parameters
			storage  = true
			correct_length,no_reply_bool = correct_length?(cmd_name,parameters)				
			if !correct_length 				
				out_msg = "#{@output.client_error} : #{cmd_name} should have exactly #{required_amount.to_s} parameters."
			else
				if no_reply_bool
					key , *string_args, no_reply = parameters
				else
					key , *string_args = parameters
				end				
				correct, parameters, out_msg = correct_type?(key, string_args)	 				    		
		    end
		else # retrieval commands, just have to check if the keys are valid
			if valid_keys?(parameters)
				correct = true
			else
				out_msg = "#{@output.client_error} : At least one of the keys supplied is not a valid."
			end
		end
		return storage,correct,parameters,out_msg,no_reply_bool
	end

	def parse_input(client, str_params)
	    parameters = str_params.split
	    cmd_name   = parameters.shift #[0]    
	    if !valid_command?(cmd_name)   	
	    	client.write @output.error
	    else	    	
	    	storage, correct_parameters, clean_parameters, out_msg, no_reply = correct_parameters?(cmd_name,parameters)
	    	
	    	if correct_parameters	    		
	    		final_parameters = storage ? request_data(client,cmd_name,clean_parameters) : clean_parameters
				out_msg = @cache.send(cmd_name, *final_parameters)								
			end   
			if !no_reply
				client.write out_msg	
			else
				client.write "no reply"
			end		
		end	    
	end

end