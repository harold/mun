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