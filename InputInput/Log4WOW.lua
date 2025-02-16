local W, M, U, D, G, L, E, API, LOG = unpack((select(2, ...)))

local Level = {
    ERROR = '|cFFF56C6C',
    WARN = '|cFFE6A23C',
    DEBUG = '|cFF909399',
    INFO = '|cFFFFFFFF'
}
local prnSuffix = "|cff409EFFII|r : "

---@param level string
---@param ... string
local function Uprint(level, ...)
    local color = Level[level]
    if E == 'DEV' then
        if level == 'DEBUG' then
            local ps = ""
            for _, v in ipairs({ ... }) do
                if v then
                    local m, c = gsub(v, '%|', "||")
                    ps = ps .. m .. ' '
                end
            end
            print(color, U:GetFormattedTimeOrDate(time()) .. ' ' .. prnSuffix, ps, '|r')
        else
            print(prnSuffix, color, ..., '|r')
        end
    elseif E == 'PRO' or E == 'BETE' then
        if level == 'ERROR' or level == 'WARN' or level == 'INFO' then
            print(prnSuffix, color, ..., '|r')
        end
    end
end
---@param ... string
function LOG:Debug(...)
    Uprint("DEBUG", ...)
end
---@param ... string
function LOG:Info(...)
    Uprint("INFO", ...)
end
---@param ... string
function LOG:Error(...)
    Uprint("ERROR", ...)
    error(...)
end
---@param ... string
function LOG:Warn(...)
    Uprint("WARN", ...)
end
---@param key string
---@param value any
function LOG:SaveLog(key, value)
    if E ~= 'DEV' then return end
    local log = D:ReadDB('LOG__', {})
    local thisKey = log[key] or {}
    tinsert(thisKey, {
        t = U:GetFormattedTimestamp(),
        v = value
    })
    if #thisKey > 200 then
        tremove(thisKey, 1)
    end
    log[key] = thisKey
    D:SaveDB('LOG__', log)
end

function LOG:ClearLog()
    D:SaveDB('LOG__', {})
end
