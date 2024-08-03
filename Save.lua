local W, M, U, D, G = unpack((select(2, ...)))

InputInput_DB = InputInput_DB or {}
function D:SaveDB(key, value)
    local accountID = UnitGUID("player")
    if accountID == nil then
        return
    end
    if not InputInput_DB[accountID] then
        InputInput_DB[accountID] = {}
    end
    InputInput_DB[accountID][key] = value
end

function D:ReadDB(key, defaultValue)
    local accountID = UnitGUID("player")
    if accountID == nil then
        return nil
    end
    InputInput_DB[accountID] = InputInput_DB[accountID] or {}
    if InputInput_DB[accountID][key] == nil then
        InputInput_DB[accountID][key] = defaultValue or {}
    end
    return InputInput_DB[accountID][key]
end

function D:HasInKey(key)
    local accountID = UnitGUID("player")
    return InputInput_DB[accountID][key] ~= nil
end
