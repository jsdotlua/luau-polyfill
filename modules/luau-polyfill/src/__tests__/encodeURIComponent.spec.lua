local JestGlobals = require("@pkg/@jsdotlua/jest-globals")
local jestExpect = JestGlobals.expect
local it = JestGlobals.it
local describe = JestGlobals.describe

local encodeURIComponent = require("../encodeURIComponent")

describe("encodeURIComponent", function()
	it("encodes characters like MDN example #1", function()
		jestExpect(encodeURIComponent("test?")).toEqual("test%3F")
	end)

	it("encodes characters like MDN example #2", function()
		jestExpect(encodeURIComponent("шеллы")).toEqual("%D1%88%D0%B5%D0%BB%D0%BB%D1%8B")
	end)

	it("encodes characters like MDN example #3", function()
		local set1 = ";,/?:@&=+$" -- Reserved Characters
		local set2 = "-_.!~*'()" -- Unescaped Characters
		local set3 = "#" -- Number Sign
		local set4 = "ABC abc 123" -- Alphanumeric Characters + Space
		local set5 = "#$&+,/:;=?@" -- Custom set

		jestExpect(encodeURIComponent(set1)).toEqual("%3B%2C%2F%3F%3A%40%26%3D%2B%24")
		jestExpect(encodeURIComponent(set2)).toEqual("-_.!~*'()")
		jestExpect(encodeURIComponent(set3)).toEqual("%23")
		jestExpect(encodeURIComponent(set4)).toEqual("ABC%20abc%20123") -- the space gets encoded as %20
		jestExpect(encodeURIComponent(set5)).toEqual("%23%24%26%2B%2C%2F%3A%3B%3D%3F%40")
	end)

	-- TODO: uncomment this test once darklua is fixed to support invalid characters
	-- it("throws like MDN example for URIError", function()
	-- 	-- high-low pair OK
	-- 	jestExpect(function()
	-- 		encodeURIComponent("\u{D800}\u{DFFF}")
	-- 	end).never.toThrow()
	-- 	-- lone high throws
	-- 	jestExpect(function()
	-- 		encodeURIComponent("\u{DFFF}")
	-- 	end).toThrow("URI malformed")
	-- 	-- lone low throws
	-- 	jestExpect(function()
	-- 		encodeURIComponent("\u{D800}")
	-- 	end).toThrow("URI malformed")
	-- 	-- character in invalid range
	-- 	jestExpect(function()
	-- 		encodeURIComponent("\u{DFFE}")
	-- 	end).toThrow("URI malformed")
	-- end)
end)
