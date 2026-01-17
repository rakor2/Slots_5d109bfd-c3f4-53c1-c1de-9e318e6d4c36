local OPENQUESTIONMARK = false
IMGUI:AntiStupiditySystem()

---@class ImguiElements
E = E or {}

Globals.ItemSlotMap = Globals.ItemSlotMap or {}

local tableSize = 5

function Slots_MCM(p)
    Slots_MCM = p

    w = Ext.IMGUI.NewWindow('Slots')
    w.Font = 'Font'
    w.Open = OPENQUESTIONMARK
    w.Closeable = true



    local openButton = p:AddButton('Open')
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
    local ViewportSize = Ext.IMGUI.GetViewportSize()
    w:SetPos({ViewportSize[1] / 6, ViewportSize[2] / 10})
    if ViewportSize[1] <= 1920 and ViewportSize[2] <= 1080 then
        w:SetSize({271, 750})
    else
        w:SetSize({400, 1000})
    end
    w.AlwaysAutoResize = false
    w.Scaling = 'Scaled'
    w.Font = 'Font'
    w.Visible = true
    w.Closeable = true

    local mainTabBar = w:AddTabBar('MainTabBar')
    E.main2 = mainTabBar:AddTabItem('Main')
    MainTab(E.main2)
    -- E.settings = mainTabBar:AddTabItem('Settings')
    -- SettingsTab(E.settings)

end



function MainTab(p)

    ICON_SIZE = {64, 64}
    PARENT = E.groupTable

    local btnWeightAll = p:AddButton('0 weight all')
    btnWeightAll.OnClick = function ()
        Channels.ItemHandler:SendToServer({
            action = 'WeightAll',
            uuid = nil
        })
    end


    E.checkAllowWpn = p:AddCheckbox('Allow weapons')
    E.checkAllowWpn.SameLine = true
    E.checkAllowWpn.OnChange = function ()
        ReBuildUI()
    end

    p:AddSeparatorText('Equipped items')
    E.groupTable = p:AddGroup('tbls')


    function CreateTable(parent, items, iconSize)
        local Slots = {}
        local Slots2 = {}
        local EquippedItems = {}
        local InventoryItems ={}
        local popup = parent:AddPopup('PopSmoke')
        local withWeapons = false

        if E.checkAllowWpn.Checked then
            Slots = SlotNamesWpn
            Slots2 = AllowedSlotsWpn
            withWeapons = true
        else
            Slots = SlotNames
            Slots2 = AllowedSlots
            withWeapons = false
        end

        local function CreateSubTables(tableId, itemTbl)
            local tbl = parent:AddTable(tableId, tableSize)
            local imageRow
            local descRow
            local count = 0

            for _, item in ipairs(itemTbl) do
                if count % tableSize == 0 then
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
                        Channels.ItemHandler:SendToServer({
                            action = 'Equip',
                            uuid = item.Item.Uuid.EntityUuid
                        })
                    end)



                    CreateSelectable(popup, 'Unequip', function()
                        Channels.ItemHandler:SendToServer({
                            action = 'Unequip',
                            uuid = item.Item.Uuid.EntityUuid
                        })
                    end)
                    local collapseVis = popup:AddCollapsingHeader('Visual')



                    for _, slot in pairs(Slots) do
                        CreateSelectable(collapseVis, slot, function()

                            Ext.Stats.Get(statsId).Slot = slot
                            Ext.Stats.Sync(statsId)

                            RequestRecreateItem(item.Item)

                        end)
                    end
                    local collapseNonVis = popup:AddCollapsingHeader('Non-Visual')



                    for _, slot in pairs(NonVisualSlots) do
                        CreateSelectable(collapseNonVis, slot, function()

                            Ext.Stats.Get(statsId).Slot = slot
                            Ext.Stats.Sync(statsId)

                            RequestRecreateItem(item.Item)

                        end)
                    end
                    popup:AddSeparator()



                    CreateSelectable(popup, '0 weight', function()
                        Channels.ItemHandler:SendToServer({
                            action = 'Weight',
                            uuid = item.Item.Uuid.EntityUuid
                        })
                    end)
                    popup:AddSeparator()



                    CreateSelectable(popup, 'Delete', function()
                        Channels.ItemHandler:SendToServer({
                            action = 'Delete',
                            uuid = item.Item.Uuid.EntityUuid
                        })
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

                    -- CreateSelectable(popup, 'Dump stats', function()
                    --     local statsId = item.Item.Data.StatsId
                    --     DDump(Ext.Stats.Get(statsId))
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


        Channels.RequestEquipped:RequestToServer({withWeapons = withWeapons}, function(Response)
            if Response then
                local Equipped = Response
                local EquippedCheck = {}

                for _, uuid in pairs(Equipped) do
                    EquippedCheck[uuid] = true
                    local item = Ext.Entity.Get(uuid)
                    local name = item.DisplayName.Name:Get()
                    local icon = item.Icon.Icon

                    table.insert(EquippedItems, {
                        ['Item'] = item,
                        ['Name'] = name,
                        ['Icon'] = icon
                    })
                end


                for _, item in pairs(items) do
                    if not EquippedCheck[item.Uuid] then
                        for _, allowed in pairs(Slots2) do
                            if item.Item.Equipable and item.Item.Equipable.Slot == allowed then
                                local entity = Ext.Entity.Get(item.Uuid)
                                local name = entity.DisplayName.Name:Get()
                                local icon = entity.Icon.Icon
                                table.insert(InventoryItems, {
                                    ['Item'] = item.Item,
                                    ['Name'] = name,
                                    ['Icon'] = icon
                                })
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

    local CurrentInventory = parseInventory(_C())
    CreateTable(E.groupTable, CurrentInventory, ICON_SIZE)

end



function SettingsTab(p)
    local slIntTableSize = p:AddSliderInt('Table size', 5, 5, 15, 1)

    slIntTableSize.OnChange = function (e)
        tableSize = e.Value[1]
    end

end


MCM.InsertModMenuTab('Slots', Slots_MCM, ModuleUUID)