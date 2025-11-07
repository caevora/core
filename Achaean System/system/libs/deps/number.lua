---@meta NumberClass

------------------------------------------------------------------------------
-- NumberClass
------------------------------------------------------------------------------



--[[

EXAMPLES:


This script provides a set of utility functions that perform common numerical calculations or checks, making it easier for developers to handle numerical operations in Lua. Here's why someone would use it and examples of how it could be applied:

Why Use This Script?

Code Simplification: It abstracts common mathematical operations, such as clamping, normalizing, and interpolation, into reusable functions.

Readability: Instead of writing custom logic for every mathematical operation, you can use self-explanatory functions like number.clamp or number.lerp.

Error Reduction: Predefined and tested functions minimize the risk of introducing bugs when implementing these operations.
Utility for Game or UI Development: Many of these functions, such as lerp or normalize, are especially useful for animations, physics simulations, or user interface designs.

Consistency: It ensures consistent behavior for similar tasks throughout the codebase.


Examples of Usage:


1. Average of Numbers
local avg = number.average(10, 20, 30)
print(avg) -- Output: 20

2. Clamping a Value
Ensure a number stays within a specified range.
local clamped = number.clamp(15, 0, 10)
print(clamped) -- Output: 10

3. Linearly Interpolate Between Two Values
Smoothly transition between two numbers.
local interpolated = number.lerp(0, 100, 0.5)
print(interpolated) -- Output: 50

4. Check if a Number is Between Two Values
local isBetween = number.is_between(5, 1, 10)
print(isBetween) -- Output: true

5. Map a Value from One Range to Another
Convert a number from one range to another (e.g., for UI scaling or normalization).
local mapped = number.map(5, 0, 10, 0, 100)
print(mapped) -- Output: 50

6. Normalize a Value
Convert a number to a range between 0 and 1.
local normalized = number.normalize(25, 0, 100)
print(normalized) -- Output: 0.25

7. Random Number Between Two Values
Get a random number in a given range.
local randomNum = number.random_clamp(1, 10)
print(randomNum) -- Output: Random number between 1 and 10

8. Sum of Numbers
local total = number.sum(1, 2, 3, 4)
print(total) -- Output: 10

9. Check if a Number is Positive
local isPositive = number.positive(-5)
print(isPositive) -- Output: false

10. Round a Number
local rounded = number.round(3.14159, 2)
print(rounded) -- Output: 3.14


Real-World Applications
Game Development:

Use number.lerp for smooth animations or transitions between game states.
Use number.clamp to ensure player health stays within a valid range.
Use number.map for scaling scores or values to visual representations like progress bars.

UI/UX Development:
Normalize values using number.normalize for progress indicators or loading bars.
Use number.random_clamp to add subtle, randomized animations to UI elements.

Data Analysis:
Use number.average and number.sum to calculate statistics on numerical datasets.
Use number.is_approximate to compare floating-point numbers with tolerances.

Simulations and Physics:
Interpolate values using number.lerp for physical simulations.
Use number.clamp to constrain simulated values within defined boundaries.


How to Include This Script
Save the script in a Lua file (e.g., number_utils.lua).


Import it into your Lua project:

require("number_utils")
Use the functions as shown in the examples above.
This utility can save time, improve consistency, and reduce boilerplate code for common numerical operations!



]]




if false then -- ensure that functions do not get defined

  ---@class NumberClass

  ---Calculates the average of a list of numbers. The input can be a single
  ---table of numbers or multiple numbers as individual arguments.
  ---
  ---@name average
  ---@param ... number|number[] - The numbers to average.
  ---@return number # The average of the numbers.
  function number.average(...) end

  ---Clamps a number between a minimum and maximum value.
  ---
  ---@name clamp
  ---@param num number - The number to clamp.
  ---@param min number - The minimum value.
  ---@param max number - The maximum value.
  ---@return number # The clamped number.
  function number.clamp(num, min, max) end

  ---Constrains a number to a certain precision.
  ---
  ---@name constrain
  ---@param num number - The number to constrain.
  ---@param precision number - The precision (e.g., 0.1, 0.01, etc.).
  ---@return number # The constrained number.
  function number.constrain(num, precision) end

  ---Checks if two numbers are approximately equal, given a percentage tolerance.
  ---
  ---@name is_approximate
  ---@param a number - The first number.
  ---@param b number - The second number.
  ---@param percent_tolerance number - The percentage tolerance.
  ---@return boolean # Whether the numbers are approximately equal.
  function number.is_approximate(a, b, percent_tolerance) end

  ---Checks if a number is between a minimum and maximum value.
  ---
  ---@name is_between
  ---@param num number - The number to check.
  ---@param min number - The minimum value.
  ---@param max number - The maximum value.
  ---@return boolean # Whether the number is between the minimum and maximum values.
  function number.is_between(num, min, max) end

  ---Linearly interpolates between two values, easing in at the beginning.
  ---
  ---@name lerp_ease_in
  ---@param start number - The starting value.
  ---@param end_val number - The ending value.
  ---@param t number - The interpolation factor.
  ---@return number # The interpolated value.
  function number.lerp_ease_in(start, end_val, t) end

  ---Linearly interpolates between two values, easing out at the end.
  ---
  ---@name lerp_ease_out
  ---@param start number - The starting value.
  ---@param end_val number - The ending value.
  ---@param t number - The interpolation factor.
  ---@return number # The interpolated value.
  function number.lerp_ease_out(start, end_val, t) end

  ---Linearly interpolates between two values, smoothly easing in and out.
  ---
  ---@name lerp_smooth
  ---@param start number - The starting value.
  ---@param end_val number - The ending value.
  ---@param t number - The interpolation factor.
  ---@return number # The interpolated value.
  function number.lerp_smooth(start, end_val, t) end

  ---Linearly interpolates between two values, smoothly easing in and out.
  ---
  ---@name lerp_smoother
  ---@param start number - The starting value.
  ---@param end_val number - The ending value.
  ---@param t number - The interpolation factor.
  ---@return number # The interpolated value.
  function number.lerp_smoother(start, end_val, t) end

  ---Linearly interpolates between two values.
  ---
  ---@name lerp
  ---@param a number - The starting value.
  ---@param b number - The ending value.
  ---@param t number - The interpolation factor.
  ---@return number # The interpolated value.
  function number.lerp(a, b, t) end

  ---Maps a value from one range to another. The input value is scaled to the
  ---output range.
  ---
  ---@name map
  ---@param value number - The value to map.
  ---@param in_min number - The minimum value of the input range.
  ---@param in_max number - The maximum value of the input range.
  ---@param out_min number - The minimum value of the output range.
  ---@param out_max number - The maximum value of the output range.
  ---@return number # The mapped value.
  function number.map(value, in_min, in_max, out_min, out_max) end

  ---Returns the maximum value from a list of numbers. The input can be a single
  ---table of numbers or multiple numbers as individual arguments.
  ---
  ---@name max
  ---@param ... number|number[] - The numbers to compare.
  ---@return number # The maximum value.
  function number.max(...) end

  ---Returns the minimum value from a list of numbers. The input can be a single
  ---table of numbers or multiple numbers as individual arguments.
  ---
  ---@name min
  ---@param ... number|number[] - The numbers to compare.
  ---@return number # The minimum value.
  function number.min(...) end

  ---Normalizes a number to a range between 0 and 1.
  ---
  ---@name normalize
  ---@param num number - The number to normalize.
  ---@param min number - The minimum value of the range.
  ---@param max number - The maximum value of the range.
  ---@return number # The normalized number.
  function number.normalize(num, min, max) end

  ---Calculates the percentage of the first value relative to the second value.
  ---
  ---@example
  ---```lua
  ---number.percent_of(5, 20)
  ----- 5
  ---```
  ---@name percent_of
  ---@param numerator number - The numerator of the percentage.
  ---@param denominator number - The denominator of the percentage.
  ---@param round_digits number? - The number of digits to round the result to.
  ---@return number # The percentage of the numerator relative to the denominator.
  function number.percent_of(numerator, denominator, round_digits) end

  ---Returns the value of a percentage relative to a total.
  ---
  ---@example
  ---```lua
  ---number.percent(5, 20)
  ----- 1
  ---```
  ---@name percent
  ---@param percent number - The percentage
  ---@param total number - The total value.
  ---@param round_digits number? - The number of digits to round the result to.
  ---@return number # The value of the percentage relative to the total.
  function number.percent(percent, total, round_digits) end

  ---Checks if a number is positive.
  ---
  ---@name positive
  ---@param num number - The number to check.
  ---@return boolean # Whether the number is positive.
  function number.positive(num) end

  ---Returns a random number between a minimum and maximum value.
  ---
  ---@example
  ---```lua
  ---number.random_clamp(1, 10)
  ----- 5
  ---```
  ---@name random_clamp
  ---@param min number - The minimum value.
  ---@param max number - The maximum value.
  ---@return number # A random number between the minimum and maximum values.
  function number.random_clamp(min, max) end

  ---Rounds a number to a certain precision.
  ---
  ---@name round
  ---@param num number - The number to round.
  ---@param digits number? - The number of digits to round to.
  ---@return number # The rounded number.
  function number.round(num, digits) end

  ---Sums a list of numbers. The input can be a single table of numbers or
  ---multiple numbers as individual arguments.
  ---
  ---@name sum
  ---@param ... number|number[] - The numbers to sum.
  ---@return number # The sum of the numbers.
  function number.sum(...) end

end