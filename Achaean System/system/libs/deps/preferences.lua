---@meta PreferencesClass

------------------------------------------------------------------------------
-- PreferencesClass
------------------------------------------------------------------------------

--[[


The PreferencesClass is a utility for managing application preferences. It provides methods to load and save preferences to files, optionally using a package name for organizing paths.

How to Use PreferencesClass

Step 1: Include or Require the PreferencesClass
Ensure the PreferencesClass is included in your Lua project.


local preferences = require("path.to.preferences")

Step 2: Load Preferences
Use the preferences.load method to load preferences from a file. This method supports default values for missing settings.


-- Example: Load preferences from a package
local prefs = preferences.load("my_package", "settings", { theme = "dark", volume = 50 })

print(prefs.theme)  -- Outputs: "dark" if no existing settings are found
print(prefs.volume) -- Outputs: 50 if no existing settings are found

Parameters:

pkg (optional): The name of the package to load preferences from. If omitted, preferences are loaded from the profile directory.
file: The name of the file to load preferences from.

defaults: A table of default values to use if preferences are missing or incomplete.
Returns: A table containing the loaded preferences.

Step 3: Save Preferences
Use the preferences.save method to save preferences to a file. You can specify a package name for organized paths.

-- Example: Save preferences to a package
preferences.save("my_package", "settings", { theme = "light", volume = 75 })
Parameters:

pkg (optional): The name of the package to save preferences to. If omitted, preferences are saved in the profile directory.
file: The name of the file to save preferences to.
prefs: A table of preferences to save.
Returns: Nothing.


Examples of Usage:


1. Loading and Saving Preferences

-- Load preferences with defaults
local user_prefs = preferences.load("game_package", "user_settings", { sound = true, difficulty = "normal" })

-- Modify preferences
user_prefs.sound = false
user_prefs.difficulty = "hard"

-- Save updated preferences
preferences.save("game_package", "user_settings", user_prefs)

2. Using Without a Package Name
If no package name is provided, preferences are stored in the profile directory.

-- Load preferences without a package
local prefs = preferences.load(nil, "global_settings", { notifications = true })

-- Change preferences
prefs.notifications = false

-- Save preferences
preferences.save(nil, "global_settings", prefs)

Applications:

Game Development:

Store player settings like sound levels, difficulty, or control mappings.
Load and save configurations specific to a game or player profile.

Application Settings:
Manage global or user-specific application preferences such as themes, layouts, or API configurations.

Package-Based Configuration:
Use the pkg parameter to organize settings for modular or package-based applications.

Best Practices:

Use Defaults:
Always provide a defaults table when loading preferences to ensure no missing settings.

Organize by Package:
Use the pkg parameter to separate settings by modules or features, keeping them well-organized.

Validation:
Validate the loaded preferences to ensure they meet the expected format or range.

Error Handling:
Handle cases where preferences cannot be loaded or saved due to missing files or permission issues.

Summary:
The PreferencesClass simplifies the management of settings or configurations in Lua applications. 
It supports organized storage using package names, fallback to default values, and seamless loading and saving operations. 
By using this class, developers can easily create configurable and user-friendly applications.



]]


if false then -- ensure that functions do not get defined

  ---@class PreferencesClass

  ---Loads preferences from a file. If a package name is provided, it will be
  ---used to construct the path. Otherwise, the file will be loaded from the
  ---profile directory.
  ---
  ---@example
  ---```lua
  ---preferences.load("my_package", "settings", { default_value = 1 })
  ---```
  ---
  ---@name load
  ---@param pkg string? - The package name. (Optional. Default is nil.)
  ---@param file string - The file name.
  ---@param defaults table - The default values.
  ---@return table # The loaded preferences.
  function preferences.load(pkg, file, defaults) end

  ---Saves preferences to a file. If a package name is provided, it will be
  ---used to construct the path. Otherwise, the file will be saved to the
  ---profile directory.
  ---
  ---@example
  ---```lua
  ---preferences.save("my_package", "settings", { default_value = 1 })
  --- ```
  ---
  ---@name save
  ---@param pkg string? - The package name. (Optional. Default is nil.)
  ---@param file string - The file name.
  ---@param prefs table - The preferences to save.
  function preferences.save(pkg, file, prefs) end

end