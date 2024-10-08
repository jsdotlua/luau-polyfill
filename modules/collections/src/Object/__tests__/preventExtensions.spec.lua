local preventExtensions = require("../preventExtensions")

local JestGlobals = require("@pkg/@jsdotlua/jest-globals")
local jestExpect = JestGlobals.expect
local it = JestGlobals.it

it("should return the same table", function()
	local base = {
		a = 1,
	}
	local modified = preventExtensions(base)

	jestExpect(modified).toEqual(base)
end)

it("should allow access to any keys that were defined before it's called", function()
	local t = preventExtensions({
		a = 1,
	})

	jestExpect(t.a).toEqual(1)
end)

it("should allow mutation of existing values", function()
	local t = preventExtensions({
		a = 1,
	})

	t.a = 2
	jestExpect(t.a).toEqual(2)
end)

it("should preserve iteration functionality", function()
	local t = preventExtensions({
		a = 1,
		b = 2,
	})

	-- selene: allow(manual_table_clone)
	local tPairsCopy = {}
	for k, v in pairs(t) do
		tPairsCopy[k] = v
	end

	jestExpect(tPairsCopy).toEqual(t)

	local a = preventExtensions({ "hello", "world" })

	-- selene: allow(manual_table_clone)
	local aIpairsCopy = {}
	for i, v in ipairs(a) do
		aIpairsCopy[i] = v
	end

	jestExpect(aIpairsCopy).toEqual(a)
end)

it("should error when setting a nonexistent key", function()
	local t = preventExtensions({
		a = 1,
		b = 2,
	})

	jestExpect(function()
		t.c = 3
	end).toThrow()
end)
