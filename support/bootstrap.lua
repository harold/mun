require 'support/runtime'

--runtime.set( 'dolua', ...createExpressionHere... )

function defineFunction( inContext, inName, inFormName, inFunction )
	runtime.set( inContext, inName, inFunction )
	runtime.gForms[ inFunction ] = runtime.gForms[ inFormName ] 
end

defineFunction( runtime.GLOBAL, '*', 'globalWithValues', function( inContext, inValueList )
	return inValueList.head * inValueList.tail.head
end )

defineFunction( runtime.GLOBAL, '+', 'globalWithValues', function( inContext, inValueList )
	return inValueList.head + inValueList.tail.head
end )

defineFunction( runtime.GLOBAL, 'head', 'globalWithValues', function( inContext, inValueList )
	return inValueList.head.head
end )

defineFunction( runtime.GLOBAL, 'tail', 'globalWithValues', function( inContext, inValueList )
	return inValueList.head.tail.head
end )

defineFunction( runtime.GLOBAL, 'join', 'globalWithValues', function( inContext, inValueList )
	return runtime.join( inValueList.head, inValueList.tail )
end )

defineFunction( runtime.GLOBAL, 'print', 'globalWithValues', function( inContext, inValueList )
	local theValuePair = inValueList
	while theValuePair do
		local theValue = theValuePair.head
		print( "PRINT SEZ: " .. tostring(theValue) )
		theValuePair = theValuePair.tail
	end
end )
