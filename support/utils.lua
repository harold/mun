function table.dump( t, accessPath, tablePath )
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

function table.equal( t1, t2 )
	-- Easy out
	if t1 == t2 then
		return true
	end
	
	-- Ensure all keys in t1 match in t2
	for k,t1v in pairs( t1 ) do
		if type(t1v)=='table' then
			local t2v = t2[k]
			if not t2v or type(t2v)~='table' then
				return false
			elseif t2v ~= t1v then
				return table.equal( t1v, t2v )
			end
		else
			if t2[k] ~= t1v then
				return false
			end
		end
	end
	
	-- Ensure t2 doesn't have keys that aren't in t1
	for k,_ in pairs(t2) do
		if t1[k] == nil then
			return false
		end
	end
	
	return true
end