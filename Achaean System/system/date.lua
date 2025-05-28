---@meta DateClass

------------------------------------------------------------------------------
-- DateClass
------------------------------------------------------------------------------


--[[

EXAMPLE:

The DateClass script provides a utility for converting seconds into a human-readable string format, 
which is particularly useful for formatting time values in applications, games, or logs.

Why Use This Script?

Time Formatting:
Convert raw time values into a user-friendly format for display.

Enhanced Readability:
Provide clear and structured time information, either as a string or as individual components (hours, minutes, seconds).

Versatility:
Use the output in various contexts such as logs, game timers, or countdowns.

Examples of Usage:

1. Convert Seconds to Human-Readable Format
local formattedTime = date.shms(6543)
print(formattedTime[1], "h") -- "01"
print(formattedTime[2], "m") -- "49"
print(formattedTime[3], "s") -- "03"

2. Get Time as a Single String
If the as_string parameter is true, the output will be a concatenated string:
local formattedString = date.shms(6543, true)
print(formattedString) -- "1h 49m 3s"


Real-World Applications
Game Development:

Display player activity times, cooldowns, or timers in hours, minutes, and seconds.
Show elapsed or remaining time in a readable format.


Logging and Monitoring:
Format uptime, durations, or timestamps in logs for easier analysis.

User Interfaces:
Show countdowns or elapsed time in applications such as fitness trackers or task managers.

Data Visualization:
Annotate time-based graphs or charts with readable labels.


How to Use
Save the class definition as date.lua in your project directory.
Include it in your script using require:

require("date")

Call date.shms() wherever needed in your code.

Additional Ideas for Extension

If you want to expand the functionality of this class:

Add Day Conversion: Include logic to display days if the number of seconds exceeds 86,400 (seconds in a day).

-- Example: 172,800 seconds -> "2d 0h 0m 0s"
Custom Formatting Options: Allow users to specify custom delimiters or units, such as:

date.shms(6543, true, ":", false) -- "1:49:3"
Localization: Provide localized strings for different languages.


This lightweight utility is a great addition to any project requiring time management or formatting!


]]


if false then -- ensure that functions do not get defined

  ---@class DateClass

  ---Converts a number of seconds into a human-readable string. By default, the
  ---result is returned as a table of three strings. However, if the `as_string`
  ---parameter is provided, the result is returned as a single string.
  ---
  ---@example
  ---```lua
  ---date.shms(6543)
  -----"01"
  -----"49"
  -----"03"
  ---
  ---date.shms(6453, true)
  ----- "1h 49m 3s"
  ---```
  ---
  ---@name shms
  ---@param seconds number - The number of seconds to convert.
  ---@param as_string boolean? - Whether to return the result as a string.
  ---@return string[]|string # The resulting string or table of strings.
  function date.shms(seconds, as_string) end

end