local W, M, U, D, G = unpack((select(2, ...)))

-- 获取当前时间戳和毫秒数
function U:GetFormattedTimestamp()
    local currentTime = GetServerTime()                     -- 获取当前时间戳（秒）
    local milliseconds = math.floor((GetTime() % 1) * 1000) -- 获取当前时间的毫秒数

    -- 格式化时间戳
    local formattedTime = date("%y%m/%d %H:%M:%S", currentTime)

    -- 添加毫秒数
    formattedTime = formattedTime .. string.format(".%03d", milliseconds)

    return formattedTime
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
            local affixName, affixDesc, affixIcon = W.C_ChallengeMode.GetAffixInfo(v)
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
        local accountInfo = C_BattleNet.GetFriendAccountInfo(i)
        if accountInfo and accountInfo.battleTag == battleTag then
            return accountInfo
        end
    end
    return nil
end

function U:Print(...)
    local ps = {}
    for _, v in ipairs({ ... }) do
        if v then
            local m, c = gsub(v, '%|', "||")
            tinsert(ps, m)
        end
    end
    print(unpack(ps))
end

-- |BTag:沉沦血刃#5247|BTag|Kp61|k
function U:BTagFilter(text)
    local patt = '%|BTag:.-%|BTag'
    if text == nil or #text <= 0 or not text:find(patt) then return text end
    return gsub(text, patt, function(str)
        local BTag, _ = str:match('%|BTag:(.-)%|BTag')
        local accountInfo = U:GetAccountInfoByBattleTag(BTag)
        if accountInfo then
            local gameFriend = accountInfo.gameAccountInfo
            if gameFriend and gameFriend.realmName then
                return U:join('-', gameFriend.characterName, gameFriend.realmName)
            else
                return accountInfo.accountName
            end
        end
    end)
end


-- 使用string.find来进行纯文本匹配替换
function U:ReplacePlainTextUsingFind(text, pattern, replacement)
    local result = ""
    local searchFrom = 1
    local startPos, endPos = text:find(pattern, searchFrom, true)  -- true 表示纯文本匹配

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