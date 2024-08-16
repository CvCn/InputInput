local W, M, U, D, G, L, E, API = unpack((select(2, ...)))

local version, buildVersion, buildDate, uiVersion = GetBuildInfo()


local function getVersion(v)
    local expansion, majorPatch, minorPatch = (v or "5.0.0"):match("^(%d+)%.(%d+)%.(%d+)")
    return (expansion or 0) * 10000 + (majorPatch or 0) * 100 + (minorPatch or 0)
end

local clientVersion = getVersion(version)

do
    local currVersion
    local v = {
        Classic = 'Classic',
        TBC = 'TBC',
        WotLK = 'WotLK',
        Cataclysm = 'Cataclysm',
        MoP = 'MoP',
        TWW = 'TWW'
    }

    if clientVersion < 20000 then
        currVersion = v.Classic
    elseif clientVersion < 30000 then
        currVersion = v.TBC
    elseif clientVersion < 40000 then
        currVersion = v.WotLK
    elseif clientVersion < 50000 then
        currVersion = v.Cataclysm
    elseif clientVersion < 60000 then
        currVersion = v.MoP
    elseif clientVersion >= 110000 then
        currVersion = v.TWW
    end
end

local function Fun(funTable)
    if not funTable then return end
    for k, v in pairs(funTable) do
        if clientVersion >= getVersion(k) then
            return v
        end
    end
    return function() end
end

API.C_Item_GetItemInfo = Fun({
    ['10.2.6'] = C_Item and C_Item.GetItemInfo,
    ---@diagnostic disable-next-line: deprecated
    ['1.15.0'] = GetItemInfo
})

API.C_Item_GetDetailedItemLevelInfo = Fun({
    ['10.2.6'] = C_Item and C_Item.GetDetailedItemLevelInfo,
    ---@diagnostic disable-next-line: deprecated
    ['1.0.0'] = GetDetailedItemLevelInfo
})

API.C_Spell_GetSpellTexture = Fun({
    ['10.2.6'] = C_Spell and C_Spell.GetSpellTexture,
    ---@diagnostic disable-next-line: deprecated
    ['1.0.0'] = GetSpellTexture
})
API.GetSpecializationInfoByID = Fun({
    ['5.0.4'] = GetSpecializationInfoByID
})
API.GetTalentInfoByID = Fun({
    ['6.0.2'] = GetTalentInfoByID,
    ['3.4.3'] = function(talentID)
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
    end,
    ['1.0.0'] = function(talentID)
        ---@diagnostic disable-next-line: undefined-global
        for tabIndex = 1, GetNumTalentTabs() do
            ---@diagnostic disable-next-line: undefined-global
            for talentIndex = 1, GetNumTalents(tabIndex) do
                local talentName, iconTexture, tier, column, rank, maxRank, meetsPrereq, previewRank, meetsPreviewPrereq, isExceptional, goldBorder, id =
                    GetTalentInfo(tabIndex, talentIndex)
                if id == talentID then
                    return id, talentName, iconTexture, previewRank > 1, previewRank == 0, nil, nil, tier, column,
                        previewRank > 1,
                        false
                end
            end
        end
        return nil
    end
})

API.UnitTokenFromGUID = Fun({
    ['10.0.2'] = UnitTokenFromGUID
})
API.UnitName = Fun({
    ['1.0.0'] = function(unit)
        local name, realm = UnitName(unit)
        if not realm then
            realm = GetRealmName()
        end
        return name, realm
    end

})
API.C_ClubFinder_GetRecruitingClubInfoFromFinderGUID = Fun({
    ['4.0.0'] = C_ClubFinder and C_ClubFinder.GetRecruitingClubInfoFromFinderGUID
})

API.GetAchievementInfo = Fun({
    ['1.0.0'] = GetAchievementInfo
})
API.UnitClass = Fun({
    ['1.0.0'] = UnitClass
})
API.C_CurrencyInfo_GetCurrencyInfo = Fun({
    ['1.0.0'] = C_CurrencyInfo.GetCurrencyInfo
})

API.C_AddOns_IsAddOnLoaded = Fun({
    ['10.2.0'] = C_AddOns and C_AddOns.IsAddOnLoaded,
    ---@diagnostic disable-next-line: deprecated
    ['1.0.0'] = IsAddOnLoaded
})

API.GetChannelList = Fun({
    ['1.0.0'] = GetChannelList
})

API.IsInRaid = Fun({
    ['1.0.0'] = IsInRaid
})
API.IsInGroup = Fun({
    ['1.0.0'] = IsInGroup
})

API.IsInGuild = Fun({
    ['1.0.0'] = IsInGuild
})

API.GetMaxPlayerLevel = Fun({
    ['1.0.0'] = GetMaxPlayerLevel
})
API.UnitLevel = Fun({
    ['1.0.0'] = UnitLevel
})

API.GetRealmName = Fun({
    ['1.0.0'] = GetRealmName
})

API.C_BattleNet_GetAccountInfoByID = Fun({
    ['1.0.0'] = C_BattleNet and C_BattleNet.GetAccountInfoByID,
})

API.GetPlayerInfoByGUID = Fun({
    ['1.0.0'] = GetPlayerInfoByGUID,
})

API.UnitClass = Fun({
    ['1.0.0'] = GetAchievementInfo
})

API.GetChannelName = Fun({
    ['1.0.0'] = GetChannelName
})

API.IsShiftKeyDown = Fun({
    ['1.0.0'] = IsShiftKeyDown
})

API.GetCursorPosition = Fun({
    ['1.0.0'] = GetCursorPosition
})

API.InCombatLockdown = Fun({
    ['1.0.0'] = InCombatLockdown
})

API.IsLeftControlKeyDown = Fun({
    ['1.0.0'] = IsLeftControlKeyDown
})

API.IsLeftShiftKeyDown = Fun({
    ['1.0.0'] = IsLeftShiftKeyDown
})

API.UnitGUID = Fun({
    ['1.0.0'] = UnitGUID
})
API.BNGetInfo = Fun({
    ['1.0.0'] = BNGetInfo
})
API.C_ChallengeMode_GetAffixInfo = Fun({
    ['7.0.3'] = C_ChallengeMode and C_ChallengeMode.GetAffixInfo
})
API.C_BattleNet_GetFriendAccountInfo = Fun({
    ['3.3.5'] = C_BattleNet and C_BattleNet.GetFriendAccountInfo
})

API.BNGetNumFriends = Fun({
    ['1.0.0'] = BNGetNumFriends
})
