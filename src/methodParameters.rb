require 'singleton'
require 'ostruct'

class MethodsParameters
  include Singleton 

  def initialize()
    @cmd_type = OpenStruct.new
    @cmd_type.storage   = "storage"
    @cmd_type.retrieval = "retrieval"
    @cmd_type.deletion  = "deletion"

    @parameters_amounts = Hash.new
    @parameters_amounts["set"]     = [4,@cmd_type.storage]
    @parameters_amounts["add"]     = [4,@cmd_type.storage]
    @parameters_amounts["replace"] = [4,@cmd_type.storage]
    @parameters_amounts["append"]  = [2,@cmd_type.storage]
    @parameters_amounts["prepend"] = [2,@cmd_type.storage]
    @parameters_amounts["cas"]     = [5,@cmd_type.storage]
    @parameters_amounts["delete"]  = [1,@cmd_type.deletion]
    @parameters_amounts["get"]     = [2,@cmd_type.retrieval]
    @parameters_amounts["gets"]    = [2,@cmd_type.retrieval]
    @parameters_amounts["printData"]    = [2,@cmd_type.deletion]

    @byte_size_pos = Hash.new
    @byte_size_pos["set"]     = 2
    @byte_size_pos["add"]     = 2
    @byte_size_pos["replace"] = 2
    @byte_size_pos["append"]  = 0
    @byte_size_pos["prepend"] = 0
    @byte_size_pos["cas"]     = 3
  end

  def getParametersAmounts
    @parameters_amounts
  end

  def getByteSizePos
    @byte_size_pos
  end

  def getStorageCommands
    stg_commands = Array.new
    @parameters_amounts.each do | key, info |      
      if info[1] == @cmd_type.storage
        stg_commands.push(key)
      end
    end
    stg_commands
  end
end