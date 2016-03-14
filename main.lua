AdvancedFilters = {}
local AF = AdvancedFilters

AF.subfilterGroups = {
	[INVENTORY_BACKPACK] = {},
	[INVENTORY_BANK] = {},
	[INVENTORY_GUILD_BANK] = {},
	--[5] = {},
}
AF.lastSubfilterBar = nil
AF.currentInventoryType = INVENTORY_BACKPACK

local function InitializeHooks()
	local function RefreshSubfilterBar(currentFilter)
		local function UpdateListAnchors(self, shiftY)
			local layoutData = self.appliedLayout or BACKPACK_DEFAULT_LAYOUT_FRAGMENT.layoutData
			if not layoutData then return end

			local list = self.list or self.inventories[AF.currentInventoryType].listView
			list:SetWidth(layoutData.width)
			list:ClearAnchors()
			list:SetAnchor(TOPRIGHT, nil, TOPRIGHT, 0, layoutData.backpackOffsetY + shiftY)
			list:SetAnchor(BOTTOMRIGHT)

			ZO_ScrollList_SetHeight(list, list:GetHeight())

			local sortBy = self.sortHeaders or self:GetDisplayInventoryTable(AF.currentInventoryType).sortHeaders
			sortBy = sortBy.headerContainer
			sortBy:ClearAnchors()
			sortBy:SetAnchor(TOPRIGHT, nil, TOPRIGHT, 0, layoutData.sortByOffsetY + shiftY)
		end

		--get new bar
		subfilterBars = AF.subfilterGroups[AF.currentInventoryType]
		local subfilterBar = subfilterBars[currentFilter]

		--hide and update old bar, if it exists
		if AF.lastSubfilterBar ~= nil then
			AF.lastSubfilterBar:SetHidden(true)
		end

		--if new bar exists
		if subfilterBar then
			--set old bar reference
			AF.lastSubfilterBar = subfilterBar

			--set currentFilter since we need it before the original ChangeFilter updates it
			if AF.currentInventoryType == 5 then
				STORE_WINDOW.currentFilter = currentFilter
			else
				PLAYER_INVENTORY.inventories[AF.currentInventoryType].currentFilter = currentFilter
			end

			--activate current button
			subfilterBar:ActivateButton(subfilterBar:GetCurrentButton())

			--show the bar
			subfilterBar:SetHidden(false)

			--set proper inventory anchor displacement
			if AF.currentInventoryType == 5 then
				UpdateListAnchors(STORE_WINDOW, subfilterBar.control:GetHeight())
			else
				UpdateListAnchors(PLAYER_INVENTORY, subfilterBar.control:GetHeight())
			end
		else
			--remove all filters
			AF.util.RemoveAllFilters()

			--set original inventory anchor displacement
			if AF.currentInventoryType == 5 then
				UpdateListAnchors(STORE_WINDOW, 0)
			else
				UpdateListAnchors(PLAYER_INVENTORY, 0)
			end
		end
	end

	--SCENE SHOWN HOOKS
	local function hookInventory(control, inventoryType)
		local function onInventoryShown(control, hidden)
			AF.currentInventoryType = inventoryType

			if inventoryType == 5 then
				RefreshSubfilterBar(STORE_WINDOW.currentFilter)
			else
				RefreshSubfilterBar(PLAYER_INVENTORY.inventories[inventoryType].currentFilter)
			end
		end

		ZO_PreHookHandler(control, "OnEffectivelyShown", onInventoryShown)
	end
	hookInventory(ZO_PlayerInventory, INVENTORY_BACKPACK)
	hookInventory(ZO_PlayerBank, INVENTORY_BANK)
	hookInventory(ZO_GuildBank, INVENTORY_GUILD_BANK)
	--hookInventory(ZO_StoreWindow, 5)

	--PREHOOKS
	local function ChangeFilterInventory(self, filterTab)
		local currentFilter = self:GetTabFilterInfo(filterTab.inventoryType, filterTab)
		RefreshSubfilterBar(currentFilter)
	end
	ZO_PreHook(PLAYER_INVENTORY, "ChangeFilter", ChangeFilterInventory)
	local function ChangeFilterStore(self, filterTab)
		local currentFilter = filterTab.filterType
		RefreshSubfilterBar(currentFilter)
	end
	--ZO_PreHook(STORE_WINDOW, "ChangeFilter", ChangeFilterStore)

	--POSTHOOKS
	--create private index
	--this is my table. There are many like it, but this one is mine.
    local index = {}
    --create metatable
    local mt = {
		__index = function (t,k)
        	--d("*access to element " .. tostring(k))
        	return t[index][k]   -- access the original table
    	end,
    	__newindex = function (t,k,v)
        	--d("*update of element " .. tostring(k) .. " to " .. tostring(v))
        	t[index][k] = v   -- update original table
			AF.util.RefreshSubfilterButtons(AF.lastSubfilterBar)
    	end,
    }
	--tracking function. Returns a proxy table with our metatable attached.
	local function track(t)
		local proxy = {}
		proxy[index] = t
		setmetatable(proxy, mt)
		return proxy
    end
	--PLAYER_INVENTORY.isListDirty doesn't "exist" in the first place.
	--The table in the backing class was being used, so we'll track that table,
	--	but set the proxy to the lookup point.
	PLAYER_INVENTORY.isListDirty = track(ZO_InventoryManager.isListDirty)
end

local function CreateSubfilterBars()
	local inventoryTypes = {
		["PlayerInventory"] = INVENTORY_BACKPACK,
		["PlayerBank"] = INVENTORY_BANK,
		["GuildBank"] = INVENTORY_GUILD_BANK,
		--["StoreWindow"] = 5,
	}
	local filterTypes = {
		["Weapons"] = ITEMFILTERTYPE_WEAPONS,
		["Armor"] = ITEMFILTERTYPE_ARMOR,
		["Consumables"] = ITEMFILTERTYPE_CONSUMABLE,
		["Crafting"] = ITEMFILTERTYPE_CRAFTING,
		["Miscellaneous"] = ITEMFILTERTYPE_MISCELLANEOUS,
	}
	local subfilterGroups = {
		[ITEMFILTERTYPE_WEAPONS] = {
			"HealStaff", "DestructionStaff", "Bow", "TwoHand", "OneHand", "All",
		},
		[ITEMFILTERTYPE_ARMOR] = {
			"Vanity", "Jewelry", "Shield", "Clothing", "Light", "Medium",
			"Heavy", "All",
		},
		[ITEMFILTERTYPE_CONSUMABLE] = {
			"Trophy", "Repair", "Container", "Motif", --[["Poison",]] "Potion",
			"Recipe", "Drink", "Food", "Crown", "All",
		},
		[ITEMFILTERTYPE_CRAFTING] = {
			"ArmorTrait", "WeaponTrait", "Style", "Provisioning", "Enchanting",
			"Alchemy", "Woodworking", "Clothier", "Blacksmithing", "All",
		},
		[ITEMFILTERTYPE_MISCELLANEOUS] = {
			"Trash", "Fence", "Trophy", "Tool", "Bait", "Siege", "SoulGem",
			"Glyphs", "All",
		},
	}

	for inventoryName, inventoryType in pairs(inventoryTypes) do
		for groupName, filterType in pairs(filterTypes) do
			local subfilterNames = subfilterGroups[filterType]

			AF.subfilterGroups[inventoryType][filterType] = AF.AF_FilterBar:New(inventoryName, groupName, subfilterNames)
		end
	end
end

local function AdvancedFilters_Loaded(eventCode, addonName)
	if addonName ~= "AdvancedFilters" then return end
	EVENT_MANAGER:UnregisterForEvent("AdvancedFilters_Loaded", EVENT_ADD_ON_LOADED)

	--enable ZOS inventory search boxes
	local bagSearch = ZO_PlayerInventorySearchBox
	local bankSearch = ZO_PlayerBankSearchBox
	local guildBankSearch = ZO_GuildBankSearchBox

	bagSearch:ClearAnchors()
	bagSearch:SetAnchor(RIGHT, ZO_PlayerInventoryMenuBarLabel, LEFT, -5)
	bagSearch:SetAnchor(BOTTOMLEFT, ZO_PlayerInventoryMenuDivider, TOPLEFT, 0, -11)
	bagSearch:SetHidden(false)

	bankSearch:ClearAnchors()
	bankSearch:SetAnchor(RIGHT, ZO_PlayerBankMenuBarLabel, LEFT, -5)
	bankSearch:SetAnchor(BOTTOMLEFT, ZO_PlayerBankMenuDivider, TOPLEFT, 0, -11)
	bankSearch:SetHidden(false)
	bankSearch:SetWidth(bagSearch:GetWidth())

	guildBankSearch:ClearAnchors()
	guildBankSearch:SetAnchor(RIGHT, ZO_GuildBankMenuBarLabel, LEFT, -5)
	guildBankSearch:SetAnchor(BOTTOMLEFT, ZO_GuildBankMenuDivider, TOPLEFT, 0, -11)
	guildBankSearch:SetHidden(false)
	guildBankSearch:SetWidth(bagSearch:GetWidth())

	CreateSubfilterBars()

	InitializeHooks()
end
EVENT_MANAGER:RegisterForEvent("AdvancedFilters_Loaded", EVENT_ADD_ON_LOADED, AdvancedFilters_Loaded)