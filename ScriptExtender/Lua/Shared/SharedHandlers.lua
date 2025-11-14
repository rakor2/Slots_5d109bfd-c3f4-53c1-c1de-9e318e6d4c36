function parseInventory(entity)
    local CurrentInventory = {}
    local inventories = entity.InventoryOwner.Inventories

    for _, inventoryEntity in pairs(inventories) do
        local inventory = Ext.Entity.Get(inventoryEntity)

        if inventory and inventory.InventoryContainer then
            for _, itemEntry in pairs(inventory.InventoryContainer.Items) do
                local item = itemEntry.Item
                if item then
                    local name = item.DisplayName.Name:Get()
                    local icon = item.Icon.Icon
                    local uuid = item.Uuid.EntityUuid
                    table.insert(CurrentInventory, {['Item'] = item, ['Uuid'] = uuid, ['Name'] = name, ['Icon'] = icon})
                end
            end
        end
    end

    return CurrentInventory
end