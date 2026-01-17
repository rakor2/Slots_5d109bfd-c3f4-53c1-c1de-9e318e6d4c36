Ext.Require('Shared/LibLib/Style.lua')

Globals.ItemSlotMap = Globals.ItemSlotMap or {}



-- -TBD: MODVARS IT IS
function SaveSlotsToLocal()
    Ext.IO.SaveFile('Slots/SavedSlots.json', Ext.Json.Stringify(Globals.ItemSlotMap))
end



function LoadSlotsFromLocal()
    Globals.ItemSlotMap = Ext.Json.Parse(Ext.IO.LoadFile('Slots/SavedSlots.json'))
end



if Ext.IO.LoadFile('Slots/SavedSlots.json') then
    LoadSlotsFromLocal()
end







-- function AssignSlotsToStats()
--     Globals.ItemSlotMap = Globals.ItemSlotMap or {}

--     for uuid, slot in pairs(Globals.ItemSlotMap) do
--         if not uuid then return end
--         local item = Ext.Entity.Get(uuid)
--         if item then
--             local Stats = item.Data.StatsId
--             Ext.Stats.Get(Stats).Slot = slot
--             Ext.Stats.Sync(Stats)
--         end
--     end
-- end



Ext.Require('Client/ClientHandlers.lua')
Ext.Require('Client/ClientListeners.lua')
Ext.Require('Client/UI.lua')