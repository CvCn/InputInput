local W, M, U, D, G, L, E, API, LOG = unpack((select(2, ...)))
local HISTORY = {}
M.HISTORY = HISTORY

local history = { '' }
local index = 1

-- 返回上一次的输入历史
-- 通过递减索引值来访问历史记录中的上一条记录
---@return string
function HISTORY:undo()
    index = index - 1
    if index < 1 then
        index = 1
    end
    return history[index]
end

-- 返回下一次的输入历史
-- 通过递增索引值来访问历史记录中的下一条记录
---@return string
function HISTORY:redo()
    index = index + 1
    if index > #history then
        index = #history
    end
    return history[index]
end

-- 模拟输入框内容更改
-- 当输入框内容更改时，更新历史记录
-- 索引加一表示新增一条记录，同时删除相同索引的历史记录（如果存在），然后插入新的记录
---@param newText string
function HISTORY:simulateInputChange(newText)
    index = index + 1
    tremove(history, index)
    table.insert(history, newText)
end

-- 清除所有输入历史
-- 将历史记录表重置为空表，并将索引重置为1
function HISTORY:clearHistory()
    history = { '' }
    index = 1
end