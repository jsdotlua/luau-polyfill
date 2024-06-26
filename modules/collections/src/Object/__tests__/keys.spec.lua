local keys = require("../keys")

local Set = require("../../Set")
local JestGlobals = require("@pkg/@jsdotlua/jest-globals")
local jestExpect = JestGlobals.expect
local it = JestGlobals.it

it("returns an empty array for an empty table", function()
	jestExpect(#keys({})).toEqual(0)
end)

it("returns an empty array for Sets", function()
	jestExpect(keys(Set.new({ 1, 2, 3 }))).toEqual({})
end)

it("returns an array with the table keys", function()
	local t = { foo = true, bar = false }
	local result = keys(t)
	jestExpect(#result).toEqual(2)
	table.sort(result)
	jestExpect(result).toEqual({ "bar", "foo" })
end)

it("returns an array of indices when given a string", function()
	local s = "Roblox"
	local result = keys(s)
	jestExpect(#result).toEqual(string.len(s))
	jestExpect(result).toEqual({ "1", "2", "3", "4", "5", "6" })
end)

-- Luau types don't allow this to happen, figure out how to enable this test with type stripped
it.skip("returns an empty array given a number", function()
	-- jestExpect(keys(1)).toEqual({})
end)

-- Luau types don't allow this to happen, figure out how to enable this test with type stripped
it.skip("returns an empty array given boolean", function()
	-- jestExpect(keys(true)).toEqual({})
	-- jestExpect(keys(false)).toEqual({})
end)

-- Luau types don't allow this to happen, figure out how to enable this test with type stripped
it.skip("throws when given nil", function()
	jestExpect(function()
		-- keys(nil)
	end).toThrow("cannot extract keys from a nil value")
end)

-- deviation: JS has this behavior, which we don't specifically need now.
-- To not risk making the function significantly slower, this behavior is
-- not implemented
it.skip("returns an array of stringified index given an array", function()
	jestExpect(keys({ true, false, true })).toEqual({ "1", "2", "3" })
end)
