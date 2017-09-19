require_relative 'cache'
require_relative 'method_parameters'
require_relative 'constants'
require 'socket'
require 'json'
require 'monitor'

class Server

	def initialize(ip, port, cache_max_size, msg_max_size)
		@cache   	  = Cache.instance  	
		@server  	  = TCPServer.open(ip, port)
		@clients 	  = Hash.new
    @client_id  = 0
		
		@msg_max_size = msg_max_size # max message size allowed
		@cache.set_max_size(cache_max_size) # max number of keys allowed
		
		@params_amounts      = MethodsParameters::PARAMETERS_AMOUNTS	
		@public_commands     = MethodsParameters::PARAMETERS_AMOUNTS.keys	
		@strg_commands_names = MethodsParameters.get_storage_commands	
    @del_commands_names  = MethodsParameters.get_deletion_commands 
		@byte_size_pos       = MethodsParameters::BYTE_SIZE_POS
		run
	end

	def run
    lock = Monitor.new
		loop {
			Thread.start(@server.accept) do |client|				
        @clients[client]  = get_client_id
        client_num        = @clients[client]
        @thread_variables = Thread.current  

        puts "Client##{client_num} is now connected"

        file = init_file(client_num)
        client.write greeting_msg(@clients[client])
				loop do					  
          # variables accessible only from inside the thread
          @thread_variables[:out_msg]    = String.new 
          @thread_variables[:no_reply]   = false  
          @thread_variables[:is_storage] = false  
          @thread_variables[:parameters] = Array.new

					in_msg = client.recv(@msg_max_size).chomp	
          
          lock.synchronize do 
            parse_input(client, in_msg)
            log(file,in_msg,@thread_variables[:out_msg]) # specially for the charge test                  
          end 
				end				
				Thread.kill
			end
		}.join
	end  

  def log(file, in_msg, out_msg)
    file.puts("Client :#{in_msg}\nServer: #{out_msg}")
  end

  def greeting_msg(id)
    "Greetings Client##{id}, you are now connected to RG-CacheServer"
  end
  
  def init_file(client_num)
    file_name = "spec/charge_test_outputs/client#{client_num}.txt"
    File.delete(file_name) if File.exist?(file_name)
    file = File.new(file_name, "a")    
    file.puts("Client##{client_num} is now connected") 
    file 
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

	def request_data(client, cmd_name) # request the data according to the size provided
		client.write "Now send the data you want to store" # then request data block 
		
		byte_size = @thread_variables[:parameters][@byte_size_pos[cmd_name]]	
  	data      = get_data(client, byte_size) 
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
		ret = !cmd_name.nil? && (@public_commands.include? cmd_name)   
	end

  def correct_length?(cmd_name, parameters)
    required_amount = @params_amounts[cmd_name].first
    @thread_variables[:parameters] = parameters

    if (!parameters.empty?) && (parameters.length == required_amount) # check if the amount of parameters is the same as expected and if it includes noreply.      		
      correct = true
      @thread_variables[:no_reply] = false      		
    else
      if (!parameters.empty?) && (parameters.length == required_amount + 1) && (parameters[parameters.length-1] == "noreply") 
        correct = true
        @thread_variables[:no_reply]   = true
        @thread_variables[:parameters].pop # i don't need to hold "noreply" param anymore
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
  			@thread_variables[:out_msg] = "#{Constants::CLIENT_ERROR} : for storage commands parameters must be integers (except key)."	      				      			
  		else	      			   		
    		numeric_args                   = string_args.map(&:to_i) # now i know parameters are integers, i convert them
    		@thread_variables[:parameters] = key, *numeric_args
    		correct                        = true
    	end
    end
    return correct
	end

	def correct_parameters?(cmd_name, parameters)		
		correct = false 	

		if @strg_commands_names.include? cmd_name #if its a storage command, check if the amount and type of parameters      
			@thread_variables[:is_storage]  = true	
			if !correct_length?(cmd_name, parameters)   
				@thread_variables[:out_msg] = "#{Constants::CLIENT_ERROR} : #{cmd_name} should have exactly #{ @params_amounts[cmd_name].first} parameters."
      else  
				key, *string_args = @thread_variables[:parameters]					    
				correct = correct_type?(key, string_args)	 	
		  end
		else
      if @del_commands_names.include? cmd_name       
        if correct_length?(cmd_name, parameters)
          @thread_variables[:parameters] = parameters          
          correct = true
        else
          @thread_variables[:out_msg] = "#{Constants::CLIENT_ERROR} : #{cmd_name} should have exactly #{ @params_amounts[cmd_name].first} parameters."
        end
      else # retrieval commands, just have to check if the supplied keys are valid
  			if valid_keys?(parameters)
          @thread_variables[:parameters] = parameters
  				correct = true
  			else
  				@thread_variables[:out_msg] = "#{Constants::CLIENT_ERROR} : At least one of the keys supplied is not a valid."
  			end
      end
		end    
		return correct
	end

  def parse_input(client, str_params) # check's if the commands given are valid, and in that case, it forwards them to the cache
    parameters = str_params.split
    cmd_name   = parameters.shift # first parameter is the command name 

    if !valid_command?(cmd_name)   	
      client.write Constants::ERROR
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
        client.write Constants::EOL
      end		
    end    
  end

end