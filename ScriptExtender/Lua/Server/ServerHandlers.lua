local xd



function createListener()
    local handle = Ext.Osiris.RegisterListener("TemplateAddedTo", 4, "after", function(objectTemplate, objectTemplate2, inventoryHolder, addType)
        Globals.newUuid = objectTemplate2
        Channels.IDGAF:Broadcast(Globals.newUuid) --I don't know why RequestHandelr doesn't return it in Channels.RecreateItem
    end)
    Globals.newUuid = Globals.newUuid
    return handle
end



function FindEquppedItems()
    local EquippedItems = {}
    local character = _C().Uuid.EntityUuid
    for _, slot in pairs(SlotNames) do
        pcall(function ()
            local item = Osi.GetEquippedItem(character, slot)
            table.insert(EquippedItems, item)
        end)
    end
    return EquippedItems
end