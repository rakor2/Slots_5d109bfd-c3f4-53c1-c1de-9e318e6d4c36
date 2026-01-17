Ext.RegisterNetListener('Slots_WhenLevelGameplayStarted', function (channel, payload, user)
end)

--- :warning:
-- Ext.Entity.OnChange('InventoryMember', function()
--     DPrint('SLOTS_InventoryMember')
--     ReBuildUI()
-- end)


Channels.RebuildTable:SetHandler(function (Data)
    ReBuildUI()
end)



Channels.IDGAF:SetHandler(function (Data)
    Globals.newUuid = Data
end)