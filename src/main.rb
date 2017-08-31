require_relative 'server'
port = 2626
max_size = 1000
Server.new("localhost",port,max_size)