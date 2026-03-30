-- 注意!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
-- 这个是专门的调试文件
-- 注意!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

local W, M, U, D, G, L, E, API, LOG = unpack((select(2, ...)))

if E ~= 'DEV' then
    return
end

U:Delay(1, function()
    local entityTable = U:StringToTable(
        "!INPUTINPUT:1!9rvxUTTrqyKBqutqCkAFPa95aeFd0pwkkr02vI2c9j5HKJiNQL7Uy2DLJ8J(i4tqHoc8guDem6jqhHCc6qkvjf4Icir(nFZYDMD2VzEv)nkdKHzTZYUs7(Zrp3XyCEsNhBmk3MieRnM4nACtBLQBbWqQh5TT158QVGRC1UCp3Mtlm66pYt2Q2Hupz0G3W2x3b8EfEn67WiMnS32deDnbTN7q5tPCN9D7bZU1qP4SplXT()tD8t)Ta68o7pEaUBl6B42pGSXxyBDWveLPP8c)jR(FPUMnktEaR(LoH8bmKKGmlWjq6cUlyTs4ESldZ9tOYKE4Fe0l4EOhiLZ(69GzDnLwGXZpYmXZiuI86Ee0eGBgo(c1YBg(TMNZgrjmWe62BpL0zn131x817fCxdJv7Grygb7XnljzGIYqUZG4(xT(tGoB1Lgp6S)0r8Sxun(1)hNXsU6cSSfNDYQ6XqUrpx1u5E)jogf0a3xQI0sqzFZjEouO)5)dYJr50p5AbkfcW(UtiNuazM7vcX3NsXf4uGNs(csBF7jooY(YtWa1kBHBmLft2hhQ73CGwpuBd(Mh2ZoIpEVm7HIQVuGUvPZOrlvCeyhrA88OXXvrKM2BBFBuTI9ZMaRb1f6cqNIzBIcSYS4IVAnS3(drRKulTxqNJ7AiCpDjWPKZfC2whGZgikMRHSNUSxGKljPbOLp7qRXKuMS(1ckwA4wGST1rSib1ZP8KRvG0kUzSuemLFcb2xunwKMtsbTwK2JXsWNkCMvYjyqqesBNalLMqTZxN7UVjc9GSlsZAATU3(MytjE18yuH1hNgpjcN8BBmhWjc1TGsARQKRbBp0QqpUEkSYAiT)MHBRf3YycFFsjj3t)UHxCJM8UNJGu2iDgOJEaTTgwAzZYMjpg9iY5FovrO2FlYojOV)v)9FXl3Hh)Xp8XpC(Jo0xpmYTSc1qIchosU3UZEwg5QnhzYj9q9Cdx2K23L4km3NKxuv)wsjPMOU7XAJyQeVBtnkkidSeTYo(68U4F(d")

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
end)
