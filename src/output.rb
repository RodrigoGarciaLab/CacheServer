require 'singleton'

class Output
      include Singleton 

      attr_accessor :stored, :not_stored,:exists,:not_found
      attr_accessor :end, :value,:eol,:error,:client_error,:server_error

      def initialize()
            @stored       = "STORED\r\n"
            @not_stored    = "NOT_STORED\r\n"
            @exists  	  = "EXISTS\r\n"
            @not_found     = "NOT_FOUND\r\n"
            @end		  = "END\r\n"
            @value	  = "VALUE"
            @error        = "ERROR\r\n"
            @client_error = "CLIENT ERROR"
            @server_error = "SERVER ERROR\r\n"
            @eol		  = "\r\n"
      end	
end