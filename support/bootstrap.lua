require 'support/runtime'

--runtime.set( 'dolua', ...createExpressionHere... )

runtime.set( runtime.GLOBAL, 'print', function( inContext, inValueList )
	local theValuePair = inValueList
	while theValuePair do
		local theValue = theValuePair.head
		print( theValue )
		theValuePair = theValuePair.tail
	end
end )
