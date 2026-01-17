Ext.Osiris.RegisterListener("LevelGameplayStarted", 2, "after", function(levelName, isEditorMode)
    Ext.Net.BroadcastMessage('Slots_WhenLevelGameplayStarted', '')
    Globals.ItemSlotMap = Helpers.ModVars.Get(ModuleUUID).SlotsVars
    AssignSlotsToStats()
end)



Ext.Entity.OnChange('InventoryMember', function()
    -- DPrint('SLOTS_InventoryMember')
    Channels.RebuildTable:Broadcast({})
end)



function AssignSlotsToStats()
    Globals.ItemSlotMap = Globals.ItemSlotMap or {}

    for uuid, slot in pairs(Globals.ItemSlotMap) do
        if not uuid then return end
        local item = Ext.Entity.Get(uuid)
        if item then
            local Stats = item.Data.StatsId
            item.Equipable.Slot = slot
            item:Replicate('Equipable')
            Ext.Stats.Get(Stats).Slot = slot
        end
    end
end



Ext.Osiris.RegisterListener("Equipped", 2, "after", function(item, character)
    -- DPrint('SLOTS_Equipped')
    Channels.RebuildTable:Broadcast({})
end)



Ext.Osiris.RegisterListener("Unequipped", 2, "after", function(item, character)
    -- DPrint('SLOTS_Unequipped')
    Channels.RebuildTable:Broadcast({})
end)



Channels.ItemHandler:SetHandler(function (Data)
    local action = Data.action
    local entity = Ext.Entity.Get(Data.uuid)

    if action == 'Delete' then
        Osi.RequestDelete(Data.uuid)
    end

    if action == 'Equip' then
        Osi.Equip(_C().Uuid.EntityUuid, Data.uuid)
    end

    if action == 'Unequip' then
        Osi.Unequip(_C().Uuid.EntityUuid, Data.uuid)
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

        if item.ItemDye then
            dyeUuid = item.ItemDye.Color
        end

        if item.Data.Weight == 0 then
            weight = 0
        end

        Osi.TemplateAddTo(guid, character, 1) -- this is a crime that it doesn't return uuid

        Helpers.Timer:OnTicks(15, function ()
            local newItem = Ext.Entity.Get(Globals.newUuid)

            if isEquipped == 1 then
                Osi.Equip(character, Globals.newUuid)
            end

            newItem.Use.Boosts = item.Use.Boosts
            newItem.Data.Weight = weight or newItem.Data.Weight

            newItem:Replicate('Use')
            newItem:Replicate('Data')

            if dyeUuid then
                newItem:CreateComponent('ItemDye')
                newItem.ItemDye.Color = dyeUuid
                newItem:Replicate('ItemDye')
            end

            Osi.RequestDelete(uuid)

            Ext.Osiris.UnregisterListener(handle) --learned from EasyCheat :warning:
        end)
    end)
    return true
end)



Channels.RequestEquipped:SetRequestHandler(function (Data)
    return FindEquppedItems(Data.withWeapons)
end)



Channels.EquipCheck:SetRequestHandler(function (Data)
    return Osi.IsEquipped(Data.uuid)
end)