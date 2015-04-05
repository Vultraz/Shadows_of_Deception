
if lp8 ~= nil then
	if type(lp8) ~= 'table' or lp8 ~= namespace_of_8680s_Lua_Pack then
		local function dbgstr(x)
			return ('%s(%s)'):format(type(x), tostring(x))
		end
		error(("lp8 is %s; namespace_of_8680s_Lua_Pack is %s"):
			format(dbgstr(lp8),
				dbgstr(namespace_of_8680s_Lua_Pack)))
	end

	for _, module in ipairs {
		'wml';
		'modifications';
		'table';
	} do
		lp8.require(module)
	end
end
