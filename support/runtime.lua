module( 'runtime', package.seeall )

function join( inHeadValue, inTailValue )
	return { head=inHeadValue, tail=inTailValue }
end

function list( ... )
	local theHead
	for i=select('#',...),1,-1 do
		theHead = join( select(i,...), theHead )
	end
	return theHead
end

function createValue( inType, inValue, inQuotedFlag )
	local theResult
	if inType == 'symbol' then
		theResult = { symbol=inValue, quotedFlag=inQuotedFlag }
	else
		error( "Unrecognized value type '"..inType.."'" )
	end
	return theResult
end

ContextMeta = {
	-- Use a function for inheritance to allow the superior to be changed
	__index = function( self, inKey )
		return rawget(self,'superior') and self.superior[ inKey ]
	end
}

function createContext( inSuperiorContext )
	local theContext = {
		superior = inSuperiorContext
	}
	setmetatable( theContext, ContextMeta )
	return theContext
end

function set( inContext, inName, inValue )
	inContext[ inName ] = inValue
	return inValue
end

function get( inContext, inName )
	return inContext[ inName ]
end



function evalExpressions( inCallingContext, inList )
	eval( inCallingContext, inList.head, "evalExpressions" )
	if inList.tail then
		return evalExpressions( inCallingContext, inList.tail )
	end
end

gForms = {}

function gForms.globalWithValues( inList )
	local theContext = createContext( GLOBAL )
end

function isSimpleValue( inValue )
	return type(inValue)=='string' or type(inValue)=='number'
end

function isSymbol( inValue )
	return type(inValue)=='table' and inValue.symbol
end

function isPair( inValue )
	return type(inValue)=='table' and inValue.head
end

function isFunction( inValue )
	return type(inValue)=='function'
end

function isQuoted( inValue )
	return type(inValue)=='table' and inValue.quotedFlag
end

function isDefinition( inValue )
	return type(inValue)=='table' and inValue.head.symbol == "define"
end

function isLambda( inValue )
	return type(inValue)=='table' and inValue.head and inValue.head.symbol=="lambda"
end

function listOfValues( inContext, inList )
	return inList and join( eval( inContext, inList.head, "listOfValues" ), listOfValues( inContext, inList.tail ) )
end

function eval( inContext, inValue, inWhere )
	-- print( string.rep( '=',40))
	-- table.dump( type(inValue) == 'table' and inValue.head or inValue )

	local theResult
	if isSimpleValue( inValue ) then
		theResult = inValue
	elseif isSymbol( inValue ) then
		theResult = get( inContext, inValue.symbol )
	elseif isQuoted( inValue ) then
		theResult = inValue
	elseif isDefinition( inValue ) then
		theResult = makeDefinition( inContext, inValue )
	elseif isLambda( inValue ) then
		-- TODO: shouldn't this be a special form?
		theResult = makeProcedure( inContext, inValue.tail, inValue.tail.tail )
	elseif isPair( inValue ) then
		-- TODO: lookup forms
		local theRunnable = eval( inContext, inValue.head, "eval!" )
		if not theRunnable then
			print( "Failed to find runnable/procedure:" )
			table.dump( inValue.head )
			error( "Bailing..." )
		end
		local theArgList = listOfValues( inContext, inValue.tail )
		theResult = apply( theRunnable, theArgList )
	else
		error( "Unknown value type passed to eval ("..tostring(inValue)..")")
	end
	
	return theResult
end

function apply( inRunnable, inArgList )
	-- local theForm = gForms[ theProcedure ] or gForms.globalWithValues
	-- local theContext = theForm( inValue )
		
	if isFunction( inRunnable ) then
		return inRunnable( theContext, inArgList )
	elseif isPair( inRunnable ) then
		local theContext = createContext( inRunnable.tail.tail.tail.head )
		augmentContext( theContext, inRunnable.tail.head.head, inArgList )
		return eval( theContext, inRunnable.tail.head.tail, "apply!" )
	else
		print( "WARNING (This used to be an error?): WTF KIND OF RUNNABLE IS THIS? ("..tostring(inRunnable)..")" )
		return inRunnable
	end
end

function makeProcedure( inContext, inParameters, inBodyExpressions )
	return list( createValue( 'symbol', 'procedure' ), inParameters, inBodyExpressions, inContext )
end

function makeDefinition( inContext, inList )
	runtime.set( inContext, inList.tail.head.symbol, eval( inContext, inList.tail.tail.head, "makeDefinition" ) )
end

function augmentContext( inContext, inArgNameList, inArgValueList )
	inContext[ inArgNameList.head.symbol ] = inArgValueList.head
	if inArgNameList.tail then
		augmentContext( inContext, inArgNameList.tail, inArgValueList.tail )
	end
end

GLOBAL = createContext( )

