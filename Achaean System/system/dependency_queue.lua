---@meta DependencyQueueClass

------------------------------------------------------------------------------
-- DependencyQueueClass
------------------------------------------------------------------------------

--[[

EXAMPLE:

The DependencyQueueClass is designed to manage and sequentially execute the installation of a list of dependencies, ensuring that dependencies are installed in the correct order while providing feedback on success or failure. It's particularly useful in projects that require loading external modules, scripts, or assets in a structured and error-handling manner.

Why Use This Script?

Dependency Management:
Ensures that multiple dependencies are installed in a specific order.
Handles errors gracefully with callbacks.

Automation:
Streamlines the installation process for projects that require multiple external packages or scripts.


Error Handling:
Provides detailed feedback on success or failure, allowing you to debug issues effectively.


Examples of Usage:



1. Basic Usage

local queue = DependencyQueueClass.new_dependency_queue({
  { name = "package_1", url = "https://example.com/package_1" },
  { name = "package_2", url = "https://example.com/package_2" },
}, function(success, error)
  if success then
    print("All dependencies installed successfully.")
  else
    print("Failed to install dependencies: " .. error)
  end
end)

-- Start the queue
queue:start()



2. Custom Callback
If you want to perform specific actions based on success or failure:


local function customCallback(success, error)
  if success then
    print("Dependencies are ready. Proceeding with initialization.")
  else
    print("An error occurred while installing dependencies: " .. error)
  end
end

local queue = DependencyQueueClass.new_dependency_queue({
  { name = "lib_A", url = "https://example.com/lib_A" },
  { name = "lib_B", url = "https://example.com/lib_B" },
}, customCallback)

queue:start()


3. Alternative Syntax
If you use a global utility object like glu:


local queue = glu.dependency_queue({
  { name = "module_1", url = "https://example.com/module_1" },
  { name = "module_2", url = "https://example.com/module_2" },
}, function(success, error)
  if success then
    print("Modules installed successfully.")
  else
    print("Module installation failed: " .. error)
  end
end)

queue:start()

How to Use
Define Dependencies:

Provide a list of dependencies as a table. Each dependency must have:
name: The identifier for the dependency.

url: The location to fetch the dependency from.

Callback Function:

Define a callback function that takes two parameters:
success: Indicates whether the operation was successful (true or false).
error: Contains an error message if the operation failed.


Start the Queue:
Call the start() method on the dependency queue object to begin processing.
Applications


Game Development:
Load assets, scripts, or libraries in a sequence.


Web Projects:
Fetch and install required JavaScript libraries or CSS frameworks.


Automation Scripts:
Manage the installation of plugins or modules in automation workflows.


Software Installers:
Automate the download and installation of external tools or dependencies.

Extensions

Retry Logic:
Add functionality to retry failed installations a specified number of times.

Dependency Resolution:
Add support for resolving interdependencies among packages.

Progress Feedback:
Implement a progress indicator to show which dependencies are currently being installed.

This class is a robust and reusable tool for managing complex dependency installation workflows in a structured and error-handled way.


]]


if false then -- ensure that functions do not get defined
  ---@class DependencyQueueClass

  --- Instantiates a new dependency queue for use with DependencyClass. When
  --- the queue is executed, it will install all the dependencies in the order
  --- they are given.
  ---
  ---@example
  ---```lua
  --- local queue = DependencyQueueClass.new_dependency_queue({
  ---   { name = "package_1", url = "https://example.com/package_1" },
  ---   { name = "package_2", url = "https://example.com/package_2" },
  --- }, function(success, error)
  ---   if success then
  ---     cecho("All dependencies installed successfully.\n")
  ---   else
  ---     cecho(f "Failed to install dependencies: {error}\n")
  ---   end
  --- end)
  ---
  ----- Alternate syntax
  ---
  --- local queue = glu.dependency_queue(...)
  ---```
  ---
  ---@name new_dependency_queue
  ---@param packages table - A table of dependency objects, each with a `name` and `url` property.
  ---@param cb function - A callback function that will be called with two arguments: `success` and `error`.
  function dependency_queue.new_dependency_queue(packages, cb) end

  --- Starts the dependency queue after it has been created. The callback will
  --- be called once all the dependencies have been installed or if there was an
  --- error.
  ---
  ---@example
  ---```lua
  ---local queue = glu.dependency_queue.new_dependency_queue(...)
  ---queue:start()
  ---```
  ---
  ---@name start
  function dependency_queue.start() end
end