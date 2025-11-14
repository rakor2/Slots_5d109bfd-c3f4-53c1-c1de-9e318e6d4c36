Ext.Osiris.RegisterListener("LevelGameplayStarted", 2, "after", function(levelName, isEditorMode)
    Ext.Net.BroadcastMessage('Slots_WhenLevelGameplayStarted', '')
end)



Ext.Osiris.RegisterListener("Equipped", 2, "after", function(item, character)
    -- DPrint('Equipped')
    Channels.RebuildTable:Broadcast({})
end)



Ext.Osiris.RegisterListener("Unequipped", 2, "after", function(item, character)
    -- DPrint('Unequipped')
    Channels.RebuildTable:Broadcast({})
end)



Channels.ItemHandler:SetHandler(function (Data)
    local action = Data.action
    local entity = Ext.Entity.Get(Data.uuid)

    if action == 'Delete' then
        Osi.RequestDelete(Data.uuid)
    end

    if action == 'Weight' then
        entity.Data.Weight = 0
        entity:Replicate('Data')
    end

    if action == 'WeightAll' then
        local character = _C()
        local CurrentInventory = parseInventory(character)

        for _, v in pairs(CurrentInventory) do
            v.Item.Data.Weight = 0
            v.Item:Replicate('Data')
        end
    end

end)




Channels.RecreateItem:SetRequestHandler(function (Data)

    local handle = createListener()

    Helpers.Timer:OnTicks(5, function ()

        local dyeUuid
        local weight
        local uuid = Data.uuid
        local character = _C().Uuid.EntityUuid
        local item = Ext.Entity.Get(uuid)
        local guid = item.GameObjectVisual.RootTemplateId
        local isEquipped = Osi.IsEquipped(uuid)

        -- local equipmentSlot = item.InventoryMember.EquipmentSlot

        if item.ItemDye then
            dyeUuid = item.ItemDye.Color
        end

        if item.Data.Weight == 0 then
            weight = 0
        end

        Osi.RequestDelete(uuid)

        Osi.TemplateAddTo(guid, character, 1) -- this is a crime that it doesn't return uuid

        Helpers.Timer:OnTicks(15, function ()

            if isEquipped == 1 then
                Osi.Equip(character, Globals.newUuid)
            end

            local newItem = Ext.Entity.Get(Globals.newUuid)

            -- doesn't work; new slot doesn't automatically update in inventory ui. noesis xd?
            -- if isEquipped ~= 1 then
            -- -- Helpers.Timer:OnTicks(15, function ()
            --     newItem.InventoryMember.EquipmentSlot = equipmentSlot
            --     newItem:Replicate('InventoryMember')
            -- -- end)
            -- end

            Helpers.Timer:OnTicks(5, function ()
                newItem.Data.Weight = weight or newItem.Data.Weight
                newItem:Replicate('Data')
            end)

            if dyeUuid then
                newItem:CreateComponent('ItemDye')
                newItem.ItemDye.Color = dyeUuid
                newItem:Replicate('ItemDye')
            end

            Ext.Osiris.UnregisterListener(handle) --learned from EasyCheat :warning:

        end)
    end)
    return true
end)



Channels.RequestEquipped:SetRequestHandler(function (Data)
    return FindEquppedItems()
end)



Channels.EquipCheck:SetRequestHandler(function (Data)
    return Osi.IsEquipped(Data.uuid)
end)