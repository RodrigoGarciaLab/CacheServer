require 'ostruct'

module MethodsParameters

  CMD_TYPE = OpenStruct.new
  CMD_TYPE.storage   = "storage"
  CMD_TYPE.retrieval = "retrieval"
  CMD_TYPE.deletion  = "deletion"

  PARAMETERS_AMOUNTS = Hash.new
  PARAMETERS_AMOUNTS["set"]     = [4, CMD_TYPE.storage]
  PARAMETERS_AMOUNTS["add"]     = [4, CMD_TYPE.storage]
  PARAMETERS_AMOUNTS["replace"] = [4, CMD_TYPE.storage]
  PARAMETERS_AMOUNTS["append"]  = [2, CMD_TYPE.storage]
  PARAMETERS_AMOUNTS["prepend"] = [2, CMD_TYPE.storage]
  PARAMETERS_AMOUNTS["cas"]     = [5, CMD_TYPE.storage]
  PARAMETERS_AMOUNTS["delete"]  = [1, CMD_TYPE.deletion]
  PARAMETERS_AMOUNTS["get"]     = [2, CMD_TYPE.retrieval]
  PARAMETERS_AMOUNTS["gets"]    = [2, CMD_TYPE.retrieval]

  BYTE_SIZE_POS = Hash.new
  BYTE_SIZE_POS["set"]     = 3
  BYTE_SIZE_POS["add"]     = 3
  BYTE_SIZE_POS["replace"] = 3
  BYTE_SIZE_POS["append"]  = 1
  BYTE_SIZE_POS["prepend"] = 1
  BYTE_SIZE_POS["cas"]     = 3
  
  def MethodsParameters.get_storage_commands
    stg_commands = Array.new
    PARAMETERS_AMOUNTS.each do | key, info |      
      if info[1] == CMD_TYPE.storage
        stg_commands.push(key)
      end
    end
    stg_commands
  end

  def MethodsParameters.get_deletion_commands
    del_commands = Array.new
    PARAMETERS_AMOUNTS.each do | key, info |      
      if info[1] == CMD_TYPE.deletion
        del_commands.push(key)
      end
    end
    del_commands
  end
  
end