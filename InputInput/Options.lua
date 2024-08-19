local W, M, U, D, G, L, E, API, LOG = unpack((select(2, ...)))
local OPT = {}
M.OPT = OPT

local C_AddOns_IsAddOnLoaded = API.C_AddOns_IsAddOnLoaded
local GetAddOnMemoryUsage = API.GetAddOnMemoryUsage
local C_AddOns_GetAddOnEnableState = API.C_AddOns_GetAddOnEnableState

local settings = {
    showChat = true,
    showChannel = true,
    showTime = true,
    showbg = false,
    enableIL_zh = true
}


local options = CreateFrame("FRAME")
options.name = W.N
options:Hide()

local texture = options:CreateTexture(nil, "BACKGROUND")
texture:SetPoint("RIGHT", options, "RIGHT", -50, 0)
texture:SetTexture("Interface/AddOns/InputInput/Media/pet_type_dragon")
texture:SetSize(150, 150)

local title = options:CreateFontString(nil, "OVERLAY", "GameFontNormal")
title:SetPoint("TOPLEFT", options, "TOPLEFT", 20, -20)
title:SetText(W.colorName)
local font, fontsize, flags = title:GetFont()
---@diagnostic disable-next-line: param-type-mismatch
title:SetFont(font, 28, flags)

local button = CreateFrame("Button", nil, options, "UIPanelButtonTemplate")
button:SetSize(120, 25)
button:SetPoint("TOPRIGHT", options, "TOPRIGHT", -20, -20)
button:SetText(L['Default Setting'])

if Settings and Settings.RegisterCanvasLayoutCategory then
    local category, layout = Settings.RegisterCanvasLayoutCategory(options, W.N);
    Settings.RegisterAddOnCategory(category);
    options.settingcategory = category
else
    InterfaceOptions_AddCategory(options)
end

-- 添加命令来打开设置页面
SLASH_INPUTINPUT1 = "/InputInput"
SLASH_INPUTINPUT2 = "/II"

local function OpenSettingsPanel()
    if Settings and SettingsPanel then
        Settings.OpenToCategory(options.settingcategory.ID)
    else
        InterfaceOptionsFrame_OpenToCategory(options)

        InterfaceOptionsFrame_OpenToCategory(options)
    end
end

SlashCmdList["INPUTINPUT"] = OpenSettingsPanel

local function changeSetting()
    M.MAIN:HideChat(settings.showChat)
    M.MAIN:HideChannel(settings.showChannel)
    M.MAIN:HideTime(settings.showTime)
    M.MAIN:Hidebg(settings.showbg)
    M.MAIN:EnableIL_zh(settings.enableIL_zh)
end

---@param addonName string
---@return string
local function GetAddonMemory(addonName)
    -- 获取插件的内存占用（以 KB 为单位）
    local memoryUsage = GetAddOnMemoryUsage(addonName)
    -- 转换为 MB（可选）
    local memoryUsageMB = memoryUsage / 1024
    if memoryUsageMB == 0 then
        return ''
    else
        return '(' .. math.floor(memoryUsageMB) .. 'MB)'
    end
end

function OPT:loadOPT()
    settings = D:ReadDB("settings", settings)
    settings.enableIL_zh = C_AddOns_GetAddOnEnableState("InputInput_Libraries_zh") == 2
    -- Show Chat 显示聊天
    local showChat = CreateFrame("CheckButton", W.N .. "showChat", options,
        "InterfaceOptionsCheckButtonTemplate")
    showChat:SetPoint("TOPLEFT", 16, -66)
    showChat.Text:SetText(L['Show Chat'])
    showChat:SetChecked(settings.showChat)

    -- 时间戳
    local showTime = CreateFrame("CheckButton", W.N .. "showTime", options,
        "InterfaceOptionsCheckButtonTemplate")
    showTime:SetPoint("TOPLEFT", 32, -98)
    showTime.Text:SetText(L['Show Timestamp'])
    showTime:SetChecked(settings.showTime)

    -- 聊天消息背景
    local showbg = CreateFrame("CheckButton", W.N .. "showbg", options,
        "InterfaceOptionsCheckButtonTemplate")
    showbg:SetPoint("TOPLEFT", 32, -130)
    showbg.Text:SetText(L['Show bg'])
    showbg:SetChecked(settings.showbg)

    -- 显示频道名称
    local showChannel = CreateFrame("CheckButton", W.N .. "showChannel", options,
        "InterfaceOptionsCheckButtonTemplate")
    showChannel:SetPoint("TOPLEFT", 16, -168)
    showChannel.Text:SetText(L['Show channel Name'])
    showChannel:SetChecked(settings.showChannel)

    -- 启用|cff409EFF|cffF56C6Ci|rnput|cffF56C6Ci|rnput|r_Libraries_|cffF56C6Czh|r
    local enableIL_zh = CreateFrame("CheckButton", W.N .. "enableIL_zh", options,
        "InterfaceOptionsCheckButtonTemplate")
    enableIL_zh:SetPoint("TOPLEFT", 16, -206)
    -- enableIL_zh.Text:SetText(format(L['Enable InputInput_Libraries_zh'],
    --     'InputInput_Libraries_zh'))
    -- enableIL_zh:Hide()

    -- 添加鼠标提示的显示和隐藏事件
    enableIL_zh:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")                                                       -- 设置提示框的位置
        GameTooltip:SetText(L['Chinese word processing module can make input prompts more intelligent']) -- 设置提示框的内容
        GameTooltip:Show()                                                                               -- 显示提示框
    end)

    enableIL_zh:SetScript("OnLeave", function(self)
        GameTooltip:Hide() -- 隐藏提示框
    end)


    options:SetScript("OnShow", function(self)
        UpdateAddOnMemoryUsage()
        enableIL_zh.Text:SetText(format(L['Enable InputInput_Libraries_zh'],
                '|cff409EFF|cffF56C6Ci|rnput|cffF56C6Ci|rnput|r_Libraries_|cffF56C6Czh|r') ..
            ' |cFF909399' .. GetAddonMemory('InputInput_Libraries_zh') .. ' (' .. L['Need To Reload'] .. ')|r')
        settings.enableIL_zh = C_AddOns_GetAddOnEnableState("InputInput_Libraries_zh") == 2
        enableIL_zh:SetChecked(settings.enableIL_zh)
    end)

    changeSetting()

    showChat:SetScript("OnClick", function(self)
        settings.showChat = self:GetChecked()
        D:SaveDB("settings", settings)
        changeSetting()
        if settings.showChat then
            showTime:Show()
            showbg:Show()
            showChannel:SetPoint("TOPLEFT", 16, -168)
            enableIL_zh:SetPoint("TOPLEFT", 16, -206)
        else
            showTime:Hide()
            showbg:Hide()
            showChannel:SetPoint("TOPLEFT", 16, -98)
            enableIL_zh:SetPoint("TOPLEFT", 16, -136)
        end
    end)
    showChannel:SetScript("OnClick", function(self)
        settings.showChannel = self:GetChecked()
        D:SaveDB("settings", settings)
        changeSetting()
    end)
    showTime:SetScript("OnClick", function(self)
        settings.showTime = self:GetChecked()
        D:SaveDB("settings", settings)
        changeSetting()
    end)
    showbg:SetScript("OnClick", function(self)
        settings.showbg = self:GetChecked()
        D:SaveDB("settings", settings)
        changeSetting()
    end)
    enableIL_zh:SetScript("OnClick", function(self)
        settings.enableIL_zh = self:GetChecked()
        D:SaveDB("settings", settings)
        changeSetting()
    end)

    button:SetScript("OnClick", function()
        settings = {
            showChat = true,
            showChannel = true,
            showTime = true,
            showbg = false,
            enableIL_zh = true
        }
        D:SaveDB("settings", settings)
        changeSetting()
        showChat:SetChecked(settings.showChat)
        if settings.showChat then
            showTime:Show()
            showbg:Show()
            showChannel:SetPoint("TOPLEFT", 16, -168)
            enableIL_zh:SetPoint("TOPLEFT", 16, -206)
        else
            showTime:Hide()
            showbg:Hide()
            showChannel:SetPoint("TOPLEFT", 16, -98)
            enableIL_zh:SetPoint("TOPLEFT", 16, -136)
        end
        showTime:SetChecked(settings.showTime)
        showbg:SetChecked(settings.showbg)
        showChannel:SetChecked(settings.showChannel)
        enableIL_zh:SetChecked(settings.enableIL_zh)
    end)
end
