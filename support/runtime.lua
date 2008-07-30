module( 'runtime', package.seeall )

function join( inHeadValue, inTailValue )
	return { head=inHeadValue, tail=inTailValue }
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
	return inContext
end

function isPair( inValue )
	return type(inValue)=='table' and inValue.head
end

function evalExpressions( inCallingContext, inList )
	eval( inCallingContext, inList.head )
	if inList.tail then
		evalExpressions( inCallingContext, inList.tail )
	end
end

-- [print "foo"]
function eval( inCallingContext, inValue )
	local theResult

	if type(inValue)=='string' then
		theResult = inValue
	
	elseif type(inValue)=='number' then
		theResult = inValue
		
	elseif type(inValue)=='table' then
		local theProcedure = inValue.head
		if type(theProcedure) == 'table' and theProcedure.symbol then
			theProcedure = inCallingContext[ theProcedure.symbol ]
		end		

		if type( theProcedure )	== 'function' then
			-- TODO: special form
			local theContext  = createContext( inCallingContext )
			-- local theValues   = join( eval( ) )
			-- local theArgPair  = inValue.tail
			-- local theArgValue = theArgPair.head
			-- while theArgPair do
			-- 	theValues
			-- end
			theResult = theProcedure( theContext, inValue.tail )
		elseif isPair( inValue ) then
			error( "Not yet implemented: evaluating sub-lists" )
		else
			-- bork
			error( "Can't evaluate expression because the first value isn't a procedure or symbol that references a procedure.")
		end
	
	else
		error( 'WTF value is this?' )
			
	end
	
	return theResult
end

GLOBAL = createContext( )

