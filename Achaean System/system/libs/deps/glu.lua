---@meta Glu

------------------------------------------------------------------------------
-- Glu
------------------------------------------------------------------------------

--[[

The Glu class is a utility framework designed to manage packages, modules, and "glasses" within a Lua-based system. Here's a guide on how someone might use the Glu class:

How to Use Glu

Step 1: Include or Require the Glu Class
Ensure the Glu class is included in your Lua project.


local Glu = require("path.to.glu")

Step 2: Instantiate a Glu Instance
Use the Glu.new method or directly call Glu to create a new instance.

-- Example 1: Using the new method
local glu = Glu.new("MyPackage", "MyModule")

-- Example 2: Directly invoking the class
local glu = Glu("MyPackage", "MyModule")
Parameters:

package_name: The name of the package to which this module belongs (required).
module_dir_name: The directory name inside the package directory where the modules are located (optional).
Use Case: This is useful for organizing and managing modules within a package.


Step 3: Generate a Unique Identifier
Use the Glu.id method to generate a version 4 UUID.


local id = Glu.id()
print("Generated ID:", id)

Use Case: This is helpful for creating unique identifiers for objects, tasks, or transactions.

Step 4: Work with Glasses

Get All Glasses

Retrieve all registered glasses.


local glasses = Glu.get_glasses()
for _, glass in ipairs(glasses) do
  print("Glass:", glass)
end

Get All Glass Names
Retrieve the names of all registered glasses.


local glass_names = Glu.get_glass_names()
for _, name in ipairs(glass_names) do
  print("Glass Name:", name)
end
Get a Specific Glass

Retrieve a specific glass by name.


local glass = Glu.get_glass("MyGlass")
if glass then
  print("Found glass:", glass)
else
  print("Glass not found.")
end


Check if a Glass Exists

Verify whether a glass is registered.


local exists = Glu.has_glass("MyGlass")
if exists then
  print("Glass exists!")
else
  print("Glass does not exist.")
end

Use Case: This is useful for managing and querying registered "glass" components in your project.

Step 5: Get the Last Traceback Line
Retrieve the last line of a traceback for debugging or validation.

local traceback_line = Glu.get_last_traceback_line()
print("Last Traceback Line:", traceback_line)

Use Case: 

Useful for error handling and debugging purposes.

Examples of Usage:
1. Managing Glasses
-- Instantiate a new Glu instance
local glu = Glu("MyPackage", "Modules")

-- Check if a specific glass exists
if glu:has_glass("MySpecialGlass") then
  print("Glass exists!")
else
  print("Glass not found!")
end

-- Get and use a specific glass
local my_glass = glu:get_glass("MySpecialGlass")
if my_glass then
  -- Perform actions with the glass
end

2. Generating UUIDs
local unique_id = Glu.id()
print("Generated Unique ID:", unique_id)

3. Debugging with Tracebacks
local last_error_line = Glu.get_last_traceback_line()
print("Last Error Traceback Line:", last_error_line)

Applications:

Package and Module Management:

Organize and structure Lua packages and modules systematically.
Manage components ("glasses") within packages efficiently.

Dynamic Component Management:
Query and interact with registered components dynamically.

Debugging and Logging:
Use traceback information to debug and resolve issues.

Unique Identifiers:
Generate unique IDs for objects, sessions, or events.

Best Practices:

Error Handling:
Always check for the existence of glasses using Glu.has_glass before attempting to retrieve or manipulate them.

Organized Structure:
Use the package_name and module_dir_name parameters to keep your codebase well-structured.

Traceback Usage:
Use Glu.get_last_traceback_line to log or display helpful debugging information.

The Glu class offers a comprehensive framework for managing packages, modules, and glasses, along with utilities like UUID generation and debugging support. 
This makes it highly suitable for modular and scalable Lua-based applications.




]]



if false then -- ensure that functions do not get defined

  ---@class Glu

  ---Instantiate a new Glu instance. Can be invoked by its class name or
  ---by the `new` function.
  ---
  ---@example
  ---```lua
  ---local glu = Glu.new("MyPackage", "MyModule")
  ---local glu = Glu("MyPackage", "MyModule")
  ---```
  ---
  ---@name new
  ---@param package_name string - The name of the package to which this module belongs.
  ---@param module_dir_name string? - The directory name inside the package directory where the modules are located.
  ---@return Glu # A new Glu instance.
  function Glu.new(package_name, module_dir_name) end

  ---Generate a unique identifier, producing a version 4 UUID.
  ---
  ---@name id
  ---@return string # A unique identifier.
  ---@example
  ---```lua
  ---local id = Glu.id()
  ---```
  ---@name id
  function Glu.id() end

  ---Get all glasses.
  ---
  ---@name get_glasses
  ---@return Glass[] # A table of glasses.
  ---@example
  ---```lua
  ---local glasses = Glu.get_glasses()
  ---```
  ---
  function Glu.get_glasses() end

  ---Get all glass names.
  ---
  ---@name get_glass_names
  ---@return string[] # A table of glass names.
  ---@example
  ---```lua
  ---local glass_names = Glu.get_glass_names()
  ---```
  ---
  function Glu.get_glass_names() end

  ---Get a glass by name.
  ---
  ---@name get_glass
  ---@param glass_name string - The name of the glass to retrieve.
  ---@return Glass? # The glass, or nil if it does not exist.
  ---@example
  ---```lua
  ---local glass = Glu.get_glass("MyGlass")
  ---```
  ---
  function Glu.get_glass() end

  ---Check if a glass exists.
  ---
  ---@name has_glass
  ---@param glass_name string - The name of the glass to check for.
  ---@return boolean # True if the glass exists, false otherwise.
  ---@example
  ---```lua
  ---local exists = Glu.has_glass("MyGlass")
  ---```
  ---
  function Glu.has_glass(glass_name) end

  ---Get the last traceback line. Used for validation functions, or any
  ---time you need to get the last line of a traceback. Also available
  ---via the `v` table from the anchor.
  ---
  ---@name get_last_traceback_line
  ---@return string # The last traceback line.
  function Glu.get_last_traceback_line() end
end