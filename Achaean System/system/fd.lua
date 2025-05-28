---@meta FdClass

------------------------------------------------------------------------------
-- FdClass
------------------------------------------------------------------------------

--[[

EXAMPLE:


The FdClass script provides a utility class for working with filesystem paths, files, and directories. This class is useful for developers who need to perform common file and directory operations programmatically, such as splitting paths, checking file existence, reading/writing files, managing directories, and validating paths.

Why Use This Script?

Path and File Manipulation:
Easily split, validate, and manipulate paths and file structures.
Handle file operations like reading, writing, and removing files.

Directory Management:
Validate, create, and manage directories programmatically.
Check if directories are empty or list their contents.

Cross-Platform Compatibility:
Normalize paths to use forward slashes for cross-platform support.

Error Handling:
Provides detailed return values to handle errors gracefully.


Examples of Usage:

1. Splitting a Path
Use dir_file to split a file path into its directory and file name:

local dir, file = fd.dir_file("path/to/file.txt")
print(dir)  -- Output: "path/to"
print(file) -- Output: "file.txt"

2. Check if a File Exists
Use file_exists to verify whether a file exists:

if fd.file_exists("path/to/existing_file.txt") then
  print("File exists!")
else
  print("File does not exist.")
end

3. Read and Write Files
Read the contents of a file:

local contents, err, code = fd.read_file("path/to/file.txt")
if contents then
  print(contents)
else
  print("Failed to read file:", err, code)
end


Write to a file:

local result = fd.write_file("path/to/file.txt", "Hello, world!", true)
if result then
  print("File written successfully.")
else
  print("Failed to write to file.")
end

4. Normalize a Path
Use fix_path to convert backslashes to forward slashes:

local fixed_path = fd.fix_path("path\\to\\file.txt")
print(fixed_path) -- Output: "path/to/file.txt"


5. Check if a Directory is Empty
Use dir_empty to verify whether a directory contains any files or subdirectories:


if fd.dir_empty("path/to/directory") then
  print("Directory is empty.")
else
  print("Directory is not empty.")
end

6. Create a Directory

Ensure a directory exists with assure_dir:

local result, err, code = fd.assure_dir("path/to/directory")
if result then
  print("Directory created successfully.")
else
  print("Failed to create directory:", err, code)
end

7. List Files in a Directory

Use get_dir to get all files in a directory:

local files = fd.get_dir("path/to/directory")
for _, file in ipairs(files) do
  print(file)
end


8. Remove Files or Directories

Remove a file:

local success, err = fd.rmfile("path/to/file.txt")
if success then
  print("File removed successfully.")
else
  print("Failed to remove file:", err)
end
Remove a directory:


local success, err = fd.rmdir("path/to/directory")
if success then
  print("Directory removed successfully.")
else
  print("Failed to remove directory:", err)
end

9. Validate Paths
Check if a path string is valid:

if fd.valid_path("path/to/file.txt") then
  print("Path is valid.")
else
  print("Invalid path.")
end
Check a table of paths:

if fd.valid_paths({"path/to/file1.txt", "path/to/dir"}) then
  print("All paths are valid.")
else
  print("Some paths are invalid.")
end


How to Use This Class

Load the Class:

Include or require this script in your Lua project.

Call Functions:
Use any of the provided functions like fd.file_exists, fd.read_file, or fd.get_dir to perform operations.

Handle Results:

Most functions return values indicating success, the result of the operation, and error messages or codes when applicable. Check these to handle errors gracefully.
Applications

File Handling:
Automate file creation, reading, and deletion tasks.

Directory Management:
Validate and manage directories in automation scripts or tools.

Cross-Platform Development:
Normalize paths to ensure compatibility across operating systems.

Asset Loading:
Use for dynamically loading and verifying game or application assets.

Scripting Utilities:
Build utilities or tools that require managing filesystem resources efficiently.


This class provides a robust and comprehensive set of tools for interacting with files and directories in Lua.




]]




if false then -- ensure that functions do not get defined

  ---@class FdClass

  --- Splits a path into a directory and file.
  ---
  --- If the directory is required and does not exist, nil is returned.
  ---
  ---@example
  ---```lua
  ---fd.dir_file("path/to/file.txt")
  ----- "path/to", "file.txt"
  ---```
  ---@name dir_file
  ---@param path string - The path to split.
  ---@param dir_required boolean? - Whether the directory is required (Optional. Default is false).
  ---@return string?,string? - A table with the directory and file, or nil if the path is invalid.
  function fd.dir_file(path, dir_required) end

  --- Gets the root of a path, as well as the directory and file.
  ---
  ---@example
  ---```lua
  ---fd.root_dir_file("c:\\test\\moo")
  ----- "c:", "test", "moo"
  ---```
  ---
  ---@name root_dir_file
  ---@param path string - The path to get the root of.
  ---@return string?,string?,string? - The root, directory, and file, or nil if the path is invalid.
  function fd.root_dir_file(path) end

  --- Checks if a file exists.
  ---
  ---@example
  ---```lua
  ---fd.file_exists("path/to/file/that/does/exist.txt")
  ----- true
  ---
  ---fd.file_exists("file/that/definitely/doesnt/exist.mp3")
  ----- false
  ---```
  ---@name file_exists
  ---@param path string - The path to check.
  ---@return boolean - Whether the file exists.
  function fd.file_exists(path) end

  --- Reads a file.
  ---
  ---@example
  ---```lua
  ---fd.read_file("path/to/file.txt")
  --- -- "contents of file"
  ---```
  ---@name read_file
  ---@param path string - The path to the file.
  ---@param binary boolean? - Whether the file is binary (default false).
  ---@return string|nil,string|nil,number|nil - The contents of the file, or nil, the error message, and the error code.
  function fd.read_file(path, binary) end

  --- Writes to a file.
  ---
  ---@example
  ---```lua
  ---fd.write_file("path/to/file.txt", "contents of file")
  --- -- "path/to/file.txt", "contents of file", nil
  ---```
  ---@name write_file
  ---@param path string - The path to the file.
  ---@param data string - The data to write to the file.
  ---@param overwrite boolean? - Whether to overwrite the file (default false).
  ---@param binary boolean? - Whether the file is binary (default false).
  ---@return string|table - The path to the file or nil, a table with the error and code, or the attributes of the file.
  function fd.write_file(path, data, overwrite, binary) end

  --- Fixes a path to use forward slashes.
  ---
  ---@example
  ---```lua
  ---fd.fix_path("path\\to\\file.txt")
  ----- "path/to/file.txt"
  ---
  ---fd.fix_path("c:\\test\\moo")
  ----- "c:/test/moo"
  ---```
  ---@name fix_path
  ---@param path string - The path to fix.
  ---@return string, number - The fixed path and the number of replacements made.
  function fd.fix_path(path) end

  --- Determines the path separator of a path.
  ---
  ---@example
  ---```lua
  ---fd.determine_path_separator("path\\to\\file.txt")
  ----- "\\"
  ---```
  ---@name determine_path_separator
  ---@param path string - The path to determine the separator of.
  ---@return string - The path separator.
  function fd.determine_path_separator(path) end

  --- Checks if a path is valid.
  ---
  ---@example
  ---```lua
  ---fd.valid_path_string("path/to/file.txt")
  ----- true
  ---```
  ---@name valid_path_string
  ---@param path string - The path to check.
  ---@return boolean - Whether the path is valid.
  function fd.valid_path_string(path) end

  --- Checks if a table of paths are valid.
  ---
  ---@example
  ---```lua
  ---fd.valid_path_table({"path/to/file.txt", "path/to/directory"})
  ----- true
  ---```
  ---@name valid_path_table
  ---@param paths table - The table of paths to check.
  ---@return boolean - Whether the table of paths is valid.
  function fd.valid_path_table(paths) end

  --- Checks if a path is valid.
  ---
  ---@example
  ---```lua
  ---fd.valid_path_table_or_string({"path/to/file.txt", "path/to/directory"})
  ----- true
  ---```
  ---@name valid_path_table_or_string
  ---@param path string|table - The path to check.
  ---@return boolean - Whether the path is valid.
  function fd.valid_path_table_or_string(path) end

  --- Checks if a path is valid.
  ---
  ---@example
  ---```lua
  ---fd.valid_path("path/to/file.txt")
  ----- true
  ---```
  ---@name valid_path
  ---@param path string - The path to check.
  ---@return boolean - Whether the path is valid.
  function fd.valid_path(path) end

  --- Checks if a table of paths are valid.
  ---
  ---@example
  ---```lua
  ---fd.valid_paths({"path/to/file.txt", "path/to/directory"})
  ----- true
  ---```
  ---@name valid_paths
  ---@param paths table - The table of paths to check.
  ---@return boolean - Whether the table of paths is valid.
  function fd.valid_paths(paths) end

  --- Ensures that a directory exists.
  ---@param path string - The path to the directory.
  ---@return table|nil, string|nil, number|nil - A table of created directories, the error message, and the error code.
  ---@example
  ---```lua
  ---fd.assure_dir("path/to/directory")
  ---```
  function fd.assure_dir(path) end


  --- Determines the root of a path.
  ---
  ---@example
  ---```lua
  ---fd.determine_root("c:\\test\\moo")
  --- -- "c:"
  ---```
  ---@name determine_root
  ---@param path string - The path to determine the root of.
  ---@return string? - The root of the path, or nil if the path is invalid.
  function fd.determine_root(path) end


  --- Removes a file.
  ---
  ---@example
  ---```lua
  ---fd.rmfile("path/to/file.txt")
  --- -- true
  ---```
  ---@name rmfile
  ---@param path string - The path to the file.
  ---@return boolean?, string? - Whether the file was removed, or nil and the error message.
  function fd.rmfile(path) end

  --- Removes a directory.
  ---
  ---@example
  ---```lua
  ---fd.rmdir("path/to/directory")
  --- -- true
  ---```
  ---@name rmdir
  ---@param path string - The path to the directory.
  ---@return boolean?, string? - Whether the directory was removed, or nil and the error message.
  function fd.rmdir(path) end

  --- Checks if a directory is empty.
  ---
  ---@example
  ---```lua
  ---fd.dir_empty("/path/to/directory")
  ----- true
  ---```
  ---@name dir_empty
  ---@param path string - The path to the directory.
  ---@return boolean - Whether the directory is empty.
  function fd.dir_empty(path) end

  --- Gets the files in a directory.
  ---
  ---@example
  ---```lua
  ---fd.get_dir("/path/to/directory")
      --- -- {"file1", "file2", "file3"}
  ---```
  ---@name get_dir
  ---@param path string - The path to the directory.
  ---@param include_dots boolean? - Whether to include the "." and ".." directories (default false).
  ---@return table - A table of files in the directory.
  function fd.get_dir(path, include_dots) end

  --- Creates a temporary directory.
  ---
  ---@return string?, string?, number? - The path to the temporary directory, the error message, and the error code.
  ---@example
  ---```lua
  ---fd.temp_dir()
  --- -- "path/to/temporary/directory", nil, nil
  ---```
  ---@name temp_dir
  function fd.temp_dir() end
end