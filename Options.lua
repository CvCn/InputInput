local N, T = ...
local W, M, U, D, G, L, E = unpack(T)
local OPT = {}
M.OPT = OPT

local options = CreateFrame("FRAME")
options.name = N
options:Hide()

if Settings and Settings.RegisterCanvasLayoutCategory then
    local category, layout = Settings.RegisterCanvasLayoutCategory(options, N);
    Settings.RegisterAddOnCategory(category);
    options.settingcategory = category
else
    ---@diagnostic disable-next-line: undefined-global
    InterfaceOptions_AddCategory(options)
end

local settings = {
    showChat = true,
    showChannel = true,
    showTime = false,
    showbg = false
}

-- 添加命令来打开设置页面
SLASH_INPUTINPUT1 = "/InputInput"
SLASH_INPUTINPUT2 = "/II"

local function OpenSettingsPanel()
    if Settings and SettingsPanel then
        Settings.OpenToCategory(options.settingcategory.ID)
    else
        ---@diagnostic disable-next-line: undefined-global
        InterfaceOptionsFrame_OpenToCategory(options)
        ---@diagnostic disable-next-line: undefined-global
        InterfaceOptionsFrame_OpenToCategory(options)
    end
end

SlashCmdList["INPUTINPUT"] = OpenSettingsPanel

local function changeSetting()
    M.MAIN:HideChat(settings.showChat)
    M.MAIN:HideChannel(settings.showChannel)
    M.MAIN:HideTime(settings.showTime)
    M.MAIN:Hidebg(settings.showbg)
end

function OPT:loadOPT()
    settings = D:ReadDB("settings", settings)

    -- 初始化和加载设置
    -- Show Chat 显示聊天
    local showChat = CreateFrame("CheckButton", N .. "showChat", options,
        "InterfaceOptionsCheckButtonTemplate")
    showChat:SetPoint("TOPLEFT", 16, -16)
    showChat.Text:SetText(L['Show Chat'])
    showChat:SetChecked(settings.showChat)

    -- 初始化和加载设置
    -- Show channel Name 时间戳
    local showTime = CreateFrame("CheckButton", N .. "showTime", options,
        "InterfaceOptionsCheckButtonTemplate")
    showTime:SetPoint("TOPLEFT", 32, -48)
    showTime.Text:SetText(L['Show Timestamp'])
    showTime:SetChecked(settings.showTime)

    -- 初始化和加载设置
    -- Show channel Name 聊天消息背景
    local showbg = CreateFrame("CheckButton", N .. "showbg", options,
        "InterfaceOptionsCheckButtonTemplate")
    showbg:SetPoint("TOPLEFT", 32, -80)
    showbg.Text:SetText(L['Show bg'])
    showbg:SetChecked(settings.showbg)

    -- 初始化和加载设置
    -- Show channel Name 显示频道名称
    local showChannel = CreateFrame("CheckButton", N .. "showChannel", options,
        "InterfaceOptionsCheckButtonTemplate")
    showChannel:SetPoint("TOPLEFT", 16, -118)
    showChannel.Text:SetText(L['Show channel Name'])
    showChannel:SetChecked(settings.showChannel)

    changeSetting()

    showChat:SetScript("OnClick", function(self)
        settings.showChat = self:GetChecked()
        D:SaveDB("settings", settings)
        changeSetting()
        if settings.showChat then
            showTime:Show()
        else
            showTime:Hide()
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
end
