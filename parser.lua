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

function parseFuncs.pushUnquotedItem( s )
	local theItem = {}
	theItem.quoted = false
	theItem.value = s
	table.insert( ast[#ast], theItem )
end

function parseFuncs.pushQuotedItem( s )
	local theItem = {}
	theItem.quoted = true
	theItem.value = s
	table.insert( ast[#ast], theItem )
end

function parseFuncs.popQuotedExpr( )
	local node = table.remove( ast )
	node.quoted = true
	if ast[1] then
		table.insert( ast[#ast], node )
	else
		table.insert( ast.program, node )
	end
end

function parseFuncs.popUnquotedExpr( )
	local node = table.remove( ast )
	node.quoted = false
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
