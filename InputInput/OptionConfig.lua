local W, M, U, D, G, L, E, API, LOG = unpack((select(2, ...)))
local OPTCONFIG = {}
M.OPTCONFIG = OPTCONFIG

OPTCONFIG.optionConfig = {
    {
        name = 'showChat',
        type = 'CheckButton',
        text = L['Show Chat'],
        click = function(this, self)
        end,
        default = true,
        subElement = {
            {
                name = 'showTime',
                type = 'CheckButton',
                text = L['Show Timestamp'],
                default = true,
            },
            {
                name = 'showbg',
                type = 'CheckButton',
                text = L['Show bg'],
                default = false,
            }
        }
    },
    {
        name = 'showChannel',
        type = 'CheckButton',
        text = L['Show channel Name'],
        default = true,
    },
    {
        name = 'showMultiTip',
        type = 'CheckButton',
        text = L['Show multi tip'],
        default = true
    },
    {
        name = 'disableLoginInformation',
        type = 'CheckButton',
        text = L['Disable Login Information'],
        default = false
    },
    {
        name = 'enableIL_zh',
        type = 'CheckButton',
        text = format(L['Enable InputInput_Libraries_zh'],
                '|cff409EFF|cffffff00i|rnput|cffffff00i|rnput|r_Libraries_|cffF56C6Czh|r') ..
            ' |cFF909399' .. ' (' .. L['Need To Reload'] .. ')|r',
        enter = function(this, self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")                                                       -- 设置提示框的位置
            GameTooltip:SetText(L['Chinese word processing module can make input prompts more intelligent']) -- 设置提示框的内容
            GameTooltip:Show()
        end,
        leave = function(this, self)
            GameTooltip:Hide() -- 隐藏提示框
        end,
        default = true,
    },
    {
        name = 'read_me',
        type = 'text',
        text = '\n\n|cff909399' .. L['READ ME'] .. '|r',
    },
    {
        name = 'contact',
        type = 'BTNGroup',
        BTNElement = {
            {
                name = 'KOOK',
                type = 'Button',
                text = 'KOOK(国服)',
                default = true,
                click = function(this, self)
                    U:OpenLink('https://kook.vip/vghP6R')
                end,
                texture = "Interface\\AddOns\\InputInput\\Media\\icon\\KOOK"
            },{
                name = 'Discord',
                type = 'Button',
                text = 'Discord',
                default = true,
                click = function(this, self)
                    U:OpenLink('https://discord.gg/qC9RAdXN')
                end,
                texture = "Interface\\AddOns\\InputInput\\Media\\icon\\Discord"
            },{
                name = 'GitHub',
                type = 'Button',
                text = 'GitHub',
                default = true,
                click = function(this, self)
                    U:OpenLink('https://github.com/CvCn/InputInput')
                end,
                texture = "Interface\\AddOns\\InputInput\\Media\\icon\\GitHub"
            },{
                name = 'CurseForge',
                type = 'Button',
                text = 'CurseForge',
                default = true,
                click = function(this, self)
                    U:OpenLink('https://www.curseforge.com/wow/addons/inputinput/comments')
                end,
                texture = "Interface\\AddOns\\InputInput\\Media\\icon\\CurseForge"
            },
        }
    }
}
