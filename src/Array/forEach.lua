--!strict

type Array = { [number]: any }
type callbackFn = (element: any, index: number?, array: Array?) -> ()
type callbackFnWithThisArg = (thisArg: any, element: any, index: number?, array: Array?) -> ()

-- Implements Javascript's `Array.prototype.forEach` as defined below
-- https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/forEach
return function(t: Array, callback: callbackFn | callbackFnWithThisArg, thisArg: any?): ()
	if typeof(t) ~= "table" then
		error(string.format("Array.forEach called on %s", typeof(t)))
	end
	if typeof(callback) ~= "function" then
		error("callback is not a function")
	end

	local len = #t
	local k = 1

	while k <= len do
		local kValue = t[k]

		if thisArg ~= nil then
			(callback :: callbackFnWithThisArg)(thisArg, kValue, k, t)
		else
			(callback :: callbackFn)(kValue, k, t)
		end

		k += 1
	end
end
