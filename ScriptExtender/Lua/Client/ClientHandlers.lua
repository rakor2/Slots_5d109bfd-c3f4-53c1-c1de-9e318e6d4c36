Globals.States = Globals.States or {}

function ReBuildUI()
    if w and not w.Open then return end
    -- DPrint('SLOTS_ReBuildUI')
    Imgui.ClearChildren(E.groupTable)
    Utils:AntiSpam(350, function () --TBD: temporary to not call it twice
        local character = _C()
        CreateTable(E.groupTable, parseInventory(character), ICON_SIZE)
    end)
end



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

                    -- Globals.ItemSlotMap = Globals.ItemSlotMap or {}
                    Globals.ItemSlotMap[newItem.Uuid.EntityUuid] = Ext.Stats.Get(Stats).Slot
                    Globals.ItemSlotMap[oldUuid] = nil
                    Channels.VarsHandler:RequestToServer({
                        action = 'SaveVars',
                        ItemSlotMap = Globals.ItemSlotMap
                    }, function () end)


                    -- Helpers.Timer:OnTicks(15, function ()

                    --     Channels.VarsHandler:RequestToServer({
                    --         action = 'LoadVars',
                    --     }, function(Response)
                    --         -- DDump(Response)
                    --     end)

                    -- end)

                end
            end)
        end
    end)
end



---@param func function --loooooooooook it's colored
function CreateSelectable(parent, name, func)
    local select = parent:AddSelectable(name)
    select.IDContext = Ext.Math.Random(1, 10000)
    select.OnClick = function(e)
        func()
    end
end

