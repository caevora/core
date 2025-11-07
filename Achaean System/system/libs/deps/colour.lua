---@meta ColourClass

------------------------------------------------------------------------------
-- ColourClass
------------------------------------------------------------------------------


--[[

EXAMPLE:

This ColourClass script provides a variety of color-related utilities that can be used to manipulate and analyze colors in Lua. 
Here's an overview of its use cases, examples, and how it can be applied effectively:

Why Use This Script?


Color Manipulation:

Modify colors for UI, graphics, or visualization needs.
Interpolate colors for smooth transitions or animations.

Color Analysis:
Determine color properties like luminance or contrast.
Find complementary, analogous, or monochromatic colors.

Game Development:
Create dynamic color palettes for environmental effects.
Use random shades or generate color harmonies for characters or objects.

Data Visualization:
Map values to color gradients using interpolation.
Generate visually distinct palettes using analogous or split-complement colors.

Web or UI Design:
Convert between RGB, HSL, and hex formats for consistency in design.
Adjust colors for accessibility with contrast ratio calculations.

Examples of Usage:

1. Interpolate Between Two Colors
Smoothly transition between two colors based on a factor.

local color1 = {255, 0, 0} -- Red
local color2 = {0, 0, 255} -- Blue
local interpolatedColor = colour.interpolate(color1, color2, 0.5)
print(interpolatedColor) -- {127, 0, 127} (Purple)


2. Convert RGB to Hex
Convert an RGB color into its hexadecimal string representation.

local hexColor = colour.to_hex({255, 255, 255})
print(hexColor) -- "#ffffff"


3. Adjust Color Saturation
Change the saturation of an RGB color.

local adjustedColor = colour.adjust_saturation({100, 150, 200}, 0.8)
print(adjustedColor) -- Adjusted RGB color


4. Generate Complementary Color
Find the complementary color for a given RGB value.

local complementaryColor = colour.complementary({100, 150, 200})
print(complementaryColor) -- Complementary color


5. Determine If a Color is Light
Check if a color is considered "light" based on luminance.

local isLight = colour.is_light({255, 255, 255})
print(isLight) -- true


6. Generate Random Color
Create a random RGB color.

local randomColor = colour.random()
print(randomColor) -- e.g., {123, 45, 67}

7. Lighten or Darken a Color
Make a color lighter or darker.

local lighterColor = colour.lighten({100, 100, 100}, 50)
print(lighterColor) -- {150, 150, 150}

local darkerColor = colour.darken({100, 100, 100}, 50)
print(darkerColor) -- {50, 50, 50}

8. Convert Between RGB and HSL
Switch between RGB and HSL formats.

local hslColor = colour.rgb_to_hsl({255, 0, 0})
print(hslColor) -- {0, 100, 50} (Hue, Saturation, Lightness)

local rgbColor = colour.hsl_to_rgb({0, 100, 50})
print(rgbColor) -- {255, 0, 0}


9. Generate Analogous Colors
Create a set of colors similar to the base color.

local analogousColors = colour.analogous({100, 100, 100}, 30)
print(analogousColors) -- A table of analogous colors


10. Calculate Contrast Ratio
Measure the contrast ratio between two colors for accessibility.

local contrastRatio = colour.contrast_ratio({255, 255, 255}, {0, 0, 0})
print(contrastRatio) -- 21.0 (Maximum contrast)


Real-World Applications
Game Development:

Interpolate colors for smooth animations (e.g., day-night transitions).
Generate dynamic lighting effects using lighten or darken.

Web Design:
Ensure text readability using contrast_ratio.
Create harmonious palettes with triad, analogous, or monochrome.

Data Visualization:
Map data values to color gradients using interpolate.
Highlight key points with contrasting colors.

Graphics Programming:
Convert between color formats for shader programs.
Use random_shade to create subtle variations in textures.

Accessibility:
Adjust color schemes for better readability.
Test color contrasts to meet accessibility guidelines.

How to Include This Script

Save the file as colour.lua in your Lua project directory.
Require the file where you want to use it:


require("colour")

Use the functions as demonstrated above.
This library simplifies complex color operations and can be invaluable in projects where visual design or color manipulation is important.


]]



if false then -- ensure that functions do not get defined
  ---@class ColourClass

  ---Interpolates between two RGB colours based on a step value. Functionally,
  ---it takes two colours and returns a third colour somewhere between the
  ---two colours, based on the step value. Generally used to fade between two
  ---colours. The step value is the current transition percentage as a whole
  ---number between the two colours, with 0 being the first colour and 100 being
  ---the second colour.
  ---
  ---Available interpolation methods are:
  ---- `linear`
  ---- `smooth` (default)
  ---- `smoother`
  ---- `ease_in`
  ---- `ease_out`
  ---
  ---@example
  ---```lua
  ---colour.interpolate({255, 0, 0}, {0, 0, 255}, 50)
  ----- {127, 0, 127}
  ---```
  ---
  ---@name interpolate
  ---@param rgb1 table - The first RGB colour as a table with three elements: red, green, and blue.
  ---@param rgb2 table - The second RGB colour as a table with three elements: red, green, and blue.
  ---@param factor number - The step value between 0 and 1.
  ---@param method string? - The interpolation method to use.
  ---@return table # The interpolated RGB colour as a table with three elements: red, green, and blue.
  function colour.interpolate(rgb1, rgb2, factor, method) end

  --- Converts an RGB colour to an HSL colour.
  ---
  ---@example
  ---```lua
  ---colour.rgb_to_hsl({255, 255, 255})
  ----- {0, 0, 100}
  ---```
  ---
  ---@name rgb_to_hsl
  ---@param rgb table - The RGB colour as a table with three elements: red, green, and blue.
  ---@return table # The HSL colour as a table with three elements: hue, saturation, and lightness.
  function colour.rgb_to_hsl(rgb) end

  ---Converts an RGB colour to a hex string. Whether the hex string includes a
  ---background colour depends on the `include_background` parameter. This
  ---parameter defaults to false.
  ---@example
  ---```lua
  ---colour.to_hex({255, 255, 255})
  ----- "#ffffff"
  ---```
  ---
  ---@name to_hex
  ---@param rgb table - The RGB colour as a table with three elements: red, green, and blue.
  ---@param include_background boolean? - Whether to include a background colour.
  ---@return string # The hex string.
  function colour.to_hex(rgb, include_background) end

  ---Converts an HSL colour to an RGB colour.
  ---
  ---@example
  ---```lua
  ---colour.hsl_to_rgb({180, 50, 50})
  ----- {127, 127, 127}
  ---```
  ---
  ---@name hsl_to_rgb
  ---@param hsl table - The HSL colour as a table with three elements: hue, saturation, and lightness.
  ---@return table # The RGB colour as a table with three elements: red, green, and blue.
  function colour.hsl_to_rgb(hsl) end

  ---Determines if a colour is a light colour. The colour is considered light
  ---if the luminance is greater than 0.5.
  ---
  ---@example
  ---```lua
  --- colour.is_light({255, 255, 255})
  --- -- true
  --- ```
  ---
  ---@name is_light
  ---@param rgb table - The RGB colour as a table with three elements: red, green, and blue.
  ---@return boolean # True if the colour is light, false otherwise.
  function colour.is_light(rgb) end

  ---Adjusts the saturation of a colour by a given factor.
  ---
  ---@example
  ---```lua
  ---colour.adjust_saturation({35, 50, 100}, 0.5)
  ----- {48, 55, 80}
  ---```
  ---
  ---@name adjust_saturation
  ---@param rgb table - The RGB colour as a table with three elements: red, green, and blue.
  ---@param factor number - A factor between 0 (fully desaturated) and 1 (fully saturated).
  ---@return table # The adjusted RGB colour as a table with three elements: red, green, and blue.
  function colour.adjust_saturation(rgb, factor) end

  ---Lightens or darkens a colour by a given amount.
  ---
  ---The `amount` parameter defaults to 30. The `lighten` parameter defaults
  ---to true.
  ---
  ---@example
  ---```lua
  ---colour.adjust_colour({100,100,100},50, true)
  ----- {150, 150, 150}
  ---```
  ---
  ---@name adjust_colour
  ---@param rgb table - The RGB colour as a table with three elements: red, green, and blue.
  ---@param amount number? - The amount to adjust the colour by.
  ---@param lighten boolean? - Whether to lighten (true) or darken (false) the colour.
  ---@return table # The adjusted RGB colour as a table with three elements: red, green, and blue.
  function colour.adjust_colour(rgb, amount, lighten) end

  ---Lightens a colour by a given amount.
  ---
  ---The `amount` parameter defaults to 30.
  ---
  ---@example
  ---```lua
  ---colour.lighten({100,100,100},50)
  ----- {150, 150, 150}
  ---```
  ---
  ---@name lighten
  ---@param rgb table - The RGB colour as a table with three elements: red, green, and blue.
  ---@param amount number? - The amount to lighten the colour by.
  ---@return table # The lightened RGB colour as a table with three elements: red, green, and blue.
  function colour.lighten(rgb, amount) end

  --- Darkens a colour by a given amount.
  ---
  ---@example
  ---```lua
  ---colour.darken({100,100,100},50)
  --- -- {50, 50, 50}
  --- ```
  ---
  ---@name darken
  ---@param rgb table - The RGB colour as a table with three elements: red, green, and blue.
  ---@param amount number? - The amount to darken the colour by.
  ---@return table # The darkened RGB colour as a table with three elements: red, green, and blue.
  function colour.darken(rgb, amount) end

  ---Lightens or darkens the first colour by a given amount based only a
  ---comparison with the second colour. If the colours are already contrasting,
  ---the original colour is returned.
  ---
  ---The `amount` parameter defaults to 30.
  ---
  ---@example
  ---```lua
  ---colour.lighten_or_darken({100,100,100}, {255,255,255}, 50)
  --- -- {100, 100, 100}
  ---```
  ---
  ---@name lighten_or_darken
  ---@param rgb_colour table - The first RGB colour as a table with three elements: red, green, and blue.
  ---@param rgb_compare table - The second RGB colour as a table with three elements: red, green, and blue.
  ---@param amount number? - The amount to darken the colour by.
  ---@return table # The darkened RGB colour as a table with three elements: red, green, and blue.
  function colour.lighten_or_darken(rgb_colour, rgb_compare, amount) end

  ---Returns the complementary colour of a given colour.
  ---
  ---@example
  ---```lua
  ---colour.complementary({150,150,150})
  --- -- {105, 105, 105}
  ---```
  ---
  ---@name complementary
  ---@param rgb table - The RGB colour as a table with three elements: red, green, and blue.
  ---@return table # The complementary RGB colour as a table with three elements: red, green, and blue.
  function colour.complementary(rgb) end

  --- Converts a colour to its grayscale equivalent.
  ---
  ---@example
  ---```lua
  ---colour.grayscale({35,50,100})
  --- -- {62, 62, 62}
  ---```
  ---
  ---@name grayscale
  ---@param rgb table - The RGB colour as a table with three elements: red, green, and blue.
  ---@return table # The grayscale RGB colour as a table with three elements: red, green, and blue.
  function colour.grayscale(rgb) end

  --- Adjusts the saturation of a colour by a given factor.
  ---
  --- The `factor` parameter defaults to 0.5.
  ---
  ---@example
  ---```lua
  ---colour.adjust_saturation({35,50,100}, 0.5)
  --- -- {48, 55, 80}
  ---```
  ---
  ---@name adjust_saturation
  ---@param rgb table - The RGB colour as a table with three elements: red, green, and blue.
  ---@param factor number? - A factor between 0 (fully desaturated) and 1 (fully saturated).
  ---@return table # The adjusted RGB colour as a table with three elements: red, green, and blue.
  function colour.adjust_saturation(rgb, factor) end

  --- Generates a random RGB colour.
  ---
  ---@example
  ---```lua
  ---colour.random()
  --- -- { 123, 45, 67 }
  ---```
  ---
  ---@name random
  ---@return table # A random RGB colour as a table with three elements: red, green, and blue.
  function colour.random() end

  --- Generates a random shade of a given colour within a range.
  ---
  ---The `range` parameter defaults to 50.
  ---
  ---@example
  ---```lua
  ---colour.random_shade({100,100,100}, 50)
  --- -- {150, 150, 150}
  ---```
  ---
  ---@name random_shade
  ---@param rgb table - The RGB colour as a table with three elements: red, green, and blue.
  ---@param range number? - The range to adjust the colour by (e.g., 50 means +/- 50 for R, G, and B).
  ---@return table # A random RGB colour that is a shade of the given colour.
  function colour.random_shade(rgb, range) end

  --- Generates the triad colours of a given colour. Does not return the
  --- original colour, but two returned colours that are considered tritones of
  --- the original colour.
  ---
  ---@example
  ---```lua
  ---colour.triad({100,100,100})
  ----- { { 15, 204, 204 }, { 100, 204, 204 } }
  ---```
  ---
  ---@name triad
  ---@param rgb table - The RGB colour as a table with three elements: red, green, and blue.
  ---@return table # A table of RGB colours that are the triad of the given colour.
  function colour.triad(rgb) end

  --- Generates the analogous colours of a given colour.
  --- The analogous colours are generated by rotating the hue of the given
  --- colour by a given angle.
  ---
  ---The `angle` parameter defaults to 30.
  ---
  ---@example
  ---```lua
  ---colour.analogous({100,100,100})
  --- -- { { 70, 100, 100 }, { 100, 100, 100 }, { 130, 100, 100 } }
  ---```
  ---
  ---@name analogous
  ---@param rgb table - The RGB colour as a table with three elements: red, green, and blue.
  ---@param angle number? - The angle to separate the analogous colours by.
  ---@return table # A table of RGB colours that are analogous to the given colour.
  function colour.analogous(rgb, angle) end

  --- Generates the split complement colours of a given colour.
  ---
  ---The `angle` parameter defaults to 30.
  ---
  ---@example
  ---```lua
  ---colour.split_complement({100,100,100})
  --- -- { { 15, 204, 204 }, { 100, 204, 204 } }
  ---```
  ---
  ---@name split_complement
  ---@param rgb table - The RGB colour as a table with three elements: red, green, and blue.
  ---@param angle number? - The angle to separate the split complement colours by.
  ---@return table # A table of RGB colours that are the split complement of the given colour.
  function colour.split_complement(rgb, angle) end

  --- Generates a series of monochromatic colours based on a given colour.
  ---
  ---The `steps` parameter defaults to 5.
  ---
  ---@example
  ---```lua
  --- colour.monochrome({ 100, 100, 100 })
  --- -- { { 100, 100, 100 }, { 100, 100, 100 }, { 100, 100, 100 } }
  ---```
  ---
  ---@name monochrome
  ---@param rgb table - The RGB colour as a table with three elements: red, green, and blue.
  ---@param steps number? - The number of variations to generate.
  ---@return table # A table of RGB colours that are monochromatic variations of the given colour.
  function colour.monochrome(rgb, steps) end

  --- Generates the tetrad colours of a given colour.
  ---
  ---@example
  ---```lua
  ---colour.tetrad({100,100,100})
  ----- { { 100, 100, 100 }, { 100, 100, 100 }, { 100, 100, 100 }, { 100, 100, 100 } }
  ---```
  ---
  ---@name tetrad
  ---@param rgb table - The RGB colour as a table with three elements: red, green, and blue.
  ---@return table # A table of RGB colours that are the tetrad of the given colour.
  function colour.tetrad(rgb) end

  --- Calculates the contrast ratio between two colours.
  ---
  ---@example
  ---```lua
  ---colour.contrast_ratio({100,100,100}, {0,0,0})
  --- -- 12.0
  ---```
  ---
  ---@name contrast_ratio
  ---@param rgb1 table - The first RGB colour as a table with three elements: red, green, and blue.
  ---@param rgb2 table - The second RGB colour as a table with three elements: red, green, and blue.
  ---@return number # The contrast ratio between the two colours.
  function colour.contrast_ratio(rgb1, rgb2) end

  --- Calculates the contrasting colour based on the luminance of a given colour.
  ---
  ---@example
  ---```lua
  ---colour.contrast({100,100,100})
  --- -- {0, 0, 0}
  ---```
  ---
  ---@name contrast
  ---@param rgb table - The RGB colour as a table with three elements: red, green, and blue.
  ---@return table # The contrasting colour as a table with three elements: red, green, and blue.
  function colour.contrast(rgb) end

end