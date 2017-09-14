require_relative 'src/server'

port = 6393
max_size = 1000
msg_max_size = 100
Server.new("localhost",port,max_size,msg_max_size)