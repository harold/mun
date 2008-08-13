require 'support/runtime'

--runtime.set( 'dolua', ...createExpressionHere... )

function defineFunction( inContext, inName, inFormName, inFunction )
	runtime.set( inContext, inName, inFunction )
	runtime.gForms[ inFunction ] = runtime.gForms[ inFormName ] 
end

defineFunction( runtime.GLOBAL, '*', 'globalWithValues', function( inContext, inValueList )
	return inValueList.head * inValueList.tail.head
end )

defineFunction( runtime.GLOBAL, 'print', 'globalWithValues', function( inContext, inValueList )
	local theValuePair = inValueList
	while theValuePair do
		local theValue = theValuePair.head
		print( "PRINT SEZ: " .. tostring(theValue) )
		theValuePair = theValuePair.tail
	end
end )

defineFunction( runtime.GLOBAL, 'define', 'globalWithValues', function( inContext, inValueList )
	runtime.set( inContext, inValueList.head.symbol, inValueList.tail )
end )

-- defineFunction( runtime.GLOBAL, 'lambda', 'procedure', function( inContext, inValueList )
-- 	return runtime.list(
-- 		runtime.createValue( 'symbol', 'procedure' ),
-- 		inValueList.head, -- argList
-- 		inValueList.tail, -- bodyExpression(s)
-- 		inContext         -- for lexical scoping
-- 	)
-- end )
