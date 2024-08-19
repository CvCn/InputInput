-- 使用 LibStub 创建一个新库
local MAJOR, MINOR = "inputinput-jieba-prob_start", 1
local p, oldVersion = LibStub:NewLibrary(MAJOR, MINOR)

-- 检查是否成功创建了新版本的库
if not p then
    return
end
p.prob_start = { ["B"] = -0.26268660809250016, ["E"] = -3.14e+100, ["M"] = -3.14e+100, ["S"] = -1.4652633398537678 }
