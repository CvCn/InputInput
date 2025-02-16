local W, M, U, D, G, L, E, API, LOG = unpack((select(2, ...)))
local OPT = {}
M.OPT = OPT

local C_AddOns_IsAddOnLoaded = API.C_AddOns_IsAddOnLoaded
local GetAddOnMemoryUsage = API.GetAddOnMemoryUsage
local C_AddOns_GetAddOnEnableState = API.C_AddOns_GetAddOnEnableState

local options = CreateFrame("FRAME")
options.name = W.N
options:Hide()
-- options:GetFontObject():SetTextColor(1, 1, 1)

local title = options:CreateFontString(nil, "OVERLAY", "GameFontNormal")
title:SetPoint("TOPLEFT", options, "TOPLEFT", 20, -20)
title:SetText(W.colorName)
local font, _, flags = title:GetFont()
---@diagnostic disable-next-line: param-type-mismatch
title:SetFont(font, 28, flags)

local title2 = options:CreateFontString(nil, "OVERLAY", "GameFontNormal")
title2:SetPoint("TOPLEFT", title, "TOPRIGHT", 0, 0)
title2:SetText('Bete')
local font2, _, flags2 = title:GetFont()
---@diagnostic disable-next-line: param-type-mismatch
title2:SetFont(font2, 12, flags2)
title2:SetTextColor(245 / 255, 108 / 255, 108 / 255)
if E ~= 'BETE' then
    title2:Hide()
end
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

local function changeSetting(settings)
    M.MAIN:HideChat(settings.showChat)
    M.MAIN:HideChannel(settings.showChannel)
    M.MAIN:HideTime(settings.showTime)
    M.MAIN:Hidebg(settings.showbg)
    M.MAIN:EnableIL_zh(settings.enableIL_zh)
    M.MAIN:MultiTip(settings.showMultiTip)
    M.MAIN:DisableLoginInformation(settings.disableLoginInformation)

    -- M:Fire('MAIN', 'HideChat', settings.showChat)
    -- M:Fire('MAIN', 'HideChannel', settings.showChannel)
    -- M:Fire('MAIN', 'HideTime', settings.showTime)
    -- M:Fire('MAIN', 'Hidebg', settings.showbg)
    -- M:Fire('MAIN', 'EnableIL_zh', settings.enableIL_zh)
    -- M:Fire('MAIN', 'MultiTip', settings.showMultiTip)
end
local afterMemory = 0
---@param addonName string
---@return string
local function GetAddonMemory(addonName)
    if C_AddOns_GetAddOnEnableState(addonName) == 2 then
        if GetTime() - afterMemory > 30 then
            UpdateAddOnMemoryUsage()
            afterMemory = GetTime()
        end
        -- 获取插件的内存占用（以 KB 为单位）
        local memoryUsage = GetAddOnMemoryUsage(addonName)
        -- 转换为 MB（可选）
        local memoryUsageMB = memoryUsage / 1024
        if memoryUsageMB == 0 then
            return ''
        else
            return '(' .. (math.floor(memoryUsageMB * 100) / 100) .. 'MB)'
        end
    end
    return ''
end

local option_info = M.OPTCONFIG.optionConfig

local settings = {
}
local this = {}
OPT.this = this
local function InItOPT(config, preX, preY, name)
    preX = preX or 0
    preY = preY or 0
    config = config or option_info
    local offsetX = 16
    local offsetY = -32
    local nextY = 0
    for i, v in ipairs(config) do
        local baseX = preX + 16
        local baseY = preY
        local frame = nil
        if v.type == 'CheckButton' then
            frame = this[v.name] or
                CreateFrame(v.type, W.N .. v.name, options, "InterfaceOptionsCheckButtonTemplate")
            if name ~= v.name then
                frame:SetChecked(settings[v.name] ~= nil and settings[v.name] or v.default)
            end
            frame.Text:SetText(v.text)
            if frame:HasScript("OnClick") then
                frame:SetScript('OnClick', function(...)
                    local self = ...
                    local open = self:GetChecked()
                    settings[v.name] = open
                    D:SaveDB("settings", settings)
                    if self.IIConfig.subElement then
                        for _, v2 in ipairs(self.IIConfig.subElement) do
                            if open then
                                this[v2.name]:Show()
                            else
                                this[v2.name]:Hide()
                            end
                        end
                        InItOPT(nil, nil, -32, v.name)
                    end
                    if v.click then
                        v.click(this, ...)
                    end
                    changeSetting(settings)
                end)
            end
        end
        if v.type == 'text' then
            frame = this[v.name] or options:CreateFontString(W.N .. v.name, "OVERLAY", "GameFontNormal")
            frame:SetText(v.text)
            frame:SetJustifyH('LEFT')
            frame:SetTextColor(1, 1, 1)
            frame:SetWordWrap(true) -- 启用换行
            frame:SetWidth(600)
        end
        if v.type == 'BTNGroup' then
            frame = CreateFrame("FRAME", W.N .. v.name, options)
            frame:SetSize(600, 200)
            for idx, btnConfig in ipairs(v.BTNElement) do
                local btn = this[btnConfig.name] or CreateFrame("Button", W.N .. btnConfig.name, frame, "UIPanelButtonTemplate")
                btn:SetSize(50, 50)
                btn:SetText(btnConfig.text)
                -- 设置按钮普通状态的材质
                local normalTexture = this[btnConfig.name .. 'Texture'] or btn:CreateTexture(nil, "BACKGROUND")
                normalTexture:SetAllPoints()
                normalTexture:SetTexture(btnConfig.texture) -- 指定材质路径
                btn:SetNormalTexture(normalTexture)
                btn:SetPoint("TOPLEFT", idx * 100, 0)

                -- 获取按钮的文字对象
                local fontString = btn:GetFontString()
                -- 调整文字位置到底部
                -- local fontFile, fontHeight, flags = fontString:GetFont()
                -- fontString:SetFont(fontFile or W.defaultFontName, fontHeight * 0.67, flags)
                fontString:SetPoint("TOP", btn, "BOTTOM", 0, 0) -- 底部位置，微调 Y 坐标

                if btn:HasScript("OnClick") then
                    btn:SetScript('OnClick', function(...)
                        if btnConfig.click then
                            btnConfig.click(this, ...)
                        end
                    end)
                end
                this[btnConfig.name] = btn
                this[btnConfig.name .. 'Texture'] = normalTexture
            end
        end
        if frame then
            this[v.name] = frame
            frame.IIConfig = v
            local thisY = baseY + i * offsetY
            if i > 1 and config[i - 1].type == 'text' then
                local h = this[config[i - 1].name]:GetHeight()
                thisY = thisY - h
            end
            nextY = thisY + 32
            frame:SetPoint("TOPLEFT", baseX, thisY)
            if v.enter then
                frame:SetScript('OnEnter', function(...)
                    v.enter(this, ...)
                end)
            end
            if v.leave then
                frame:SetScript('OnLeave', function(...)
                    v.leave(this, ...)
                end)
            end
            if v.subElement and #v.subElement > 0 and settings[v.name] then
                preY = InItOPT(v.subElement, baseX + offsetX, thisY)
            end
        end
    end
    return nextY
end

local function InitConfig(config, s, isDefault)
    for _, v in ipairs(config) do
        if v.type == 'CheckButton' then
            if isDefault then
                s[v.name] = v.default
            else
                if s[v.name] == nil then
                    s[v.name] = v.default
                end
            end
        end
        if v.subElement and #v.subElement > 0 then
            InitConfig(v.subElement, s, isDefault)
        end
    end
    return s
end
function OPT:loadOPT()
    settings = D:ReadDB("settings", settings)
    InItOPT(nil, nil, -32)
    options:SetScript("OnShow", function(self)
        U:Delay(0.01, function()
            local text = format(L['Enable InputInput_Libraries_zh'],
                    '|cff409EFF|cffffff00i|rnput|cffffff00i|rnput|r_Libraries_|cffF56C6Czh|r') ..
                ' |cFF909399' .. GetAddonMemory('InputInput_Libraries_zh') .. ' (' .. L['Need To Reload'] .. ')|r'
            this.enableIL_zh.Text:SetText(text)
            settings.enableIL_zh = C_AddOns_GetAddOnEnableState("InputInput_Libraries_zh") == 2
            this.enableIL_zh:SetChecked(settings.enableIL_zh)
            for _, v in ipairs(option_info) do
                if v.name == 'enableIL_zh' then
                    v.text = text
                    break
                end
            end
        end)
    end)
    button:SetScript("OnClick", function()
        settings = InitConfig(option_info, settings, true)
        D:SaveDB("settings", settings)
        changeSetting(settings)
        InItOPT(nil, nil, -32)
    end)
    settings = InitConfig(option_info, settings)
    changeSetting(settings)
    M:Fire('OPT', 'loadOPTFinish')
end

M:RegisterCallback('OPT', 'loadOPT', OPT.loadOPT)

-- 拦截超链接点击事件
function IISetItemRef(link, text, button, chatFrame)
    local linkType, linkData = link:match("^(.-):(.*)$")
    if linkType == "InputInputURL" then
        U:OpenLink(linkData)
        return false
    elseif linkType == "InputInputOPT" and linkData == 'show' then
        OpenSettingsPanel()
        return false
    end
    return true
end

-- 注册点击事件拦截
hooksecurefunc("SetItemRef", IISetItemRef)
