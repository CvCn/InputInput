local W, M, U, D, G, L, E, API, LOG = unpack((select(2, ...)))

local UnitGUID = API.UnitGUID
local BNGetInfo = API.BNGetInfo

InputInput_DB = InputInput_DB or {}

local playerID = UnitGUID("player")
local _, battleTag = BNGetInfo()

-- 计算 Lua 对象的近似字节大小（递归）
local function calculateObjectSize(obj, cache)
    cache = cache or {} -- 用于防止循环引用导致的无限递归

    -- 如果已经计算过，直接返回
    if cache[obj] then
        return 0
    end
    cache[obj] = true

    local size = 0

    -- 基本类型的大小估算
    local objType = type(obj)
    if objType == "string" then
        size = size + #obj -- 字符串的字节长度
    elseif objType == "number" then
        size = size + 8    -- 假设数字占8字节（Lua 默认用 double）
    elseif objType == "boolean" then
        size = size + 1    -- 布尔值占1字节
    elseif objType == "table" then
        -- 表本身的开销（估算）
        size = size + 16 -- 表的初始开销（估算）

        -- 递归计算所有键和值的大小
        for k, v in pairs(obj) do
            size = size + calculateObjectSize(k, cache)
            size = size + calculateObjectSize(v, cache)
        end
    else                 -- function, userdata, thread 等
        size = size + 16 -- 其他类型按16字节估算
    end

    return size
end

local function trimLargeTablesBySize(obj, threshold, cache)
    threshold = threshold or (1024 * 1024 * 20) -- 默认阈值 20MB
    cache = cache or {}                    -- 用于防止循环引用

    -- 如果不是表，直接返回
    if type(obj) ~= "table" then
        return obj
    end

    -- 防止循环引用
    if cache[obj] then
        return obj
    end
    cache[obj] = true

    -- 先递归处理所有值
    for k, v in pairs(obj) do
        obj[k] = trimLargeTablesBySize(v, threshold, cache)
    end

    -- 计算当前表的总字节大小
    local totalSize = calculateObjectSize(obj)

    -- 如果超过阈值，删除前10个元素
    if totalSize > threshold then
        for i = 1, 10 do
            -- 获取第一个键
            local firstKey = nil
            for k in pairs(obj) do
                firstKey = k
                break
            end
            -- 删除第一个键值对
            if firstKey ~= nil then
                obj[firstKey] = nil
            end
        end
    end

    return obj
end

---@param key string
---@param value any
---@param AccountUniversal boolean|nil
function D:SaveDB(key, value, AccountUniversal)
    local accountID
    if not AccountUniversal then
        accountID = playerID
    else
        accountID = battleTag
    end
    if not accountID then return end

    if not InputInput_DB[accountID] then
        InputInput_DB[accountID] = {}
    end
    InputInput_DB[accountID][key] = trimLargeTablesBySize(value)
end

---@param key string
---@param defaultValue any
---@param AccountUniversal boolean|nil
function D:ReadDB(key, defaultValue, AccountUniversal)
    local accountID
    if not AccountUniversal then
        accountID = playerID
    else
        accountID = battleTag
    end
    if not accountID then return defaultValue end
    InputInput_DB[accountID] = InputInput_DB[accountID] or {}
    if InputInput_DB[accountID][key] == nil then
        InputInput_DB[accountID][key] = defaultValue
    end
    -- InputInput_DB[accountID][key] = trimLargeTablesBySize(InputInput_DB[accountID][key])
    return InputInput_DB[accountID][key]
end

---@param key string
---@param addvalue any
---@param AccountUniversal boolean|nil
---@param limit number
function D:AddArray(key, addvalue, AccountUniversal, limit)
    local date = self:ReadDB(key, {}, AccountUniversal)
    table.insert(date, addvalue)
    if #date > limit then
        tremove(date, 1)
    end
    self:SaveDB(key, date, AccountUniversal)
end

---@param key string
---@param AccountUniversal boolean|nil
function D:HasInKey(key, AccountUniversal)
    local accountID
    if not AccountUniversal then
        accountID = playerID
    else
        accountID = battleTag
    end
    if not accountID then return false end
    return InputInput_DB[accountID][key] ~= nil
end