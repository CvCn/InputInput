local Name, AddOnesTable = ...
_G['INPUTINPUT_LIBRARIES_ZH'] = AddOnesTable

-- 使用 LibStub 创建一个新库
local MAJOR, MINOR = "INPUTINPUT_LIBRARIES_ZH", 1
local M, oldVersion = LibStub:NewLibrary(MAJOR, MINOR)

-- 检查是否成功创建了新版本的库
if not M then
    return
end
local W = {}
W.dict1 = LibStub("inputinput-simplified1").dict
W.dict2 = LibStub("inputinput-simplified2").dict
W.dict3 = LibStub("inputinput-simplified3").dict
W.dict4 = LibStub("inputinput-simplified4").dict
W.dict5 = LibStub("inputinput-traditional1").dict
W.dict6 = LibStub("inputinput-traditional2").dict
W.dict7 = LibStub("inputinput-traditional3").dict


local jieba, U

local loadGlossary = false

function M:load(locale)
    locale = locale or "zhCN"
    if not loadGlossary and INPUTINPUT then
        -- 魔兽词库
        if locale == "zhCN" then
            W.words = LibStub("inputinput-words").words
        else
            W.words = LibStub("inputinput-words_traditional").words
        end


        jieba = LibStub("inputinput-jieba")
        U = INPUTINPUT[3]
        W.dictWord = {}

        local function addDictWord(word, freq, _locale)
            if locale ~= _locale then return end
            if word == nil or word == '' then return end
            local firstChar = strlower(jieba.sub(word, 1, 1))
            if W.dictWord[firstChar] == nil then W.dictWord[firstChar] = {} end
            W.dictWord[firstChar][word] = freq
        end

        local total = 60101967 + 78989790

        local logtotal = math.log(total)

        for i, v in pairs(W.dict1) do
            W.dict1[i] = math.log(v) - logtotal
            addDictWord(i, v, "zhCN")
        end
        for i, v in pairs(W.dict2) do
            W.dict2[i] = math.log(v) - logtotal
            addDictWord(i, v, "zhCN")
        end
        for i, v in pairs(W.dict3) do
            W.dict3[i] = math.log(v) - logtotal
            addDictWord(i, v, "zhCN")
        end
        for i, v in pairs(W.dict4) do
            W.dict4[i] = math.log(v) - logtotal
            addDictWord(i, v, "zhCN")
        end
        for i, v in pairs(W.dict5) do
            W.dict5[i] = math.log(v) - logtotal
            addDictWord(i, v, "zhTW")
        end
        for i, v in pairs(W.dict6) do
            W.dict6[i] = math.log(v) - logtotal
            addDictWord(i, v, "zhTW")
        end
        for i, v in pairs(W.dict7) do
            W.dict7[i] = math.log(v) - logtotal
            addDictWord(i, v, "zhTW")
        end

        W.dict8 = {}
        for _, v in pairs(W.words) do
            for _, word in pairs(v) do
                W.dict8[word.word] = math.log(word.freq) - logtotal
            end
        end
        loadGlossary = true
    end
end

function M:dictItem(k)
    return W.dict1[k] or W.dict2[k] or W.dict3[k] or W.dict4[k] or W.dict5[k] or W.dict6[k] or W.dict7[k] or W.dict8[k]
end

function M:searchWords(_tip, pattp)
    -- 魔兽词库
    if W.words then
        local w = ''
        local f = 0
        local w2 = ''
        local f2 = 0
        for _, spatt in ipairs(pattp) do
            local treeKey = jieba.sub(spatt, 1, 1)
            local tree = W.words[treeKey] or {}
            for _, v in ipairs(tree) do
                local word = v.word
                local freq = tonumber(v.freq) or 0
                local start, _end = strfind(word, pattp[#pattp], 1, true)
                if start and start == 1 and _end ~= #word and freq > f then
                    -- 从匹配位置之后截取字符串
                    local p = strsub(word, _end + 1)
                    if p and #p > 0 then
                        w = p
                        f = freq
                    end
                end
                if start and start == 1 and _end ~= #word and freq > f2 and freq < f then
                    -- 从匹配位置之后截取字符串
                    local p = strsub(word, _end + 1)
                    if p and #p > 0 then
                        w2 = p
                        f2 = freq
                    end
                end
            end
        end
        if f > 0 then
            U:InsertNoRepeat(_tip, w)
        end
        if f2 > 0 then
            U:InsertNoRepeat(_tip, w2)
        end
    end


    -- 中文通用词
    if W.dictWord then
        local max_re = 6 - #_tip
        local count = 0
        local zh_patt = strlower(pattp[#pattp])
        local treeKey = jieba.sub(zh_patt, 1, 1)
        local tree = W.dictWord[treeKey] or {}
        local maxFreq = 0
        for word, freq in pairs(tree) do
            freq = tonumber(freq) or 0
            if count < max_re then
                local start, _end = strfind(strlower(word), zh_patt, 1, true)
                if start and start > 0 and _end ~= #word and freq > maxFreq then
                    U:InsertNoRepeat(_tip, strsub(word, _end + 1))
                    maxFreq = freq
                    count = count + 1
                end
            else
                break
            end
        end
    end
end
