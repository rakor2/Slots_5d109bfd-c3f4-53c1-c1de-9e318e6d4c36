Ext.Require('Server/ServerHandlers.lua')
Ext.Require('Server/ServerListeners.lua')



Helpers.ModVars:Register('SlotsVars', ModuleUUID, nil, {
    Client = false,
    SyncToClient = false,
    SyncOnTick = false,
    SyncOnWrite = false,
})



Globals.ItemSlotMap = Globals.ItemSlotMap or {}



function DeleteUnusedUuids(ItemSlotMap)
    local character = _C()
    local CurrentInventory = parseInventory(character)
    local UsedUuids = {}
    local Map = ItemSlotMap or Globals.ItemSlotMap

    for _, item in pairs(CurrentInventory) do
        UsedUuids[item.Uuid] = true
    end

    for uuid, slot in pairs(Map) do
        if UsedUuids[uuid] then
            -- DPrint('Exists: %s', uuid)
        else
            -- DPrint('Unused: %s', uuid)
            Map[uuid] = nil
        end
    end
end



function SaveSlotsToVars()
    Helpers.ModVars.Get(ModuleUUID).SlotsVars = Globals.ItemSlotMap
end



function LoadSlotsFromVars()
    Globals.ItemSlotMap = Helpers.ModVars.Get(ModuleUUID).SlotsVars
end



Channels.VarsHandler:SetRequestHandler(function (Data)
    if Data.action == 'SaveVars' then
        DeleteUnusedUuids(Data.ItemSlotMap)
        Helpers.ModVars.Get(ModuleUUID).SlotsVars = Data.ItemSlotMap
        Globals.ItemSlotMap = Data.ItemSlotMap
    end

    if Data.action == 'LoadVars' then
        return Helpers.ModVars.Get(ModuleUUID).SlotsVars
    end
end)


-- _D(Mods.Slots.Helpers.ModVars.Get('5d109bfd-c3f4-53c1-c1de-9e318e6d4c36').SlotsVars)

