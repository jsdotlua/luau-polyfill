-- reference documentation: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/encodeURIComponent
local String = require("@pkg/@jsdotlua/string")
local charCodeAt = String.charCodeAt
local Error = require("./Error")
local encodeUrl = require("./encodeUrl")

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

	return encodeUrl(value)
end

return encodeURIComponent
