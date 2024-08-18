local W, M, U, D, G, L, E, API, LOG = unpack((select(2, ...)))

local C_ChallengeMode_GetAffixInfo = API.C_ChallengeMode_GetAffixInfo
local C_BattleNet_GetFriendAccountInfo = API.C_BattleNet_GetFriendAccountInfo
local BNGetNumFriends = API.BNGetNumFriends

local function GetFormattedTimestamp(currentTime, milliseconds, foramt, notMilli)
    -- 格式化时间戳
    local formattedTime = date(foramt or "%y/%m/%d %H:%M:%S", currentTime)
    if not notMilli then
        -- 添加毫秒数
        formattedTime = formattedTime .. string.format(".%03d", milliseconds)
    end
    return formattedTime
end

local function sameYear(t1, t2)
    return date("%y", t1) == date("%y", t2)
end

local function sameDate(t1, t2)
    return date("%y/%m/%d", t1) == date("%y/%m/%d", t2)
end

function U:GetFormattedTimeOrDate(localTime)
    if not sameYear(localTime, time()) then
        return GetFormattedTimestamp(localTime, 0, "%y%m/%d %H:%M", true)
    elseif not sameDate(localTime, time()) then
        return GetFormattedTimestamp(localTime, 0, "%m/%d %H:%M", true)
    else
        return GetFormattedTimestamp(localTime, 0, "%H:%M", true)
    end
end

-- 获取当前时间戳和毫秒数
function U:GetFormattedTimestamp()
    local currentTime = time()
    local milliseconds = math.floor((time() % 1) * 1000) -- 获取当前时间的毫秒数
    return GetFormattedTimestamp(currentTime, milliseconds)
end

-- RGB 转 16 进制颜色代码
function U:RGBToHex(r, g, b)
    -- 确保 RGB 值在 0-255 之间
    r = math.max(0, math.min(255, r * 255))
    g = math.max(0, math.min(255, g * 255))
    b = math.max(0, math.min(255, b * 255))

    -- 将 RGB 值转换为 16 进制并拼接成字符串
    return string.format("%02X%02X%02X", r, g, b)
end

function U:join(delim, ...)
    local t = { ... }
    local t_temp = {}
    for _, v in ipairs(t) do
        if v and #v > 0 then
            tinsert(t_temp, v)
        end
    end
    return string.join(delim, unpack(t_temp))
end

function U:GetAffixName(...)
    local name = {}
    for _, v in ipairs({ ... }) do
        if v then
            local affixName, affixDesc, affixIcon = C_ChallengeMode_GetAffixInfo(v)
            tinsert(name, affixName)
        end
    end
    return U:join(' ', unpack(name))
end

function U:HasKey(t, key)
    if not t or type(t) ~= 'table' then return false end
    for _, v in ipairs(t) do
        if v == key then
            return true
        end
    end
    return false
end

function U:Utf8Len(input)
    local len = 0
    local i = 1
    local byte = string.byte
    local input_len = #input

    while i <= input_len do
        local c = byte(input, i)
        if c > 0 and c <= 127 then
            -- 单字节字符 (ASCII)`
            i = i + 1
        elseif c >= 194 and c <= 223 then
            -- 双字节字符
            i = i + 2
        elseif c >= 224 and c <= 239 then
            -- 三字节字符
            i = i + 3
        elseif c >= 240 and c <= 244 then
            -- 四字节字符
            i = i + 4
        else
            -- 非法字符
            break
        end
        len = len + 1
    end

    return len
end

function U:GetAccountInfoByBattleTag(battleTag)
    local numFriends = BNGetNumFriends()
    for i = 1, numFriends do
        local accountInfo = C_BattleNet_GetFriendAccountInfo(i)
        if accountInfo and accountInfo.battleTag == battleTag then
            return accountInfo
        end
    end
    return nil
end

local function lcoalClassToEnglishClass(localizedClass)
    -- 尝试在男性职业表中查找
    local englishClass = nil
    for enClass, locClass in pairs(LOCALIZED_CLASS_NAMES_MALE) do
        if locClass == localizedClass then
            englishClass = enClass
            break
        end
    end
    -- 如果未找到，再尝试在女性职业表中查找
    if not englishClass then
        for enClass, locClass in pairs(LOCALIZED_CLASS_NAMES_FEMALE) do
            if locClass == localizedClass then
                englishClass = enClass
                break
            end
        end
    end
    return englishClass
end

function U:TTagFilter(text, showTime)
    local patt = '%|?%|TTag:.-%|?%|TTag'
    local notpatt = '%|%|TTag:.-%|%|TTag'
    if text == nil or #text <= 0 or not text:find(patt) then return text end
    return gsub(text, patt, function(str)
        if str:find(notpatt) then
            return str
        end
        local TTag, _ = str:match('%|TTag:(.-)%|TTag')
        if showTime then
            return '|cffC0C4CC' .. U:GetFormattedTimeOrDate(tonumber(TTag)) .. ' |r'
        else
            return ''
        end
    end)
end

-- |BTag:沉沦血刃#5247|BTag|Kp61|k
function U:BTagFilter(text)
    local patt = '%|?%|BTag:.-%|?%|BTag'
    local notpatt = '%|%|BTag:.-%|%|BTag'
    if text == nil or #text <= 0 or not text:find(patt) then return text end
    return gsub(text, patt, function(str)
        if str:find(notpatt) then
            return str
        end
        local BTag, _ = str:match('%|BTag:(.-)%|BTag')
        local accountInfo = U:GetAccountInfoByBattleTag(BTag)
        if accountInfo then
            local gameFriend = accountInfo.gameAccountInfo
            if gameFriend and gameFriend.className then
                local classColor = RAID_CLASS_COLORS[lcoalClassToEnglishClass(gameFriend.className)]
                self:UnitColor(accountInfo.accountName, classColor.colorStr)
                return '|c' .. classColor.colorStr .. accountInfo.accountName .. '|r'
            end
            return accountInfo.accountName
        else
            return BTag
        end
    end)
end

-- 使用string.find来进行纯文本匹配替换
function U:ReplacePlainTextUsingFind(text, pattern, replacement)
    local result = ""
    local searchFrom = 1
    local startPos, endPos = text:find(pattern, searchFrom, true) -- true 表示纯文本匹配

    while startPos do
        -- 拼接结果字符串
        result = result .. text:sub(searchFrom, startPos - 1) .. replacement
        searchFrom = endPos + 1
        startPos, endPos = text:find(pattern, searchFrom, true)
    end

    -- 拼接最后一部分
    result = result .. text:sub(searchFrom)
    return result
end

function U:MergeMultipleArrays(...)
    local merged = {}
    for _, array in ipairs({ ... }) do
        for i = 1, #array do
            table.insert(merged, array[i])
        end
    end
    return merged
end

function U:SplitMSG(input)
    local result = {}
    local pattern = "[%p%s%c%z]"

    local lastEnd = 1
    for start, stop in string.gmatch(input, "()" .. pattern .. "()") do
        if lastEnd < start then
            table.insert(result, string.sub(input, lastEnd, start - 1))
        end
        lastEnd = stop
    end

    -- 插入最后一个分割结果
    if lastEnd <= #input then
        table.insert(result, string.sub(input, lastEnd))
    end

    return result
end

function U:AddOrMoveToEnd(array, element)
    -- 遍历数组检查元素是否已经存在
    local index = nil
    for i, v in ipairs(array) do
        if v == element then
            index = i
            break
        end
    end

    -- 如果元素已经存在，删除它
    if index then
        table.remove(array, index)
    end

    -- 将元素添加到数组的最后
    table.insert(array, element)
    return index
end

local function getTableSize(t)
    local count = 0
    for _ in pairs(t) do
        count = count + 1
    end
    return count
end

function U:UnitColor(unitName, color)
    local UNIT_COLOR_CACHE = D:ReadDB('UNIT_COLOR_CACHE', {}, true)
    -- 如果表的大小超过 200，删除第一个元素
    if getTableSize(UNIT_COLOR_CACHE) >= 200 then
        -- 找到第一个键并删除
        for k in pairs(UNIT_COLOR_CACHE) do
            UNIT_COLOR_CACHE[k] = nil
            break
        end
    end
    UNIT_COLOR_CACHE[unitName] = color or UNIT_COLOR_CACHE[unitName]
    if UNIT_COLOR_CACHE[unitName] == nil then
        local accountInfo = BNet_GetAccountInfoFromAccountName(unitName)
        if accountInfo and accountInfo.gameAccountInfo and accountInfo.gameAccountInfo.className then
            UNIT_COLOR_CACHE[unitName] = RAID_CLASS_COLORS
                [lcoalClassToEnglishClass(accountInfo.gameAccountInfo.className)].colorStr
        end
    end
    D:SaveDB('UNIT_COLOR_CACHE', UNIT_COLOR_CACHE, true)
    return UNIT_COLOR_CACHE[unitName]
end

function BNet_GetAccountInfoFromAccountName(name)
    local n, r = strsplit("-", name)
    local _, numBNetOnline = BNGetNumFriends();
    for i = 1, numBNetOnline do
        local accountInfo = C_BattleNet_GetFriendAccountInfo(i);
        if accountInfo and accountInfo.accountName and name == accountInfo.accountName then
            return accountInfo
        end
        if accountInfo and accountInfo.gameAccountInfo and n == accountInfo.gameAccountInfo.characterName then
            return accountInfo
        end
    end
end

local function isAllWhitespace(str)
    -- 使用 Lua 的模式匹配，^%s*$ 表示字符串从头到尾都必须是空白字符
    return str:match("^%s*$") ~= nil
end

local jieba = LibStub("jieba")
local wordCache = {}

function U:InitWordCache(history)
    for _, v in ipairs(history) do
        local re = {}
        for _, i in ipairs(jieba.lcut(v, false, true)) do
            if not isAllWhitespace(i) then
                tinsert(re, i)
            end
        end
        wordCache[v] = re
    end
end

function U:CutWord(str)
    if not str or str == '' then return str end
    local cache = wordCache[str]
    if cache then return cache end
    local re = {}
    for _, i in ipairs(jieba.lcut(str, false, true)) do
        if not isAllWhitespace(i) then
            tinsert(re, i)
        end
    end
    wordCache[str] = re
    return re
end
