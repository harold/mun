function table.dump( t, accessPath, tablePath )
	if type(t) ~= 'table' then
		return print(t)
	end

	if not tablePath  then tablePath  = {} end
	if not accessPath then
		accessPath = { '__table__' }
	elseif type(accessPath)=='string' then
		accessPath = { accessPath }
	end
	
	local tableAccess = ""
	for i,pathItem in ipairs(accessPath) do
		if type(pathItem) == 'string' then
			if i>1 then tableAccess = tableAccess .. "." end
			tableAccess = tableAccess .. pathItem
		else
			tableAccess = tableAccess .. "[" .. tostring(pathItem) .. "]"
		end		
	end
	tablePath[ t ] = tableAccess --.. " -- " .. tostring(t)
	
	local indent = ("  "):rep( #accessPath - 1 )
	if #accessPath == 1 then
		io.write( accessPath[1].." = " )
	end

	print( "{ --" ..tostring(t) )
	
	local allKeysInPrettyOrder = {}
	for k,v in pairs(t) do
		if type(k) == 'string' then
			table.insert( allKeysInPrettyOrder, k )
		end
	end
	table.sort( allKeysInPrettyOrder )
	
	for k,v in pairs(t) do
		if type(k) ~= 'string' and type(k) ~= 'number' then
			table.insert( allKeysInPrettyOrder, k )
		end
	end
	
	local tmpKeysInPrettyOrder = {}
	for k,v in pairs(t) do
		if type(k) == 'number' then
			table.insert( tmpKeysInPrettyOrder, k )
		end
	end
	table.sort( tmpKeysInPrettyOrder )
	for i,v in ipairs(tmpKeysInPrettyOrder) do
		table.insert( allKeysInPrettyOrder, v )
	end

	local k,v,kType,vType
	for i,k in ipairs(allKeysInPrettyOrder) do
		v = t[k]
		kType = type(k)
		vType = type(v)
		accessPath[ #accessPath+1 ] = k

		io.write( indent .. "  " )
		if kType == "string" then
			io.write(k)
		else
			io.write("["..tostring(k).."]")
		end
		io.write( " = " )
		
		if vType=="string" then
			io.write( string.format( '%q', v ) )
		elseif vType=="table" then
			if tablePath[ v ] then
				io.write( tablePath[ v ] )
			else
				table.dump( v, accessPath, tablePath )
			end
		else
			io.write( tostring(v) )
		end

		if i < #allKeysInPrettyOrder then
			print( "," )
		else
			print( "" )
		end

		table.remove( accessPath )
	end
	io.write( indent .. "}" )
	if #accessPath == 1 then
		print("")
	end
end