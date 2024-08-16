local W, M, U, D, G, L, E, API = unpack((select(2, ...)))

local version, buildVersion, buildDate, uiVersion = GetBuildInfo()


local function getVersion(v)
    local expansion, majorPatch, minorPatch = (v or "5.0.0"):match("^(%d+)%.(%d+)%.(%d+)")
    return (expansion or 0) * 10000 + (majorPatch or 0) * 100 + (minorPatch or 0)
end

local clientVersion = getVersion(version)

local function Fun(funTable)
    for name, t in pairs(funTable) do
        if t then
            for v, f in pairs(t) do
                if clientVersion >= getVersion(v) then
                    API[name] = f
                    break
                end
            end
            if not API[name] then
                API[name] = function() end
            end
        end
    end
end

Fun({
    C_Item_GetItemInfo = {
        ['10.2.6'] = C_Item and C_Item.GetItemInfo,
        ---@diagnostic disable-next-line: deprecated
        ['1.15.0'] = GetItemInfo
    },
    C_Item_GetDetailedItemLevelInfo = {
        ['10.2.6'] = C_Item and C_Item.GetDetailedItemLevelInfo,
        ---@diagnostic disable-next-line: deprecated
        ['1.0.0'] = GetDetailedItemLevelInfo
    },
    C_Spell_GetSpellTexture = {
        ['10.2.6'] = C_Spell and C_Spell.GetSpellTexture,
        ---@diagnostic disable-next-line: deprecated
        ['1.0.0'] = GetSpellTexture
    },
    GetSpecializationInfoByID = {
        ['5.0.4'] = GetSpecializationInfoByID
    },
    GetTalentInfoByID = {
        ['6.0.2'] = GetTalentInfoByID,
        ['3.4.3'] = function(talentID)
            ---@diagnostic disable-next-line: undefined-global
            for tabIndex = 1, GetNumTalentTabs() do
                ---@diagnostic disable-next-line: undefined-global
                for talentIndex = 1, GetNumTalents(tabIndex) do
                    local name, iconTexture, tier, column, rank, maxRank,
                    isExceptional, available, previewRank, previewAvailable, id = GetTalentInfo(tabIndex, talentIndex)
                    if id == talentID then
                        return id, name, iconTexture, available == 1, available ~= 1, nil, nil, tier, column,
                            available == 1,
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
    },
    UnitTokenFromGUID = {
        ['10.0.2'] = UnitTokenFromGUID
    },
    UnitName = {
        ['1.0.0'] = function(unit)
            local name, realm = UnitName(unit)
            if not realm then
                realm = GetRealmName()
            end
            return name, realm
        end
    },
    C_ClubFinder_GetRecruitingClubInfoFromFinderGUID = {
        ['4.0.0'] = C_ClubFinder and C_ClubFinder.GetRecruitingClubInfoFromFinderGUID

    },
    GetAchievementInfo = {
        ['1.0.0'] = GetAchievementInfo

    },
    C_CurrencyInfo_GetCurrencyInfo = {
        ['1.0.0'] = C_CurrencyInfo.GetCurrencyInfo

    },
    C_AddOns_IsAddOnLoaded = {
        ['10.2.0'] = C_AddOns and C_AddOns.IsAddOnLoaded,
        ---@diagnostic disable-next-line: deprecated
        ['1.0.0'] = IsAddOnLoaded
    },
    GetChannelList = {
        ['1.0.0'] = GetChannelList

    },
    IsInRaid = {
        ['1.0.0'] = IsInRaid
    },
    IsInGroup = {
        ['1.0.0'] = IsInGroup
    },
    IsInGuild = {
        ['1.0.0'] = IsInGuild
    },
    GetMaxPlayerLevel = {
        ['1.0.0'] = GetMaxPlayerLevel
    },
    UnitLevel = {
        ['1.0.0'] = UnitLevel
    },
    GetRealmName = {
        ['1.0.0'] = GetRealmName
    },
    C_BattleNet_GetAccountInfoByID = {
        ['1.0.0'] = C_BattleNet and C_BattleNet.GetAccountInfoByID,
    },
    GetPlayerInfoByGUID = {
        ['1.0.0'] = GetPlayerInfoByGUID,
    },
    UnitClass = {
        ['1.0.0'] = GetAchievementInfo
    },
    GetChannelName = {
        ['1.0.0'] = GetChannelName
    },
    IsShiftKeyDown = {
        ['1.0.0'] = IsShiftKeyDown
    },
    GetCursorPosition = {
        ['1.0.0'] = GetCursorPosition
    },
    InCombatLockdown = {
        ['1.0.0'] = InCombatLockdown
    },
    IsLeftControlKeyDown = {
        ['1.0.0'] = IsLeftControlKeyDown
    },
    IsLeftShiftKeyDown = {
        ['1.0.0'] = IsLeftShiftKeyDown
    },
    UnitGUID = {
        ['1.0.0'] = UnitGUID
    },
    BNGetInfo = {
        ['1.0.0'] = BNGetInfo
    },
    C_ChallengeMode_GetAffixInfo = {
        ['7.0.3'] = C_ChallengeMode and C_ChallengeMode.GetAffixInfo
    },
    C_BattleNet_GetFriendAccountInfo = {
        ['3.3.5'] = C_BattleNet and C_BattleNet.GetFriendAccountInfo
    },
    BNGetNumFriends = {
        ['1.0.0'] = BNGetNumFriends
    }
})
