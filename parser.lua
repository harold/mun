require 'lpeg'
require 're'
require 'support/utils'

grammar = [[
	Program    <- (<Expression> %nl?)+
	Expression <- &. -> pushExpr <Space>? ("[" <Item> (<Space> <Item>)* <Space>? "]" <Space>?) -> popExpr
	Item       <- [a-z0-9+/*-]+ -> pushItem / <Expression>
	Space      <- (%s)+
]]

code = [==[
[+ 5 [- 1 3]]
[* 6 7]
[print [fib 8]]
]==]

parseFuncs = {}
function parseFuncs.pushExpr()
	table.insert( ast, {} )
end

function parseFuncs.pushItem( s )
	table.insert( ast[#ast], s )
end

function parseFuncs.popExpr( )
	local node = table.remove( ast )
	if ast[1] then
		table.insert( ast[#ast], node )
	else
		table.insert( ast.program, node )
	end
end

ast = {
	program = {}
}

print( code ) 
print( re.compile( grammar, parseFuncs ):match( code ) )
table.dump( ast.program )
