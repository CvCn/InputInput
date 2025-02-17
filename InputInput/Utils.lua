local W, M, U, D, G, L, E, API, LOG = unpack((select(2, ...)))

local C_ChallengeMode_GetAffixInfo = API.C_ChallengeMode_GetAffixInfo
local C_BattleNet_GetFriendAccountInfo = API.C_BattleNet_GetFriendAccountInfo
local BNGetNumFriends = API.BNGetNumFriends
local GetNumGuildMembers = API.GetNumGuildMembers
local GetGuildRosterInfo = API.GetGuildRosterInfo
local GetRealmName = API.GetRealmName
local UnitName = API.UnitName
local IsInRaid = API.IsInRaid
local GetNumGroupMembers = API.GetNumGroupMembers
local GetZoneText = API.GetZoneText
local GetSubZoneText = API.GetSubZoneText
local C_ChatInfo_SendAddonMessage = API.C_ChatInfo_SendAddonMessage
local C_Timer_After = API.C_Timer_After

-- 格式化时间戳函数
-- @param currentTime 当前时间，通常为系统当前时间
-- @param milliseconds 毫秒数，用于在需要时添加到时间戳上
-- @param format 格式字符串，默认为"%y/%m/%d %H:%M:%S"
-- @param notMilli 是否不显示毫秒数，默认为false
-- @return 格式化后的时间戳字符串
local function GetFormattedTimestamp(currentTime, milliseconds, format, notMilli)
    -- 根据提供的格式字符串或默认格式，格式化时间戳
    local formattedTime = date(format or "%y/%m/%d %H:%M:%S", currentTime)
    -- 如果不需要毫秒数，则不进行任何操作
    if not notMilli then
        -- 将毫秒数添加到时间戳上
        formattedTime = formattedTime .. string.format(".%03d", milliseconds)
    end
    -- 返回格式化后的时间戳字符串
    return formattedTime
end

-- 检查两个时间是否同一年
-- @param t1 第一个时间
-- @param t2 第二个时间
-- @return 如果两个时间同一年，返回true，否则返回false
local function sameYear(t1, t2)
    -- 比较两个时间的年份是否相同
    return date("%y", t1) == date("%y", t2)
end

-- 检查两个时间是否相同的日期（年/月/日）
-- @param t1 第一个时间
-- @param t2 第二个时间
-- @return 如果两个时间的日期相同，返回true，否则返回false
local function sameDate(t1, t2)
    -- 比较两个时间的日期是否相同
    return date("%y/%m/%d", t1) == date("%y/%m/%d", t2)
end

-- 根据给定的时间参数，返回格式化的时间或日期字符串
-- @param localTime 给定的本地时间
-- @return 格式化后的字符串，包含时间或日期
function U:GetFormattedTimeOrDate(localTime)
    -- 如果给定时间与当前时间的年份不同，则返回包含年月日时分的格式化字符串
    if not sameYear(localTime, time()) then
        return GetFormattedTimestamp(localTime, 0, "%y%m/%d %H:%M", true)
        -- 如果给定时间与当前时间的日期不同，则返回包含月日时分的格式化字符串
    elseif not sameDate(localTime, time()) then
        return GetFormattedTimestamp(localTime, 0, "%m/%d %H:%M", true)
        -- 否则，返回包含时分的格式化字符串
    else
        return GetFormattedTimestamp(localTime, 0, "%H:%M", true)
    end
end

-- 获取当前时间戳和毫秒数
-- @return 当前时间戳和毫秒数
function U:GetFormattedTimestamp()
    local currentTime = time()
    local milliseconds = math.floor((time() % 1) * 1000) -- 获取当前时间的毫秒数
    return GetFormattedTimestamp(currentTime, milliseconds)
end

-- 将RGB颜色值转换为16进制颜色代码
-- @param r 红色分量值，范围0-1
-- @param g 绿色分量值，范围0-1
-- @param b 蓝色分量值，范围0-1
-- @return 16进制颜色代码字符串
function U:RGBToHex(r, g, b)
    -- 确保RGB值在0-255之间
    r = math.max(0, math.min(255, r * 255))
    g = math.max(0, math.min(255, g * 255))
    b = math.max(0, math.min(255, b * 255))

    -- 将RGB值转换为16进制并拼接成字符串
    return string.format("%02X%02X%02X", r, g, b)
end

-- 将多个字符串使用指定分隔符连接起来
---@param delim string 分隔符
---@param ... string 一个或多个待连接的字符串
---@return string 连接后的字符串
function U:join(delim, ...)
    local t = { ... }
    local t_temp = {}
    for _, v in ipairs(t) do
        if v and #v > 0 then
            table.insert(t_temp, v)
        end
    end
    if #t_temp == 0 then return '' end
    return string.join(delim, unpack(t_temp))
end

-- 获取挑战模式词缀名称
---@param ... number 一个或多个挑战模式词缀ID
---@return string 按空格分隔的词缀名称字符串
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

--- 检查表格中是否存在指定的键
---@param t table 要检查的表格
---@param key string 要查找的键
---@return boolean 如果找到键则返回true，否则返回false
function U:HasKey(t, key)
    if not t or type(t) ~= 'table' then return false end
    for _, v in ipairs(t) do
        if v == key then
            return true
        end
    end
    return false
end

-- 计算UTF-8字符串的长度
---@param input string 要计算长度的UTF-8字符串
---@return number 字符的个数（而非字节的个数）
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

-- 根据战斗标签获取账户信息
---@param battleTag string 玩家的战斗标签
---@return table|nil 如果找到，返回账户信息表，否则返回nil
function U:GetAccountInfoByBattleTag(battleTag)
    -- 获取战网好友数量
    local numFriends = BNGetNumFriends()
    -- 遍历所有好友
    for i = 1, numFriends do
        -- 获取当前好友的账户信息
        local accountInfo = C_BattleNet_GetFriendAccountInfo(i)
        -- 检查账户信息是否有效，并且战斗标签是否匹配
        if accountInfo and accountInfo.battleTag == battleTag then
            -- 返回匹配的账户信息
            return accountInfo
        end
    end
    -- 如果没有找到匹配的账户信息，返回nil
    return nil
end

-- 将本地化职业名称转换为英文职业名称
---@param localizedClass string 本地化的职业名称
---@return string 英文职业名称，如果找不到对应关系则返回nil
local function lcoalClassToEnglishClass(localizedClass)
    -- 尝试在男性职业表中查找对应关系
    local englishClass = ''
    for enClass, locClass in pairs(LOCALIZED_CLASS_NAMES_MALE) do
        if locClass == localizedClass then
            englishClass = enClass
            break
        end
    end
    -- 如果未找到，再尝试在女性职业表中查找对应关系
    if not englishClass then
        for enClass, locClass in pairs(LOCALIZED_CLASS_NAMES_FEMALE) do
            if locClass == localizedClass then
                englishClass = enClass
                break
            end
        end
    end
    -- 返回英文职业名称，如果找不到对应关系则返回nil
    return englishClass
end

-- TTag过滤函数
-- 该函数的作用是根据参数text中的TTag标记，返回格式化后的时间或空字符串
-- 如果showTime为true，则返回格式化后的时间字符串，否则返回空字符串
---@param text string 包含TTag标记的字符串
---@param showTime boolean 布尔值，决定是否显示时间
---@return string 格式化后的字符串或原字符串
function U:TTagFilter(text, showTime)
    local patt = '%|?%|TTag:.-%|?%|TTag'
    local notpatt = '%|%|TTag:.-%|%|TTag'
    if text == nil or #text <= 0 or not text:find(patt) then return text or '' end
    local re, count = gsub(text, patt, function(str)
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
    return re
end

-- BTag过滤器函数，用于处理文本中的BTag标记
-- 该函数会搜索文本中特定格式的BTag，并将其替换为对应账号信息的彩色显示
-- 如果文本中不包含BTag标记，或所有BTag标记都符合特定格式，则文本保持不变
---@param text string 要处理的文本
---@return string|nil, integer|nil 处理后的文本
function U:BTagFilter(text)
    -- 定义BTag标记的正则表达式模式
    local patt = '%|?%|BTag:.-%|?%|BTag'
    -- 定义不符合要求的BTag标记的正则表达式模式
    local notpatt = '%|%|BTag:.-%|%|BTag'

    -- 如果文本为空或不包含BTag标记，则直接返回原文本
    if text == nil or #text <= 0 or not text:find(patt) then return text end

    -- 使用正则表达式替换所有符合要求的BTag标记
    return gsub(text, patt, function(str)
        -- 如果当前BTag标记不符合要求，则保持不变
        if str:find(notpatt) then
            return str
        end

        -- 提取BTag标记中的账号信息
        local BTag, _ = str:match('%|BTag:(.-)%|BTag')
        -- 通过BTag获取对应的账号信息
        local accountInfo = U:GetAccountInfoByBattleTag(BTag)

        -- 如果找到了对应的账号信息
        if accountInfo then
            -- 获取账号的游戏信息
            local gameFriend = accountInfo.gameAccountInfo

            -- 如果游戏信息包含职业名称
            if gameFriend and gameFriend.className then
                -- 根据职业名称获取对应的颜色
                local classColor = RAID_CLASS_COLORS[lcoalClassToEnglishClass(gameFriend.className)]
                -- 设置账号名称的颜色
                self:UnitColor(accountInfo.accountName, classColor.colorStr)
                -- 返回带有颜色代码的账号名称
                return '|c' .. classColor.colorStr .. accountInfo.accountName .. '|r'
            end

            -- 如果没有游戏信息，直接返回账号名称
            return accountInfo.accountName
        else
            -- 如果找不到对应的账号信息，返回BTag
            return BTag
        end
    end)
end

---@param text string
---@param pattern string
---@param replacement string
---@return string
function U:ReplacePlainTextUsingFind(text, pattern, replacement)
    -- 初始化结果字符串
    local result = ""
    -- 设置起始搜索位置
    local searchFrom = 1
    -- 使用find函数查找匹配模式的位置，true表示纯文本匹配
    local startPos, endPos = text:find(pattern, searchFrom, true)

    -- 循环直到找到匹配
    while startPos do
        -- 将找到的匹配部分替换为replacement，并拼接到结果字符串
        result = result .. text:sub(searchFrom, startPos - 1) .. replacement
        -- 更新搜索起始位置
        searchFrom = endPos + 1
        -- 继续查找下一个匹配
        startPos, endPos = text:find(pattern, searchFrom, true)
    end

    -- 将剩余的文本拼接到结果字符串
    result = result .. text:sub(searchFrom)
    -- 返回替换完成的结果
    return result
end

---@param ... table[] 传入的多个数组
---@return table 合并后的数组
-- 合并多个数组到一个数组中
function U:MergeMultipleArrays(...)
    -- 创建一个空表用于存放合并后的数组
    local merged = {}
    -- 遍历传入的所有数组
    for _, array in ipairs({ ... }) do
        -- 将每个数组的元素逐个插入到merged数组中
        for i = 1, #array do
            table.insert(merged, array[i])
        end
    end
    -- 返回合并后的数组
    return merged
end

-- 分割消息函数
-- 该函数通过正则表达式将输入字符串分割成一个字符串数组
---@param input string 要分割的字符串
---@return table 分割后的字符串数组
function U:SplitMSG(input)
    -- 初始化结果表，用于存储分割后的字符串
    local result = {}
    -- 定义正则表达式模式，用于匹配分割字符
    -- 这里匹配的是非单词字符，包括标点符号、空格、控制字符等
    local pattern = "[%p%s%c%z]"

    -- 初始化上一次匹配的结束位置为1，即字符串的起始位置
    local lastEnd = 1
    -- 使用正则表达式遍历输入字符串，找到所有匹配的分割字符
    for start, stop in string.gmatch(input, "()" .. pattern .. "()") do
        -- 如果上一次匹配的结束位置小于本次匹配的开始位置，则说明找到了一个待分割的字符串
        if lastEnd < start then
            -- 将找到的字符串插入到结果表中，并更新上一次匹配的结束位置
            table.insert(result, string.sub(input, lastEnd, start - 1))
        end
        -- 更新上一次匹配的结束位置为本次匹配的结束位置
        lastEnd = stop
    end

    -- 检查是否还有剩余的字符串未被分割
    -- 如果上一次匹配的结束位置小于等于输入字符串的长度，则说明还有剩余
    if lastEnd <= #input then
        -- 将剩余的字符串插入到结果表中
        table.insert(result, string.sub(input, lastEnd))
    end

    -- 返回分割后的字符串数组
    return result
end

-- 将指定元素添加到数组末尾，如果元素已存在，则先将其移至末尾
---@param array table 要操作的数组
---@param element any 要添加或移动的元素
---@return integer|nil 如果元素已存在，返回其原索引；否则返回nil
function U:AddOrMoveToEnd(array, element)
    -- 检查元素是否为空或长度是否为0，如果是则直接返回
    if element == nil or #element <= 0 then return end

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

-- 获取表的元素数量
--
---@param tbl table 要计算大小的表
---@return integer 表中元素的数量
local function getTableSize(tbl)
    local count = 0
    local key = next(tbl)
    while key do
        count = count + 1
        key = next(tbl, key)
    end
    return count
end

function U:AddOrAddOne(tables, element)
    local e = tables[element]
    if e then
        e = e + 1
    else
        e = 1
    end
    tables[element] = e
    -- LOG:Debug(tableSize(tables))
    if getTableSize(tables) > 300 then
        local min = 0
        local minv = ''
        for k, v in pairs(tables) do
            if v <= min or min == 0 then
                min = v
                minv = k
            end
        end
        tables[minv] = nil
    end
    return tables
end

function U:FindMaxValue(tables, msg)
    if not tables then return nil end
    local maxv = 0
    local word = nil
    for k, v in pairs(tables) do
        local start, _end = strfind(k, msg, 1, true)
        if start and start > 0 and _end ~= #k then
            if v > maxv then
                maxv = v
                word = k
            end
        end
    end
    return word
end

-- 设置或获取单位的颜色
---@param unitName string 单位名称
---@param color string|nil 单位颜色，如果未提供，则尝试根据单位名称从缓存中获取
---@return string|nil 单位的颜色字符串，如果无法确定，则为nil
function U:UnitColor(unitName, color)
    -- 从数据库读取单位颜色缓存，如果不存在，则初始化为空表，避免每次都读取数据库
    local UNIT_COLOR_CACHE = D:ReadDB('UNIT_COLOR_CACHE', {}, true)

    -- 如果缓存表的大小超过200，为了防止表过大影响性能，删除第一个元素
    if getTableSize(UNIT_COLOR_CACHE) >= 200 then
        -- 找到第一个键并删除，这里使用break实现只删除一个元素
        for k in pairs(UNIT_COLOR_CACHE) do
            UNIT_COLOR_CACHE[k] = nil
            break
        end
    end

    -- 如果提供了颜色，则直接缓存该颜色，否则尝试从缓存中获取
    UNIT_COLOR_CACHE[unitName] = color or UNIT_COLOR_CACHE[unitName]

    -- 如果缓存中没有该单位的颜色，尝试根据单位名称获取战斗网账号信息并设置颜色
    if UNIT_COLOR_CACHE[unitName] == nil then
        local accountInfo = BNet_GetAccountInfoFromAccountName(unitName)
        -- 如果账号信息存在，并且包含游戏账号信息以及职业名称，则设置颜色
        if accountInfo and accountInfo.gameAccountInfo and accountInfo.gameAccountInfo.className then
            -- 将职业名称转换为英文，并根据职业获取对应的颜色
            UNIT_COLOR_CACHE[unitName] = RAID_CLASS_COLORS
                [lcoalClassToEnglishClass(accountInfo.gameAccountInfo.className)].colorStr
        end
    end

    -- 将更新后的缓存保存回数据库
    D:SaveDB('UNIT_COLOR_CACHE', UNIT_COLOR_CACHE, true)

    -- 返回单位的颜色，可能为nil
    return UNIT_COLOR_CACHE[unitName]
end

-- 从战网账户名称获取账户信息
-- 该函数解析传入的账户名称，尝试从战网获取相应的账户信息
---@param name string 带有"-"分隔的账户名称字符串
---@return table|nil 如果找到对应的账户信息，则返回一个表，否则返回nil
function BNet_GetAccountInfoFromAccountName(name)
    -- 分割账户名称以获取可能的游戏角色名称
    local n, r = strsplit("-", name)
    -- 获取在线的战网好友数量
    local _, numBNetOnline = BNGetNumFriends();
    -- 遍历在线的好友列表
    for i = 1, numBNetOnline do
        -- 获取当前好友的账户信息
        local accountInfo = C_BattleNet_GetFriendAccountInfo(i);
        -- 检查是否能通过账户名称匹配到好友
        if accountInfo and accountInfo.accountName and name == accountInfo.accountName then
            -- 如果匹配成功，则返回该账户信息
            return accountInfo
        end
        -- 检查是否能通过游戏角色名称匹配到好友
        if accountInfo and accountInfo.gameAccountInfo and n == accountInfo.gameAccountInfo.characterName then
            -- 如果匹配成功，则返回该账户信息
            return accountInfo
        end
    end
end

-- 判断字符串是否全为空白字符
--
---@param str string 待检查的字符串
---@return boolean 如果字符串全为空白字符，则返回 true；否则返回 false
local function isAllWhitespace(str)
    -- 使用 Lua 的模式匹配，^%s*$ 表示字符串从头到尾都必须是空白字符
    return str:match("^%s*$") ~= nil
end

function U:InsertNoRepeat(t, e)
    if not t then return {} end
    for i, v in ipairs(t) do
        if v == e then
            return t
        end
    end
    table.insert(t, e)
    return t
end

-- 引入结巴分词库
local jieba = LibStub("inputinput-jieba")
-- 定义一个缓存表，用于存储分词结果
local wordCache = {}

-- 初始化分词缓存
-- 该函数接受一个历史记录表作为参数，对每个历史记录进行分词处理，并将结果缓存起来
---@param history table 一个包含历史记录的表
function U:InitWordCache(history)
    -- 遍历历史记录表
    for _, v in ipairs(history) do
        -- 定义一个表，用于存储当前历史记录的分词结果
        local re = {}
        -- 对当前历史记录进行分词，不使用模糊分词，使用HMM（隐马尔可夫模型）
        for _, i in ipairs(jieba.lcut(v, false, true)) do
            -- 如果分词结果不是全空格，则加入到结果表中
            if not isAllWhitespace(i) then
                table.insert(re, i)
            end
        end
        -- 将当前历史记录的分词结果缓存起来
        wordCache[v] = re
    end
end

-- CutWord函数：用于将输入的字符串切割成单词列表
---@param str string 待切割的字符串
---@return table 切割后的单词列表，如果输入为空或空字符串，则返回原输入
function U:CutWord(str)
    -- 检查输入是否为空或空字符串，如果是，则直接返回
    if not str or str == '' then return {} end

    -- 尝试从缓存中获取切割结果，如果存在缓存则直接返回
    local cache = wordCache[str]
    if cache then return cache end

    -- 初始化一个空表，用于存储最终的切割结果
    local re = {}

    -- 使用jieba分词库对输入字符串进行分词，不使用模糊模式，使用HMM模式
    for _, i in ipairs(jieba.lcut(str, false, true)) do
        -- 过滤掉所有的空白词（如空格、换行等）
        if not isAllWhitespace(i) then
            -- 将非空白词加入到最终结果表中
            tinsert(re, i)
        end
    end

    -- 将最终的切割结果缓存起来，用于后续相同输入的快速返回
    wordCache[str] = re

    -- 返回切割后的单词列表
    return re
end

-- 定义一个空表，用于存储好友名称相关信息
local friendName = {}
-- 初始化好友信息的函数
function U:InitFriends()
    -- 获取战网好友的总数、在线数、收藏数和收藏在线数
    local numBNetTotal, numBNetOnline, numBNetFavorite, numBNetFavoriteOnline = BNGetNumFriends()
    -- 记录好友初始化开始的日志
    LOG:Debug('---好友初始化---')
    -- 从在线好友列表的末尾开始遍历，以便于处理离线的好友
    for i = 1, numBNetOnline do
        -- 获取第i个好友的账户信息
        local accountInfo = C_BattleNet_GetFriendAccountInfo(i)
        -- 检查账户信息是否存在
        if accountInfo then
            -- 获取游戏账户信息
            local gameAccountInfo = accountInfo.gameAccountInfo
            -- 检查游戏账户信息是否完整，包括角色名和在线状态
            if gameAccountInfo and gameAccountInfo.characterName and gameAccountInfo.isOnline then
                -- 获取角色所在服务器名称
                local realm = gameAccountInfo.realmName
                -- 如果服务器名称为空，则尝试从富媒体信息中提取
                if not realm or realm == '' then
                    -- 分割富媒体信息以获取服务器名称
                    local zoneName, realmName = strsplit('-', gameAccountInfo.richPresence)

                    -- 确保提取到的服务器名称非空
                    if realmName and realmName ~= '' then
                        -- 清理并设置服务器名称
                        realm = strtrim(realmName)
                    end
                end
                -- U:AddOrMoveToEnd(friendName,
                --     U:join('-', gameAccountInfo.characterName, realm))
                U:AddOrMoveToEnd(friendName, gameAccountInfo.characterName)
                U:AddOrMoveToEnd(friendName, realm)
            end
        end
    end
    -- 记录好友初始化结束的日志
    LOG:Debug('---好友初始化结束---')
end

-- 定义一个空表，用于存储公会名称
local guildName = {}
local guildNameOnLine = {}

-- 初始化公会成员
function U:InitGuilds()
    -- 获取公会成员总数，包括在线、离线和移动设备登录的成员
    local numTotalGuildMembers, numOnlineGuildMembers, numOnlineAndMobileMembers = GetNumGuildMembers()
    -- 遍历公会成员
    LOG:Debug('---公会成员初始化---')
    for i = 1, numTotalGuildMembers do
        -- 获取公会成员的详细信息
        local name, rank, rankIndex, level, class, zone, note, officerNote, online = GetGuildRosterInfo(i)
        -- 如果成员名称存在，则进行处理
        if name then
            if online then
                -- 添加或移动成员到列表末尾
                U:AddOrMoveToEnd(guildNameOnLine, name)
                -- 分割名称和服务器
                local name, realm = strsplit('-', name)
                -- 获取或设置服务器名称
                realm = realm or GetRealmName()
                -- 添加或移动服务器到列表末尾
                U:AddOrMoveToEnd(guildNameOnLine, name)
                U:AddOrMoveToEnd(guildNameOnLine, realm)
            else
                -- 添加或移动成员到列表末尾
                U:AddOrMoveToEnd(guildName, name)
                -- 分割名称和服务器
                local name, realm = strsplit('-', name)
                -- 获取或设置服务器名称
                realm = realm or GetRealmName()
                -- 添加或移动服务器到列表末尾
                U:AddOrMoveToEnd(guildName, name)
                U:AddOrMoveToEnd(guildName, realm)
            end
        end
    end
    -- 结束公会成员初始化
    LOG:Debug('---公会成员初始化结束---')
end

-- 定义一个全局变量来存储区域名称
local zoneName = {}
-- 定义一个全局变量用于标记区域是否已经初始化
local zoneInit = false

-- 初始化区域数据
function U:InitZones()
    -- 只有在区域未被初始化时才执行初始化操作
    if not zoneInit then
        zoneInit = true -- 标记区域已初始化
        -- 从数据库读取已保存的区域名称，如果不存在则使用空表，并强制更新
        zoneName = D:ReadDB('zoneName', {}, true)
    end
    -- 将当前区域名称添加到列表末尾
    U:AddOrMoveToEnd(zoneName, GetZoneText())
    -- 将当前子区域名称添加到列表末尾
    U:AddOrMoveToEnd(zoneName, GetSubZoneText())
    -- 如果区域名称列表长度超过200，则移除前两个元素
    if #zoneName >= 200 then
        table.remove(zoneName, 1)
        table.remove(zoneName, 1)
    end
    -- 保存区域名称列表到数据库，并强制更新
    D:SaveDB('zoneName', zoneName, true)
end

-- 定义一个空表，用于存储队伍成员的名字和服务器
local groupMembers = {}
-- 定义一个变量，用于缓存队伍成员数量
local cacheMember = 0

---@brief 初始化队伍成员信息
---@details 此函数会获取当前队伍(小队或团队)的所有成员，并将他们的名字和服务器存储在一个表中
function U:InitGroupMembers()
    -- 获取当前队伍成员的数量
    local numGroupMembers = GetNumGroupMembers()
    -- 如果当前队伍成员数量与上一次缓存的数量相同，则不需要重新初始化
    if numGroupMembers == cacheMember then return end
    -- 更新缓存的队伍成员数量
    cacheMember = numGroupMembers
    -- 输出调试信息，表示开始初始化队伍成员
    LOG:Debug('---队伍成员初始化---')
    -- 遍历所有队伍成员
    for i = 1, numGroupMembers do
        -- 根据成员在队伍中的位置，构建单位ID
        local unitID = "party" .. i -- 对于小队成员
        -- 如果在团队中，则使用团队的单位ID
        if IsInRaid() then
            unitID = "raid" .. i -- 对于团队成员
            -- 如果是小队成员的最后一个，并且不在团队中，则设置为玩家自己
        elseif i == numGroupMembers and not IsInRaid() then
            unitID = "player" -- 自己作为小队成员的最后一个
        end

        -- 获取成员的名字和服务器
        local name, realm = UnitName(unitID)
        -- 如果服务器名为空或不存在，则设置为当前服务器
        if realm == "" or not realm then
            realm = GetRealmName() -- 如果服务器名为空，则为当前服务器
        end

        -- 将名字和服务器存储在表中
        U:AddOrMoveToEnd(groupMembers, U:join('-', name, realm))
        U:AddOrMoveToEnd(groupMembers, name)
        U:AddOrMoveToEnd(groupMembers, realm)
    end
    -- 输出调试信息，表示结束初始化队伍成员
    LOG:Debug('---队伍成员初始化结束---')
end

-- 根据用户输入提供玩家名称建议
---@param inpall string 所有输入的集合，用于搜索匹配的玩家名称
---@param inp string 当前输入，用于过滤并提供玩家名称建议
---@return string|nil 返回建议
function U:PlayerTip(inpall, inp)
    LOG:Debug(inp)
    -- 检查输入集合是否为空或未定义，如果是则返回
    if inpall == nil or #inpall <= 0 then return end
    -- 检查当前输入是否为空或未定义，如果是则返回
    if inp == nil or #inp <= 0 then return end

    -- 遍历好友列表
    for i = #friendName, 1, -1 do
        local v = friendName[i]
        -- 在好友名称中查找输入字符串，如果找到且不是完整匹配，则处理
        local start, _end = strfind(v, inp, 1, true)
        if start and start == 1 and _end ~= #v then
            -- 从匹配位置之后截取字符串
            local p = strsub(v, _end + 1)
            if p and #p > 0 then
                LOG:Debug('好友')
                return p
            end
        end
    end

    -- 遍历公会列表(在线）
    for i = #guildNameOnLine, 1, -1 do
        local v = guildNameOnLine[i]
        -- 在公会名称中查找输入字符串，如果找到且不是完整匹配，则处理
        local start, _end = strfind(v, inp, 1, true)
        if start and start == 1 and _end ~= #v then
            -- 从匹配位置之后截取字符串
            local p = strsub(v, _end + 1)
            if p and #p > 0 then
                LOG:Debug('公会(在线）', v)
                return p
            end
        end
    end

    -- 遍历公会列表
    for i = #guildName, 1, -1 do
        local v = guildName[i]
        -- 在公会名称中查找输入字符串，如果找到且不是完整匹配，则处理
        local start, _end = strfind(v, inp, 1, true)
        if start and start == 1 and _end ~= #v then
            -- 从匹配位置之后截取字符串
            local p = strsub(v, _end + 1)
            if p and #p > 0 then
                LOG:Debug('公会', v)
                return p
            end
        end
    end

    -- 遍历组队成员列表
    for i = #groupMembers, 1, -1 do
        local v = groupMembers[i]
        -- 在组队成员名称中查找输入字符串，如果找到且不是完整匹配，则处理
        local start, _end = strfind(v, inp, 1, true)
        if start and start == 1 and _end ~= #v then
            -- 从匹配位置之后截取字符串
            local p = strsub(v, _end + 1)
            if p and #p > 0 then
                LOG:Debug('组队')
                return p
            end
        end
    end

    -- 遍历区域列表
    for i = #zoneName, 1, -1 do
        local v = zoneName[i]
        -- 在区域名称中查找输入字符串，如果找到且不是完整匹配，则处理
        local start, _end = strfind(v, inp, 1, true)
        if start and start > 0 and _end ~= #v then
            -- 从匹配位置之后截取字符串
            local p = strsub(v, _end + 1)
            if p and #p > 0 then
                LOG:Debug('区域')
                return p
            end
        end
    end

end

-- INPUTINPUT_V
-- 发送版本信息
function U:SendVersionMsg()
    if IsInRaid() then
        C_ChatInfo_SendAddonMessage('INPUTINPUT_V', W.version,
            (not IsInRaid(LE_PARTY_CATEGORY_HOME) and IsInRaid(LE_PARTY_CATEGORY_INSTANCE)) and 'INSTANCE_CHAT' or 'RAID')
    elseif IsInGroup() then
        C_ChatInfo_SendAddonMessage('INPUTINPUT_V', W.version,
            (not IsInGroup(LE_PARTY_CATEGORY_HOME) and IsInGroup(LE_PARTY_CATEGORY_INSTANCE)) and 'INSTANCE_CHAT' or
            'PARTY')
    elseif IsInGuild() then
        C_ChatInfo_SendAddonMessage('INPUTINPUT_V', W.version, 'GUILD')
    end
end

do
    -- 创建一个闭包函数，用于将可变参数传递给目标函数
    local function CreateClosure(func, data)
        return function() func(unpack(data)) end
    end

    -- 延迟执行函数
    -- @param delay: 延迟时间，单位为秒
    -- @param func: 要延迟执行的函数
    -- @param ...: 可变参数，传递给要延迟执行的函数
    -- @return: 返回一个布尔值，表示是否成功创建延迟执行任务
    function U:Delay(delay, func, ...)
        if type(delay) ~= 'number' or type(func) ~= 'function' then return false end

        local args = { ... } -- delay: Restrict to the lowest time that the API allows us
        C_Timer_After(delay < 0.01 and 0.01 or delay, (#args <= 0 and func) or CreateClosure(func, args))

        return true
    end
end

function U:OpenLink(linkData)
    ChatFrame1EditBox:Show() -- 强制显示
    ChatFrame1EditBox:SetFocus() -- 保持焦点
    ChatFrame1EditBox:SetText(linkData)
    ChatFrame1EditBox:HighlightText()
end

-- 定义一个静态提示框，用于在用户需要重新加载UI时提供确认提示
StaticPopupDialogs["InputInput_RELOAD_UI_CONFIRMATION"] = {
    text = L['Do you want to reload the addOnes'], -- 提示框的文本内容，询问用户是否想要重新加载插件
    button1 = L['Yes'],                            -- 提示框的第一个按钮，提供“是”的选项
    button2 = L['No'],                             -- 提示框的第二个按钮，提供“否”的选项
    OnAccept = function()                          -- 当用户点击“是”时的回调函数
        ReloadUI()                                 -- 执行重载UI的操作
    end,
    timeout = 10,                                  -- 提示框显示的超时时间，0表示不自动消失
    whileDead = true,                              -- 在玩家死亡时是否显示该提示框，true表示显示
    hideOnEscape = true,                           -- 当用户按下ESC键时是否隐藏该提示框，true表示隐藏
    preferredIndex = 3,                            -- 设置提示框的显示优先级，避免与其他静态提示框冲突
}
