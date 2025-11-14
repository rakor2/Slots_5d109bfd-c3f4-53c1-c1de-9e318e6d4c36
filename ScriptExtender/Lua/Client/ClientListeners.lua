Ext.RegisterNetListener('Slots_WhenLevelGameplayStarted', function (channel, payload, user)
    AssignSlotsToStats()
end)



Channels.RebuildTable:SetHandler(function (Data)
    ReBuildUI()
end)



Channels.IDGAF:SetHandler(function (Data)
    Globals.newUuid = Data
end)