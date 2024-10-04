local N, T = ...
local W, M, U, D, G, L, E, API, LOG = unpack((select(2, ...)))
local GetLocale = API.GetLocale
local locale = GetLocale() or 'enUS'
T[6] = L[locale] or {}

-- 定义元表，重写 __index
local mt = {
    -- 定制下标取值的逻辑
    __index = function(table, key)
        return rawget(table, key) or rawget(L['enUS'], key) -- 如果没有值，返回缺省值
    end
}

-- 设置元表
setmetatable(T[6], mt)
