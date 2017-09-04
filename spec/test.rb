require_relative '../src/methodParameters'
require_relative '../src/cache'

params  = MethodsParameters.instance
params_amounts =  params.getParametersAmounts		

public_commands = params_amounts.keys	
p public_commands
strgCommandsNames = params.getStorageCommands	
p params_amounts["set"].first