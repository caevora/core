
---@meta GlassLoaderClass

------------------------------------------------------------------------------
-- GlassLoaderClass
------------------------------------------------------------------------------

--[[

The GlassLoaderClass (or glass_loader) provides functionality for loading and optionally executing "glass" scripts from 
either a local path or a URL. Here's how someone would use it:

How to Use glass_loader
Step 1: Include or Require glass_loader

Before using it, ensure that the glass_loader class is included or required in your Lua project.

glass_loader = require("path.to.glass_loader")

Step 2: Prepare the Options Table
The load_glass function requires an options table with the following keys:

path: The local path or URL to the glass script.
cb: A callback function that processes the result after loading.
execute: (Optional) Whether the script should be executed after being loaded (default is false).

Step 3: Call load_glass
Use glass_loader.load_glass to load the script with the prepared options table.

Examples of Usage

1. Loading and Executing a Glass Script
Here, the script is located at a local path and will be executed after loading.

glass_loader.load_glass({
  path = "path/to/glass.lua",
  cb = function(result)
    if result then
      print("Glass script loaded and executed successfully!")
    else
      print("Failed to execute glass script.")
    end
  end,
  execute = true
})

2. Loading a Glass Script Without Execution
This example only loads the script but does not execute it.

glass_loader.load_glass({
  path = "path/to/glass.lua",
  cb = function(result)
    if result then
      print("Glass script loaded successfully! Result: ", result)
    else
      print("Failed to load glass script.")
    end
  end,
  execute = false
})


3. Loading a Glass Script from a URL
If the script is hosted online, provide the URL instead of a local path.

glass_loader.load_glass({
  path = "https://example.com/path/to/glass.lua",
  cb = function(result)
    if result then
      print("Glass script loaded and executed successfully from URL!")
    else
      print("Failed to load glass script from URL.")
    end
  end,
  execute = true
})


Use Cases
Dynamic Loading:


Load glass scripts at runtime without including them in the main codebase.
Useful for plugins, modular systems, or loading updates from remote servers.


Execution Control:
Decide whether to execute the script immediately (execute = true) or handle the result manually (execute = false).

Callback Processing:
Use the cb callback to process the loaded script or handle errors.

Best Practices:


Error Handling:
Ensure the cb function handles scenarios where the script cannot be loaded (e.g., invalid path, network issues).

Validation:
Validate the loaded script before execution if execute = false. For example, check its type or content.

Security:
When loading scripts from a URL, ensure the source is trusted to avoid executing malicious code.

What Happens Internally

Loading Process:
The load_glass function reads the file or fetches it from the URL specified in opts.path.

Execution (Optional):
If opts.execute is true, the script is executed using loadstring or a similar Lua function.

Callback (opts.cb):
Once the script is loaded (and executed, if specified), the result is passed to the callback function.

With this flexible approach, glass_loader allows dynamic loading and execution of Lua scripts, making it particularly useful for modular or plugin-based systems.



]]




if false then -- ensure that functions do not get defined

  ---@class GlassLoaderClass

  --- Loads a glass script from a path or url.
  ---@example
  ---```lua
  ---glass_loader.load_glass({
  ---  path = "path/to/glass.lua",
  ---  cb = function(result)
  ---    print(result)
  ---  end,
  ---  execute = true
  ---})
  ---```
  ---
  ---@name load_glass
  ---@param opts table - The options table.
  ---@param opts.path string - The path or url to the glass script.
  ---@param opts.cb function - The callback function.
  ---@param opts.execute boolean? - Whether to execute the glass script.
  ---@return any - The result of the glass script.
  function glass_loader.load_glass(opts) end

end
