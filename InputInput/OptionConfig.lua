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
                showChat = true,
            },
            {
                name = 'showbg',
                type = 'CheckButton',
                text = L['Show bg'],
                showChat = false,
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
        name = 'enableIL_zh',
        type = 'CheckButton',
        text = format(L['Enable InputInput_Libraries_zh'],
                '|cff409EFF|cffF56C6Ci|rnput|cffF56C6Ci|rnput|r_Libraries_|cffF56C6Czh|r') ..
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
        text = '\n\n\n\n|cff909399' .. L['READ ME'] .. '|r',
    }
}
