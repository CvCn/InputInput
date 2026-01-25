-- 注意!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
-- 这个是专门的调试文件
-- 注意!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

local W, M, U, D, G, L, E, API, LOG = unpack((select(2, ...)))

if E ~= 'DEV' then
    return
end


local entityTable = U:StringToTable(
    "!INPUTINPUT:1!9jvxoTrtqqXribcKO80NuEmcfYnW)aog8co4f8JR7DN272IXtpQNzmFlpYrGtqKpc7jiIJakNaoc5eKznrGJIuK2FQPQPREMU7To6Endku1rPoZ4(2hFOlZopzktzw7ESJPuQpbRDE2GUMoHcpXgWZI0LkNsLo7U)gKDjtfy2XXyBFVRRF6xdOZ7SV7zycPmuzLFSWAUmG238SuAfofKPKVImn)x3q5abYZXyEcLtGIRKEG1g992Ecm3pHwi9rpqA3Q(eS2SlgMpqtkuw9fWOQpL9OZ((xWzDbVxJhXsNBqH9v2p8petfeCbjAXEBSR(cuYM562lHD7neghHGqGD3niNubk(ADK4pDzZ7QDNneEH9Vt6aDTTYDoPsj7QHgBWV(JDVxWzJOCjEkIXCtvZjvORUiJgTu)5KZtBsidLa2rKbT7KWbJ)yoigqFOPcmfO6(KGO5Ro8)TS4TVoPoEsk6hmLiBwpoC3PGuqoxWzF1ZWSbWcCmOYhRbpkpobwIQHgNV1tND7yrqqvcQiiRheCOd)zS9fI7ookv02nTBNYlWZMNIASn3RvYJCXNhtLaojsDjOJdknXsKTpA1OhxnfQTmz8xm8HcnHg)LO4IH(2T(X3LLpHp)G9py)pDRd9Tt1ULnObY14WrXs0m7EkY1UCexsMHM5SSyDYNL7Q4RZlRAA)3lwFmOE2TTlsPf4S7BrjbTNIDJN4JBYx9R)")

LOG:Debug(entityTable.clientVersion)
LOG:Debug(entityTable.version)
LOG:Debug("-------loadedAddOns-----------")
for i, name in ipairs(entityTable.loadedAddOns) do
    LOG:Debug(name)
end
LOG:Debug("-------settings---------------")
for k, v in pairs(entityTable.settings) do
    LOG:Debug(k, v)
end