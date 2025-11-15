local OPENQUESTIONMARK = false
IMGUI:AntiStupiditySystem()




---@class imgui_elements
E = E or {}



Globals.ItemSlotMap = Globals.ItemSlotMap or {}
Globals.States.modEnabled = false


function Slots_MCM(p)

    Slots_MCM = p

    w = Ext.IMGUI.NewWindow('Slots')
    w.Font = 'Font'
    w.Open = OPENQUESTIONMARK
    w.Closeable = true


    openButton = p:AddButton('Open')
    openButton.IDContext = 'aekjfnwlekfjne'
    openButton.OnClick = function()

        w.Open = not w.Open

        ReBuildUI()

    end

    w.OnClose = function()
        w.Open = false
    end

    MCM.SetKeybindingCallback('sl_toggle_window', function()

        w.Open = not w.Open

        ReBuildUI()

    end)

    ApplyStyle(w, 1)

    MainWindow(w)
end



function MainWindow(w)
    ViewportSize = Ext.IMGUI.GetViewportSize()
    w:SetPos({ViewportSize[1] / 6, ViewportSize[2] / 10})
    if ViewportSize[1] <= 1920 and ViewportSize[2] <= 1080 then
        w:SetSize({ 271, 750 })
    else
        w:SetSize({ 400, 1000 })
    end
    w.AlwaysAutoResize = false
    w.Scaling = 'Scaled'
    w.Font = 'Font'

    w.Visible = true
    w.Closeable = true

    local mainTabBar = w:AddTabBar('MainTabBar')

    E.main2 = mainTabBar:AddTabItem('Main')

    -- local btnEnableMod = E.main2:AddButton('Enable mod')
    -- btnEnableMod.OnClick = function (e)
    --     Globals.States.modEnabled = true
    --     MainTab(E.main2)
    --     btnEnableMod.Visible = false
    -- end

    MainTab(E.main2)
end


function MainTab(p)


    local btnWeightAll = p:AddButton('0 weight all')
    btnWeightAll.OnClick = function ()
         Data = {
            action = 'WeightAll',
            uuid = nil
        }
        Channels.ItemHandler:SendToServer(Data)

    end


    p:AddSeparatorText('Equipped items')

    E.groupTable = p:AddGroup('tbls')

    ICON_SIZE = {64,64}
    PARENT = E.groupTable



    function CreateTable(parent, items, iconSize)

        local EquippedItems = {}
        local InventoryItems ={}

        local popup = parent:AddPopup('PopSmoke')

        local function CreateSubTables(tableId, itemTbl)

            local tbl = parent:AddTable(tableId, 5)
            local imageRow
            local descRow
            local count = 0

            for i, item in ipairs(itemTbl) do
                if count % 5 == 0 then
                    descRow = tbl:AddRow()
                    imageRow = tbl:AddRow()
                end

                descRow:AddCell():AddText('')
                local cell = imageRow:AddCell()

                local imgbtn = cell:AddImageButton(item.Icon, item.Icon, iconSize)
                imgbtn.IDContext = Ext.Math.Random(1, 1000)
                imgbtn.OnClick = function(e)
                    local statsId = item.Item.Data.StatsId

                    Imgui.ClearChildren(popup)

                    popup:AddText(item.Name)
                    popup:AddSeparator()

                    popup:AddText('Current slot: ' .. Ext.Stats.Get(statsId).Slot)
                    popup:AddSeparator()

                    CreateSelectable(popup, 'Equip', function()
                        local Data = {
                            action = 'Equip',
                            uuid = item.Item.Uuid.EntityUuid
                        }
                        Channels.ItemHandler:SendToServer(Data)
                    end)

                    CreateSelectable(popup, 'Unequip', function()
                        local Data = {
                            action = 'Unequip',
                            uuid = item.Item.Uuid.EntityUuid
                        }
                        Channels.ItemHandler:SendToServer(Data)
                    end)

                    local collapseVis = popup:AddCollapsingHeader('Visual slots')



                    for _, slot in pairs(SlotNames) do
                        CreateSelectable(collapseVis, slot, function()

                            Ext.Stats.Get(statsId).Slot = slot
                            Ext.Stats.Sync(statsId)

                            RequestRecreateItem(item.Item)

                        end)
                    end
                    local collapseNonVis = popup:AddCollapsingHeader('Non-Visual slots')


                    for _, slot in pairs(NonVisualSlots) do
                        CreateSelectable(collapseNonVis, slot, function()

                            Ext.Stats.Get(statsId).Slot = slot
                            Ext.Stats.Sync(statsId)

                            RequestRecreateItem(item.Item)

                        end)
                    end
                    popup:AddSeparator()


                    CreateSelectable(popup, '0 weight', function()
                        local Data = {
                            action = 'Weight',
                            uuid = item.Item.Uuid.EntityUuid
                        }
                        Channels.ItemHandler:SendToServer(Data)
                    end)
                    popup:AddSeparator()


                    CreateSelectable(popup, 'Delete', function()
                        local Data = {
                            action = 'Delete',
                            uuid = item.Item.Uuid.EntityUuid
                        }
                        Channels.ItemHandler:SendToServer(Data)
                        Helpers.Timer:OnTicks(3, function ()
                            ReBuildUI()
                        end)
                    end)


                    -- popup:AddSeparator()

                    -- CreateSelectable(popup, 'Dump', function()
                    --     DDump(item.Item:GetAllComponents())
                    -- end)

                    -- CreateSelectable(popup, 'Stats slot', function()
                    --     local statsId = item.Item.Data.StatsId
                    --     DDump(Ext.Stats.Get(statsId).Slot)
                    -- end)

                    -- CreateSelectable(popup, 'EquipmentSlot', function()
                    --     DDump(item.Item.InventoryMember.EquipmentSlot)
                    -- end)

                    popup:Open()

                end

                local tooltip = imgbtn:Tooltip('tooltip')
                tooltip:AddText([[
                ]] ..
                item.Name)

                count = count + 1
            end
        end


        Channels.RequestEquipped:RequestToServer({}, function (Response)
            if Response then
                Equipped = Response


                local EquippedCheck = {}
                for _, uuid in pairs(Equipped) do
                    EquippedCheck[uuid] = true
                    local item = Ext.Entity.Get(uuid)
                    local name = item.DisplayName.Name:Get()
                    local icon = item.Icon.Icon
                    table.insert(EquippedItems, {['Item'] = item, ['Name'] = name, ['Icon'] = icon})
                end

                for _, item in pairs(items) do
                    if not EquippedCheck[item.Uuid] then
                        for _, allowed in pairs(AllowedSlots) do
                            if item.Item.Equipable and item.Item.Equipable.Slot == allowed then
                                local entity = Ext.Entity.Get(item.Uuid)
                                local name = entity.DisplayName.Name:Get()
                                local icon = entity.Icon.Icon
                                table.insert(InventoryItems, {['Item'] = entity, ['Name'] = name, ['Icon'] = icon})
                            end
                        end
                    end
                end

                local tableIdEquipped = 'equipped'
                CreateSubTables(tableIdEquipped, EquippedItems)

                parent:AddSeparatorText('Other items')

                local tableIdOther = 'other'
                CreateSubTables(tableIdOther, InventoryItems)

            end
        end)

    end

    local character = _C()

    CreateTable(PARENT, parseInventory(character), ICON_SIZE)

end



Mods.BG3MCM.IMGUIAPI:InsertModMenuTab(ModuleUUID, 'Slots', Slots_MCM)

MCM.InsertModMenuTab('Slots', Slots_MCM, ModuleUUID)