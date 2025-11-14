local xd


Globals.States = Globals.States or {}


function ReBuildUI()
    if not w.Open then return end
    Imgui.ClearChildren(PARENT)
    -- Helpers.Timer:OnTicks(5, function ()
    Utils:AntiSpam(350, function () --TBD: temporary to not call it twice
        local character = _C()
        CreateTable(PARENT, parseInventory(character), ICON_SIZE)
    end)
end



Ext.Entity.OnChange('InventoryMember', function ()
    -- DPrint('InventoryMember')
    ReBuildUI()
end)



function RequestRecreateItem(item)

    local uuid = item.Uuid.EntityUuid
    local oldUuid = uuid

    local Data = {
        uuid = uuid,
    }

    Channels.RecreateItem:RequestToServer(Data, function (Response)
        if Response then
            Helpers.Timer:OnTicks(50, function ()

                --DPrint('RequestRecreateItem') --TBD: figure out how to make it to not call ReBuildUI twice
                ReBuildUI()

                -- DPrint('New uuid: %s', Globals.newUuid)
                local newItem = Ext.Entity.Get(Globals.newUuid)

                if newItem then
                    local Stats = newItem.Data.StatsId
                    Globals.ItemSlotMap[newItem.Uuid.EntityUuid] = Ext.Stats.Get(Stats).Slot
                    Globals.ItemSlotMap[oldUuid] = nil
                    SaveSlotsToLocal()
                    DeleteUnusedUuids() --clean up
                end

            end)
        end
    end)
end



---@param func function --loooooooooook it's colored
function CreateSelectable(parent, name, func)
    local select = parent:AddSelectable(name)
    select.OnClick = function(e)
        func()
    end
end


