require 'lpeg'
require 're'
require 'support/utils'

if not arg then arg = {} end
if not arg.debugLevel then arg.debugLevel = 0 end

module( 'parser', package.seeall )

grammar = [[
	Program            <- (<Expression> %nl?)+

	Expression         <- &. -> pushExpr <Space>? (<QuotedExpression> / <UnquotedExpression>)
	QuotedExpression   <- ("'[" <Item> (<Space> <Item>)* <Space>? "]" <Space>?) -> popQuotedExpr
	UnquotedExpression <- ( "[" <Item> (<Space> <Item>)* <Space>? "]" <Space>?) -> popUnquotedExpr

	Item               <- <QuotedItem> / <UnquotedItem>
	QuotedItem         <- "'" <Symbol> -> pushQuotedItem   / <Expression>
	UnquotedItem       <-     <Symbol> -> pushUnquotedItem / <Expression>
	Symbol             <- [a-z0-9+/*-]+

	Space              <- (%s)+
]]

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

function parseFile( file )
	return parse( io.input(file):read("*a") )
end

function parse( code )
	local ast = parseToAST( code )
	return codeFromAST( ast )
end

function parseToAST( code )
	-- intentionally global; reset on each call
	ast = { program = {} }
	local matchLength = re.compile( grammar, parseFuncs ):match( code )
	if not matchLength or (matchLength < #code) then
		if arg.debugLevel > 0 then
			table.dump( ast )
		end
		error( "Failed to parse code! (Got to around char "..tostring(matchLength).." / "..(#code)..")" )
	end
	return ast.program
end

function codeFromAST( ast )
	error( "TODO: implement codeFromAST" )
end