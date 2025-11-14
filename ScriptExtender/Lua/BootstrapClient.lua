Ext.Require('_Libs/_InitLibs.lua')
Ext.Require('Shared/_init.lua')
Ext.Require('Client/_init.lua')



Globals.ItemSlotMap = Globals.ItemSlotMap or {}



function SaveSlotsToLocal()
    Ext.IO.SaveFile('Slots/SavedSlots.json', Ext.Json.Stringify(Globals.ItemSlotMap))
end



function LoadSlotsFromLocal()
    Globals.ItemSlotMap = Ext.Json.Parse(Ext.IO.LoadFile('Slots/SavedSlots.json'))
end



function DeleteUnusedUuids()
    local character = _C()
    local CurrentInventory = parseInventory(character)
    local UsedUuids = {}
    
    for _, item in pairs(CurrentInventory) do
        UsedUuids[item.Uuid] = true
    end
    
    for uuid, slot in pairs(Globals.ItemSlotMap) do
        if UsedUuids[uuid] then
            -- DPrint('Exists: %s', uuid)
        else
            -- DPrint('Unused: %s', uuid)
            Globals.ItemSlotMap[uuid] = nil
        end
    end
    SaveSlotsToLocal()
end



if Ext.IO.LoadFile('Slots/SavedSlots.json') then
    LoadSlotsFromLocal()
end



function AssignSlotsToStats()
    for uuid, slot in pairs(Globals.ItemSlotMap) do
        local item = Ext.Entity.Get(uuid)
        if item then
            local Stats = item.Data.StatsId
            Ext.Stats.Get(Stats).Slot = slot
            Ext.Stats.Sync(Stats)
        end
    end
end