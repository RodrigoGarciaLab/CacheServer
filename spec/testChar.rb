require_relative '../src/dataItem'
require_relative '../src/cache'
p "pene"
@cache = Cache.instance
p @cache.respond_to
cmd_name = "set"
if @cache.respond_to? cmd_name
	p "responde"
else
	p "no responde"
end