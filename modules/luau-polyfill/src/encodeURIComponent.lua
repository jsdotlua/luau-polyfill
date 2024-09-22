-- reference documentation: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/encodeURIComponent
local HttpService = game:GetService("HttpService")

local String = require("@pkg/@jsdotlua/string")
local charCodeAt = String.charCodeAt
local Error = require("./Error")

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

local function encodeURIComponent(value: string): string
	local valueLength = utf8.len(value)
	if valueLength == 0 or valueLength == nil then
		return ""
	end
	-- we don't exhaustively test the whole string for invalid characters like ECMA-262 15.1.3 says
	local check = charCodeAt(value, 1)
	if valueLength == 1 then
		if check == 0xD800 then
			error(Error.new("URI malformed"))
		end
		if check == 0xDFFF then
			error(Error.new("URI malformed"))
		end
	end
	if check >= 0xDC00 and check < 0xDFFF then
		error(Error.new("URI malformed"))
	end
	local encoded = HttpService:UrlEncode(value)
	-- reverting encoded chars which are not encoded by JS
	local result = string.gsub(encoded, "%%[257][1789ADEF]", REPLACEMENTS)

	return result
end

return encodeURIComponent
