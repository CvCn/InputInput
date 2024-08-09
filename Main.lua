local W, M, U, D, G, L, E = unpack((select(2, ...)))
local MAIN = {}
M.MAIN = MAIN

local measureFontString = UIParent:CreateFontString(nil, "ARTWORK", "GameFontNormal")
local tip = ''
-- 更新显示 FontString 位置的函数
local function UpdateFontStringPosition(editBox, displayFontString, msg)
	if not msg or #msg <= 0 then
		displayFontString:Hide()
		return
	end
	local text = editBox:GetText()
	local cursorPosition = #text

	-- 设置测量 FontString 的字体和字体大小
	measureFontString:SetFontObject(editBox:GetFontObject())

	-- 获取内边距
	local leftPadding, rightPadding, topPadding, bottomPadding = 10, 10, 0, 0

	-- 分割文本为显示行，处理自动换行
	local lines = {}
	local lineStart = 1
	local editBoxWidth = editBox:GetWidth() - leftPadding - rightPadding
	while lineStart <= #text do
		local lineEnd = lineStart
		local lastSpace = nil
		while lineEnd <= #text do
			local subStr = text:sub(lineStart, lineEnd)
			measureFontString:SetText(subStr)
			if measureFontString:GetWidth() > editBoxWidth then
				break
			end
			if subStr:sub(-1):match("%s") then
				lastSpace = lineEnd
			end
			lineEnd = lineEnd + 1
		end

		if lineEnd > #text then
			table.insert(lines, text:sub(lineStart))
			break
		end

		if lastSpace then
			table.insert(lines, text:sub(lineStart, lastSpace - 1))
			lineStart = lastSpace + 1
		else
			table.insert(lines, text:sub(lineStart, lineEnd - 1))
			lineStart = lineEnd
		end
	end

	-- 找到光标所在行和相对于行的列位置
	local accumulatedLength = 0
	local cursorLine = 0
	local cursorColumn = 0
	local found = false

	for i, line in ipairs(lines) do
		if accumulatedLength + #line >= cursorPosition then
			cursorLine = i
			cursorColumn = cursorPosition - accumulatedLength
			found = true
			break
		end
		accumulatedLength = accumulatedLength + #line
	end

	-- 如果未找到，设置 cursorLine 和 cursorColumn 到文本末尾
	if not found then
		cursorLine = #lines
		if cursorLine > 0 then
			cursorColumn = #lines[cursorLine]
		else
			cursorColumn = 0
		end
	end

	-- 获取光标所在行之前的宽度
	local widthBeforeCursor = 0
	if cursorLine > 0 and lines[cursorLine] then
		local textBeforeCursor = lines[cursorLine]:sub(1, cursorColumn)
		measureFontString:SetText(textBeforeCursor)
		widthBeforeCursor = measureFontString:GetWidth()
	end

	-- 计算显示 FontString 的位置，考虑内边距
	local font, fontSize = measureFontString:GetFont()
	local x = widthBeforeCursor + leftPadding
	local y = -fontSize * (cursorLine - 1) - topPadding
	displayFontString:SetFontObject(editBox:GetFontObject())
	displayFontString:ClearAllPoints()
	displayFontString:SetPoint("TOPLEFT", editBox, "TOPLEFT", x, y)
	displayFontString:SetText(msg)
	displayFontString:Show()
end

local replace = {}

local function FindHis(his, patt)
	if not his or #his <= 0 or not patt or #patt <= 0 then return '' end
	local second = ''
	for i = #his, 1, -1 do
		local h = his[i]
		if h and #h > 0 then
			-- |cff0070dd|Hitem:38613::::::::80:::::::::|h[火热珠串]|h|r
			local inp, count = h:gsub("(%|c.-%|H.-%|h(%[.-%])%|h|r)", function(a1, a2)
				replace[a2] = a1
				return a2
			end)
			local start, _end = strfind(inp, patt, 1, true)
			if start and start > 0 and _end ~= #inp then
				local p = strsub(inp, _end + 1)

				if start == 1 then
					return p
				else
					if second == '' then
						second = p
					end
				end
			end
		end
	end
	return second
end

local currentChannelIndex = 1
function UpdateChannel(editBox)
	local channels = { "SAY" }
	if IsInGuild() then
		tinsert(channels, 'GUILD')
	end
	if IsInRaid() then
		tinsert(channels, 'RAID')
	elseif IsInGroup() then
		tinsert(channels, 'PARTY')
	end

	currentChannelIndex = currentChannelIndex + 1
	if currentChannelIndex > #channels then
		currentChannelIndex = 1
	end
	local temp = editBox:GetText()
	editBox:SetText("/" .. channels[currentChannelIndex] .. " ")
	if temp:sub(1, 1) == '/' then
		temp = ''
	end
	editBox:SetText(temp)
end

local messageHistory = {}
local historyIndex = 0
local newFontSize = 32 -- 新的字体大小

function LoadPostion(editBox)
	-- load point
	if D:HasInKey('editBoxPosition') then
		local point, relativePoint, xOfs, yOfs = unpack(
			D:ReadDB('editBoxPosition'))
		editBox:ClearAllPoints()
		editBox:SetPoint(point, UIParent, relativePoint, xOfs, yOfs)
	end
end

local scale = 1
local chat_frame = {}
local scale_temp = scale
local chat_h = 1
function LoadSize(scale, editBox, backdropFrame2, channel_name, II_TIP, II_LANG)
	editBox:SetWidth(480 * scale)
	local font, _, flags = editBox:GetFont()
	editBox:SetFont(font, newFontSize * scale, flags)

	-- 确保光标可见
	-- editBox.cursorOffset = 0
	-- editBox.cursorHeight = newFontSize * scale + 2

	backdropFrame2:SetWidth(480 * scale)
	local fontfile, _, flags = channel_name:GetFont()
	channel_name:SetFont(fontfile, newFontSize * scale, flags)

	local c_h = 0
	for idx, v in ipairs(chat_frame) do
		local fontfile, _, flags = v:GetFont()
		v:SetFont(fontfile, 16 * scale, flags)
		v:ClearAllPoints()
		v:SetWidth(backdropFrame2:GetWidth() - 20)
		-- v:SetPoint("BOTTOMLEFT", backdropFrame2, "TOPLEFT", 10, (30 - (10 - idx + 1) * 20) * scale)
		if idx == 1 then
			v:SetPoint("BOTTOMLEFT", backdropFrame2, "BOTTOMLEFT", 10, 3)
		else
			v:SetPoint("BOTTOMLEFT", chat_frame[idx - 1], "TOPLEFT", 0, 3)
		end
		c_h = c_h + v:GetHeight() + 3
	end
	backdropFrame2:SetHeight(c_h + 10)
	UpdateFontStringPosition(editBox, II_TIP, tip)

	local font, fontsize, flags = editBox:GetFont()
	II_LANG:SetFont(font, fontsize * 0.4, flags)
	scale_temp = scale
end

function MAIN:Init()
	scale = D:ReadDB('input_size', 1)
	messageHistory = D:ReadDB('messageHistory') or {}
	historyIndex = #messageHistory + 1
	-- 获取默认的聊天输入框
	local editBox = ChatFrame1EditBox

	-- 设置聊天输入框的位置和大小
	editBox:ClearAllPoints()
	editBox:SetPoint("CENTER", UIParent, "BOTTOM", 0, 330)
	editBox:SetWidth(480)
	editBox:SetMultiLine(true)
	editBox:SetAltArrowKeyMode(false)
	-- editBox:SetAutoFocus(true)  -- 自动获得焦点

	LoadPostion(editBox)

	-- 设置聊天输入框的字体大小
	local font, _, flags = editBox:GetFont()
	editBox:SetFont(font, newFontSize, flags)

	-- 确保光标可见
	-- editBox.cursorOffset = 0
	-- editBox.cursorHeight = newFontSize + 2

	-- 移除默认背景和边框
	local regions = { editBox:GetRegions() }
	for _, region in ipairs(regions) do
		if region:GetObjectType() == "Texture" then
			local texturePath = region:GetTexture()
			if texturePath ~= nil then
				region:SetTexture(nil)
			end
		elseif region:GetObjectType() == "FontString" then
			-- 调整频道名称字体大小
			-- local font, _, flags = region:GetFont()
			-- region:SetFont(font, newFontSize, flags)
			-- local point, frame, relativePoint, xOfs, yOfs = region:GetPoint(1)
			-- region:ClearAllPoints()
			-- region:SetPoint('TOP', frame, 'BOTTOM', 0, -20)
		end
	end

	-- 创建自定义背景和边框
	local backdropFrame = CreateFrame("Frame", "II_BG_FRAME", editBox)
	backdropFrame:SetPoint("TOPLEFT", editBox, "TOPLEFT", -5, 5)
	backdropFrame:SetPoint("BOTTOMRIGHT", editBox, "BOTTOMRIGHT", 5, -5)

	local bg2 = backdropFrame:CreateTexture("II_BG_FRAME_TEXTURE2", "BACKGROUND")
	bg2:SetColorTexture(0, 0, 0, 0.5) -- 半透明黑色背景
	bg2:SetAllPoints(backdropFrame)

	local bg = backdropFrame:CreateTexture("II_BG_FRAME_TEXTURE", "BACKGROUND")
	-- bg:SetColorTexture(0, 0, 0, 0.5) -- 半透明黑色背景
	bg:SetAllPoints(backdropFrame)

	local channel_name = backdropFrame:CreateFontString("II_CHANNEL_NAME", "OVERLAY", "GameFontNormal")
	channel_name:SetPoint('TOP', backdropFrame, 'BOTTOM', 0, -20)
	if channel_name then
		local font, _, flags = channel_name:GetFont()
		channel_name:SetFont(font, newFontSize, flags)
	end

	local border = CreateFrame("Frame", "II_BG_FRAME_BORDER", backdropFrame, "BackdropTemplate")
	border:SetPoint("TOPLEFT", -25, 25)
	border:SetPoint("BOTTOMRIGHT", 25, -25)
	border:SetBackdrop({
		edgeFile = "Interface\\AddOns\\InputInput\\Media\\rounded-border-small.tga",
		edgeSize = 32
	})
	border:SetBackdropBorderColor(1, 1, 1, 1)

	-- 确保自定义背景位于输入框后面
	backdropFrame:SetFrameLevel(editBox:GetFrameLevel() - 1)
	local BoxLanguage = ChatFrame1EditBoxLanguage
	BoxLanguage:SetAlpha(0)

	editBox:EnableMouse(true)
	editBox:SetMovable(true);
	editBox:RegisterForDrag("LeftButton")

	-- 聊天窗口
	local backdropFrame2 = CreateFrame("Frame", "II_CHAT_BG_FRAME", editBox)
	backdropFrame2:SetPoint("BOTTOM", editBox, "TOP", 0, 15)
	backdropFrame2:SetWidth(480)
	backdropFrame2:SetHeight(180)
	-- backdropFrame2:SetPoint("BOTTOMRIGHT", editBox, "BOTTOMRIGHT", 5, -5)

	backdropFrame2:SetFrameLevel(editBox:GetFrameLevel())
	local bg3
	-- bg3 = backdropFrame2:CreateTexture("II_CHAT_BG_FRAME_Texture", "BACKGROUND")
	-- bg3:SetAllPoints(backdropFrame2)
	-- bg3:SetTexture("Interface\\ChatFrame\\ChatFrameBackground")


	-- resize
	local resizeButton = CreateFrame("Button", "II_RESIZEBUTTON", editBox)
	resizeButton:SetSize(64, 64)
	resizeButton:SetPoint("CENTER", editBox, "RIGHT", 32, 0)
	resizeButton:SetAlpha(0.3)

	local texturePath = "Interface\\AddOns\\InputInput\\Media\\EthricArrow8.tga"

	local texture_btn = resizeButton:CreateTexture("II_RESIZEBUTTON_TEXTURE", "BACKGROUND")
	texture_btn:SetAllPoints(resizeButton)
	texture_btn:SetTexture(texturePath)

	resizeButton:Hide()

	local II_TIP = editBox:CreateFontString('II_TIP', "OVERLAY", "GameFontNormal")
	II_TIP:SetTextColor(1, 1, 1, 0.3) -- 设置颜色为白色
	II_TIP:Hide()

	-- 语言
	local II_LANG = editBox:CreateFontString('II_LANG', "OVERLAY", "GameFontNormal")
	II_LANG:SetTextColor(1, 1, 1, 0.6) -- 设置颜色为白色
	II_LANG:SetPoint('BOTTOMRIGHT', editBox, 'BOTTOMRIGHT', 0, 0)
	local font, fontsize, flags = editBox:GetFont()
	II_LANG:SetFont(font, fontsize * 0.4, flags)
	II_LANG:SetText(_G["INPUT_" .. editBox:GetInputLanguage()])

	LoadSize(scale, editBox, backdropFrame2, channel_name, II_TIP, II_LANG)

	return editBox, bg, border, backdropFrame2, resizeButton, texture_btn, channel_name, II_TIP, II_LANG, bg3
end

local function addLevel(name, realm)
	local maxLevel = GetMaxPlayerLevel()
	local level = UnitLevel(name)
	local name_realm = name
	if realm and #realm > 0 and realm ~= GetRealmName() then
		name_realm = U:join('-', name, realm)
	end
	if level and level ~= 0 and maxLevel ~= level then
		name_realm = '|cFF909399' .. level .. '.|r' .. name_realm
	end
	return name_realm
end

function FormatMSG(channel, senderGUID, msg, isChannel, sender, isPlayer)
	local info = ChatTypeInfo[channel]
	local channelColor = U:RGBToHex(info.r, info.g, info.b)
	local name_realm = ''
	local class
	if senderGUID then
		if tonumber(senderGUID) ~= nil then
			local accountInfo = C_BattleNet.GetAccountInfoByID(senderGUID)
			if accountInfo then
				local gameFriend = accountInfo.gameAccountInfo
				if gameFriend and gameFriend.realmName then
					class = gameFriend.className
					name_realm = addLevel(gameFriend.characterName, gameFriend.realmName)
				else
					name_realm = accountInfo.accountName
				end
				if name_realm:find('%|K.-%|k') then
					name_realm = '|BTag:' .. accountInfo.battleTag .. '|BTag'
				end
			end
		elseif #senderGUID > 0 then
			local localizedClass, englishClass, localizedRace, englishRace, sex, name, realmName = GetPlayerInfoByGUID(
				senderGUID)
			class = englishClass
			name_realm = addLevel(name, realmName)
		end
	end
	if #name_realm <= 0 then
		name_realm = sender
		local name, realm = strsplit('-', name_realm)
		class = UnitClass(name)
		name_realm = addLevel(name, realm)
	end

	local classColor = RAID_CLASS_COLORS[class]
	if not classColor then
		classColor = {
			colorStr = 'FF' .. channelColor
		}
	end

	local TO = ''
	if isPlayer then
		TO = 'TO: '
	end
	if #name_realm > 0 then
		name_realm = name_realm .. ' : '
	end
	if isChannel then
		return TO .. string.format('|W|cFF%s|c%s|r%s|r|w',
			channelColor,
			classColor.colorStr .. name_realm, msg)
	else
		return TO .. string.format('|W|cFF%s|c%s|r%s|r|w',
			channelColor,
			classColor.colorStr .. name_realm, msg)
	end
end

function SaveMSG(saveKey, channel, senderGUID, msg, isChannel, sender, isPlayer)
	local key = saveKey
	local channelMsg = D:ReadDB(key)
	tinsert(channelMsg, FormatMSG(channel, senderGUID, msg, isChannel, sender, isPlayer))
	local temp = {}
	if #channelMsg > 10 then
		for k = #channelMsg - 10, #channelMsg do
			tinsert(temp, channelMsg[k])
		end
	else
		temp = channelMsg
	end
	D:SaveDB(key, temp)
end

local ChatLabels = {
	["SAY"]                  = 'CHAT_MSG_SAY',
	["YELL"]                 = 'CHAT_MSG_YELL',
	["WHISPER"]              = 'CHAT_MSG_WHISPER',
	["WHISPER_INFORM"]       = 'CHAT_MSG_WHISPER_INFORM',
	["PARTY"]                = 'CHAT_MSG_PARTY',
	["PARTY_LEADER"]         = 'CHAT_MSG_PARTY_LEADER',
	["RAID"]                 = 'CHAT_MSG_RAID',
	["RAID_LEADER"]          = 'CHAT_MSG_RAID_LEADER',
	["RAID_WARNING"]         = 'CHAT_MSG_RAID_WARNING',
	["INSTANCE_CHAT"]        = 'CHAT_MSG_INSTANCE_CHAT',
	["INSTANCE_CHAT_LEADER"] = 'CHAT_MSG_INSTANCE_CHAT_LEADER',
	["GUILD"]                = 'CHAT_MSG_GUILD',
	["OFFICER"]              = 'CHAT_MSG_OFFICER',
	["BN_WHISPER"]           = 'CHAT_MSG_BN_WHISPER',
	["BN_WHISPER_INFORM"]    = 'CHAT_MSG_BN_WHISPER_INFORM',
}

function HideEuiBorder(editBox)
	---@diagnostic disable-next-line: undefined-global
	if ElvUI then
		C_Timer.After(0.001, function()
			editBox:SetBackdropBorderColor(0, 0, 0, 0)
			editBox:SetBackdropColor(0, 0, 0, 0)
			local font, _, flags = editBox:GetFont()
			editBox:SetFont(font, newFontSize * scale, flags)
		end)
	end
end

function Chat(editBox, chatType, backdropFrame2, channel_name)
	local msg_list
	local info = ChatTypeInfo[chatType]
	local r, g, b = info.r, info.g, info.b
	local chatGroup = Chat_GetChatCategory(chatType);
	if chatType == "CHANNEL" then
		local channelTarget = editBox:GetAttribute("channelTarget") or 'SAY'
		local channelNumber, channelname = GetChannelName(channelTarget)
		channel_name:SetText('|cFF' .. U:RGBToHex(r, g, b) .. '/' .. channelTarget .. ' ' .. channelname .. '|r')
		msg_list = D:ReadDB('CHANNEL' .. channelNumber)
	else
		local target = 'TO: ' .. (editBox:GetAttribute("tellTarget") or '')
		if not chatType:find('WHISPER') then target = '' end
		channel_name:SetText('|cFF' .. U:RGBToHex(r, g, b) .. U:join(' ', G[chatType], target) .. '|r')
		msg_list = D:ReadDB(chatGroup)
	end
	-- chat_h = 1
	local c_h = 0
	for k = 0, 4 do
		local msg = msg_list[#msg_list - k]
		msg = M.ICON:EmojiFilter(msg)
		if ElvUI == nil then
			msg = M.ICON:IconFilter(msg)
		end
		msg = U:BTagFilter(msg)

		-- if msg and #msg > 0 then chat_h = chat_h + 1 end
		local fontString = chat_frame[k + 1] or
			backdropFrame2:CreateFontString("II_CHAT_FONTSTRING" .. (k + 1), "OVERLAY", "GameFontNormal")
		fontString:SetText(msg)
		fontString:SetJustifyH("LEFT")
		fontString:SetWordWrap(true)
		fontString:SetNonSpaceWrap(true)
		fontString:SetWidth(backdropFrame2:GetWidth() - 20)
		if k == 0 then
			fontString:SetPoint("BOTTOMLEFT", backdropFrame2, "BOTTOMLEFT", 10, 3)
		else
			fontString:SetPoint("BOTTOMLEFT", chat_frame[k], "TOPLEFT", 0, 3)
		end
		local fontfile, _, flags = fontString:GetFont()
		fontString:SetFont(fontfile, 16 * scale, flags)
		local a = 1 - math.log(k + 1) + 2 / math.log(#msg_list)
		if a < 0 then a = 0 end
		if a > 1 then a = 1 end
		fontString:SetAlpha(a)
		chat_frame[k + 1] = fontString
		c_h = c_h + fontString:GetHeight() + 3
	end
	backdropFrame2:SetHeight(c_h)
end

function ChannelChange(editBox, bg, bg3, border, backdropFrame2, resizeBtnTexture, channel_name, II_LANG)
	HideEuiBorder(editBox)
	ChatFrame1EditBoxHeader:Hide()
	editBox:SetTextInsets(10, 10, 0, 0) -- 左, 右, 上, 下
	local chatType = editBox:GetAttribute("chatType") or "SAY"
	local info = ChatTypeInfo[chatType]
	local r, g, b = info.r, info.g, info.b
	bg:SetColorTexture(r, g, b, 0.15)
	II_LANG:SetTextColor(r, g, b, 0.6) -- 设置颜色为白色
	-- local c_start = CreateColor(0, 0, 0, 0.3)
	-- local c_end = CreateColor(r, g, b, 0.15)
	-- bg3:SetGradient("VERTICAL", c_start, c_end)
	border:SetBackdropBorderColor(r, g, b, 1)
	resizeBtnTexture:SetVertexColor(r, g, b, 1)
	Chat(editBox, chatType, backdropFrame2, channel_name)
end

local canChangeMessage = function(arg1, id)
	if id and arg1 == '' then return id end
end

local function MessageIsProtected(message)
	return message and (message ~= gsub(message, '(:?|?)|K(.-)|k', canChangeMessage))
end

local function chatEventHandler(event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12,
								arg13, arg14, arg15, arg16, arg17)
	local filter, new1, new2, new3, new4, new5, new6, new7, new8, new9, new10, new11, new12, new13, new14, new15, new16, new17 =
		false, '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', ''

	for _, chatFrame in ipairs(G.CHAT_FRAMES) do
		for _, messageType in pairs(G[chatFrame].messageTypeList) do
			if gsub(strsub(event, 10), '_INFORM', '') == messageType and arg1 and not MessageIsProtected(arg1) then
				local chatFilters = ChatFrame_GetMessageEventFilters(event)
				if chatFilters then
					for _, filterFunc in ipairs(chatFilters) do
						filter, new1, new2, new3, new4, new5, new6, new7, new8, new9, new10, new11, new12, new13, new14, new15, new16, new17 =
							filterFunc(G[chatFrame], event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10,
								arg11, arg12, arg13, arg14, arg15, arg16, arg17)
						if filter then
							return true
						elseif new1 then
							arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17 =
								new1, new2, new3, new4, new5, new6, new7, new8, new9, new10, new11, new12, new13, new14,
								new15, new16, new17
						end
					end
				end
			end
		end
	end
	return filter, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17
end

local ChatChange = false
---@diagnostic disable-next-line: deprecated
local IsAddOnLoaded = (C_AddOns and C_AddOns.IsAddOnLoaded) or IsAddOnLoaded
local frame = CreateFrame("Frame", "II_MAIN_FRAME")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function(self_f, event, ...)
	---@diagnostic disable-next-line: undefined-global
	if (ElvUI ~= nil and IsAddOnLoaded("ElvUI") or ElvUI == nil) and
		(NDui ~= nil and IsAddOnLoaded("NDui") or NDui == nil) then
		local editBox, bg, border, backdropFrame2, resizeButton, texture_btn, channel_name, II_TIP, II_LANG, bg3 = MAIN
			:Init()
		editBox:SetScript("OnEscapePressed", editBox.ClearFocus) -- 允许按下 Esc 清除焦点+
		-- NDui
		if NDui then
			editBox:HookScript("OnShow", function(self)
				LoadPostion(self)
			end)
		end
		editBox:SetScript("OnDragStart", function(...)
			if IsShiftKeyDown() then
				editBox.StartMoving(...)
			end
		end);
		editBox:SetScript("OnDragStop", function()
			editBox:StopMovingOrSizing()
			local point, _, relativePoint, xOfs, yOfs = editBox:GetPoint(1)
			D:SaveDB('editBoxPosition', {
				point, relativePoint, xOfs, yOfs
			})
		end);
		-- resize repoint
		editBox:SetScript("OnMouseDown", function(self, button)
			if IsShiftKeyDown() and button == "RightButton" then
				editBox:ClearAllPoints()
				editBox:SetPoint("CENTER", UIParent, "BOTTOM", 0, 330)
				local point, _, relativePoint, xOfs, yOfs = editBox:GetPoint(1)
				D:SaveDB('editBoxPosition', {
					point, relativePoint, xOfs, yOfs
				})
				scale = 1
				scale_temp = 1
				LoadSize(scale, editBox, backdropFrame2, channel_name, II_TIP, II_LANG)
				D:SaveDB('input_size', 1)
			end
		end);

		local resize = false
		local X_g = 0

		resizeButton:SetScript("OnMouseDown", function(self, button)
			if button == "LeftButton" and IsShiftKeyDown() then
				resize = true
				local x, y = GetCursorPosition()
				X_g = x
			end
		end)
		resizeButton:SetScript("OnMouseUp", function(self, button)
			resize = false
			scale = scale_temp
			D:SaveDB('input_size', scale)
		end)
		local w = GetScreenWidth()
		resizeButton:SetScript("OnUpdate", function(self, button)
			if not IsShiftKeyDown() then
				resize = false
			end
			if resize then
				self:SetAlpha(0.6)
				local x, y = GetCursorPosition()
				local _scale = scale + (x - X_g) / w * 4
				LoadSize(_scale, editBox, backdropFrame2, channel_name, II_TIP, II_LANG)
			else
				self:SetAlpha(0.3)
			end
		end)

		UIParent:SetScript("OnUpdate", function(self, button)
			if not InCombatLockdown() then
				if IsShiftKeyDown() then
					resizeButton:Show()
				else
					resizeButton:Hide()
				end
			else
				resizeButton:Hide()
			end
		end)

		local originalOnEnterPressed = editBox:GetScript("OnEnterPressed")
		editBox:SetScript("OnEnterPressed", function(self)
			local message = self:GetText()
			if II_TIP:IsShown() and IsLeftControlKeyDown() then
				local p = message .. tip
				local inp, count = p:gsub("(%|c.-%|H.-%|h(%[.-%])%|h|r)", function(a1, a2)
					replace[a2] = a1
					return a2
				end)
				for k, v in pairs(replace) do
					inp = U:ReplacePlainTextUsingFind(inp, k, v)
				end
				self:SetText(inp)
				M.HISTORY:simulateInputChange(inp, self:GetInputLanguage())
				return
			end
			-- 检查输入框是否有内容
			if message and message ~= "" then
				if message ~= messageHistory[#messageHistory] then
					-- 将消息添加到历史记录中
					table.insert(messageHistory, message)
				end
			end

			local temp = {}
			if #messageHistory > 200 then
				for k = #messageHistory - 200, #messageHistory do
					tinsert(temp, messageHistory[k])
				end
			else
				temp = messageHistory
			end
			messageHistory = temp
			D:SaveDB('messageHistory', messageHistory)

			-- 重置历史索引
			historyIndex = #messageHistory + 1

			if message:sub(1, 4) == "/sp " then
				message = string.gsub(message, "/sp ", "", 1)
				message = '/script print(' .. message .. ')'
				self:SetText(message)
			elseif message:sub(1, 5) == "/sps " then
				message = string.gsub(message, "/sps ", "", 1)
				message = '/script print("' .. message .. '")'
				self:SetText(message)
			elseif message:sub(1, 5) == "/spa " then
				message = string.gsub(message, "/spa ", "", 1)
				message = '/script for _, v in ipairs(' .. message .. ') do print(v) end'
				self:SetText(message)
			elseif message:sub(1, 5) == "/spt " then
				message = string.gsub(message, "/spt ", "", 1)
				message = '/script for k, v in pairs(' .. message .. ') do print(k, v) end'
				self:SetText(message)
			end

			if originalOnEnterPressed then
				originalOnEnterPressed(self)
			end
		end)
		editBox:HookScript("OnTextChanged", function(self, userInput)
			local text = self:GetText()
			if userInput then
				M.HISTORY:simulateInputChange(text, self:GetInputLanguage())
			end
		end)
		local originalOnTextChanged = editBox:GetScript("OnTextChanged")
		editBox:SetScript("OnTextChanged", function(self, ...)
			local text = self:GetText()
			tip = FindHis(messageHistory, text)
			UpdateFontStringPosition(self, II_TIP, tip)
			if originalOnTextChanged then
				originalOnTextChanged(self, ...)
			end
		end)
		editBox:HookScript("OnInputLanguageChanged", function(self)
			II_LANG:SetText(_G["INPUT_" .. self:GetInputLanguage()])
		end)
		local originalOnOnKeyDown = editBox:GetScript("OnKeyDown")
		editBox:SetScript("OnKeyDown", function(self, key, ...)
			if key == "TAB" then
				if not ElvUI and not NDui then
					UpdateChannel(self)
				end
				if NDui then
					hooksecurefunc("ChatEdit_CustomTabPressed", function(self)
						ChannelChange(self, bg, bg3, border, backdropFrame2, texture_btn, channel_name, II_LANG)
					end)
				end
			elseif key == "UP" then
				-- 上滚历史消息
				if historyIndex > 1 then
					historyIndex = historyIndex - 1
					local h = messageHistory[historyIndex]
					self:SetText(h)
					self:SetCursorPosition(#h)
				end
			elseif key == "DOWN" then
				-- 下滚历史消息
				if historyIndex < #messageHistory then
					historyIndex = historyIndex + 1
					local h = messageHistory[historyIndex]
					self:SetText(h)
					self:SetCursorPosition(#h)
				elseif historyIndex == #messageHistory then
					-- 如果是最新消息，清空输入框
					historyIndex = #messageHistory + 1
					self:SetText("")
				end
			elseif key == "Z" and IsLeftControlKeyDown() and IsLeftShiftKeyDown() then
				local text = M.HISTORY:redo()
				if text then
					self:SetText(text)
				end
			elseif key == "Z" and IsLeftControlKeyDown() then
				local text = M.HISTORY:undo()
				if text then
					self:SetText(text)
				end
			else
			end

			if originalOnOnKeyDown then
				originalOnOnKeyDown(self, key, ...)
			end
		end)
		hooksecurefunc("ChatEdit_UpdateHeader", function(self)
			ChannelChange(self, bg, bg3, border, backdropFrame2, texture_btn, channel_name, II_LANG)
		end)

		-- 设置焦点获得事件处理函数
		editBox:SetScript("OnEditFocusGained", function(self)
			HideEuiBorder(self)
			ChatChange = true
		end)

		editBox:SetScript("OnEditFocusLost", function(self)
			self:Hide()
			ChatChange = false
			if not self:GetText() or #self:GetText() <= 0 then
				M.HISTORY:clearHistory()
			end
		end)
		local frame_E = CreateFrame("Frame", "II_EVENT_FRAME")
		for k, v in pairs(ChatLabels) do
			frame_E:RegisterEvent(v)
		end
		frame_E:RegisterEvent('CHAT_MSG_CHANNEL')

		frame_E:SetScript("OnEvent",
			function(self, ...)
				local event, msg, sender, language, channelString, target, flags, zoneChannelID, channelNumber,
				channelName, languageID, _, guid, bnSenderID, isMobile, isSubtitle, supressRaidIcons = ...

				U:SaveLog('msg_even_' .. event, { ... })

				local type = strsub(event, 10) or 'SAY';

				local filter = false
				filter, msg, sender, language, channelString, target, flags, zoneChannelID, channelNumber,
				channelName, languageID, _, guid, bnSenderID, isMobile, isSubtitle, supressRaidIcons =
					chatEventHandler(event, msg, sender, language, channelString, target, flags, zoneChannelID,
						channelNumber,
						channelName, languageID, _, guid, bnSenderID, isMobile, isSubtitle, supressRaidIcons)
				if filter then
					return
				end

				if language and #language > 0 and sender and #sender > 0 then
					if UnitFactionGroup('player') ~= UnitFactionGroup(sender) then
						msg = '[' .. language .. ']' .. msg
					end
				end


				local chatGroup = Chat_GetChatCategory(type);
				if isMobile then
					local info = ChatTypeInfo[type];
					msg = ChatFrame_GetMobileEmbeddedTexture(info.r, info.g, info.b) .. msg;
				end
				-- msg = C_ChatInfo.ReplaceIconAndGroupExpressions(msg, supressRaidIcons,
				-- 	not ChatFrame_CanChatGroupPerformExpressionExpansion(chatGroup))
				if event == 'CHAT_MSG_CHANNEL' then
					SaveMSG('CHANNEL' .. channelNumber, 'CHANNEL' .. channelNumber, guid or bnSenderID, msg,
						true, sender)
					if ChatChange then
						ChannelChange(editBox, bg, bg3, border, backdropFrame2, texture_btn, channel_name, II_LANG)
					end
				end
				for k, v in pairs(ChatLabels) do
					if event == v then
						SaveMSG(chatGroup, k, guid or bnSenderID, msg, false, sender, event:find('_INFORM'))
						if ChatChange then
							ChannelChange(editBox, bg, bg3, border, backdropFrame2, texture_btn, channel_name, II_LANG)
						end
						break
					end
				end
			end)
	end
end)
