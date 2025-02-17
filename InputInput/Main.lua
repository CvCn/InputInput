local W, M, U, D, G, L, E, API, LOG = unpack((select(2, ...)))
local MAIN = {}
M.MAIN = MAIN

local C_AddOns_IsAddOnLoaded = API.C_AddOns_IsAddOnLoaded
local GetChannelList = API.GetChannelList
local IsInRaid = API.IsInRaid
local IsInGroup = API.IsInGroup
local IsInGuild = API.IsInGuild
local GetMaxPlayerLevel = API.GetMaxPlayerLevel
local UnitLevel = API.UnitLevel
local GetRealmName = API.GetRealmName
local C_BattleNet_GetAccountInfoByID = API.C_BattleNet_GetAccountInfoByID
local GetPlayerInfoByGUID = API.GetPlayerInfoByGUID
local UnitClass = API.UnitClass
local GetChannelName = API.GetChannelName
local IsShiftKeyDown = API.IsShiftKeyDown
local GetCursorPosition = API.GetCursorPosition
local InCombatLockdown = API.InCombatLockdown
local IsLeftControlKeyDown = API.IsLeftControlKeyDown
local IsLeftShiftKeyDown = API.IsLeftShiftKeyDown
local C_AddOns_GetAddOnEnableState = API.C_AddOns_GetAddOnEnableState
local C_AddOns_EnableAddOn = API.C_AddOns_EnableAddOn
local C_AddOns_DisableAddOn = API.C_AddOns_DisableAddOn
local C_ChatInfo_RegisterAddonMessagePrefix = API.C_ChatInfo_RegisterAddonMessagePrefix
-- 引入结巴分词库
local jieba = LibStub("inputinput-jieba")

local measureFontString = UIParent:CreateFontString(nil, "ARTWORK", "GameFontNormal")

local editMode = false

local II_TIP_BG = {}

local tip = {}
-- 更新显示 FontString 位置的函数
---@param editBox EditBox
---@param displayFontString FontString
---@param msg string
local function UpdateFontStringPosition(editBox, displayFontString, msg, i, sizei)
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
	-- displayFontString:SetFontObject(editBox:GetFontObject())
	displayFontString:ClearAllPoints()
	local font2, fontsize, flags = editBox:GetFont()
	local smallSize = 1
	displayFontString:SetFont(font2, fontsize * smallSize, flags)
	displayFontString:SetDrawLayer("OVERLAY", 1)
	-- 创建背景纹理
	local bg = II_TIP_BG[i] or displayFontString:GetParent():CreateTexture(nil, "BACKGROUND")
	II_TIP_BG[i] = bg
	bg:SetAllPoints(displayFontString)
	-- bg:SetTexture("Interface\\AddOns\\InputInput\\Media\\rounded-backdrop-small.tga")
	bg:Show()
	bg:SetDrawLayer("OVERLAY", 1)
	bg:SetColorTexture(0, 0, 0, 0.6)
	if i > 1 then
		displayFontString:SetPoint("TOPLEFT", editBox, "TOPLEFT", x - (1.5 * fontsize),
			y - (i - 0.8) * fontsize - fontsize * (1 - smallSize))
		displayFontString:SetText(' ' .. i .. ': ' .. msg .. ' ')
	else
		displayFontString:SetPoint("TOPLEFT", editBox, "TOPLEFT", x, y)
		displayFontString:SetText(msg)
	end
	-- if sizei > 1 then
	-- 	bg:SetColorTexture(0, 0, 0, 0.7)
	-- else
	-- 	bg:SetColorTexture(0, 0, 0, 0)
	-- end
	displayFontString:Show()
end

local function getLastUTF8Char(s)
	if not s or #s <= 0 then return '' end
	-- 初始化起始位置
	local lastCharStart = nil

	-- 遍历字符串，找到最后一个字符的起始位置
	for i = 1, #s do
		local c = string.byte(s, i)
		if c >= 128 then
			-- 多字节字符的处理
			if c >= 240 then
				lastCharStart = i
				i = i + 3
			elseif c >= 224 then
				lastCharStart = i
				i = i + 2
			elseif c >= 192 then
				lastCharStart = i
				i = i + 1
			end
		else
			-- 单字节字符的处理
			lastCharStart = i
		end
	end

	-- 返回最后一个字符
	return s:sub(lastCharStart)
end

local C_Word = {}
local multiTip = true

---@return table
local function FindHis(his, patt)
	if not his or #his <= 0 or not patt or #patt <= 0 then return {} end
	if patt:sub(1, 1) == "/" then return {} end
	patt = patt:gsub("%|c.-(%[.-%]).-%|r", function(a1)
		return a1
	end)
	-- local lastChat = getLastUTF8Char(patt)
	local pattp = U:CutWord(patt)
	-- LOG:Debug('pattp: ', pattp[#pattp])
	-- for i, v in ipairs(U:CutWord('不会 找jason')) do
	-- 	LOG:Debug('pattp2: ', v)
	-- end
	if not pattp or #pattp <= 0 then return {} end
	local _tip = {}
	local f1break = false
	for i = #his, 1, -1 do
		if f1break then break end
		local h = his[i]
		if h and #h > 0 then
			h = h:gsub("%|c.-(%[.-%]).-%|r", function(a1)
				-- LOG:Debug(a1)
				return a1
			end)
			-- LOG:Debug('h: ', h)
			local hisp = U:CutWord(h)
			for h_index, h2 in ipairs(hisp) do
				if f1break then break end
				-- 先按分词匹配
				local patt2 = pattp[#pattp]
				-- LOG:Debug(patt2)
				local start, _end = strfind(h2, patt2, 1, true)
				if start and start > 0 then
					-- LOG:Debug(patt2)
					if _end ~= # h2 then
						U:InsertNoRepeat(_tip, strsub(h2, _end + 1))
					else
						local pnex = hisp[h_index + 1]
						if pnex and #pnex > 0 then
							U:InsertNoRepeat(_tip, pnex)
							f1break = true
						end
					end
				end
			end
		end
	end
	-- for i = #his, 1, -1 do
	-- 	local h = his[i]
	-- 	if h and #h > 0 then
	-- 		h = h:gsub("%|c.-(%[.-%]).-%|r", function(a1)
	-- 			-- LOG:Debug(a1)
	-- 			return a1
	-- 		end)
	-- 		-- LOG:Debug('h: ', h)
	-- 		local hisp = U:CutWord(h)
	-- 		for h_index, h2 in ipairs(hisp) do
	-- 			-- 再使用最后一个字符匹配分词
	-- 			local patt2 = lastChat
	-- 			local start, _end = strfind(h2, patt2, 1, true)
	-- 			if start and start > 0 then
	-- 				-- LOG:Debug(patt2)
	-- 				if _end ~= # h2 then
	-- 					return strsub(h2, _end + 1)
	-- 				else
	-- 					local pnex = hisp[h_index + 1]
	-- 					if pnex and #pnex > 0 then
	-- 						return pnex
	-- 					end
	-- 				end
	-- 			end
	-- 		end
	-- 	end
	-- end
	-- 匹配常用词
	local c_w = U:FindMaxValue(C_Word, pattp[#pattp])
	if c_w then
		local start, _end = strfind(c_w, pattp[#pattp], 1, true)
		U:InsertNoRepeat(_tip, strsub(c_w, _end + 1))
	end
	for i = #his, 1, -1 do
		local h = his[i]
		if h and #h > 0 then
			-- 如果分词匹配不到，使用输入的最后一个字符匹配
			-- local start, _end = strfind(h, lastChat, 1, true)
			-- if start and start > 0 and _end ~= #h then
			-- 	return strsub(h, _end + 1)
			-- end
			-- LOG:Debug(lastChat)
			-- 匹配角色名字和地区名字
			-- LOG:Debug(pattp[#pattp])
			local playerTip = U:PlayerTip(patt, pattp[#pattp])
			if playerTip then
				U:InsertNoRepeat(_tip, playerTip)
				break
			else
				playerTip = U:PlayerTip(patt, patt)
				if playerTip then
					U:InsertNoRepeat(_tip, playerTip)
					break
				end
			end
		end
	end
	-- 魔兽词库
	if W.words then
		local w = ''
		local f = 0
		local w2 = ''
		local f2 = 0
		local treeKey = jieba.sub(pattp[#pattp], 1, 1)
		local tree = W.words[treeKey] or {}
		for _, v in ipairs(tree) do
			local word = v.word
			local freq = tonumber(v.freq) or 0
			local start, _end = strfind(word, pattp[#pattp], 1, true)
			if start and start == 1 and _end ~= #word and freq > f then
				-- 从匹配位置之后截取字符串
				local p = strsub(word, _end + 1)
				if p and #p > 0 then
					w = p
					f = freq
				end
			end
			if start and start == 1 and _end ~= #word and freq > f2 and freq < f then
				-- 从匹配位置之后截取字符串
				local p = strsub(word, _end + 1)
				if p and #p > 0 then
					w2 = p
					f2 = freq
				end
			end
		end
		if f > 0 then
			LOG:Debug('词库')
			U:InsertNoRepeat(_tip, w)
		end
		if f2 > 0 then
			LOG:Debug('词库')
			U:InsertNoRepeat(_tip, w2)
		end
	end
	if not multiTip then
		return { _tip[1] }
	end
	return _tip
end

local lastChannel = ''

function IsInChannel(channelName)
	local id, name
	-- 获取所有加入的频道列表
	for i = 1, select("#", GetChannelList()), 3 do
		id, name = select(i, GetChannelList())
		-- 比较频道名
		if name and name:lower() == channelName:lower() then
			return true, id
		end
	end
	return false
end

local currentChannelIndex = 1
function UpdateChannel(editBox)
	local channels = { "SAY" }
	if IsInRaid() then
		tinsert(channels, 'RAID')
	elseif IsInGroup() then
		tinsert(channels, 'PARTY')
	end
	if IsInGuild() then
		tinsert(channels, 'GUILD')
	end
	local dajiao, id = IsInChannel("大脚世界频道")
	if dajiao then
		tinsert(channels, id)
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
	local point, relativePoint, xOfs, yOfs =
		unpack(D:ReadDB('editBoxPosition', { "CENTER", "BOTTOM", 0, 330 }, false))
	editBox:ClearAllPoints()
	-- LOG:Debug(point, relativePoint, xOfs, yOfs)
	editBox:SetPoint(point, UIParent, relativePoint, xOfs, yOfs)
	-- LOG:Debug(editBox:GetPoint())
end

local scale = 1
local chat_frame = {}
local chat_frame_texture = {}
local scale_temp = scale
local chat_h = 1

---@param scale number
---@param editBox EditBox
---@param backdropFrame2 table|BackdropTemplate|Frame
---@param channel_name FontString
---@param II_TIP FontString
---@param II_LANG FontString
function LoadSize(scale, editBox, backdropFrame2, channel_name, II_TIP, II_LANG)
	editBox:SetWidth(480 * scale)
	local font, _, flags = editBox:GetFont()
	local newH = newFontSize * scale
	editBox:SetFont(font, newH < 0 and 0 or newH, flags)

	-- 确保光标可见
	-- editBox.cursorOffset = 0
	-- editBox.cursorHeight = newFontSize * scale + 2

	backdropFrame2:SetWidth(480 * scale)
	local fontfile, _, flags = channel_name:GetFont()
	channel_name:SetFont(fontfile or W.defaultFontName, newFontSize * scale, flags)

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
	for i, v in ipairs(II_TIP) do
		UpdateFontStringPosition(editBox, v, tip[i], i, #tip)
	end

	local font, fontsize, flags = editBox:GetFont()
	II_LANG:SetFont(font, fontsize * 0.4, flags)
	scale_temp = scale
end

local isInit = false
function MAIN:Init()
	scale = D:ReadDB('input_size', 1)
	messageHistory = D:ReadDB('messageHistory', {}, true)
	C_Word = D:ReadDB('C_Word', {}, true)
	U:InitWordCache(messageHistory)
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

	-- LoadPostion(editBox)

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
	local backdropFrame = CreateFrame("Frame", "II_BG_FRAME", editBox, "BackdropTemplate")
	backdropFrame:SetPoint("TOPLEFT", editBox, "TOPLEFT", -4, 4)
	backdropFrame:SetPoint("BOTTOMRIGHT", editBox, "BOTTOMRIGHT", 4, -4)

	local bg2 = backdropFrame:CreateTexture("II_BG_FRAME_TEXTURE2", "BACKGROUND")
	bg2:SetColorTexture(0, 0, 0, 0.5) -- 半透明黑色背景
	bg2:SetAllPoints()

	local bg = backdropFrame:CreateTexture("II_BG_FRAME_TEXTURE", "BACKGROUND")
	-- bg:SetColorTexture(0, 0, 0, 0.5) -- 半透明黑色背景
	bg:SetAllPoints()

	local channel_name = backdropFrame:CreateFontString("II_CHANNEL_NAME", "OVERLAY", "GameFontNormal")
	channel_name:SetPoint('TOP', backdropFrame, 'BOTTOM', 0, -20)
	channel_name:SetFont(font, newFontSize, flags)
	-- 添加阴影
	channel_name:SetShadowOffset(2, -2)  -- 阴影偏移（右下角）
	channel_name:SetShadowColor(0, 0, 0, 1) -- 阴影颜色为黑色，透明度为50%
	channel_name:SetDrawLayer("ARTWORK", 1)

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
	local backdropFrame2 = CreateFrame("Frame", "II_CHAT_BG_FRAME", editBox, "BackdropTemplate")
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

	local II_TIP = {
		backdropFrame:CreateFontString('II_TIP', "OVERLAY", "GameFontNormal"),
		backdropFrame:CreateFontString('II_TIP2', "OVERLAY", "GameFontNormal"),
		backdropFrame:CreateFontString('II_TIP3', "OVERLAY", "GameFontNormal"),
		backdropFrame:CreateFontString('II_TIP4', "OVERLAY", "GameFontNormal"),
		backdropFrame:CreateFontString('II_TIP5', "OVERLAY", "GameFontNormal"),
	}
	for _, v in ipairs(II_TIP) do
		v:SetTextColor(1, 1, 1, 0.3) -- 设置颜色为白色
		v:Hide()
	end

	-- 语言
	local II_LANG = editBox:CreateFontString('II_LANG', "OVERLAY", "GameFontNormal")
	II_LANG:SetTextColor(1, 1, 1, 0.6) -- 设置颜色为白色
	II_LANG:SetPoint('BOTTOMRIGHT', editBox, 'BOTTOMRIGHT', 0, 0)
	local font, fontsize, flags = editBox:GetFont()
	II_LANG:SetFont(font, fontsize * 0.4, flags)
	II_LANG:SetText(_G["INPUT_" .. editBox:GetInputLanguage()])

	-- LoadSize(scale, editBox, backdropFrame2, channel_name, II_TIP, II_LANG)

	isInit = true
	return editBox, bg, border, backdropFrame2, resizeButton, texture_btn, channel_name, II_TIP, II_LANG, bg3
end

---@param name string
---@param realm string
---@return string
local function addLevel(name, realm)
	local maxLevel = GetMaxPlayerLevel()
	local level = UnitLevel(name)
	local name_realm = name
	if realm and #realm > 0 and realm ~= GetRealmName() then
		name_realm = U:join('-', name, realm)
	end
	if level and level ~= 0 and maxLevel ~= level then
		name_realm = '|cFF909399' .. level .. ' |r' .. name_realm
	end
	return name_realm
end

---@param channel string
---@param senderGUID string|nil
---@param msg string
---@param isChannel boolean
---@param sender string|nil
---@param isPlayer boolean|nil
---@return string
function FormatMSG(channel, senderGUID, msg, isChannel, sender, isPlayer)
	local info = ChatTypeInfo[channel]
	local channelColor = U:RGBToHex(info.r, info.g, info.b)
	local name_realm = ''
	local class
	if senderGUID then
		if tonumber(senderGUID) ~= nil then
			local accountInfo = C_BattleNet_GetAccountInfoByID(senderGUID)
			if accountInfo then
				name_realm = accountInfo.accountName
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
		name_realm = sender or ''
		local name, realm = strsplit('-', name_realm)
		class = UnitClass(name)
		name_realm = addLevel(name, realm)
	end

	local classColor = RAID_CLASS_COLORS[class]
	if not classColor then
		---@diagnostic disable-next-line: missing-fields
		classColor = {
			colorStr = 'FF' .. channelColor
		}
	else
		U:UnitColor(name_realm, classColor.colorStr)
	end

	local TO = ''
	if isPlayer then
		TO = L['TO'] .. ': '
	end
	if #name_realm > 0 then
		name_realm = name_realm .. ' : '
	end
	if isChannel then
		return TO .. string.format('|cFF%s|W|c%s|r|w%s|r',
			channelColor,
			classColor.colorStr .. name_realm, msg)
	else
		return TO .. string.format('|cFF%s|W|c%s|r|w%s|r',
			channelColor,
			classColor.colorStr .. name_realm, msg)
	end
end

local showTime = false
local showbg = false

---@param saveKey string
---@param channel string
---@param senderGUID string|nil
---@param msg string
---@param isChannel boolean
---@param sender string|nil
---@param isPlayer boolean|nil
function SaveMSG(saveKey, channel, senderGUID, msg, isChannel, sender, isPlayer)
	local key = saveKey
	local w = strfind(channel, 'BN_WHISPER')
	local channelMsg = D:ReadDB(key, {}, w)
	local currtime = ""
	currtime = "|TTag:" .. time() .. "|TTag"
	tinsert(channelMsg, currtime .. FormatMSG(channel, senderGUID, msg, isChannel, sender, isPlayer))
	local temp = {}
	if #channelMsg > 10 then
		for k = #channelMsg - 10, #channelMsg do
			tinsert(temp, channelMsg[k])
		end
	else
		temp = channelMsg
	end
	D:SaveDB(key, temp, w)
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

---@param editBox EditBox
function HideEuiBorder(editBox)
	if ElvUI then
		---@diagnostic disable-next-line: undefined-field
		if editBox.SetBackdropBorderColor then
			---@diagnostic disable-next-line: undefined-field
			editBox:SetBackdropBorderColor(0, 0, 0, 0)
		end
		---@diagnostic disable-next-line: undefined-field
		if editBox.SetBackdropColor then
			---@diagnostic disable-next-line: undefined-field
			editBox:SetBackdropColor(0, 0, 0, 0)
		end
		-- editBox:StripTextures()
		---@diagnostic disable-next-line: undefined-field
		if editBox.shadow then
			---@diagnostic disable-next-line: undefined-field
			editBox.shadow:Hide()
		end
		local font, _, flags = editBox:GetFont()
		editBox:SetFont(font, newFontSize * scale, flags)
		---@diagnostic disable-next-line: undefined-field
		if editBox.characterCount then
			---@diagnostic disable-next-line: undefined-field
			editBox.characterCount:Hide()
		end
	end
end

function HideLS_GLASSBorder(editBox)
	if ls_Glass and editBox and editBox.Backdrop then
		LoadPostion(editBox)
		---@diagnostic disable-next-line: undefined-field
		editBox.Backdrop:SetBackdropColor(0, 0, 0, 0)
		---@diagnostic disable-next-line: undefined-field
		editBox.Backdrop:SetBackdropBorderColor(0, 0, 0, 0)
		editBox:SetTextInsets(10, 10, 0, 0)
	end
end

local showChannelName = true

---@param editBox EditBox
---@param chatType string
---@param backdropFrame2 table|BackdropTemplate|Frame
---@param channel_name FontString
function Chat(editBox, chatType, backdropFrame2, channel_name)
	local msg_list
	local info = ChatTypeInfo[chatType]
	local r, g, b = info.r, info.g, info.b
	local chatGroup = Chat_GetChatCategory(chatType);
	if chatType == "CHANNEL" then
		local channelTarget = editBox:GetAttribute("channelTarget") or 'SAY'
		local channelNumber, channelname = GetChannelName(channelTarget)
		local channelText = ""
		if showChannelName then
			channelText = '|cFF' .. U:RGBToHex(r, g, b) .. channelTarget .. ' ' .. channelname .. '|r'
		end
		channel_name:SetText(channelText)
		msg_list = D:ReadDB('CHANNEL' .. channelNumber, {})
	else
		local classColor
		local target = (editBox:GetAttribute("tellTarget") or '')
		if target and target ~= '' then
			local name, realm = strsplit('-', target)
			if realm == GetRealmName() then
				target = name
			end
		end
		if not chatType:find('WHISPER') then
			target = ''
		else
			classColor = U:UnitColor(target)
			if classColor then
				target = '|c' .. classColor .. target .. '|r'
			end
		end
		local channelText = ""
		if showChannelName then
			channelText = '|cFF' .. U:RGBToHex(r, g, b) .. U:join(' : ', G[chatType], target) .. '|r'
		else
			channelText = '|cFF' .. U:RGBToHex(r, g, b) .. target .. '|r'
		end
		channel_name:SetText(channelText)
		if strfind(chatType, "BN_WHISPER") then
			msg_list = D:ReadDB(chatGroup, {}, true)
		else
			msg_list = D:ReadDB(chatGroup, {})
		end
	end
	for _, v in ipairs(chat_frame) do
		v:Hide()
	end
	for _, v in ipairs(chat_frame_texture) do
		v:Hide()
	end
	-- chat_h = 1
	local c_h = 0
	for k = 0, 4 do
		local msg = msg_list[#msg_list - k]
		msg = M.ICON:EmojiFilter(msg)
		msg = M.ICON:IconFilter(msg)
		msg = U:BTagFilter(msg)
		msg = U:TTagFilter(msg, showTime)
		if msg and #msg > 0 then
			-- if msg and #msg > 0 then chat_h = chat_h + 1 end
			local fontString = chat_frame[k + 1] or
				backdropFrame2:CreateFontString("II_CHAT_FONTSTRING" .. (k + 1), "OVERLAY", "GameFontNormal")
			local bgTexture = chat_frame_texture[k + 1] or
				backdropFrame2:CreateTexture("II_CHAT_FONTSTRING_TEXTURE" .. (k + 1), "BACKGROUND", nil, 1)
			bgTexture:Hide()
			bgTexture:SetColorTexture(0, 0, 0, 0.3)
			bgTexture:SetPoint("TOPLEFT", fontString, "TOPLEFT", -5, 1)
			bgTexture:SetPoint("BOTTOMRIGHT", fontString, "BOTTOMRIGHT", 5, -2)

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
			fontString:SetFont(fontfile or W.defaultFontName, 16 * scale, flags)
			local a = 1 - math.log(k + 1) + 2 / math.log(#msg_list)
			if a < 0 then a = 0 end
			if a > 1 then a = 1 end
			fontString:SetAlpha(a)
			bgTexture:SetAlpha(a)
			fontString:Show()
			if showbg then
				bgTexture:Show()
			end
			chat_frame[k + 1] = fontString
			chat_frame_texture[k + 1] = bgTexture
			c_h = c_h + fontString:GetHeight() + 3
		end
	end
	backdropFrame2:SetHeight(c_h)
end

---@param editBox EditBox
---@param bg Texture
---@param bg3 Texture
---@param border table|BackdropTemplate|Frame
---@param backdropFrame2 table|BackdropTemplate|Frame
---@param resizeBtnTexture Texture
---@param channel_name FontString
---@param II_LANG FontString
function ChannelChange(editBox, bg, bg3, border, backdropFrame2, resizeBtnTexture, channel_name, II_LANG)
	HideEuiBorder(editBox)
	for i = 1, #G.CHAT_FRAMES do
		G['ChatFrame' .. i .. 'EditBoxHeader']:SetText("")
	end
	editBox:SetTextInsets(10, 10, 0, 0) -- 左, 右, 上, 下
	local chatType = editBox:GetAttribute("chatType") or "SAY"
	local info = ChatTypeInfo[chatType]
	local r, g, b = info.r, info.g, info.b
	bg:SetColorTexture(r, g, b, 0.15)
	-- for i, v in ipairs(II_TIP_BG) do
	-- 	v:SetColorTexture(r, g, b, 0.15)
	-- end
	II_LANG:SetTextColor(r, g, b, 0.6)
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
	local useFunc = {}
	for idx, chatFrame in ipairs(G.CHAT_FRAMES) do
		if G[chatFrame] then
			for _, messageType in pairs(G[chatFrame].messageTypeList) do
				if gsub(strsub(event, 10), '_INFORM', '') == messageType and arg1 and not MessageIsProtected(arg1) then
					local chatFilters = ChatFrame_GetMessageEventFilters(event)
					if chatFilters then
						for _, filterFunc in ipairs(chatFilters) do
							local isUse = false
							for _, v in ipairs(useFunc) do
								if v == filterFunc then
									isUse = true
								end
							end
							if not isUse then
								local filter, new1, new2, new3, new4, new5, new6, new7, new8, new9, new10, new11, new12, new13, new14, new15, new16, new17 =
									filterFunc(G[chatFrame], event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9,
										arg10,
										arg11, arg12, arg13, arg14, arg15, arg16, arg17)
								tinsert(useFunc, filterFunc)
								if filter then
									return true
								elseif new1 then
									arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17 =
										new1, new2, new3, new4, new5, new6, new7, new8, new9, new10, new11, new12, new13,
										new14,
										new15, new16, new17
								end
							end
						end
					end
				end
			end
		end
	end
	return false, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16,
		arg17
end
local autoHide = true

local last_text = ''

---@param editBox EditBox
---@param bg Texture
---@param border table|BackdropTemplate|Frame
---@param backdropFrame2 table|BackdropTemplate|Frame
---@param resizeButton table|Button
---@param texture_btn Texture
---@param channel_name FontString
---@param II_TIP FontString
---@param II_LANG FontString
local function eventSetup(editBox, bg, border, backdropFrame2, resizeButton, texture_btn, channel_name, II_TIP, II_LANG,
						  bg3)
	editBox:HookScript("OnEscapePressed", editBox.ClearFocus) -- 允许按下 Esc 清除焦点+
	-- NDui
	if NDui then
		editBox:HookScript("OnShow", function(self)
			LoadPostion(self)
			LoadSize(scale, editBox, backdropFrame2, channel_name, II_TIP, II_LANG)
			local children = { editBox:GetChildren() }
			for _, child in ipairs(children) do
				---@diagnostic disable-next-line: undefined-field
				if child.__bgTex then
					---@diagnostic disable-next-line: undefined-field
					child:Hide()
				end
			end
		end)
	else
		if not ElvUI then
			editBox:HookScript("OnShow", function(self)
				-- if lastChannel ~= '' and lastChannel ~= self:GetAttribute("channelTarget") then
				-- 	editBox:SetText("/" .. lastChannel .. " ")
				-- end`
			end)
		else
		end
	end
	-- editBox:HookScript("OnShow", function(self)
	-- 	LoadPostion(self)
	-- 	LoadSize(scale, editBox, backdropFrame2, channel_name, II_TIP, II_LANG)
	-- end)

	editBox:HookScript("OnDragStart", function(...)
		if IsShiftKeyDown() and not editMode then
			editBox.StartMoving(...)
		end
	end);
	editBox:HookScript("OnDragStop", function()
		editBox:StopMovingOrSizing()
		local point, _, relativePoint, xOfs, yOfs = editBox:GetPoint(1)
		D:SaveDB('editBoxPosition', {
			point, relativePoint, xOfs, yOfs
		})
	end);
	-- resize repoint
	editBox:HookScript("OnMouseDown", function(self, button)
		if IsShiftKeyDown() and button == "RightButton" and not editMode then
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

	resizeButton:HookScript("OnMouseDown", function(self, button)
		if button == "LeftButton" and IsShiftKeyDown() then
			resize = true
			local x, y = GetCursorPosition()
			X_g = x
		end
	end)
	resizeButton:HookScript("OnMouseUp", function(self, button)
		resize = false
		scale = scale_temp
		D:SaveDB('input_size', scale)
	end)
	local w = GetScreenWidth()
	resizeButton:HookScript("OnUpdate", function(self, button)
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

	UIParent:HookScript("OnUpdate", function(self, button)
		if not InCombatLockdown() and not editMode then
			if IsShiftKeyDown() then
				resizeButton:Show()
			else
				resizeButton:Hide()
			end
		else
			resizeButton:Hide()
		end
	end)

	-- local orgOnEnterPressed = editBox:GetScript("OnEnterPressed")
	editBox:HookScript("OnEnterPressed", function(self, ...)
		local message = last_text
		-- 检查输入框是否有内容
		if message and message ~= "" and message:sub(1, 1) ~= "/" then
			U:AddOrMoveToEnd(messageHistory, message)
			local patt = message:gsub("%|c.-(%[.-%]).-%|r", function(a1)
				return a1
			end)
			if patt and patt ~= "" then
				-- 常用词
				local hisp = U:CutWord(patt)
				if hisp and #hisp > 0 then
					for _, word in ipairs(hisp) do
						if word and #word > 1 then
							U:AddOrAddOne(C_Word, word)
						end
					end
				end
			end
		end
		local temp = {}
		if #messageHistory > 100 then
			for k = #messageHistory - 100, #messageHistory do
				tinsert(temp, messageHistory[k])
			end
		else
			temp = messageHistory
		end
		messageHistory = temp
		D:SaveDB('messageHistory', messageHistory, true)
		D:SaveDB('C_Word', C_Word, true)

		-- 重置历史索引
		historyIndex = #messageHistory + 1
		last_text = ''
	end)
	local cacheTxt = ''
	editBox:HookScript("OnTextChanged", function(self, userInput)
		local text = self:GetText()
		if text ~= cacheTxt then
			tip = FindHis(messageHistory, text)
			cacheTxt = text
		end
		for i, v in ipairs(II_TIP) do
			if II_TIP_BG[i] then
				II_TIP_BG[i]:Hide()
			end
			UpdateFontStringPosition(self, v, tip[i], i, #tip)
		end
		if userInput then
			M.HISTORY:simulateInputChange(text, self:GetInputLanguage())
		end
		last_text = text
		-- lastChannel = self:GetAttribute("chatType")
		if ls_Glass then
			-- editBox:SetTextInsets(10, 10, 0, 0)
		end
	end)
	editBox:HookScript("OnInputLanguageChanged", function(self)
		II_LANG:SetText(_G["INPUT_" .. self:GetInputLanguage()])
	end)
	editBox:HookScript("OnKeyDown", function(self, key, ...)
		-- local totalHeight = self:GetHeight() -- 获取 EditBox 的总高度
		-- local _, fontHeight = self:GetFont() -- 获取字体高度
		-- local multiLine = totalHeight > fontHeight * 1.1
		local multiLine = false
		if key == "TAB" then
			if not ElvUI and not NDui then
				UpdateChannel(self)
			end
			if NDui then
				hooksecurefunc("ChatEdit_CustomTabPressed", function(self)
					ChannelChange(self, bg, bg3, border, backdropFrame2, texture_btn, channel_name, II_LANG)
				end)
			end
		elseif key == "UP" and not multiLine then
			-- 上滚历史消息
			if not ElvUI or ls_Glass then
				if historyIndex > 1 then
					historyIndex = historyIndex - 1
					local h = messageHistory[historyIndex]
					self:SetText(h)
					self:SetCursorPosition(#h)
				end
			end
		elseif key == "DOWN" and not multiLine then
			if not ElvUI or ls_Glass then
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
		elseif #tip > 0 and IsLeftControlKeyDown() and (key == "1" or key == "2" or key == "3" or key == "4" or key == "5") then
			local ps = tip[tonumber(key)]
			if ps then
				local message = self:GetText()
				local p = message .. ps
				self:SetText(p)
				M.HISTORY:simulateInputChange(p, self:GetInputLanguage())
			end
		elseif key == "LCTRL" then
			-- local message = self:GetText()
			-- if #tip > 0 and IsLeftControlKeyDown() then
			-- 	local p = message .. tip[1]
			-- 	self:SetText(p)
			-- 	M.HISTORY:simulateInputChange(p, self:GetInputLanguage())
			-- 	return
			-- end
			-- if message:sub(1, 4) == "/sp " then
			-- 	message = string.gsub(message, "/sp ", "", 1)
			-- 	message = '/script print(' .. message .. ')'
			-- 	self:SetText(message)
			-- elseif message:sub(1, 5) == "/sps " then
			-- 	message = string.gsub(message, "/sps ", "", 1)
			-- 	message = '/script print("' .. message .. '")'
			-- 	self:SetText(message)
			-- elseif message:sub(1, 5) == "/spa " then
			-- 	message = string.gsub(message, "/spa ", "", 1)
			-- 	message = '/script for _, v in ipairs(' .. message .. ') do print(v) end'
			-- 	self:SetText(message)
			-- elseif message:sub(1, 5) == "/spt " then
			-- 	message = string.gsub(message, "/spt ", "", 1)
			-- 	message = '/script for k, v in pairs(' .. message .. ') do print(k, v) end'
			-- 	self:SetText(message)
			-- end
		end
	end)
	hooksecurefunc("ChatEdit_UpdateHeader", function(self)
		ChannelChange(self, bg, bg3, border, backdropFrame2, texture_btn, channel_name, II_LANG)
	end)

	-- 设置焦点获得事件处理函数
	editBox:HookScript("OnEditFocusGained", function(self)
		HideEuiBorder(self)
		HideLS_GLASSBorder(editBox)
		-- Elvui 会重置输入框的位置大小
		if ElvUI then
			LoadSize(scale, self, backdropFrame2, channel_name, II_TIP, II_LANG)
			LoadPostion(self)
		end
		ChatChange = true
		self:SetText(last_text)
	end)
	editBox:HookScript("OnEditFocusLost", function(self)
		if not autoHide then
			self:Show() -- 强制显示
			self:SetFocus() -- 保持焦点
		else
			self:Hide()
			ChatChange = false
			if not self:GetText() or #self:GetText() <= 0 then
				M.HISTORY:clearHistory()
			end
		end
	end)

	local frame_E = CreateFrame("Frame", "II_EVENT_FRAME")
	for k, v in pairs(ChatLabels) do
		frame_E:RegisterEvent(v)
	end
	frame_E:RegisterEvent('CHAT_MSG_CHANNEL')

	frame_E:HookScript("OnEvent",
		function(self, ...)
			local event, msg, sender, language, channelString, target, flags, zoneChannelID, channelNumber,
			channelName, languageID, _, guid, bnSenderID, isMobile, isSubtitle, supressRaidIcons = ...
			LOG:SaveLog('msg_even_' .. event, { ... })

			local chatType = strsub(event, 10) or 'SAY';

			local filter = false
			filter, msg, sender, language, channelString, target, flags, zoneChannelID, channelNumber,
			channelName, languageID, _, guid, bnSenderID, isMobile, isSubtitle, supressRaidIcons =
				chatEventHandler(event, msg, sender, language, channelString, target, flags, zoneChannelID,
					channelNumber,
					channelName, languageID, _, guid, bnSenderID, isMobile, isSubtitle, supressRaidIcons)
			if filter then
				return
			end

			-- if language and #language > 0 and sender and #sender > 0 then
			-- 	if UnitFactionGroup('player') ~= UnitFactionGroup(sender) then
			-- 		msg = '[' .. language .. ']' .. msg
			-- 	end
			-- end

			local chatGroup = Chat_GetChatCategory(chatType);
			if isMobile then
				local info = ChatTypeInfo[chatType];
				msg = ChatFrame_GetMobileEmbeddedTexture(info.r, info.g, info.b) .. msg;
			end
			-- msg = C_ChatInfo.ReplaceIconAndGroupExpressions(msg, supressRaidIcons,
			-- 	not ChatFrame_CanChatGroupPerformExpressionExpansion(chatGroup))

			if chatType == "SAY" or chatType == "YELL" then
				local usingDifferentLanguage = (language ~= "") and
					(language ~= ChatFrame1.alternativeDefaultLanguage)
				local languageHeader = "[" .. language .. "] "
				if msg and type(msg) == 'string' and (not ElvUI or not strfind(msg, languageHeader, 1, true)) and usingDifferentLanguage then
					msg = languageHeader .. msg
				end
			end

			if event == 'CHAT_MSG_CHANNEL' then
				SaveMSG('CHANNEL' .. channelNumber, 'CHANNEL' .. channelNumber, guid or bnSenderID, msg or '',
					true, sender)
				if ChatChange then
					ChannelChange(editBox, bg, bg3, border, backdropFrame2, texture_btn, channel_name, II_LANG)
				end
			end
			for k, v in pairs(ChatLabels) do
				if event == v then
					local start, _end = event:find('_INFORM')
					SaveMSG(chatGroup, k, guid or bnSenderID, msg or '', false, sender, start and start > 0)
					if ChatChange then
						ChannelChange(editBox, bg, bg3, border, backdropFrame2, texture_btn, channel_name, II_LANG)
					end
					break
				end
			end
			-- 记录聊天频道的信息作为提示
			if event == 'CHAT_MSG_WHISPER' or event == 'CHAT_MSG_GUILD' or event == 'CHAT_MSG_OFFICER' or event == 'CHAT_MSG_BN_WHISPER' then
				local patt = (msg or ''):gsub("%|c.-(%[.-%]).-%|r", function(a1)
					return a1
				end)
				if patt and patt ~= "" then
					-- 常用词
					local hisp = U:CutWord(patt)
					if hisp and #hisp > 0 then
						for _, word in ipairs(hisp) do
							if word and #word > 1 then
								U:AddOrAddOne(C_Word, word)
							end
						end
					end
					D:SaveDB('C_Word', C_Word, true)
				end
			end
		end)
end
local disableLoginInformation = false
---@param backdropFrame2 table|BackdropTemplate|Frame
local function optionSetup(backdropFrame2)
	-- options 设置
	function MAIN:HideChat(show)
		if show then
			backdropFrame2:Show()
		else
			backdropFrame2:Hide()
		end
	end

	function MAIN:HideChannel(show)
		showChannelName = show
	end

	function MAIN:HideTime(show)
		showTime = show
	end

	function MAIN:Hidebg(show)
		showbg = show
	end

	function MAIN:MultiTip(show)
		multiTip = show
	end

	function MAIN:DisableLoginInformation(show)
		disableLoginInformation = show
	end

	-- M:RegisterCallback('MAIN', 'HideChat', function(show)
	-- 	if show then
	-- 		backdropFrame2:Show()
	-- 	else
	-- 		backdropFrame2:Hide()
	-- 	end
	-- end)
	-- M:RegisterCallback('MAIN', 'HideChannel', function(show)
	-- 	showChannelName = show
	-- end)
	-- M:RegisterCallback('MAIN', 'HideTime', function (show)
	-- 	showTime = show
	-- end)
	-- M:RegisterCallback('MAIN', 'Hidebg', function (show)
	-- 	showbg = show
	-- end)
	-- M:RegisterCallback('MAIN', 'MultiTip', function (show)
	-- 	multiTip = show
	-- end)

	function M.MAIN:EnableIL_zh(show)
		local isLoad = C_AddOns_GetAddOnEnableState("InputInput_Libraries_zh") == 2
		if (isLoad and not show) or (not isLoad and show) then
			StaticPopup_Show("InputInput_RELOAD_UI_CONFIRMATION")
		end
		if show then
			C_AddOns_EnableAddOn('InputInput_Libraries_zh')
		else
			C_AddOns_DisableAddOn('InputInput_Libraries_zh')
		end
	end

	M:Fire('OPT', 'loadOPT')
	-- M.OPT:loadOPT()
end

local ChatChange = false
local frame = CreateFrame("Frame", "II_MAIN_FRAME")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("CVAR_UPDATE")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("CHAT_MSG_ADDON")

frame:RegisterEvent("ZONE_CHANGED")
frame:RegisterEvent("ZONE_CHANGED_INDOORS")
frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")

frame:RegisterEvent("GROUP_ROSTER_UPDATE")
frame:RegisterEvent("RAID_ROSTER_UPDATE")

for _, event in pairs(ChatTypeGroup["BN_WHISPER"]) do
	frame:RegisterEvent(event);
end
for _, event in pairs(ChatTypeGroup["WHISPER"]) do
	frame:RegisterEvent(event);
end
local editBox, bg, border, backdropFrame2, resizeButton, resizeBtnTexture, channel_name, II_TIP, II_LANG, bg3
local SendRecieveGroupSize = 0
local SendMessageWaiting = nil
local versionUpdateMsg = nil
frame:HookScript("OnEvent", function(self_f, event, ...)
	if not isInit then
		editBox, bg, border, backdropFrame2, resizeButton, resizeBtnTexture, channel_name, II_TIP, II_LANG, bg3 =
			MAIN:Init()
		C_ChatInfo_RegisterAddonMessagePrefix('INPUTINPUT_V')
		U:Delay(5, function()
			U:InitFriends()
			U:InitGuilds()
			U:InitGroupMembers()
		end)

		-- 正式服编辑模式
		if W.ClientVersion >= 100000 then
			local LEM = LibStub('LibEditMode')
			editBox.editModeName = L['InputBox']
			LEM:AddFrame(editBox, function(f, layoutName, point, x, y)
				local _, _, relativePoint, _, _ = editBox:GetPoint(1)
				D:SaveDB('editBoxPosition', {
					point, relativePoint, x, y
				})
				D:SaveDB('input_size', scale)
			end, {
				point = 'BOTTOM',
				x = 0,
				y = 315,
			})

			LEM:RegisterCallback('enter', function()
				editBox:Show()
				autoHide = false
				editMode = true
			end)
			LEM:RegisterCallback('exit', function()
				editBox:Hide()
				autoHide = true
				editMode = false
				editBox:SetMovable(true)
			end)

			LEM:AddFrameSettings(editBox, {
				{
					name = L['scale'],
					kind = LEM.SettingType.Slider,
					default = 1,
					get = function(layoutName)
						return scale
					end,
					set = function(layoutName, value)
						scale = value
						LoadSize(scale, editBox, backdropFrame2, channel_name, II_TIP, II_LANG)
					end,
					minValue = 0.1,
					maxValue = 10,
					valueStep = 0.1,
					formatter = function(value)
						return FormatPercentage(value, true)
					end,
				}
			})
		end

		
		-- 更新记录
		local updateTip = D:ReadDB('IIUpdateTip', '1.0.17', true)
		-- 首次安装的版本
		local fristInstallVersion = D:ReadDB('fristInstallVersion', nil, true)
		-- if fristInstallVersion ~= nil and W:getVersion(fristInstallVersion) < W:getVersion(W.version) then
		-- 	updateTip = W.version
		-- end
		if fristInstallVersion == nil then
			D:SaveDB('fristInstallVersion', W.version, true)
		end
		if W:getVersion(updateTip) <= W:getVersion(W.version) then
			local updateTipframe = CreateFrame("Frame", nil, UIParent)
			updateTipframe:SetSize(1000, 200)  -- 设置框的大小
			updateTipframe:SetPoint("CENTER", UIParent, "CENTER", 0, 0)  -- 设置框的位置

			-- 创建一个背景纹理并设置为黑色
			local background = updateTipframe:CreateTexture(nil, "BACKGROUND")
			background:SetAllPoints(updateTipframe)  -- 设置背景纹理填满整个框
			background:SetColorTexture(0, 0, 0, 0.6)  -- 设置背景颜色为黑色（RGBA）

			local title = updateTipframe:CreateFontString(nil, "OVERLAY", "GameFontNormal")
			title:SetPoint("TOP", updateTipframe, "TOP", 0, -5)  -- 设置文本在框中的位置
			title:SetText(W.colorName)
			local fontFile, hight, flags = title:GetFont()
			title:SetFont(fontFile or W.defaultFontName, 44, flags)

			-- 创建一个显示文本的框
			local text = updateTipframe:CreateFontString(nil, "OVERLAY", "GameFontNormal")
			text:SetPoint("CENTER", updateTipframe, "CENTER", 0, 0)  -- 设置文本在框中的位置
			text:SetText(L['UpdateTip'])  -- 设置显示的文本
			local fontFile, hight, flags = text:GetFont()
			text:SetFont(fontFile or W.defaultFontName, 22, flags)
			text:SetWordWrap(true)
			text:SetNonSpaceWrap(true)
			text:SetWidth(800)

			-- 可选：修改文本颜色
			text:SetTextColor(1, 1, 1)  -- 设置文本颜色为白色

			-- 创建关闭按钮
			local closeButton = CreateFrame("Button", nil, updateTipframe, "UIPanelCloseButton")
			closeButton:SetPoint("TOPRIGHT", updateTipframe, "TOPRIGHT", -5, -5)

			-- 创建“下次不再提示”复选框
			local checkBox = CreateFrame("CheckButton", nil, updateTipframe, "UICheckButtonTemplate")
			checkBox:SetPoint("TOPRIGHT", updateTipframe, "TOPRIGHT", 30, 0)
			checkBox.text:SetText(L['nextNoTip'])
			checkBox:SetChecked(false)

			-- 关闭按钮点击事件
			closeButton:SetScript("OnClick", function()
				local check = checkBox:GetChecked()
				if check == true then
					D:SaveDB('IIUpdateTip', '99999.0.0', true)
				end
				updateTipframe:Hide()
			end)
		end
	end
	if event == 'PLAYER_ENTERING_WORLD' or strfind(event, "WHISPER", 0, true) then
		for _, chatFrameName in pairs(CHAT_FRAMES) do
			local chatFrameTab = _G[chatFrameName .. "Tab"]
			-- Hook点击标签的事件
			chatFrameTab:HookScript("OnClick", function(self, button)
				if button == "LeftButton" then
					local chatFrameEditBox = _G[chatFrameName .. "EditBox"]
					chatFrameEditBox:Hide() -- 隐藏聊天输入框
					ChatFrame1EditBox:SetFocus()
					ChatFrame1EditBox:Hide()
				end
			end)
		end
		-- 覆盖默认的聊天输入框打开行为
		hooksecurefunc("ChatEdit_ActivateChat", function(self)
			-- 如果当前焦点不是 ChatFrame1EditBox，切换焦点
			if self ~= ChatFrame1EditBox then
				ChatFrame1EditBox:SetText(editBox:GetText()) -- 保留原输入框中的内容
				ChatFrame1EditBox:Show()
				ChatFrame1EditBox:SetFocus()
				self:Hide() -- 隐藏原输入框
				-- 默认输入框失去焦点后重新设置输入框频道信息
				local ct = ChatFrame1EditBox:GetAttribute("chatType")
				local temp = self:GetText()
				self:SetText("/" .. ct .. " ")
				if temp:sub(1, 1) == '/' then
					temp = ''
				end
				self:SetText(temp)
			end
		end)

		U:InitZones()
		if not SendMessageWaiting then
			SendMessageWaiting = U:Delay(10, U.SendVersionMsg)
		end
	elseif event == 'CVAR_UPDATE' then
		local cvarName, value = ...
		if cvarName == 'chatStyle' or cvarName == 'whisperMode' then
			LoadSize(scale, editBox, backdropFrame2, channel_name, II_TIP, II_LANG)
			LoadPostion(editBox)
		end
	elseif event == 'FRIENDLIST_UPDATE' then
		U:InitFriends()
	elseif event == 'GUILD_ROSTER_UPDATE' then
		U:InitGuilds()
	elseif event == 'ADDON_LOADED' then
		local addOnName, containsBindings = ...
		if addOnName == "InputInput_Libraries_zh" then
			LOG:Debug("---加载词库0%---")
			W.dict1 = LibStub("inputinput-dict1").dict
			W.dict2 = LibStub("inputinput-dict2").dict
			W.dict3 = LibStub("inputinput-dict3").dict
			W.dict4 = LibStub("inputinput-dict4").dict
			W.dict5 = LibStub("inputinput-dict5").dict
			W.dict6 = LibStub("inputinput-dict6").dict
			-- 魔兽词库
			W.words = LibStub("inputinput-words").words

			local total = 60101967

			local logtotal = math.log(total)

			for i, v in pairs(W.dict1) do
				W.dict1[i] = math.log(v) - logtotal
			end
			for i, v in pairs(W.dict2) do
				W.dict2[i] = math.log(v) - logtotal
			end
			for i, v in pairs(W.dict3) do
				W.dict3[i] = math.log(v) - logtotal
			end
			for i, v in pairs(W.dict4) do
				W.dict4[i] = math.log(v) - logtotal
			end
			for i, v in pairs(W.dict5) do
				W.dict5[i] = math.log(v) - logtotal
			end
			for i, v in pairs(W.dict6) do
				W.dict6[i] = math.log(v) - logtotal
			end
			LOG:Debug("---加载词库100%---")
			U:InitWordCache(messageHistory)
		end
	elseif event == 'ZONE_CHANGED' or event == 'ZONE_CHANGED_INDOORS' or event == 'ZONE_CHANGED_NEW_AREA' then
		U:InitZones()
	elseif event == 'GROUP_ROSTER_UPDATE' or event == 'RAID_ROSTER_UPDATE' then
		U:InitGroupMembers()
		local num = GetNumGroupMembers()
		if num ~= SendRecieveGroupSize then
			if num > 1 and num > SendRecieveGroupSize then
				if not SendMessageWaiting then
					SendMessageWaiting = U:Delay(10, U.SendVersionMsg)
				end
			end
			SendRecieveGroupSize = num
		end
	elseif event == 'CHAT_MSG_ADDON' then
		local prefix, text, channel, sender, target, zoneChannelID, localID, name, instanceID = ...
		if prefix == "INPUTINPUT_V" and (not versionUpdateMsg or time() - versionUpdateMsg > 60 * 30) then
			local ver, msg, inCombat = W:getVersion(W.version), W:getVersion(text), InCombatLockdown()
			LOG:Debug(ver, msg, text)
			if msg and (msg > ver) and not inCombat then
				LOG:Info(string.format(L['New Version Discovered'], W.colorName,
					'|cFFFFFFFF' .. text .. '|r|cFF909399 (' .. W.version .. ')|r'))
				versionUpdateMsg = time()
			end
		end
	else
		if (C_AddOns_IsAddOnLoaded("ElvUI") or ElvUI == nil) and
			(C_AddOns_IsAddOnLoaded("NDui") or NDui == nil) then
			eventSetup(editBox, bg, border, backdropFrame2, resizeButton, resizeBtnTexture, channel_name, II_TIP, II_LANG,
				bg3)
			optionSetup(backdropFrame2)
			M:RegisterCallback('OPT', 'loadOPTFinish', function()
				if not disableLoginInformation then
					local discord = 'https://discord.gg/qC9RAdXN'
					local curseforge = 'https://www.curseforge.com/wow/addons/inputinput/comments'
					local kook = 'https://kook.vip/vghP6R'
					U:Delay(5, function(cb)
						LOG:Info(string.format(L['Login Information 1'],
							W.colorName,
							'|cFFF56C6C[|HInputInputURL:' ..
							kook .. '|hKOOK(国服)|h]|r、' .. '|cFFF56C6C[|HInputInputURL:' .. discord .. '|hDiscord|h]|r',
							'|cFFF56C6C[|HInputInputURL:' .. curseforge .. '|hCurseForge|h]|r'))
						LOG:Info(string.format(L['Login Information 2'], "|cff409EFF/ii|r", "|cff409EFF/inputinput|r",
							'|cffF56C6C|HInputInputOPT:show|h[', ']|h|r'))
					end)
				end
			end)

			U:Delay(7, function(cb)
				local isLoad = C_AddOns_GetAddOnEnableState("InputInput_Libraries_zh") == 2
				if GetLocale() == 'zhCN' or GetLocale() == 'zhTW' then
					if not (C_AddOns_GetAddOnEnableState("InputInput_Libraries_zh") == 2) then
						LOG:Warn('|cff409EFF|cffffff00i|rnput|cffffff00i|rnput|r_Libraries_|cffF56C6Czh|r' ..
							format(L['Not enabled, enter/ii to enable'], "|cff409EFF/ii|r"))
					end
				end
			end)

			LoadSize(scale, editBox, backdropFrame2, channel_name, II_TIP, II_LANG)
			LoadPostion(editBox)

			-- local jieba = LibStub("inputinput-jieba")
			-- for _, i in ipairs(jieba.lcut('地精', false, true)) do
			-- 	LOG:Debug(i)
			-- end
		end
	end
end)
