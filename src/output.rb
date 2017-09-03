require 'singleton'

class Output

	include Singleton 

	attr_accessor :stored, :notStored,:exists,:notFound
	attr_accessor :end, :value,:eol

	def initialize()
      @stored       = "STORED\r\n"
      @notStored    = "NOT_STORED\r\n"
      @exists  	  = "EXISTS\r\n"
      @notFound     = "NOT_FOUND\r\n"
      @end		     = "END\r\n"
      @value	     = "VALUE"
      @error        = "ERROR\r\n"
      @client_error = "CLIENT ERROR\r\n"
      @server_error = "SERVER ERROR\r\n"
      @eol		     = "\r\n"
   end	
end