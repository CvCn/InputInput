local W, M, U, D, G, L, E, API, LOG = unpack((select(2, ...)))
local OPT = {}
M.OPT = OPT

local C_AddOns_IsAddOnLoaded = API.C_AddOns_IsAddOnLoaded
local GetAddOnMemoryUsage = API.GetAddOnMemoryUsage
local C_AddOns_GetAddOnEnableState = API.C_AddOns_GetAddOnEnableState

local options = CreateFrame("FRAME")
options.name = W.N
options:Hide()

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

local function changeSetting(settings)
    M.MAIN:HideChat(settings.showChat)
    M.MAIN:HideChannel(settings.showChannel)
    M.MAIN:HideTime(settings.showTime)
    M.MAIN:Hidebg(settings.showbg)
    M.MAIN:EnableIL_zh(settings.enableIL_zh)
    M.MAIN:MultiTip(settings.showMultiTip)

    -- M:Fire('MAIN', 'HideChat', settings.showChat)
    -- M:Fire('MAIN', 'HideChannel', settings.showChannel)
    -- M:Fire('MAIN', 'HideTime', settings.showTime)
    -- M:Fire('MAIN', 'Hidebg', settings.showbg)
    -- M:Fire('MAIN', 'EnableIL_zh', settings.enableIL_zh)
    -- M:Fire('MAIN', 'MultiTip', settings.showMultiTip)
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
        return '(' .. (math.floor(memoryUsageMB * 100) / 100) .. 'MB)'
    end
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
        if frame then
            this[v.name] = frame
            frame.IIConfig = v
            local thisY = baseY + i * offsetY
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

local function InitConfig(config, s)
    for _, v in ipairs(config) do
        if v.type == 'CheckButton' then
            s[v.name] = s[v.name] ~= nil and s[v.name] or v.default
        end
    end
    return s
end

function OPT:loadOPT()
    settings = D:ReadDB("settings", settings)
    InItOPT(nil, nil, -32)
    options:SetScript("OnShow", function(self)
        U:Delay(0.01, function()
            UpdateAddOnMemoryUsage()
            local text = format(L['Enable InputInput_Libraries_zh'],
                    '|cff409EFF|cffF56C6Ci|rnput|cffF56C6Ci|rnput|r_Libraries_|cffF56C6Czh|r') ..
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
        settings = InitConfig(option_info, settings)
        D:SaveDB("settings", settings)
        changeSetting(settings)
        InItOPT(nil, nil, -32)
    end)
    settings = InitConfig(option_info, settings)
    changeSetting(settings)
end

M:RegisterCallback('OPT', 'loadOPT', OPT.loadOPT)
