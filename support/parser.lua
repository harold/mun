require 'lpeg'
require 're'
require 'support/utils'
require 'support/runtime'

if not arg then arg = {} end
if not arg.debugLevel then arg.debugLevel = 0 end

module( 'parser', package.seeall )

gGrammar = [[
	Program            <- (<Expression> %nl?)+
	Expression         <- &. -> pushExpr <Space>? (<QuotedExpression> / <UnquotedExpression>)
	QuotedExpression   <- ("'[" <Space>? <Item>? (<Space> <Item>)* <Space>? "]") -> popQuotedExpr
	UnquotedExpression <- ( "[" <Space>? <Item>? (<Space> <Item>)* <Space>? "]") -> popUnquotedExpr
	
	Item           <- (<QuotedSymbol> / <UnquotedSymbol> / <Number> / <String>) / <Expression>
	QuotedSymbol   <- "'" ([a-zA-Z+*\-] [a-zA-Z_+*\-]*) -> pushQuotedSymbol
	UnquotedSymbol <-     ([a-zA-Z+*\-] [a-zA-Z_+*\-]*) -> pushUnquotedSymbol
	Number         <- ( ( [+-]? [0-9] [0-9_]* ('.' [0-9] [0-9_]*)? ) / ( [+-]? '.' [0-9] [0-9_]* ) ) -> pushNumber
	String         <- ( '"' ([^"]* -> pushString) '"' )
	
	Space <- (%s)+
]]

gParseFuncs = {}
function gParseFuncs.pushExpr()
	table.insert( gAST, {} )
end

function gParseFuncs.addExpr( inQuotedFlag )
	local theNode = table.remove( gAST )
	theNode.type = "expression"
	if inQuotedFlag then theNode.quotedFlag = true end
	if gAST[1] then
		table.insert( gAST[#gAST], theNode )
	else
		table.insert( gAST.program, theNode )
	end
end

function gParseFuncs.popQuotedExpr( )
	gParseFuncs.addExpr( true )
end

function gParseFuncs.popUnquotedExpr( )
	gParseFuncs.addExpr( false )
end

function gParseFuncs.addItem( inQuotedFlag, inType, inValue )
	local theItem = {}
	if inQuotedFlag then theItem.quotedFlag = true end
	theItem.type  = inType
	theItem.value = inValue
	table.insert( gAST[#gAST], theItem )
end

function gParseFuncs.pushQuotedSymbol( s )
	gParseFuncs.addItem( true, "symbol", s )
end

function gParseFuncs.pushUnquotedSymbol( s )
	gParseFuncs.addItem( false, "symbol", s )
end

function gParseFuncs.pushNumber( s )
	gParseFuncs.addItem( false, "number", tonumber(s) )
end

function gParseFuncs.pushString( s )
	gParseFuncs.addItem( false, "string", s )
end

function parseFile( inFilePath )
	return parse( io.input(file):read("*a") )
end

function parse( inCodeString )
	local theASTRoot = parseToAST( inCodeString )
	return codeFromAST( theASTRoot.program )
end

function parseToAST( inCodeString )
	gAST = { program = { type="program" } }
	local theMatchLength = re.compile( gGrammar, gParseFuncs ):match( inCodeString )
	if not theMatchLength or (theMatchLength < #inCodeString) then
		if arg.debugLevel > 0 then
			table.dump( gAST )
		end
		error( "Failed to parse code! (Got to around char "..tostring(theMatchLength).." / "..(#inCodeString)..")" )
	end
	return gAST.program
end

function codeFromAST( inASTNode )
	local theResult
	if inASTNode.type == "program" then
		theResult = runtime.createList( )
		for i,theChildNode in ipairs( inASTNode ) do
			runtime.appendListItem( theResult, codeFromAST( theChildNode ) )
		end

	elseif inASTNode.type == "expression" then
		theResult = runtime.createList{ quotedFlag = inASTNode.quotedFlag }
		for i,theChildNode in ipairs( inASTNode ) do
			runtime.appendListItem( theResult, codeFromAST( theChildNode ) )
		end

	else -- symbol, number, string
		theResult = runtime[ inASTNode.type ][ inASTNode.value ]

	end
	
	return theResult
end