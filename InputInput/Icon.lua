local W, M, U, D, G, L, E, API, LOG = unpack((select(2, ...)))
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

-- ReplaceEmote函数：将传入的字符串中的表情符号替换为游戏内的表情图标
---@param value string|nil 待处理的字符串
---@return string 替换后的字符串，如果传入的字符串为空或只包含表情符号，则返回空字符串
local function ReplaceEmote(value)
    -- 检查传入的字符串是否为空或只包含表情符号，如果是，则直接返回空字符串
    if not value or value == '' then return '' end

    -- 移除字符串中的所有表情符号，以获取纯文本部分
    local emote = gsub(value, "[%{%}]", "")

    -- 遍历预定义的表情符号列表
    for _, v in ipairs(emotes) do
        -- 检查移除表情符号后的文本是否与列表中的某个表情符号键匹配
        if emote == v.key then
            -- 如果匹配，则返回对应的游戏内表情图标代码
            return "|T" ..
                (v.texture or ("Interface\\AddOns\\InputInput\\Media\\Emotes\\" .. v.value)) ..
                ":" .. 15 .. "|t"
        end
    end

    -- 如果没有找到匹配的表情符号，则直接返回原始字符串
    return value
end
local itemshowLevel = {
    2, 4, 8, 9, 13, 17
}

---@param text string 输入的字符串，可能包含各种类型的编码
---@return string 返回替换后的字符串，其中编码被替换为相应的图标和后缀
-- 该函数的主要作用是解析输入字符串中的特殊编码，并将其替换为游戏内的图标和后缀信息
local function ReplaceIconString(text)
    -- 如果输入为空，直接返回空字符串
    if not text or text == '' then return '' end
    
    -- 通过正则表达式匹配出字符串中的编码类型和ID
    local H_type, id = text:match("%|H(.-):(%d+)")
    local icon
    local suffix = ''
    
    -- 根据不同的编码类型，执行相应的处理逻辑
    if H_type then
        if H_type == 'item' then
            -- 如果ElvUI不存在，则通过C_Item_GetItemInfo接口获取物品信息
            if ElvUI == nil then
                local itemName, itemLink, itemQuality, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount,
                itemEquipLoc, itemTexture, sellPrice, classID, subclassID, bindType, expansionID, setID, isCraftingReagent =
                    C_Item_GetItemInfo(id)
                -- 设置物品的图标
                icon = itemTexture
                
                -- 如果物品显示级别设置中包含该物品的类别ID，则获取并设置物品的有效等级作为后缀
                if U:HasKey(itemshowLevel, classID) then
                    local effectiveILvl, isPreview, baseILvl = C_Item_GetDetailedItemLevelInfo(text:match("%|H(.-)|h"))
                    suffix = tostring(effectiveILvl)
                end
            end
        elseif H_type == 'spell' then
            -- 如果ElvUI不存在，则通过C_Spell_GetSpellTexture接口获取法术图标
            if ElvUI == nil then
                local spellPath = C_Spell_GetSpellTexture(id)
                icon = spellPath
            end
        elseif H_type == 'achievement' then
            -- LOG:Debug(id)
            icon = select(10, GetAchievementInfo(id))
        elseif H_type == 'talentbuild' then
            -- 如果ElvUI不存在，则通过GetSpecializationInfoByID接口获取专精信息，并设置专精的图标
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
            -- 解析交易技能编码，并设置相应的图标和后缀
            local guid, spellID, tradeSkillLineID = text:match("trade:(.+):(%d+):(%d+)")
            -- trade_level = level
            local unit = UnitTokenFromGUID(guid)
            if unit then
                local classColor = RAID_CLASS_COLORS[select(2, UnitClass(unit))]
                if not classColor then
                    ---@diagnostic disable-next-line: missing-fields
                    classColor = {
                        colorStr = 'ffffffff'
                    }
                end
                -- 设置交易技能的后缀为单位名称，带职业颜色编码
                suffix = string.format('|c%s%s|r', classColor.colorStr, UnitName(unit))
            end
            
            -- 设置交易技能的图标为法术图标
            icon = C_Spell_GetSpellTexture(spellID)
        elseif H_type == 'quest' then
            -- 解析任务编码，并设置任务的图标和后缀
            -- local questId, questLevel = text:match("quest:(%d+):(%d+)")
            -- suffix = questLevel
            -- local tagID, tagName, worldQuestType, rarity, isElite, tradeskillLineIndex, displayTitle, isDaily, isStory = C_QuestLog.GetQuestTagInfo(questId)
        elseif H_type == 'currency' then
            -- 如果ElvUI不存在，则通过C_CurrencyInfo_GetCurrencyInfo接口获取货币信息，并设置货币的图标
            if ElvUI == nil then
                local currencyInfo = C_CurrencyInfo_GetCurrencyInfo(id)
                icon = currencyInfo.iconFileID
            end
            -- 解析货币数量，并设置为后缀
            local id, amount = text:match(
                "currency:(%d+):(%d+)")
            if amount and tonumber(amount) ~= nil and tonumber(amount) > 0 then
                suffix = amount
            end
        elseif H_type == 'dungeonScore' then
            -- 设置地下城评分的图标和后缀
            icon = 'Interface\\Icons\\inv_relics_hourglass'
            suffix = id
        elseif H_type == 'keystone' then
            -- 解析钥石编码，并设置相应的后缀
            local id, challengeModeID, level, a1, a2, a3, a4 = text:match(
                "keystone:(%d+):(%d+):(%d+):(%d+):(%d+):(%d+):(%d+)")
            suffix = U:GetAffixName(a1, a2, a3, a4)
        elseif H_type == 'mount' then
            -- 设置坐骑的图标为法术图标
            icon = C_Spell_GetSpellTexture(id)
        elseif H_type == 'enchant' then
            -- 如果ElvUI不存在，则通过C_Spell_GetSpellTexture接口获取附魔的图标
            if not ElvUI then
                icon = C_Spell_GetSpellTexture(id)
            end
        end
    else
        -- 处理不含H_type的编码
        H_type, id = text:match("%|H(.-):(.+)|h%[.-%]")
        if H_type then
            if H_type == 'clubFinder' then
                -- 解析公会查找器编码，并设置相应的后缀
                local clubInfo = C_ClubFinder_GetRecruitingClubInfoFromFinderGUID(id)
                if clubInfo and clubInfo.numActiveMembers > 0 then
                    suffix = '|Tinterface\\friendsframe\\ui-toast-chatinviteicon:15|t' .. clubInfo.numActiveMembers
                end
            end
        end
    end
    
    -- 将解析得到的图标和后缀拼接到原始字符串上，并返回结果
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
