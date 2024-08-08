-- C_Item.GetItemInfo
-- C_Item.GetDetailedItemLevelInfo
-- C_ChallengeMode.GetAffixInfo
-- GetSpecializationInfoByID
-- UnitTokenFromGUID

-- GetSpellTexture
-- GetAchievementInfo
-- UnitName
-- C_CurrencyInfo.GetCurrencyInfo
local N, T = ...
local W, M, U, D, G = unpack(T)

W.C_Item = C_Item
if not W.C_Item then
    W.C_Item = {}
end

---@diagnostic disable-next-line: deprecated
W.C_Item.GetItemInfo = C_Item.GetItemInfo or GetItemInfo
---@diagnostic disable-next-line: deprecated
W.C_Item.GetDetailedItemLevelInfo = C_Item.GetDetailedItemLevelInfo or GetDetailedItemLevelInfo
W.C_Item.GetAffixInfo = C_Item.GetAffixInfo or function() end

W.C_ChallengeMode = C_ChallengeMode
if not W.C_ChallengeMode then
    W.C_ChallengeMode = {}
end

W.GetSpecializationInfoByID = GetSpecializationInfoByID or function() end
W.UnitTokenFromGUID = UnitTokenFromGUID or function(GUID)
    return GUID
end

function W.UnitName(unit)
    return UnitName(unit) or ''
end

-- talentID, name, texture, selected, available, spellID, unknown, row, column, known, grantedByAura
W.GetTalentInfoByID = GetTalentInfoByID or function(talentID, specGroupIndex, ...)
    ---@diagnostic disable-next-line: undefined-global
    for tabIndex = 1, GetNumTalentTabs() do
        ---@diagnostic disable-next-line: undefined-global
        for talentIndex = 1, GetNumTalents(tabIndex) do
            local name, iconTexture, tier, column, rank, maxRank,
            isExceptional, available, previewRank, previewAvailable, id = GetTalentInfo(tabIndex, talentIndex)
            if id == talentID then
                return id, name, iconTexture, available == 1, available ~= 1, nil, nil, tier, column, available == 1,
                    false
            end
        end
    end
    return nil
end


W.C_Spell = C_Spell
if not W.C_Spell then
    W.C_Spell = {}
end

---@diagnostic disable-next-line: deprecated
W.C_Spell.GetSpellTexture = W.C_Spell.GetSpellTexture or GetSpellTexture

W.C_ClubFinder = C_ClubFinder
if not W.C_ClubFinder then
    W.C_ClubFinder = {}
end

W.C_ClubFinder.GetRecruitingClubInfoFromFinderGUID = W.C_ClubFinder.GetRecruitingClubInfoFromFinderGUID or function()
    return nil
end