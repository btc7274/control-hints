local Settings = {}
local ControlHints = script.Parent
local IconSets = ControlHints.IconSets
local DisplayStyles = ControlHints.DisplayStyles


-- Select a Control Hints icon set
Settings.ICON_SET = require(IconSets.Kenney)


-- Select a Control Hints display style
Settings.DISPLAY_STYLE = DisplayStyles.Classic


-- Toggle detailed non-critical warnings
Settings.DEBUG = false


-- Responsive icons provide visual feedback by switching to filled/active icons while an InputAction is Pressed
--   • Selected icon set must include separate tables with a '_pressed' suffix
Settings.ENABLE_RESPONSIVE = true


-- Dynamic scaling makes it easier to read button hints for console users who are playing from a distance
--   • Example: 1× font/icon size at 1080px width → 1.4× font/icon size at 1920px width)
--   • Only active for gamepad (console) users
--   • Tweak settings below to ensure your display style scales appropriately
Settings.ENABLE_DYNAMIC_SCALING = true
Settings.MIN_SCREEN_WIDTH = 1080 -- When screen width > MIN_SCREEN_WIDTH, font/icon size begins scaling
Settings.MAX_SCREEN_WIDTH = 1920 -- When screen width > MAX_SCREEN_WIDTH, font/icon size stops scaling
Settings.BASE_FONT_SIZE = 16 -- ActionText font size when screen width ≤ MIN_SCREEN_WIDTH
Settings.BASE_ICON_SIZE = 30 -- IconImage size when screen width ≤ MIN_SCREEN_WIDTH
Settings.MAX_SCALE_FACTOR = 1.4 -- Final font/icon scale reached when screen width ≥ MAX_SCREEN_WIDTH


-- Tweak to change the LayoutOrder increment for icons
Settings.INCREMENT = 1






-- Error handling (ignore)
assert(typeof(Settings.ICON_SET) == "table", "Settings.ICON_SET (icon set table) is missing!")
assert(typeof(Settings.DISPLAY_STYLE) == "Instance" and Settings.DISPLAY_STYLE:IsA("ScreenGui"), "Settings.DISPLAY_STYLE (ScreenGui) is missing!")
assert(typeof(Settings.INCREMENT) == "number", "Settings.INCREMENT (number) is missing!")
assert(typeof(Settings.DEBUG) == "boolean", "Settings.DEBUG (boolean) is missing!")
assert(typeof(Settings.ENABLE_RESPONSIVE) == "boolean", "Settings.ENABLE_RESPONSIVE (boolean) is missing!")
assert(typeof(Settings.ENABLE_DYNAMIC_SCALING) == "boolean", "Settings.ENABLE_DYNAMIC_SCALING (boolean) is missing!")
if Settings.ENABLE_DYNAMIC_SCALING then
	assert(typeof(Settings.BASE_FONT_SIZE) == "number", "[Dynamic Scaling] Settings.BASE_FONT_SIZE (number) is missing!")
	assert(typeof(Settings.BASE_ICON_SIZE) == "number", "[Dynamic Scaling] Settings.BASE_ICON_SIZE (number) is missing!")
	assert(typeof(Settings.MIN_SCREEN_WIDTH) == "number", "[Dynamic Scaling] Settings.MIN_SCREEN_WIDTH (number) is missing!")
	assert(typeof(Settings.MAX_SCREEN_WIDTH) == "number", "[Dynamic Scaling] Settings.MAX_SCREEN_WIDTH (number) is missing!")
	assert(typeof(Settings.MAX_SCALE_FACTOR) == "number", "[Dynamic Scaling] Settings.MAX_SCALE_FACTOR (number) is missing!")
end

return Settings