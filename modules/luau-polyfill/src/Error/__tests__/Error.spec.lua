--[[
	* Copyright (c) Roblox Corporation. All rights reserved.
	* Licensed under the MIT License (the "License");
	* you may not use this file except in compliance with the License.
	* You may obtain a copy of the License at
	*
	*     https://opensource.org/licenses/MIT
	*
	* Unless required by applicable law or agreed to in writing, software
	* distributed under the License is distributed on an "AS IS" BASIS,
	* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	* See the License for the specific language governing permissions and
	* limitations under the License.
]]
return function()
	local ErrorModule = script.Parent.Parent
	local Error = require(ErrorModule)
	type Error = Error.Error
	local LuauPolyfill = ErrorModule.Parent
	local Packages = LuauPolyfill.Parent
	local RegExp = require(Packages.Dev.RegExp)
	local extends = require(LuauPolyfill).extends
	local instanceof = require(LuauPolyfill).instanceof

	local JestGlobals = require(Packages.Dev.JestGlobals)
	local jestExpect = JestGlobals.expect

	local MyError = extends(Error, "MyError", function(self, message)
		self.message = message
		self.name = "MyError"
	end)

	local YourError = extends(MyError, "YourError", function(self, message)
		self.message = message
		self.name = "YourError"
	end)

	it("accepts a message value as an argument", function()
		local err = Error("Some message")

		jestExpect(err.message).toEqual("Some message")
	end)

	it("defaults the `name` field to 'Error'", function()
		local err = Error("")

		jestExpect(err.name).toEqual("Error")
	end)

	it("gets passed through the `error` builtin properly", function()
		local err = Error("Throwing an error")
		local ok, result = pcall(function()
			error(err)
		end)

		jestExpect(ok).toEqual(false)
		jestExpect(result).toEqual(err)
	end)

	it("checks that Error is a class according to our inheritance standard", function()
		local err = Error("Test")
		jestExpect(instanceof(err, Error)).toEqual(true)
	end)

	it("checks the inheritance of Error", function()
		local inst: Error = MyError("my error message")

		jestExpect(inst.message).toEqual("my error message")
		jestExpect(inst.name).toEqual("MyError")

		-- inheritance checks
		jestExpect(instanceof(inst, MyError)).toEqual(true)
		jestExpect(instanceof(inst, Error)).toEqual(true)
	end)

	it("checks the inheritance of a sub error", function()
		local inst: Error = YourError("your error message")

		jestExpect(inst.message).toEqual("your error message")
		jestExpect(inst.name).toEqual("YourError")

		-- inheritance checks
		jestExpect(instanceof(inst, YourError))
		jestExpect(instanceof(inst, MyError)).toEqual(true)
		jestExpect(instanceof(inst, Error)).toEqual(true)
	end)

	it("evaluates both toString methods", function()
		jestExpect(tostring(Error)).toEqual("Error")
		jestExpect(tostring(Error("test"))).toEqual("Error: test")

		jestExpect(tostring(MyError)).toEqual("MyError")
		jestExpect(tostring(MyError("my test"))).toEqual("MyError: my test")

		jestExpect(tostring(YourError)).toEqual("YourError")
		jestExpect(tostring(YourError("your test"))).toEqual("YourError: your test")
	end)

	it("checks Error stack field", function()
		local lineNumber = (debug.info(1, "l") :: number) + 1
		local err = Error("test stack for Error()")
		local topLineRegExp = RegExp("Error.__tests__\\.Error\\.spec:" .. tostring(lineNumber))

		jestExpect(topLineRegExp:test(err.stack)).toEqual(true)

		local lineNumber2 = (debug.info(1, "l") :: number) + 1
		local err2 = Error.new("test stack for Error.new()")
		local topLineRegExp2 = RegExp("Error.__tests__\\.Error\\.spec:" .. tostring(lineNumber2))

		jestExpect(topLineRegExp2:test(err2.stack)).toEqual(true)
	end)

	it("checks Error stack field contains error message", function()
		local err = Error("test stack for Error()")
		local err2 = Error.new("test stack for Error.new()")

		local topLineRegExp = RegExp("^.*test stack for Error()")
		local topLineRegExp2 = RegExp("^.*test stack for Error.new()")

		jestExpect(topLineRegExp:test(err.stack)).toEqual(true)
		jestExpect(topLineRegExp2:test(err2.stack)).toEqual(true)
	end)

	it("checks Error stack field doesn't contains stack from callable table", function()
		local err = Error("test stack for Error()")

		local topLineRegExp = RegExp("Error:\\d+ function __call")

		jestExpect(topLineRegExp:test(err.stack)).toEqual(false)
	end)

	it("checks Error stack field doesn't contains stack from Error.new function", function()
		local err = Error.new("test stack for Error.new()")

		local topLineRegExp = RegExp("Error:\\d+ function new")

		jestExpect(topLineRegExp:test(err.stack)).toEqual(false)
	end)

	it("checks Error stack field contains error name at the beginning", function()
		local err = Error("test stack for Error()")
		local err2 = Error.new("test stack for Error.new()")

		local topLineRegExp = RegExp("^Error: test stack for Error()")
		local topLineRegExp2 = RegExp("^Error: test stack for Error.new()")

		jestExpect(topLineRegExp:test(err.stack)).toEqual(true)
		jestExpect(topLineRegExp2:test(err2.stack)).toEqual(true)
	end)

	itSKIP(
		"checks Error stack field contains error name at the beginning if name is modified before accessing stack",
		function()
			local err = Error("test stack for Error()")
			local err2 = Error.new("test stack for Error.new()")
			err.name = "MyError"
			err2.name = "MyError"

			local topLineRegExp = RegExp("^MyError: test stack for Error()")
			local topLineRegExp2 = RegExp("^MyError: test stack for Error.new()")

			jestExpect(topLineRegExp:test(err.stack)).toEqual(true)
			jestExpect(topLineRegExp2:test(err2.stack)).toEqual(true)
		end
	)

	it("checks default Error message field", function()
		jestExpect(Error().message).toEqual("")
	end)

	it("prints 'Error' for an empty Error", function()
		jestExpect(tostring(Error())).toEqual("Error")
	end)

	describe("Error.captureStackTrace", function()
		local function createErrorNew()
			return Error.new("error message new function")
		end

		local function createErrorCallable()
			return Error("error message callable table")
		end

		local function myCaptureStacktrace(err: Error)
			Error.captureStackTrace(err)
		end

		local function myCaptureStacktraceNested0(err: Error)
			local function f1()
				local function f2()
					Error.captureStackTrace(err)
				end
				f2()
			end
			f1()
		end

		local function myCaptureStacktraceNested1(err: Error)
			local function f1()
				local function f2()
					Error.captureStackTrace(err, f1)
				end
				f2()
			end
			f1()
		end

		local function myCaptureStacktraceNested2(err: Error)
			local function f1()
				local function f2()
					Error.captureStackTrace(err, f2)
				end
				f2()
			end
			f1()
		end

		it("should capture functions stacktrace - Error.new", function()
			local err = createErrorNew()

			local stacktraceRegex1 = RegExp("function createErrorNew")
			local stacktraceRegex2 = RegExp("function createErrorCallable")
			local stacktraceRegex3 = RegExp("function myCaptureStacktrace")

			jestExpect(stacktraceRegex1:test(err.stack)).toEqual(true)
			jestExpect(stacktraceRegex2:test(err.stack)).toEqual(false)
			jestExpect(stacktraceRegex3:test(err.stack)).toEqual(false)

			myCaptureStacktrace(err)

			jestExpect(stacktraceRegex1:test(err.stack)).toEqual(false)
			jestExpect(stacktraceRegex2:test(err.stack)).toEqual(false)
			jestExpect(stacktraceRegex3:test(err.stack)).toEqual(true)
		end)

		it("should capture functions stacktrace - Error", function()
			local err = createErrorCallable()

			local stacktraceRegex1 = RegExp("function createErrorNew")
			local stacktraceRegex2 = RegExp("function createErrorCallable")
			local stacktraceRegex3 = RegExp("function myCaptureStacktrace")

			jestExpect(stacktraceRegex1:test(err.stack)).toEqual(false)
			jestExpect(stacktraceRegex2:test(err.stack)).toEqual(true)
			jestExpect(stacktraceRegex3:test(err.stack)).toEqual(false)

			myCaptureStacktrace(err)

			jestExpect(stacktraceRegex1:test(err.stack)).toEqual(false)
			jestExpect(stacktraceRegex2:test(err.stack)).toEqual(false)
			jestExpect(stacktraceRegex3:test(err.stack)).toEqual(true)
		end)

		it("should capture functions stacktrace with option - Error.new", function()
			local err = createErrorNew()
			local stacktraceRegex = RegExp("function myCaptureStacktraceNested")
			local stacktraceRegexF1 = RegExp("function f1")
			local stacktraceRegexF2 = RegExp("function f2")

			myCaptureStacktraceNested0(err)

			jestExpect(stacktraceRegex:test(err.stack)).toEqual(true)
			jestExpect(stacktraceRegexF1:test(err.stack)).toEqual(true)
			jestExpect(stacktraceRegexF2:test(err.stack)).toEqual(true)

			myCaptureStacktraceNested1(err)

			jestExpect(stacktraceRegex:test(err.stack)).toEqual(true)
			jestExpect(stacktraceRegexF1:test(err.stack)).toEqual(false)
			jestExpect(stacktraceRegexF2:test(err.stack)).toEqual(false)

			myCaptureStacktraceNested2(err)

			jestExpect(stacktraceRegex:test(err.stack)).toEqual(true)
			jestExpect(stacktraceRegexF1:test(err.stack)).toEqual(true)
			jestExpect(stacktraceRegexF2:test(err.stack)).toEqual(false)
		end)

		it("should capture functions stacktrace with option - Error", function()
			local err = createErrorCallable()
			local stacktraceRegex = RegExp("function myCaptureStacktraceNested")
			local stacktraceRegexF1 = RegExp("function f1")
			local stacktraceRegexF2 = RegExp("function f2")

			myCaptureStacktraceNested0(err)

			jestExpect(stacktraceRegex:test(err.stack)).toEqual(true)
			jestExpect(stacktraceRegexF1:test(err.stack)).toEqual(true)
			jestExpect(stacktraceRegexF2:test(err.stack)).toEqual(true)

			myCaptureStacktraceNested1(err)

			jestExpect(stacktraceRegex:test(err.stack)).toEqual(true)
			jestExpect(stacktraceRegexF1:test(err.stack)).toEqual(false)
			jestExpect(stacktraceRegexF2:test(err.stack)).toEqual(false)

			myCaptureStacktraceNested2(err)

			jestExpect(stacktraceRegex:test(err.stack)).toEqual(true)
			jestExpect(stacktraceRegexF1:test(err.stack)).toEqual(true)
			jestExpect(stacktraceRegexF2:test(err.stack)).toEqual(false)
		end)
	end)
end