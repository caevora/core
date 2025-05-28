
---@meta FuncClass

------------------------------------------------------------------------------
-- FuncClass
------------------------------------------------------------------------------


--[[

EXAMPLE:


The FuncClass is designed for efficient and structured management of function execution. Here's a concise breakdown of how one would use it in various scenarios:

How to Use FuncClass
Load the Class:

Ensure the FuncClass is included in your Lua project, either by requiring the script or embedding it directly.

require("FuncClass")
Access Methods:

Use the provided methods (delay, wrap, repeater) to handle timed execution, function wrapping, or repetition.

Examples of Usage:

1. Delaying Function Execution
The func.delay method is useful when you need to execute a function after a specified time delay.

func.delay(function()
  print("This message is delayed by 3 seconds!")
end, 3)


Scenario: Use this for animations, cooldowns, or delayed UI updates.


2. Wrapping a Function
The func.wrap method allows you to extend or modify an existing function's behavior.

local wrapped_print = func.wrap(print, function(original_func, text)
  original_func("[LOG]: " .. text)
end)

wrapped_print("This is a log message.")
-- Output: [LOG]: This is a log message.
Scenario: Use this for adding debugging information, modifying the behavior of third-party functions, or logging.


3. Repeating a Function
The func.repeater method lets you execute a function multiple times with a specified interval.

func.repeater(function()
  print("Repeating this every 2 seconds, 4 times.")
end, 2, 4)
Parameters:

func: The function to execute repeatedly.
interval: (Optional) Time in seconds between executions (default: 1 second).
times: (Optional) Number of repetitions (default: 1).
Scenario: Useful for polling, recurring game events, or periodic updates.

Applications:

Game Development:
Implement delayed actions like cooldown timers or staggered animations.
Schedule periodic updates, such as environmental effects or player stats regeneration.
Dynamically modify game logic using wrap.

Automation Scripting:
Automate repetitive tasks with repeater, such as polling or batch processing.
Add timed logic for sequential actions in automation workflows.

Debugging and Logging:
Use wrap to log every call to a specific function for debugging.
Easily track function calls and modify them without changing the original code.

Best Practices:

Error Handling:
Ensure that functions passed to func.delay or func.repeater are error-free, as a failure could disrupt the execution chain.

Prevent Infinite Loops:
Always define a times parameter explicitly when using func.repeater to avoid infinite loops.

Non-Intrusive Wrapping:

Ensure that the wrapper function in func.wrap respects the behavior of the original function to avoid unexpected side effects.

Advanced Use Cases:

Combining delay and repeater:

You can chain these methods to create complex behaviors, such as delaying a function that repeats periodically.

func.delay(function()
  func.repeater(function()
    print("Repeating with an initial delay!")
  end, 1, 3)
end, 5)
Dynamic Wrapping:

Dynamically log arguments passed to any function:

local dynamic_logger = func.wrap(some_function, function(original_func, ...)
  print("Arguments passed:", ...)
  return original_func(...)
end)
dynamic_logger("arg1", "arg2")







]]



if false then -- ensure that functions do not get defined

  ---@class FuncClass

  --- Delays the execution of a function.
  ---
  ---@example
  ---```lua
  ---func.delay(function() print("Hello, world!") end, 1)
  ---```
  ---@name delay
  ---@param func function - The function to delay.
  ---@param delay number - The delay in seconds.
  function func.delay(func, delay, ...) end

  --- Wraps a function in another function.
  ---
  ---@example
  ---```lua
  ---local becho = func.wrap(cecho, function(func, text)
  ---  func("<b>{text}</b>")
  ---end)
  ---
  ---becho("Hello, world!")
  --- -- <b>Hello, world!</b>
  ---```
  ---@name wrap
  ---@param func function - The function to wrap.
  ---@param wrapper function - The wrapper function.
  function func.wrap(func, wrapper) end

  --- Repeats a function a given number of times.
  ---
  ---@example
  ---```lua
  ---func.repeater(function() print("Hello, world!") end, 1, 3)
  ---```
  ---@name repeater
  ---@param func function - The function to repeat.
  ---@param interval number? - The interval between repetitions (Optional. Default is 1).
  ---@param times number? - The number of times to repeat the function (Optional. Default is 1).
  function func.repeater(func, interval, times, ...) end

end
