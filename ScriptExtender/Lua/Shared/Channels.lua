Channels = Channels or {}


Channels.ItemHandler = Ext.Net.CreateChannel(ModuleUUID, 'ItemHandler')

Channels.RecreateItem = Ext.Net.CreateChannel(ModuleUUID, 'RecreateItem')
Channels.RebuildTable = Ext.Net.CreateChannel(ModuleUUID, 'RebuildTable')

Channels.IDGAF = Ext.Net.CreateChannel(ModuleUUID, 'IDGAF')
Channels.EquipCheck = Ext.Net.CreateChannel(ModuleUUID, 'EquipCheck')
Channels.RequestEquipped = Ext.Net.CreateChannel(ModuleUUID, 'RequestEquipped')


Channels.VarsHandler = Ext.Net.CreateChannel(ModuleUUID, 'VarsHandler')