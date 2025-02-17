local W, M, U, D, G, L, E, API, LOG = unpack((select(2, ...)))

local UnitGUID = API.UnitGUID
local BNGetInfo = API.BNGetInfo

InputInput_DB = InputInput_DB or {}

---@param key string
---@param value any
---@param AccountUniversal boolean|nil
function D:SaveDB(key, value, AccountUniversal)
    local accountID
    if not AccountUniversal then
        accountID = UnitGUID("player")
    else
        local presenceID, battleTag, toonID, currentBroadcast, bnetAFK, bnetDND, isRIDEnabled = BNGetInfo()
        accountID = battleTag
    end
    if not accountID then return end

    if not InputInput_DB[accountID] then
        InputInput_DB[accountID] = {}
    end
    InputInput_DB[accountID][key] = value
end

---@param key string
---@param defaultValue any
---@param AccountUniversal boolean|nil
function D:ReadDB(key, defaultValue, AccountUniversal)
    local accountID
    if not AccountUniversal then
        accountID = UnitGUID("player")
    else
        local presenceID, battleTag, toonID, currentBroadcast, bnetAFK, bnetDND, isRIDEnabled = BNGetInfo()
        accountID = battleTag
    end
    if not accountID then return defaultValue end
    InputInput_DB[accountID] = InputInput_DB[accountID] or {}
    if InputInput_DB[accountID][key] == nil then
        InputInput_DB[accountID][key] = defaultValue
    end
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
        accountID = UnitGUID("player")
    else
        local presenceID, battleTag, toonID, currentBroadcast, bnetAFK, bnetDND, isRIDEnabled = BNGetInfo()
        accountID = battleTag
    end
    if not accountID then return false end
    return InputInput_DB[accountID][key] ~= nil
end
