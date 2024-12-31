local W, M, U, D, G, L, E, API, LOG = unpack((select(2, ...)))

local callbacks = {}

function M:RegisterCallback(eventName, onEventFuncName, onEventFunc)
    if not callbacks[eventName] then callbacks[eventName] = {} end
    callbacks[eventName][onEventFuncName] = onEventFunc
end

function M:UnregisterCallback(eventName, onEventFuncName)
    if not callbacks[eventName] then return end
    callbacks[eventName][onEventFuncName] = nil
end

function M:UnregisterAllCallbacks(eventName)
    if not callbacks[eventName] then return end
    callbacks[eventName] = nil
end

function M:Fire(eventName, eventFuncName, ...)
    if not callbacks[eventName] then return end
    for onEventFuncName, onEventFunc in pairs(callbacks[eventName] or {}) do
        if eventFuncName == onEventFuncName then
            U:Delay(0.01, onEventFunc, ...)
        end
    end
end