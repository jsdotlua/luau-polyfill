local Object = require("@pkg/@jsdotlua/collections").Object
local task = require("@pkg/luau-task")

local makeTimerImpl = require("./makeTimerImpl")
local makeIntervalImpl = require("./makeIntervalImpl")

export type Timeout = makeTimerImpl.Timeout
export type Interval = makeIntervalImpl.Interval

return Object.assign({}, makeTimerImpl(task.delay), makeIntervalImpl(task.delay))
