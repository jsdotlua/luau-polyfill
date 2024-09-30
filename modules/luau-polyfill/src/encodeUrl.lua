if _G.LUA_ENV == "roblox" then
	local HttpService = game:GetService("HttpService")

	local REPLACEMENTS = {
		["%2D"] = "-",
		["%5F"] = "_",
		["%2E"] = ".",
		["%21"] = "!",
		["%7E"] = "~",
		["%2A"] = "*",
		["%27"] = "'",
		["%28"] = "(",
		["%29"] = ")",
	}

	local function urlEncode(value: string)
		local encoded = HttpService:UrlEncode(value)
		-- reverting encoded chars which are not encoded by JS
		local result = string.gsub(encoded, "%%[257][1789ADEF]", REPLACEMENTS)
		return result
	end

	return urlEncode
end

local function encodeCharacter(c)
	return string.format("%%%02X", string.byte(c))
end

local function urlEncode(value: string)
	local result = string.gsub(value, "([^%w%-_%.!~%*'%(%)])", encodeCharacter)
	return result
end

return urlEncode
