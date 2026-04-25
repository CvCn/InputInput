local Name, AddOnesTable = ...
_G['INPUTINPUT_LIBRARIES_EN'] = AddOnesTable

-- 使用 LibStub 创建一个新库
local MAJOR, MINOR = "INPUTINPUT_LIBRARIES_EN", 1
local M, oldVersion = LibStub:NewLibrary(MAJOR, MINOR)

-- 检查是否成功创建了新版本的库
if not M then
    return
end
local W = {}
W.en_dict1 = LibStub("inputinput-en_dict1").en_dict1

local U, jieba

local loadGlossary = false
function M:load()
    if not loadGlossary and INPUTINPUT then
        U = INPUTINPUT[3]
        jieba = LibStub("inputinput-jieba")

        for _, dict in ipairs(W.en_dict1) do
            local firstChar = strlower(jieba.sub(dict, 1, 1))
            if W.en_dict1[firstChar] == nil then W.en_dict1[firstChar] = {} end
            table.insert(W.en_dict1[firstChar], dict)
        end
        loadGlossary = true
    end
end

function M:searchWords(pattp, _tip)
    if W.en_dict1 then
        local count = 0
        local en_patt = strlower(pattp[#pattp])
        local treeKey = jieba.sub(en_patt, 1, 1)
        local tree = W.en_dict1[treeKey] or {}
        for _, v in ipairs(tree) do
            if count < 2 then
                local word = v
                local start, _end = strfind(strlower(word), en_patt, 1, true)
                if start and start > 0 and _end ~= #word then
                    U:InsertNoRepeat(_tip, strsub(word, _end + 1))
                    count = count + 1
                end
            else
                break
            end
        end
    end
end
