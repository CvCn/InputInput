local W, M, U, D, G, L, E, API = unpack((select(2, ...)))
local ICON = {}
M.ICON = ICON

local C_Item_GetItemInfo = API.C_Item_GetItemInfo
local C_Item_GetDetailedItemLevelInfo = API.C_Item_GetDetailedItemLevelInfo
local C_Spell_GetSpellTexture = API.C_Spell_GetSpellTexture
local GetSpecializationInfoByID = API.GetSpecializationInfoByID
local GetTalentInfoByID = API.GetTalentInfoByID
local UnitTokenFromGUID = API.UnitTokenFromGUID
local UnitName = API.UnitName
local C_ClubFinder_GetRecruitingClubInfoFromFinderGUID = API.C_ClubFinder_GetRecruitingClubInfoFromFinderGUID
local GetAchievementInfo = API.GetAchievementInfo
local UnitClass = API.UnitClass
local C_CurrencyInfo_GetCurrencyInfo = API.C_CurrencyInfo_GetCurrencyInfo

local emotes = {
    { value = "angel",      key = L["angel"] },
    { value = "angry",      key = L["angry"] },
    { value = "biglaugh",   key = L["biglaugh"] },
    { value = "clap",       key = L["clap"] },
    { value = "cool",       key = L["cool"] },
    { value = "cry",        key = L["cry"] },
    { value = "cutie",      key = L["cutie"] },
    { value = "despise",    key = L["despise"] },
    { value = "dreamsmile", key = L["dreamsmile"] },
    { value = "embarrass",  key = L["embarrass"] },
    { value = "evil",       key = L["evil"] },
    { value = "excited",    key = L["excited"] },
    { value = "faint",      key = L["faint"] },
    { value = "fight",      key = L["fight"] },
    { value = "flu",        key = L["flu"] },
    { value = "freeze",     key = L["freeze"] },
    { value = "frown",      key = L["frown"] },
    { value = "greet",      key = L["greet"] },
    { value = "grimace",    key = L["grimace"] },
    { value = "growl",      key = L["growl"] },
    { value = "happy",      key = L["happy"] },
    { value = "heart",      key = L["heart"] },
    { value = "horror",     key = L["horror"] },
    { value = "ill",        key = L["ill"] },
    { value = "innocent",   key = L["innocent"] },
    { value = "kongfu",     key = L["kongfu"] },
    { value = "love",       key = L["love"] },
    { value = "mail",       key = L["mail"] },
    { value = "makeup",     key = L["makeup"] },
    { value = "mario",      key = L["mario"] },
    { value = "meditate",   key = L["meditate"] },
    { value = "miserable",  key = L["miserable"] },
    { value = "okay",       key = L["okay"] },
    { value = "pretty",     key = L["pretty"] },
    { value = "puke",       key = L["puke"] },
    { value = "shake",      key = L["shake"] },
    { value = "shout",      key = L["shout"] },
    { value = "shuuuu",     key = L["shuuuu"] },
    { value = "shy",        key = L["shy"] },
    { value = "sleep",      key = L["sleep"] },
    { value = "smile",      key = L["smile"] },
    { value = "suprise",    key = L["suprise"] },
    { value = "surrender",  key = L["surrender"] },
    { value = "sweat",      key = L["sweat"] },
    { value = "tear",       key = L["tear"] },
    { value = "tears",      key = L["tears"] },
    { value = "think",      key = L["think"] },
    { value = "titter",     key = L["titter"] },
    { value = "ugly",       key = L["ugly"] },
    { value = "victory",    key = L["victory"] },
    { value = "volunteer",  key = L["volunteer"] },
    { value = "wronged",    key = L["wronged"] },

    -- 使用blizzard默认材质
    { value = "wrong",      key = L["wrong"],     texture = "Interface\\RaidFrame\\ReadyCheck-NotReady" },
    { value = "right",      key = L["right"],     texture = "Interface\\RaidFrame\\ReadyCheck-Ready" },
    { value = "question",   key = L["question"],  texture = "Interface\\RaidFrame\\ReadyCheck-Waiting" },
    { value = "skull",      key = L["skull"],     texture = "Interface\\TargetingFrame\\UI-TargetingFrame-Skull" },
    { value = "sheep",      key = L["sheep"],     texture = "Interface\\TargetingFrame\\UI-TargetingFrame-Sheep" },

    { value = "Star",       key = L["Star"],      texture = "Interface\\TargetingFrame\\ui-raidtargetingicon_1" },
    { value = "Circle",     key = L["Circle"],    texture = "Interface\\TargetingFrame\\ui-raidtargetingicon_2" },
    { value = "Diamond",    key = L["Diamond"],   texture = "Interface\\TargetingFrame\\ui-raidtargetingicon_3" },
    { value = "Triangle",   key = L["Triangle"],  texture = "Interface\\TargetingFrame\\ui-raidtargetingicon_4" },
    { value = "Moon",       key = L["Moon"],      texture = "Interface\\TargetingFrame\\ui-raidtargetingicon_5" },
    { value = "Square",     key = L["Square"],    texture = "Interface\\TargetingFrame\\ui-raidtargetingicon_6" },
    { value = "Cross",      key = L["Cross"],     texture = "Interface\\TargetingFrame\\ui-raidtargetingicon_7" },
    { value = "Skull",      key = L["Skull"],     texture = "Interface\\TargetingFrame\\ui-raidtargetingicon_8" },
    { value = "rt1",        key = "rt1",          texture = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_1" },
    { value = "rt2",        key = "rt2",          texture = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_2" },
    { value = "rt3",        key = "rt3",          texture = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_3" },
    { value = "rt4",        key = "rt4",          texture = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_4" },
    { value = "rt5",        key = "rt5",          texture = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_5" },
    { value = "rt6",        key = "rt6",          texture = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_6" },
    { value = "rt7",        key = "rt7",          texture = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_7" },
    { value = "rt8",        key = "rt8",          texture = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_8" },
}

local function ReplaceEmote(value)
    if not value or value == '' then return '' end
    local emote = gsub(value, "[%{%}]", "")
    for _, v in ipairs(emotes) do
        if emote == v.key then
            return "|T" ..
                (v.texture or ("Interface\\AddOns\\InputInput\\Media\\Emotes\\" .. v.value)) ..
                ":" .. 15 .. "|t"
        end
    end
    return value
end
local itemshowLevel = {
    2, 4, 8, 9, 13, 17
}

local function ReplaceIconString(text)
    if not text or text == '' then return '' end
    local H_type, id = text:match("%|H(.-):(%d+)")
    local icon
    local suffix = ''
    if H_type then
        if H_type == 'item' then
            if ElvUI == nil then
                local itemName, itemLink, itemQuality, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount,
                itemEquipLoc, itemTexture, sellPrice, classID, subclassID, bindType, expansionID, setID, isCraftingReagent =
                    C_Item_GetItemInfo(id)
                icon = itemTexture
                if U:HasKey(itemshowLevel, classID) then
                    local effectiveILvl, isPreview, baseILvl = C_Item_GetDetailedItemLevelInfo(text:match("%|H(.-)|h"))
                    suffix = tostring(effectiveILvl)
                end
            end
        elseif H_type == 'spell' then
            if ElvUI == nil then
                local spellPath = C_Spell_GetSpellTexture(id)
                icon = spellPath
            end
        elseif H_type == 'achievement' then
            icon = select(10, GetAchievementInfo(id))
        elseif H_type == 'talentbuild' then
            if ElvUI == nil then
                -- local id, level = text:match("talentbuild:(.+):(%d+):")
                local _, _, _, path = GetSpecializationInfoByID(id)
                icon = path
                -- suffix = level
            end
        elseif H_type == 'talent' then -- |cff4e96f7|Htalent:1898:4|h[双生戒律]|h|r
            -- local id, level = text:match("talentbuild:(.+):(%d+):")
            local _, _, path = GetTalentInfoByID(tonumber(id), nil)
            icon = path
            -- suffix = level
        elseif H_type:match("trade:(.+)") then
            local guid, spellID, tradeSkillLineID = text:match("trade:(.+):(%d+):(%d+)")
            -- trade_level = level
            local unit = UnitTokenFromGUID(guid)
            if unit then
                local classColor = RAID_CLASS_COLORS[select(2, UnitClass(unit))]
                if not classColor then
                    classColor = {
                        colorStr = 'ffffffff'
                    }
                end
                suffix = string.format('|c%s%s|r', classColor.colorStr, UnitName(unit))
            end

            icon = C_Spell_GetSpellTexture(spellID)
        elseif H_type == 'quest' then
            -- local questId, questLevel = text:match("quest:(%d+):(%d+)")
            -- suffix = questLevel
            -- local tagID, tagName, worldQuestType, rarity, isElite, tradeskillLineIndex, displayTitle, isDaily, isStory = C_QuestLog.GetQuestTagInfo(questId)
        elseif H_type == 'currency' then
            if ElvUI == nil then
                local currencyInfo = C_CurrencyInfo_GetCurrencyInfo(id)
                icon = currencyInfo.iconFileID
            end
            local id, amount = text:match(
                "currency:(%d+):(%d+)")
            if amount and tonumber(amount) ~= nil and tonumber(amount) > 0 then
                suffix = amount
            end
        elseif H_type == 'dungeonScore' then
            icon = 'Interface\\Icons\\inv_relics_hourglass'
            suffix = id
        elseif H_type == 'keystone' then
            local id, challengeModeID, level, a1, a2, a3, a4 = text:match(
                "keystone:(%d+):(%d+):(%d+):(%d+):(%d+):(%d+):(%d+)")
            suffix = U:GetAffixName(a1, a2, a3, a4)
        elseif H_type == 'mount' then
            icon = C_Spell_GetSpellTexture(id)
        elseif H_type == 'enchant' then
            if not ElvUI then
                icon = C_Spell_GetSpellTexture(id)
            end
        end
    else
        H_type, id = text:match("%|H(.-):(.+)|h%[.-%]")
        if H_type then
            if H_type == 'clubFinder' then
                local clubInfo = C_ClubFinder_GetRecruitingClubInfoFromFinderGUID(id)
                if clubInfo and clubInfo.numActiveMembers > 0 then
                    suffix = '|Tinterface\\friendsframe\\ui-toast-chatinviteicon:15|t' .. clubInfo.numActiveMembers
                end
            end
        end
    end
    local itemSrtr = ''
    if icon then
        itemSrtr = '|T' .. icon .. ':15|t'
    end
    if suffix ~= '' then
        suffix = suffix .. ' '
    end
    local newText = U:join(" ", text, itemSrtr, suffix)
    return newText
end

function ICON:EmojiFilter(msg)
    if not msg or msg == '' then return '' end
    local re = msg
    re = gsub(re, "%{.-%}", ReplaceEmote)
    return re
end

function ICON:IconFilter(msg)
    if not msg or msg == '' then return '' end
    local re = msg
    re = gsub(re, "%|H.-%]%|h", ReplaceIconString)
    return re
end
