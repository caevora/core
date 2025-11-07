
---@meta Glass

------------------------------------------------------------------------------
-- Glass
------------------------------------------------------------------------------

--[[

The Glass class provides a way to define and register new classes within the Glu framework, allowing developers to set up inheritance, dependencies, and custom behavior for their classes. Here's a guide on how one would use the Glass class effectively:

How to Use the Glass Class

1. Registering a Class
To create and register a new class, use the Glass.register function. Pass a table of options to define the class's structure, behavior, and dependencies.


local MyClass = Glass.register({
  class_name = "MyClass",
  name = "my_class",
  inherit_from = "base_class", -- Optional: Name of the parent class
  dependencies = {"dependency_class_1", "dependency_class_2"}, -- Optional: Dependencies
  inherit = {
    some_function = function(self, arg1)
      print("Inherited function called with:", arg1)
    end
  }, -- Optional: Functions to inherit
  setup = function(self, arg1, arg2)
    print("Setting up MyClass with:", arg1, arg2)
  end, -- Optional: Called when the class is initialized
  valid = function(self)
    return true -- Optional: Return whether the class is valid
  end
})


2. Explanation of Parameters

The Glass.register function accepts a table with the following fields:

Field					Type						Description
class_name				string						The name of the class, typically in the format NameClass.
name					string						A unique identifier for the class, usually in lowercase.
inherit_from			string?						Optional. Specifies the name of a parent class to inherit from.
dependencies			string[]					Optional. Specifies the names of other classes this class depends on.
inherit	table			<string, function>			Optional. A table of functions to inherit, with function_name = function.
setup					function					Optional. A setup function called during initialization of the class.
valid					function					Optional. A function that returns whether the class is valid.


3. Example Use Cases

a) Basic Class Registration
A simple class without inheritance or dependencies:

local MySimpleClass = Glass.register({
  class_name = "SimpleClass",
  name = "simple_class",
  setup = function(self)
    print("Simple class initialized.")
  end
})

b) Class with Inheritance
A class that inherits methods from a base class:

local DerivedClass = Glass.register({
  class_name = "DerivedClass",
  name = "derived_class",
  inherit_from = "base_class",
  inherit = {
    say_hello = function(self)
      print("Hello from DerivedClass!")
    end
  }
})

c) Class with Dependencies
A class that depends on other registered classes:

local DependentClass = Glass.register({
  class_name = "DependentClass",
  name = "dependent_class",
  dependencies = {"utility_class", "helper_class"},
  setup = function(self)
    print("Setting up a dependent class.")
  end
})

d) Custom Validation
A class with custom validation logic:

local ValidatedClass = Glass.register({
  class_name = "ValidatedClass",
  name = "validated_class",
  valid = function(self)
    return true -- Replace with custom validation logic
  end
})

4. Calling Methods on the Class
Once a class is registered, you can create instances or directly call the methods defined during registration:

local instance = MyClass.new() -- Assuming `.new` is defined or inherited
instance.some_function("argument")


Applications:
Object-Oriented Programming (OOP):

Use Glass.register to define reusable and inheritable classes in Lua.

Modular Development:
Build complex systems with clear dependencies and modular components.

Dynamic Class Behavior:
Extend functionality dynamically by inheriting or overriding methods.

Validation and Setup:
Ensure that classes are correctly initialized and validated using setup and valid.

Best Practices:

Avoid Circular Dependencies:
Ensure that your class dependencies do not create circular references.

Leverage Inheritance:
Use the inherit_from and inherit fields to avoid code duplication.

Use Validation:
Implement the valid function to confirm that a class is initialized properly.

Organize Classes:
Store class definitions in a structured format or file hierarchy for better maintainability.

Conclusion:

The Glass class provides a flexible way to define, register, and manage classes within the Glu framework. Its support for inheritance, 
dependencies, and validation makes it a powerful tool for building modular and extensible systems. 
By using Glass.register, developers can streamline their object-oriented programming and maintain clean, organized code.




]]


if false then -- ensure that functions do not get defined

  ---@class Glass

  ---Register a class with the Glu framework.
  ---
  ---The following options are available:
  ---
  ---* `class_name` `string` - The name of the class, usually in the form of `NameClass`.
  ---* `name` `string` - The name of the class, usually in the form of `name`.
  ---* `inherit_from` `string?` - The class to inherit from, in the form of the class's `name`.
  ---* `dependencies` `string[]` - The dependencies of the class, in the form of the class's `name` .
  ---* `inherit` `table<string, function>` - The functions to inherit, in the form of `function_name = function(self, ...) end`.
  ---* `setup` `function` - The setup function, in the form of `function(self, ...) end`.
  ---* `valid` `function` - The valid function, in the form of `function(self, ...) end`.
  ---
  ---@name register
  ---@param class_opts table - The class options.
  ---@return Glass # The class.
  function Glass.register(class_opts) end

end
