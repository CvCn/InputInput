local W, M, U, D, G, L = unpack((select(2, ...)))
local HISTORY = {}
M.HISTORY = HISTORY

local history = { '' }
local index = 1

function HISTORY:undo()
    index = index - 1
    if index < 1 then
        index = 1
    end
    return history[index]
end

function HISTORY:redo()
    index = index + 1
    if index > #history then
        index = #history
    end
    return history[index]
end

function HISTORY:simulateInputChange(newText)
    index = index + 1
    tremove(history, index)
    table.insert(history, newText)
end

function HISTORY:clearHistory()
    history = { '' }
    index = 1
end