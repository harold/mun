require 'lpeg'
require 're'
require 'support/utils'

grammar = [[
	Program            <- (<Expression> %nl?)+

	Expression         <- &. -> pushExpr <Space>? (<QuotedExpression> / <UnquotedExpression>)
	QuotedExpression   <- ("'[" <Item> (<Space> <Item>)* <Space>? "]" <Space>?) -> popQuotedExpr
	UnquotedExpression <- ( "[" <Item> (<Space> <Item>)* <Space>? "]" <Space>?) -> popUnquotedExpr

	Item               <- <QuotedItem> / <UnquotedItem>
	QuotedItem         <- "'" <ItemRegex> -> pushQuotedItem   / <Expression>
	UnquotedItem       <-     <ItemRegex> -> pushUnquotedItem / <Expression>
	ItemRegex          <- [a-z0-9+/*-]+

	Space              <- (%s)+
]]

code = [==[
[+ 5 [- 1 3]]
[* 6 7]
[print [fib 8]]
[q '[a b c]]
]==]

parseFuncs = {}
function parseFuncs.pushExpr()
	table.insert( ast, {} )
end

function parseFuncs.addItem( inQuoted, inS )
	local theItem = {}
	theItem.quoted = inQuoted
	theItem.value = inS
	table.insert( ast[#ast], theItem )
end

function parseFuncs.pushQuotedItem( s )
	parseFuncs.addItem( true, s )
end

function parseFuncs.pushUnquotedItem( s )
	parseFuncs.addItem( false, s )
end

function parseFuncs.addExpr( inQuoted )
	local node = table.remove( ast )
	node.quoted = inQuoted
	if ast[1] then
		table.insert( ast[#ast], node )
	else
		table.insert( ast.program, node )
	end
end

function parseFuncs.popQuotedExpr( )
	parseFuncs.addExpr( true )
end

function parseFuncs.popUnquotedExpr( )
	parseFuncs.addExpr( false )
end

ast = {
	program = {}
}

print( code ) 
print( re.compile( grammar, parseFuncs ):match( code ) )
table.dump( ast.program )
