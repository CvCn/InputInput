local utf8 = LibStub("inputinput-jieba-utf8")

-- 使用 LibStub 创建一个新库
local MAJOR, MINOR = "inputinput-jieba-utils", 1
local M, oldVersion = LibStub:NewLibrary(MAJOR, MINOR)

-- 检查是否成功创建了新版本的库
if not M then
   return
end

-- UTF-8 字符分类函数
local function utf8Codepoint(utf8str)
   local byte = string.byte
   local len = #utf8str -- 获取字符串长度
   local char1 = byte(utf8str, 1)

   if char1 < 0x80 then
      return char1
   elseif char1 < 0xE0 and len >= 2 then
      local char2 = byte(utf8str, 2)
      return ((char1 % 0x20) * 0x40) + (char2 % 0x40)
   elseif char1 < 0xF0 and len >= 3 then
      local char2 = byte(utf8str, 2)
      local char3 = byte(utf8str, 3)
      return ((char1 % 0x10) * 0x1000) + ((char2 % 0x40) * 0x40) + (char3 % 0x40)
   elseif len >= 4 then
      local char2 = byte(utf8str, 2)
      local char3 = byte(utf8str, 3)
      local char4 = byte(utf8str, 4)
      return ((char1 % 0x08) * 0x40000) + ((char2 % 0x40) * 0x1000) + ((char3 % 0x40) * 0x40) + (char4 % 0x40)
   else
      -- 如果字符串长度不足以解析字符，返回 nil
      return nil
   end
end


-- 判断是否为中文汉字
local function isHans(charCode)
   return charCode >= 0x4E00 and charCode <= 0x9FFF
end

-- 判断是否为英文字母
local function isEngs(charCode)
   return (charCode >= 0x61 and charCode <= 0x7A) or (charCode >= 0x41 and charCode <= 0x5A)
end

-- 判断是否为数字
local function isNums(charCode)
   return charCode >= 0x30 and charCode <= 0x39
end

-- 判断是否为半角标点符号
local function isHalfPunc(charCode)
   local halfPuncChars = "·.,;!?()[]{}+-=_!@#$%^&*~`'\"<>:|\\"
   return halfPuncChars:find(string.char(charCode), 1, true) ~= nil
end

-- 判断是否为全角标点符号
local function isFullPunc(charCode)
   return (charCode >= 0x3000 and charCode <= 0x303F) or (charCode >= 0xFF01 and charCode <= 0xFF5E) or
       (charCode >= 0x2000 and charCode <= 0x206F)
end

-- 判断是否为空白字符
local function isSpaces(charCode)
   return charCode == 0x20 or charCode == 0x09 or charCode == 0x0A
end

-- 字符串分割函数
function M.split_string(str)
   local result = {}
   local current = ""
   local lastType = nil

   local i = 1
   while i <= #str do
      local char = str:sub(i, i)
      local charCode = utf8Codepoint(char)
      local charType = "Unknown"
      if charCode then
         if isHans(charCode) then
            charType = "Hans"
         elseif isEngs(charCode) then
            charType = "Engs"
         elseif isNums(charCode) then
            charType = "Nums"
         elseif isHalfPunc(charCode) then
            charType = "HalfPunc"
         elseif isFullPunc(charCode) then
            charType = "FullPunc"
         elseif isSpaces(charCode) then
            charType = "Spaces"
         end
      end

      if charType ~= lastType and current ~= "" then
         table.insert(result, current)
         current = ""
      end

      current = current .. char
      lastType = charType

      i = i + 1
   end

   if current ~= "" then
      table.insert(result, current)
   end

   return result
end

function M.split_char(str)
   local res = {}
   local p = "[%z\1-\127\194-\244][\128-\191]*"

   for ch in string.gmatch(str, p) do
      table.insert(res, ch)
   end
   return res
end

local chsize = function(char)
   if not char then
      return 0
   elseif char > 240 then
      return 4
   elseif char > 225 then
      return 3
   elseif char > 192 then
      return 2
   else
      return 1
   end
end

M.sub = function(str, startChar, endChar)
   local startIndex = 1
   local numChars = endChar - startChar + 1
   while startChar > 1 do
      local char = string.byte(str, startIndex)
      startIndex = startIndex + chsize(char)
      startChar = startChar - 1
   end

   local currentIndex = startIndex

   while numChars > 0 and currentIndex <= #str do
      local char = string.byte(str, currentIndex)
      currentIndex = currentIndex + chsize(char)
      numChars = numChars - 1
   end
   return str:sub(startIndex, currentIndex - 1), numChars
end

M.is_eng = function(char)
   if string.find(char, "[a-zA-Z0-9]") then
      return true
   else
      return false
   end
end

local compare = function(a, b)
   if a[1] < b[1] then
      return true
   elseif a[1] > b[1] then
      return false
   end
end

M.max_of_array = function(t)
   table.sort(t, compare)
   return t[#t]
end

-- 不一定全
function M.is_punctuation(c)
   local code = utf8.codepoint(c)
   -- 全角标点符号的 Unicode 范围为：0x3000-0x303F, 0xFF00-0xFFFF
   return (code >= 0x3000 and code <= 0x303F) or (code >= 0xFF00 and code <= 0xFFFF)
end

function M.is_chinese_char(c)
   local code = utf8.codepoint(c)
   return (code >= 0x4E00 and code <= 0x9FA5)
end

function M.is_chinese(sentence)
   local tmp = true
   for i in string.gmatch(sentence, "[%z\1-\127\194-\244][\128-\191]*") do
      if not M.is_chinese_char(i) then
         tmp = tmp and false
      else
         tmp = tmp and true
      end
   end
   return tmp
end

function M.split_similar_char(s)
   local t = {} -- 创建一个table用来储存分割后的字符
   local currentString = ""
   local previousIsChinese = nil

   for i = 1, utf8.len(s) do                 -- 迭代整个字符串
      -- local c = utf8.sub(s, i, i) -- 求出第i个字符
      local c = M.sub(s, i, i)               -- 求出第i个字符
      local isChinese = M.is_chinese_char(c) --  判断是否是中文字符
      if previousIsChinese == nil or isChinese == previousIsChinese then
         currentString = currentString .. c
      else
         -- 添加先前的字符串
         if currentString ~= "" then
            table.insert(t, currentString)
            currentString = ""
         end
         currentString = c
      end
      previousIsChinese = isChinese
   end
   -- 添加最后的字符串（如存在）
   if currentString ~= "" then
      table.insert(t, currentString)
   end
   return t -- 返回含有所有字符串的table
end
