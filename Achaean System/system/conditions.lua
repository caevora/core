---@meta ConditionsClass

------------------------------------------------------------------------------
-- ConditionsClass
------------------------------------------------------------------------------


--[[
EXAMPLES:

Key Use Cases:
Validation in Application Logic:

You can use these functions to validate assumptions or user inputs in your code.
Example: Ensuring a condition is met before proceeding with a critical operation.

local result, errorMsg = conditions.is_not_nil(someVariable, "Variable should not be nil")
if not result then
    error(errorMsg)
end


Unit Testing:
These functions are ideal for writing clear and concise tests, as they handle common assertions like equality, type checking, or error expectations.
assert(conditions.is_eq(actualValue, expectedValue, "Values should be equal"))
assert(conditions.is_true(someCondition, "Condition should be true"))


Debugging:
The optional message parameter allows for more meaningful error messages, helping developers understand the issue.
conditions.is_false(flag, "Expected flag to be false")

Error Handling:
The is_error function can test whether a function raises an expected error.
local success, err = conditions.is_error(function() error("Test error") end, "Expected error")
if not success then
    print(err)
end


Dynamic Validations:
Validate conditions dynamically at runtime in larger systems to ensure consistency.
for _, value in ipairs(collection) do
    assert(conditions.is_type(value, "number", "All values must be numbers"))
end

Deep Comparisons:
The is_deeply function is helpful for verifying complex nested structures in testing or runtime validation.

assert(conditions.is_deeply({key = "value"}, {key = "value"}, "Objects should be deeply equal"))



Features and Applications by Functionality:
Function						Purpose
is	         					Generic truthy check, returning a message for failures.
is_true / is_false				Specifically check if conditions are true or false.
is_nil / is_not_nil				Validates if a value is nil or not.
is_eq / is_ne					Checks for equality or inequality between two values.
is_lt, is_le					Comparison operators: less than, less than or equal.
is_gt, is_ge					Comparison operators: greater than, greater than or equal.
is_type							Validates the type of a value (e.g., "number", "string").
is_error						Ensures a function raises an error and optionally validates the error message.
is_deeply						Performs deep equality checks for complex or nested data structures.



Example: Testing Workflow
Step 1: Input Validation
local function divide(a, b)
    assert(conditions.is_type(a, "number", "First argument must be a number"))
    assert(conditions.is_type(b, "number", "Second argument must be a number"))
    assert(conditions.is_ne(b, 0, "Division by zero is not allowed"))
    return a / b
end


Step 2: Writing Unit Tests
local function test_divide()
    local result, message = conditions.is_eq(divide(4, 2), 2, "4 divided by 2 should equal 2")
    assert(result, message)

    local result, message = conditions.is_error(function() divide(4, 0) end, "Division by zero is not allowed")
    assert(result, message)
end
test_divide()



Why Use It?
Readability: Simplifies and clarifies conditional checks in code.
Reusability: Provides a consistent API for assertions and validations across projects.
Debugging Support: Rich error messaging makes debugging easier.
Testing Compatibility: Aligns well with Lua-based testing frameworks or custom test runners.




To include this ConditionsClass script in your Lua project, follow these steps:

1. Save the Script as a File
Save the script in a Lua file, e.g., conditions.lua, in your project directory.

2. Include the Script in Your Project
Use the require function to load the script into your Lua application.

Here’s how:

-- Assuming conditions.lua is in the same directory as your main script
local conditions = require("conditions")
If the file is in a subdirectory, provide the relative path:


-- Assuming conditions.lua is in a subdirectory called 'utils'
local conditions = require("utils.conditions")


3. Ensure the Script is Returnable
For require to work, the conditions.lua file must return the ConditionsClass table. At the end of the script, add:


local conditions = {}
-- Define the conditions class here, as per the script

-- Example condition function
function conditions.is(condition, message)
    if not condition then
        return false, message
    end
    return true
end

return conditions


4. Use the Loaded Module
After including the script, you can call its functions in your code:
local conditions = require("conditions")

-- Example usage
local result, message = conditions.is(1 == 1, "1 should equal 1")
if not result then
    print("Condition failed:", message)
else
    print("Condition passed!")
end



5. Alternative: Inline Definition
If you do not want to save it in a separate file, you can directly define the conditions table in your main script:


local conditions = {}

function conditions.is(condition, message)
    if not condition then
        return false, message
    end
    return true
end



-- Example usage
local result, message = conditions.is(false, "Expected condition to be true")
print(result, message)


6. Debugging require Issues
If the script is not found or fails to load:

Ensure the file is in the correct directory.
Check the Lua package.path to see if your directory is included:

print(package.path)
Modify package.path if necessary:

package.path = package.path .. ";./utils/?.lua"


]]






if false then -- ensure that functions do not get defined
  ---@class ConditionsClass

  --- Checks if a condition is true or false.
  ---
  ---@example
  ---```lua
  ---conditions.is(true)
  ----- true, nil
  ---conditions.is(false, "Expected condition to be false")
  ----- false, "Expected condition to be false"
  ---```
  ---
  ---@name is
  ---@param condition boolean - The condition to check
  ---@param message string? - The message to return if the condition is false
  ---@return boolean, string? # The condition and message, or nil if the condition is true
  function conditions.is(condition, message) end

  --- Checks if a condition is true.
  ---
  ---@example
  ---```lua
  ---conditions.is_true(true)
  ----- true, nil
  ---conditions.is_true(false, "Expected condition to be true")
  ----- false, "Expected condition to be true"
  ---```
  ---
  ---@name is_true
  ---@param condition boolean - The condition to check
  ---@param message string? - The message to return if the condition is false
  ---@return boolean, string? # The condition and message, or nil if the condition is true
  function conditions.is_true(condition, message) end

  --- Checks if a condition is false.
  ---
  ---@example
  ---```lua
  ---conditions.is_false(false)
  ----- false, nil
  ---conditions.is_false(true, "Expected condition to be false")
  ----- true, "Expected condition to be false"
  ---```
  ---
  ---@name is_false
  ---@param condition boolean - The condition to check
  ---@param message string? - The message to return if the condition is true
  ---@return boolean, string? # The condition and message, or nil if the condition is true
  function conditions.is_false(condition, message) end

  --- Checks if a value is nil.
  ---
  ---@example
  ---```lua
  ---conditions.is_nil(nil)
  ----- true, nil
  ---conditions.is_nil(false, "Expected value to be nil")
  ----- false, "Expected value to be nil"
  ---```
  ---
  ---@name is_nil
  ---@param value any - The value to check
  ---@param message string? - The message to return if the value is nil
  ---@return boolean, string? # The condition and message, or nil if the condition is true
  function conditions.is_nil(value, message) end

  --- Checks if a value is not nil.
  ---
  ---@example
  ---```lua
  ---conditions.is_not_nil(false)
  ----- false, nil
  ---conditions.is_not_nil(nil, "Expected value to not be nil")
  ----- true, "Expected value to not be nil"
  ---```
  ---
  ---@name is_not_nil
  ---@param value any - The value to check
  ---@param message string? - The message to return if the value is nil
  ---@return boolean, string? # The condition and message, or nil if the condition is true
  function conditions.is_not_nil(value, message) end

  --- Checks if a function throws an error.
  ---
  ---@example
  ---```lua
  ---conditions.is_error(function() error("Expected error") end, "Expected error")
  ----- false, "Expected error"
  ---```
  ---
  ---@name is_error
  ---@param func function - The function to check
  ---@param message string? - The message to return if the function does not throw an error
  ---@param check function? - The function to check the error message against
  ---@return boolean, string? # The condition and message, or nil if the condition is true
  function conditions.is_error(func, message, check) end

  --- Checks if two values are equal.
  ---
  ---@example
  ---```lua
  ---conditions.is_eq(1, 1)
  ----- true, nil
  ---conditions.is_eq(1, 2, "Expected values to be equal")
  ----- false, "Expected values to be equal"
  ---```
  ---
  ---@name is_eq
  ---@param a any - The first value to check
  ---@param b any - The second value to check
  ---@param message string? - The message to return if the values are not equal
  ---@return boolean, string? # The condition and message, or nil if the condition is true
  function conditions.is_eq(a, b, message) end

  --- Checks if two values are not equal.
  ---
  ---@example
  ---```lua
  ---conditions.is_ne(1, 2)
  ----- true, nil
  ---conditions.is_ne(1, 1, "Expected values to not be equal")
  ----- false, "Expected values to not be equal"
  ---```
  ---
  ---@name is_ne
  ---@param a any - The first value to check
  ---@param b any - The second value to check
  ---@param message string? - The message to return if the values are equal
  ---@return boolean, string? # The condition and message, or nil if the condition is true
  function conditions.is_ne(a, b, message) end
  end

  --- Checks if a value is less than another value.
  ---
  ---@example
  ---```lua
  ---conditions.is_lt(1, 2)
  ----- true, nil
  ---conditions.is_lt(2, 1, "Expected values to be less than")
  ----- false, "Expected values to be less than"
  ---```
  ---
  ---@name is_lt
  ---@param a any - The first value to check
  ---@param b any - The second value to check
  ---@param message string? - The message to return if the values are not less than
  ---@return boolean, string? # The condition and message, or nil if the condition is true
  function conditions.is_lt(a, b, message) end

  --- Checks if a value is less than or equal to another value.
  ---
  ---@example
  ---```lua
  ---conditions.is_le(1, 2)
  ----- true, nil
  ---conditions.is_le(2, 1, "Expected values to be less than or equal to")
  ----- false, "Expected values to be less than or equal to"
  ---```
  ---
  ---@name is_le
  ---@param a any - The first value to check
  ---@param b any - The second value to check
  ---@param message string? - The message to return if the values are not less than or equal to
  ---@return boolean, string? # The condition and message, or nil if the condition is true
  function conditions.is_le(a, b, message) end

  --- Checks if a value is greater than another value.
  ---
  ---@example
  ---```lua
  ---conditions.is_gt(2, 1)
  ----- true, nil
  ---conditions.is_gt(1, 2, "Expected values to be greater than")
  ----- false, "Expected values to be greater than"
  ---```
  ---
  ---@name is_gt
  ---@param a any - The first value to check
  ---@param b any - The second value to check
  ---@param message string? - The message to return if the values are not greater than
  ---@return boolean, string? # The condition and message, or nil if the condition is true
  function conditions.is_gt(a, b, message) end

  --- Checks if a value is greater than or equal to another value.
  ---
  ---@example
  ---```lua
  ---conditions.is_ge(2, 1)
  ----- true, nil
  ---conditions.is_ge(1, 2, "Expected values to be greater than or equal to")
  ----- false, "Expected values to be greater than or equal to"
  ---```
  ---
  ---@name is_ge
  ---@param a any - The first value to check
  ---@param b any - The second value to check
  ---@param message string? - The message to return if the values are not greater than or equal to
  ---@return boolean, string? # The condition and message, or nil if the condition is true
  function conditions.is_ge(a, b, message) end

  --- Checks if a value is of a specific type.
  ---
  ---@example
  ---```lua
  ---conditions.is_type(1, "number")
  ----- true, nil
  ---conditions.is_type(1, "string", "Expected value to be a string")
  ----- false, "Expected value to be a string"
  ---```
  ---
  ---@name is_type
  ---@param value any - The value to check
  ---@param type string - The type to check against
  ---@param message string? - The message to return if the values are not of the specified type
  ---@return boolean, string? # The condition and message, or nil if the condition is true
  function conditions.is_type(value, type, message) end

  --- Checks if two values are deeply equal.
  ---
  ---@example
  ---```lua
  ---conditions.is_deeply({a = 1}, {a = 1})
  ----- true, nil
  ---```
  ---
  ---@name is_deeply
  ---@param a any - The first value to check
  ---@param b any - The second value to check
  ---@param message string? - The message to return if the values are not deeply equal
  ---@return boolean, string? # The condition and message, or nil if the condition is true
  function conditions.is_deeply(a, b, message) end

end