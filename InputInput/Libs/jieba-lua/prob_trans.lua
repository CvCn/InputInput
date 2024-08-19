-- 使用 LibStub 创建一个新库
local MAJOR, MINOR = "inputinput-jieba-prob_trans", 1
local p, oldVersion = LibStub:NewLibrary(MAJOR, MINOR)

-- 检查是否成功创建了新版本的库
if not p then
    return
end

p.prob_trans = {
	["B"] = { ["E"] = -0.510825623765990, ["M"] = -0.916290731874155 },
	["E"] = { ["B"] = -0.5897149736854513, ["S"] = -0.8085250474669937 },
	["M"] = { ["E"] = -0.33344856811948514, ["M"] = -1.2603623820268226 },
	["S"] = { ["B"] = -0.7211965654669841, ["S"] = -0.6658631448798212 },
}
