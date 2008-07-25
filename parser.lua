require 'lpeg'
require 're'
require 'support/utils'

grammar = [[
	Program    <- (<Expression> %nl?)+
	Expression <- &. -> startExpr <Space>? ("[" <Operator> (<Space> <Argument>)* <Space>? "]" <Space>?) -> closeExpr
	Operator   <- [+*/-] -> pushOperator
	Argument   <- <Number> -> pushNumber / <Expression>
	Number     <- ( ( [+-]? [0-9] [0-9_]* ('.' [0-9] [0-9_]*)? ) / ( [+-]? '.' [0-9] [0-9_]* ) )
	Space      <- (%s)+
]]

code = [==[
[+ 5 [- 1 3]]
[* 6 7]
]==]

parseFuncs = {}
function parseFuncs.startExpr()
	table.insert( ast, {} )
end

function parseFuncs.pushOperator( s )
	ast[#ast].operator = s
end

function parseFuncs.pushNumber( s )
	table.insert( ast[#ast], tonumber(s) )
end

function parseFuncs.closeExpr( )
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

goodast = 
{
	[1] = {
		operator = "+",
		[1] = 5,
		[2] = {
			operator = "-",
			[1] = 1,
			[2] = 3,
		}
	},
	[2] = {
		operator = "*",
		[1] = 6,
		[2] = 7
	}
}
