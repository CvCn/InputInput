local Name, AddOnesTable = ...

local Widget = {}
local Module = {}
local Utils = {}
local Data = {}
local Locale = {}
local API = {}
local LOG = {}
local Environment = 'PRO' -- DEV PRO

Widget.defaultFontName = GameFontHighlightSmall:GetFont()
AddOnesTable[1] = Widget
Widget.N = Name
Widget.colorName = '|cff409EFF|cffffff00i|rnput|cffffff00i|rnput|r'
AddOnesTable[2] = Module
AddOnesTable[3] = Utils
AddOnesTable[4] = Data
AddOnesTable[5] = _G
AddOnesTable[6] = Locale
AddOnesTable[7] = Environment
AddOnesTable[8] = API
AddOnesTable[9] = LOG
AddOnesTable.N = Name
_G['INPUTINPUT'] = AddOnesTable