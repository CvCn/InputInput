local W, M, U, D, G, L, E, API, LOG = unpack((select(2, ...)))

local version, buildVersion, buildDate, uiVersion = GetBuildInfo()

-- 斩断 ctr+shift+m


-- 版本信息
-- @param v 版本号
-- @return 版本号（number）
function W:getVersion(v)
    local expansion, majorPatch, minorPatch = (v or "1.0.0"):match("^(%d+)%.(%d+)%.(%d+)")
    return (expansion or 0) * 10000 + (majorPatch or 0) * 100 + (minorPatch or 0)
end

function U:sortTableByKey(t, comp)
    -- 创建一个键的数组
    local keys = {}
    for k in pairs(t) do
        table.insert(keys, k)
    end

    -- 对键进行排序，支持自定义比较函数
    table.sort(keys, comp)

    -- 创建一个新的表来存储排序后的键值对
    local sortedTable = {}
    for _, k in ipairs(keys) do
        sortedTable[k] = t[k]
    end

    return sortedTable
end

local clientVersion = W:getVersion(version)
W.ClientVersion = clientVersion

local function Fun(funTable)
    for name, t in pairs(funTable) do
        if t then
            t = U:sortTableByKey(t, function(a1, a2)
                -- LOG:Debug(a1)
                return W:getVersion(a1) < W:getVersion(a2)
            end)
            for v, f in pairs(t) do
                -- LOG:Debug(name, clientVersion, getVersion(v))
                if clientVersion >= W:getVersion(v) then
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
    -- Returns info for an item.
    C_Item_GetItemInfo = {
        ['10.2.6'] = C_Item and C_Item.GetItemInfo,
        ---@diagnostic disable-next-line: deprecated
        ['1.15.0'] = GetItemInfo
    },
    -- Returns detailed item level info.
    C_Item_GetDetailedItemLevelInfo = {
        ['10.2.6'] = C_Item and C_Item.GetDetailedItemLevelInfo,
        ---@diagnostic disable-next-line: deprecated
        ['1.0.0'] = GetDetailedItemLevelInfo
    },
    -- Returns the icon texture of a spell.
    C_Spell_GetSpellTexture = {
        ['10.2.6'] = C_Spell and C_Spell.GetSpellTexture,
        ---@diagnostic disable-next-line: deprecated
        ['1.0.0'] = GetSpellTexture
    },
    --  Returns information about the specified specialization.
    GetSpecializationInfoByID = {
        ['5.0.4'] = GetSpecializationInfoByID
    },
    -- Returns information about a talent.
    GetTalentInfoByID = {
        ['6.0.2'] = GetTalentInfoByID,
        ['3.4.3'] = function(talentID)
            for tabIndex = 1, GetNumTalentTabs() do
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
            for tabIndex = 1, GetNumTalentTabs() do
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
    -- clubInfo
    C_ClubFinder_GetRecruitingClubInfoFromFinderGUID = {
        ['4.0.0'] = C_ClubFinder and C_ClubFinder.GetRecruitingClubInfoFromFinderGUID
    },
    -- Returns info for an achievement.
    GetAchievementInfo = {
        ['1.0.0'] = GetAchievementInfo
    },
    -- Returns info for a currency by ID.
    C_CurrencyInfo_GetCurrencyInfo = {
        ['1.0.0'] = C_CurrencyInfo.GetCurrencyInfo
    },
    -- Returns true if the specified addon is loaded.
    C_AddOns_IsAddOnLoaded = {
        ['10.2.0'] = C_AddOns and C_AddOns.IsAddOnLoaded,
        ---@diagnostic disable-next-line: deprecated
        ['1.0.0'] = IsAddOnLoaded
    },
    --  Returns the list of joined chat channels.
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
        ['1.0.0'] = UnitClass
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
    -- Returns true if the combat lockdown restrictions are active.
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
        ['1.1.0'] = C_BattleNet and C_BattleNet.GetFriendAccountInfo
    },
    BNGetNumFriends = {
        ['1.0.0'] = BNGetNumFriends
    },
    GetNumGuildMembers = {
        ['1.0.0'] = GetNumGuildMembers
    },
    GetGuildRosterInfo = {
        ['1.0.0'] = GetGuildRosterInfo
    },
    GetNumGroupMembers = {
        ['1.0.0'] = GetNumGroupMembers
    },
    GetZoneText = {
        ['1.0.0'] = GetZoneText
    },
    GetSubZoneText = {
        ['1.0.0'] = GetSubZoneText
    },
    -- Queries the enabled state of an addon, optionally for a specific character.
    C_AddOns_GetAddOnEnableState = {
        ['10.2.0'] = C_AddOns and C_AddOns.GetAddOnEnableState,
        ['1.0.0'] = function(name, character)
            ---@diagnostic disable-next-line: deprecated
            return GetAddOnEnableState(character, name)
        end
    },
    C_AddOns_EnableAddOn = {
        ['10.2.0'] = C_AddOns and C_AddOns.EnableAddOn,
        ---@diagnostic disable-next-line: deprecated
        ['1.0.0'] = EnableAddOn
    },
    C_AddOns_DisableAddOn = {
        ['10.2.0'] = C_AddOns and C_AddOns.DisableAddOn,
        ---@diagnostic disable-next-line: deprecated
        ['1.0.0'] = DisableAddOn
    },
    --  Returns the memory used for an addon.
    GetAddOnMemoryUsage = {
        ['1.0.0'] = GetAddOnMemoryUsage
    },
    --  Returns the game client locale.
    GetLocale = {
        ['1.0.0'] = GetLocale
    },
    C_ChatInfo_SendAddonMessage = {
        ['1.0.0'] = C_ChatInfo and C_ChatInfo.SendAddonMessage
    },
    C_ChatInfo_RegisterAddonMessagePrefix = {
        ['1.0.0'] = C_ChatInfo and C_ChatInfo.RegisterAddonMessagePrefix
    },
    C_AddOns_GetAddOnMetadata = {
        ['1.0.0'] = C_AddOns and C_AddOns.GetAddOnMetadata
    },
    C_Timer_After = {
        ['1.0.0'] = C_Timer and C_Timer.After
    }
})


local C_AddOns_GetAddOnMetadata = API.C_AddOns_GetAddOnMetadata
W.version = C_AddOns_GetAddOnMetadata('InputInput', 'Version')
