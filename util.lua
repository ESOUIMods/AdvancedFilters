if AdvancedFilters == nil then AdvancedFilters = {} end
local AF = AdvancedFilters
--Utilities
AF.util = AF.util or {}
local util = AF.util

local controlsForChecks = AF.controlsForChecks

function util.GetCurrentFilterTypeForInventory(invType)
    if invType == nil then return end
    local filterType
    if invType == INVENTORY_TYPE_VENDOR_BUY then
        filterType = LF_VENDOR_BUY
    elseif util.IsCraftingStationInventoryType(invType) then
        filterType = AF.currentInventoryType
    else
        filterType = util.LibFilters:GetCurrentFilterTypeForInventory(invType)
    end
    return filterType
end

--Update the currentFilter to the current inventory or crafting inventory
function util.UpdateCurrentFilter(invType, currentFilter, isCraftingInventoryType, craftingInv)
    if invType == nil or currentFilter == nil then return nil end
    isCraftingInventoryType = isCraftingInventoryType or false
    if isCraftingInventoryType and craftingInv == nil then return false end
    --set currentFilter since we need it before the original ChangeFilter updates it
    if invType == INVENTORY_TYPE_VENDOR_BUY then
        controlsForChecks.store.currentFilter = currentFilter
    elseif isCraftingInventoryType then
        craftingInv.currentFilter = currentFilter
    else
        PLAYER_INVENTORY.inventories[invType].currentFilter = currentFilter
    end
end

function util.AbortSubfilterRefresh(inventoryType)
    if inventoryType == nil then return true end
    local doAbort = false
    local subFilterRefreshAbortInvTypes = AF.abortSubFilterRefreshInventoryTypes

    if subFilterRefreshAbortInvTypes[inventoryType] or util.IsCraftingStationInventoryType(inventoryType) then
        doAbort = true
    end
    return doAbort
end

function util.ApplyFilter(button, filterTag, requestUpdate, filterType)

    local LibFilters        = util.LibFilters
    local callback          = button.filterCallback
    local filterTypeToUse   = filterType or util.GetCurrentFilterTypeForInventory(AF.currentInventoryType)

--d("[AF]Apply " .. button.name .. " from " .. filterTag .. " for filterType " .. filterType .. " and inventoryType " .. AF.currentInventoryType)

    --if something isn't right, abort
    if callback == nil then
        d("callback was nil for " .. filterTag)
        return
    end
    if filterTypeToUse == nil then
        d("filterType was nil for " .. filterTag)
        return
    end

    --first, clear current filters without an update
    LibFilters:UnregisterFilter(filterTag)
    --then register new one and hand off update parameter
    LibFilters:RegisterFilter(filterTag, filterTypeToUse, callback)
    if requestUpdate == true then LibFilters:RequestUpdate(filterTypeToUse) end

    --Update the count of filtered/shown items in the inventory FreeSlot label
    --Delay this function call as the data needs to be filtered first!
    zo_callLater(function()
        util.updateInventoryInfoBarCountLabel(AF.currentInventoryType)

        --Run an end callback function now?
        local endCallback = button.filterEndCallback
        if endCallback and type(endCallback) == "function" then
            endCallback()
        end
    end, 50)
end

function util.RemoveAllFilters()
    local LibFilters = util.LibFilters
    local filterType = util.GetCurrentFilterTypeForInventory(AF.currentInventoryType)

    LibFilters:UnregisterFilter("AF_ButtonFilter")
    LibFilters:UnregisterFilter("AF_DropdownFilter")

    if filterType ~= nil then LibFilters:RequestUpdate(filterType) end
end

function util.MapLibFiltersInventoryTypeToRealInventoryType(inventoryType)
    --One Libfilters inventoryType can have up to 4 different real inventory types:
    --e.g. Crafting deconstruction can happen for bagpack, bank and house_bank items
    -- whereas crafting creation can use bagpack, bank, house_bank and craftabg items, etc.
    if inventoryType == nil then return nil end
    local mapLibFiltersInvToRealInvType1 = {
        [LF_RETRAIT]                = INVENTORY_BACKPACK,
        [LF_SMITHING_REFINE]        = INVENTORY_BACKPACK,
        [LF_SMITHING_CREATION]      = INVENTORY_BACKPACK,
        [LF_SMITHING_DECONSTRUCT]   = INVENTORY_BACKPACK,
        [LF_SMITHING_IMPROVEMENT]   = INVENTORY_BACKPACK,
        [LF_ENCHANTING_CREATION]    = INVENTORY_BACKPACK,
        [LF_ENCHANTING_EXTRACTION]  = INVENTORY_BACKPACK,
        [LF_JEWELRY_REFINE]         = INVENTORY_BACKPACK,
        [LF_JEWELRY_CREATION]       = INVENTORY_BACKPACK,
        [LF_JEWELRY_DECONSTRUCT]    = INVENTORY_BACKPACK,
        [LF_JEWELRY_IMPROVEMENT]    = INVENTORY_BACKPACK,
        [LF_JEWELRY_IMPROVEMENT]    = INVENTORY_BACKPACK,
    }
    local mapLibFiltersInvToRealInvType2 = {
        [LF_RETRAIT]                = INVENTORY_BANK,
        [LF_SMITHING_REFINE]        = INVENTORY_BANK,
        [LF_SMITHING_CREATION]      = INVENTORY_BACKPACK,
        [LF_SMITHING_DECONSTRUCT]   = INVENTORY_BANK,
        [LF_SMITHING_IMPROVEMENT]   = INVENTORY_BANK,
        [LF_ENCHANTING_CREATION]    = INVENTORY_BANK,
        [LF_ENCHANTING_EXTRACTION]  = INVENTORY_BANK,
        [LF_JEWELRY_REFINE]         = INVENTORY_BANK,
        [LF_JEWELRY_CREATION]       = INVENTORY_BANK,
        [LF_JEWELRY_DECONSTRUCT]    = INVENTORY_BANK,
        [LF_JEWELRY_IMPROVEMENT]    = INVENTORY_BANK,
    }
    local mapLibFiltersInvToRealInvType3 = {
        [LF_RETRAIT]                = INVENTORY_HOUSE_BANK,
        [LF_SMITHING_REFINE]        = INVENTORY_HOUSE_BANK,
        [LF_SMITHING_CREATION]      = INVENTORY_BACKPACK,
        [LF_SMITHING_DECONSTRUCT]   = INVENTORY_HOUSE_BANK,
        [LF_SMITHING_IMPROVEMENT]   = INVENTORY_HOUSE_BANK,
        [LF_ENCHANTING_CREATION]    = INVENTORY_HOUSE_BANK,
        [LF_ENCHANTING_EXTRACTION]  = INVENTORY_HOUSE_BANK,
        [LF_JEWELRY_REFINE]         = INVENTORY_HOUSE_BANK,
        [LF_JEWELRY_CREATION]       = INVENTORY_HOUSE_BANK,
        [LF_JEWELRY_DECONSTRUCT]    = INVENTORY_HOUSE_BANK,
        [LF_JEWELRY_IMPROVEMENT]    = INVENTORY_HOUSE_BANK,
    }
    local mapLibFiltersInvToRealInvType4 = {
        [LF_SMITHING_REFINE]        = INVENTORY_CRAFT_BAG,
        [LF_SMITHING_CREATION]      = INVENTORY_CRAFT_BAG,
        [LF_ENCHANTING_CREATION]    = INVENTORY_CRAFT_BAG,
        [LF_JEWELRY_REFINE]         = INVENTORY_CRAFT_BAG,
        [LF_JEWELRY_CREATION]       = INVENTORY_CRAFT_BAG,
    }
    local realInvType1 = mapLibFiltersInvToRealInvType1[inventoryType] or nil
    local realInvType2 = mapLibFiltersInvToRealInvType2[inventoryType] or nil
    local realInvType3 = mapLibFiltersInvToRealInvType3[inventoryType] or nil
    local realInvType4 = mapLibFiltersInvToRealInvType4[inventoryType] or nil
    local realInvTypes = {}
    if realInvType1 ~= nil then table.insert(realInvTypes, realInvType1) end
    if realInvType2 ~= nil then table.insert(realInvTypes, realInvType2) end
    if realInvType3 ~= nil then table.insert(realInvTypes, realInvType3) end
    if realInvType4 ~= nil then table.insert(realInvTypes, realInvType4) end
    return realInvTypes
end

--Check if an item's filterData contains an itemFilterType
function util.IsItemFilterTypeInItemFilterData(itemFilterData, itemFilterType)
    if itemFilterData == nil or itemFilterType == nil then return false end
    for _, itemFilterTypeInFilterData in ipairs(itemFilterData) do
        if itemFilterTypeInFilterData == itemFilterType then return true end
    end
end

--Refresh the subfilter button bar and disable non-given/non-matching subfilter buttons ("grey-out" the buttons)
function util.RefreshSubfilterBar(subfilterBar, calledFromExternalAddon)
    calledFromExternalAddon = calledFromExternalAddon or ""
    local inventoryType = subfilterBar.inventoryType
    local craftingType = util.GetCraftingType()
    local isNoCrafting = not util.IsCraftingPanelShown()
    local realInvTypes
    local inventory, inventorySlots
    local currentFilter
    local bagWornItemCache
--d("[AF]SubFilter refresh, calledFromExternalAddon: " .. tostring(calledFromExternalAddon) .. ", invType: " .. tostring(inventoryType) .. ", subfilterBar: " ..tostring(subfilterBar) .. ", craftingType: " .. tostring(craftingType) .. ", isNoCrafting: " .. tostring(isNoCrafting))
--AF._currentSubfilterBarAtRefreshCheck = subfilterBar

    --Abort the subfilterBar refresh method? Or check for crafting inventory types and return teh correct inventory types then
    if util.AbortSubfilterRefresh(inventoryType) then
        --Try to map the fake inventory type from LibFilters to the real ingame inventory type
        realInvTypes = util.MapLibFiltersInventoryTypeToRealInventoryType(inventoryType)
        if realInvTypes == nil then
--d("<SubFilter refresh aborted: " .. tostring(inventoryType) .. ", subfilterBar: " ..tostring(subfilterBar))
            return
        end
        --Improvement panel: BAG_WORN needs to be checked as well later on!
        if inventoryType == LF_SMITHING_IMPROVEMENT or inventoryType == LF_JEWELRY_IMPROVEMENT or inventoryType == LF_RETRAIT then
            bagWornItemCache = SHARED_INVENTORY:GetOrCreateBagCache(BAG_WORN)
        end
--d("<SubFilter refresh - go on: " .. tostring(#realInvTypes) .. ", subfilterBar: " ..tostring(subfilterBar) .. ", bagWornToo?: " ..tostring(bagWornItemCache ~= nil))
    else
        realInvTypes = {}
        table.insert(realInvTypes, inventoryType)
    end
    --Setting to gray out the buttons is enbaled?
    local grayOutSubFiltersWithNoItems  = AF.settings.grayOutSubFiltersWithNoItems
    --Check if a bank/guild bank/house storage is opened
    local isVendorPanel                 = util.IsFilterPanelShown(LF_VENDOR_SELL) or false
    local isBankDepositPanel            = AF.bankOpened and util.IsFilterPanelShown(LF_BANK_DEPOSIT) or false
    local isGuildBankDepositPanel       = AF.guildBankOpened  and util.IsFilterPanelShown(LF_GUILDBANK_DEPOSIT) or false
    local isHouseBankDepositPanel       = AF.houseBankOpened  and util.IsFilterPanelShown(LF_HOUSE_BANK_DEPOSIT) or false
    local isABankDepositPanel           = (isBankDepositPanel or isGuildBankDepositPanel or isHouseBankDepositPanel) or false
    local isGuildStoreSellPanel         = util.IsFilterPanelShown(LF_GUILDSTORE_SELL) or false
    local isRetraitStation              = util.IsRetraitPanelShown()
    local isJunkInvButtonActive         = subfilterBar.name == (AF.inventoryNames[INVENTORY_BACKPACK] .. "_" .. AF.filterTypeNames[ITEMFILTERTYPE_JUNK]) or false
    local libFiltersPanelId             = util.GetCurrentFilterTypeForInventory(inventoryType)
--d(">isVendorPanel: " .. tostring(isVendorPanel) .. ", isBankDepositPanel: " .. tostring(isBankDepositPanel) .. ", isGuildBankDepositPanel: " .. tostring(isGuildBankDepositPanel) .. ", isHouseBankDepositPanel: " .. tostring(isHouseBankDepositPanel) .. ", isRetraitStation: " .. tostring(isRetraitStation) .. ", isJunkInvButtonActive: " .. tostring(isJunkInvButtonActive) .. ", libFiltersPanelId: " .. tostring(libFiltersPanelId) .. ", grayOutSubfiltersWithNoItems: " ..tostring(grayOutSubFiltersWithNoItems))

    local doEnableSubFilterButtonAgain = false
    local breakInventorySlotsLoopNow = false
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
    --Check subfilterbutton for items, using the filter function and junk checks (only for non-crafting stations)
    local function checkBagContentsNow(bag, bagData, realInvType, button)
        doEnableSubFilterButtonAgain = false
        breakInventorySlotsLoopNow = false
        local hasAnyJunkInBag = false
        if isNoCrafting and bag ~= BAG_WORN then
            hasAnyJunkInBag = HasAnyJunk(bag, false)
        end
        local bagDataToCheck = {}
        --Worn items? The given data is quite different then the PLAYER_INVENTORY data so one needs to map it
        if bag == BAG_WORN then
            bagDataToCheck[1] = bagData
        else
            bagDataToCheck = bagData
        end
        local itemsFound = 0
        for _, itemData in pairs(bagDataToCheck) do
            breakInventorySlotsLoopNow = false
            local isItemStolen = false
            local isItemJunk = false
            local isItemBankAble = true
            local isBOPTradeable = false
            local isBound = false
            local passesCallback
            local passesFilter
            if isNoCrafting then
                passesCallback = button.filterCallback(itemData)
                --Like crafting tables the junk inventory got different itemTypes in one section (ITEMFILTERTYPE_JUNK = 9). So the filter comparison does not work and the callback should be enough to check.
                passesFilter = passesCallback and ((isJunkInvButtonActive and currentFilter == ITEMFILTERTYPE_JUNK)
                        or (util.IsItemFilterTypeInItemFilterData(itemData.filterData, currentFilter)))
                        and util.CheckIfOtherAddonsProvideSubfilterBarRefreshFilters(itemData, realInvType, craftingType, libFiltersPanelId)
            else
                passesCallback = button.filterCallback(itemData)
                --Todo: ItemData.filterData is not reliable at crafting stations as the items are collected from several different bags!
                --Todo: Thus the filter is always marked as "passed". Is this correct and does it work properly? To test!
                --> Set the currentFilter = itemData.filterData[1], which should be the itemType of the current item
                --currentFilter = itemData.filterData[1]
                local otherAddonUsesFilters = util.CheckIfOtherAddonsProvideSubfilterBarRefreshFilters(itemData, realInvType, craftingType, libFiltersPanelId)
                passesFilter = passesCallback and otherAddonUsesFilters
                --Do more filter checks for the crafting types, if the filter passes until now
                if passesFilter then
                    --Jewelry crafting
                    if craftingType == CRAFTING_TYPE_JEWELRYCRAFTING then
                        --Jewelry deconstruction
                        if libFiltersPanelId == LF_JEWELRY_DECONSTRUCT then
                            local itemLink = GetItemLink(itemData.bagId, itemData.slotIndex)
                            passesFilter = passesFilter and not IsItemLinkForcedNotDeconstructable(itemLink)
                        end
                    --Retrait
                    elseif craftingType == CRAFTING_TYPE_NONE then
                        if libFiltersPanelId == LF_RETRAIT and isRetraitStation then
                            passesFilter = passesFilter and CanItemBeRetraited(itemData.bagId, itemData.slotIndex)
                        end
                    end
                end


-- TODO: Check retrait station subfilter buttons greying out properly
-- TODO: Check jewelry refine subfilter buttons greying out properly
--if passesCallback and passesFilter then
--if libFiltersPanelId == LF_JEWELRY_REFINE then
--    local itemLink = GetItemLink(itemData.bagId, itemData.slotIndex)
--    local itemType = GetItemLinkItemType(itemLink)
--    if itemType == ITEMTYPE_JEWELRY_TRAIT or itemType == ITEMTYPE_JEWELRY_RAW_TRAIT or itemType == ITEMTYPE_JEWELRYCRAFTING_BOOSTER or
--    itemType == ITEMTYPE_JEWELRYCRAFTING_MATERIAL or itemType == ITEMTYPE_JEWELRYCRAFTING_RAW_BOOSTER or itemType == ITEMTYPE_JEWELRYCRAFTING_RAW_MATERIAL then
--d("[AF]SubfilterRefresh: " .. itemLink .. ", passesCallback: " .. tostring(passesCallback) .. ", passesFilter: " ..tostring(passesFilter))
    --end
--end
            end
            if passesCallback and passesFilter then
                --Check if item is junk and do not pass the callback then!
                if hasAnyJunkInBag then
                    isItemJunk = IsItemJunk(itemData.bagId, itemData.slotIndex)
                end
                --Check if item is stolen (crafting or banks)
                if isABankDepositPanel or isVendorPanel or not isNoCrafting or isGuildStoreSellPanel then
                    isItemStolen = IsItemStolen(itemData.bagId, itemData.slotIndex)
                end
                --Checks for bound and BOP tradeable
                if isGuildBankDepositPanel or isGuildStoreSellPanel then
                    isBound         = IsItemBound(itemData.bagId, itemData.slotIndex)
                    isBOPTradeable  = IsItemBoPAndTradeable(itemData.bagId, itemData.slotIndex)
                end
                --Is an item below a subfilter but cannot be deposit/sold (bank, guild bank, vendor):
                --The subfilter button will be still enabled as there are no items to check (will be filtered by ESO vanilla UI BEFORE AF can check them)
                --if isBankDepositPanel or isHouseBankDepositPanel then
                --Check if items are not bankable:
                --isItemBankAble =
                --end
                if isGuildBankDepositPanel then
                    --Check if items are not guild bankable:
                    --Stolen items
                    --Bound items
                    --Bound but tradeable items
                    isItemBankAble = not isBound and not isBOPTradeable
                end
                ----------------------------------------------------------------------------------------
                --[No crafting panel] (e.g. inventory, bank, guild bank, mail, trade, craftbag):
                --Item is:
                -->no junk
                -->or at junk panel and item is junk
                if isNoCrafting then
                    --[Bank/Guild Bank deposit]
                    --Item is:
                    -->Not stolen
                    -->Bankable (unbound)
                    -->not junk
                    -->Or junk, and junk inventory filter button is active
                    if isABankDepositPanel then
                        doEnableSubFilterButtonAgain = not isItemStolen and isItemBankAble and (not isItemJunk or (isJunkInvButtonActive and isItemJunk))

                        --[Vendor]
                        --Item is:
                        -->Not stolen
                        -->not junk
                        -->Or junk, and junk inventory filter button is active
                    elseif isVendorPanel then
                        doEnableSubFilterButtonAgain = not isItemStolen and (not isItemJunk or (isJunkInvButtonActive and isItemJunk))

                        --[Guild store list/sell]
                        --Item is:
                        -->Not stolen
                        -->not junk
                        -->not bound
                    elseif isGuildStoreSellPanel then
                        doEnableSubFilterButtonAgain = not isItemStolen and not isItemJunk and not isBound and not isBOPTradeable

                        --[Normal inventory, mail, trade, craftbag]
                        --Item is:
                        -->not junk
                        -->Or junk, and junk inventory filter button is active
                    else
                        doEnableSubFilterButtonAgain = (not isItemJunk or (isJunkInvButtonActive and isItemJunk))
                    end
                        ----------------------------------------------------------------------------------------
                        --[Crafting panel] (e.g. refine, creation, deconstruction, improvement, research, recipes, extraction, retrait):
                        --Item is:
                        -->Not stolen (currently deactivated!)
                else
--if isRetraitStation and button.name == "Shield" then
--d(">" .. GetItemLink(itemData.bagId, itemData.slotIndex) .. " passesCallback: " ..tostring(passesCallback) .. ", otherAddonUsesFilters: " .. tostring(otherAddonUsesFilters) .. ", passesFilter: " ..tostring(passesFilter) .. ", canBeRetraited: " .. tostring(CanItemBeRetraited(itemData.bagId, itemData.slotIndex)) .. " - doEnableSubFilterButtonAgain: " ..tostring(doEnableSubFilterButtonAgain))
--end
                    itemsFound = itemsFound +1
--d("<<< Crafting station: " ..tostring(itemsFound))
                    --doEnableSubFilterButtonAgain = not isItemStolen
                    doEnableSubFilterButtonAgain = (itemsFound > 0) or false
                end
                if doEnableSubFilterButtonAgain then
                    breakInventorySlotsLoopNow = true
                    break
                end
            else
--d("<<< did not pass filter or callback!")
            end
        end -- for ... itemData in bagData
--d(">breakInventorySlotsLoopNow: " ..tostring(breakInventorySlotsLoopNow) .. ", doEnableSubFilterButtonAgain: " .. tostring(doEnableSubFilterButtonAgain))
    end
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

    --Check if filters apply to the subfilter and change the color of the subfilter button
    for _, button in ipairs(subfilterBar.subfilterButtons) do
--d(">==============================>\nButtonName: " .. tostring(button.name))
        if button.name ~= AF_CONST_ALL then
            --Setting to disable subfilter buttons with no items is enabled?
            if grayOutSubFiltersWithNoItems then
--d("Gray out wished!")
                doEnableSubFilterButtonAgain = false
                breakInventorySlotsLoopNow = false
                --Disable button first (May be enabled further down again if checks allow it)
                if button.clickable then
--d(">disabling button!")
                    button.texture:SetColor(.3, .3, .3, .9)
                    button:SetEnabled(false)
                    button.clickable = false
                end
                --Check each inventory now
                for _, realInvType in pairs(realInvTypes) do
                    if breakInventorySlotsLoopNow then break end
                    breakInventorySlotsLoopNow = false
                    inventory = PLAYER_INVENTORY.inventories[realInvType]
                    if inventory ~= nil and inventory.slots ~= nil then
                        --Get the current filter. Normally this comes from the inventory. Crafting currentFilter determination is more complex!
                        if isNoCrafting then
                            currentFilter = inventory.currentFilter
--d(">currentFilter: " .. tostring(currentFilter))
                        else
                            --Todo: ItemData.filterData is not reliable at crafting stations as the items are collected from several different bags!
                            --Todo: Thus the filter is always marked as "passed". Is this correct and does it work properly? To test!
                            --Todo: Enable this section again if currentFilter is needed further down in this function!
                            --[[
                            local invType = AF.currentInventoryType
                            local craftingMode = util.GetCraftingMode(invType)
                            currentFilter = util.MapCraftingStationFilterType2ItemFilterType(craftingMode, invType, craftingType)
                            ]]
                        end
                        inventorySlots = inventory.slots
                        --Check subfilterbutton for items, using the filter function and junk checks (only for non-crafting stations)
                        for bag, bagData in pairs(inventorySlots) do
                            if breakInventorySlotsLoopNow then break end
                            checkBagContentsNow(bag, bagData, realInvType, button)
                            if doEnableSubFilterButtonAgain then
--d(">>> !!! subfilterButton got enabled again !!!")
                                breakInventorySlotsLoopNow = true
                            end
                        end
                    end
                    if doEnableSubFilterButtonAgain then
--d(">>>> !!!! subfilterButton got enabled again !!!!")
                        breakInventorySlotsLoopNow = true
                    end
                end
                --Check the worn items as well? (for LF_SMITHING_IMPROVEMENT e.g.)
                if not doEnableSubFilterButtonAgain and bagWornItemCache ~= nil then
                    for _, data in pairs(bagWornItemCache) do
                        checkBagContentsNow(BAG_WORN, data, INVENTORY_BACKPACK, button)
                        if doEnableSubFilterButtonAgain then
--d(">>>>> !!!!! BAG_WORN: subfilterButton got enabled again !!!!")
                            breakInventorySlotsLoopNow = true
                            break
                        end
                    end
                end
            else
--d("No gray out wished!")
                --Setting to disable subfilter buttons with no items is disabled:
                --Enable all subfilter buttons again
                doEnableSubFilterButtonAgain = true
            end
            --Enable the subfilter button again now?
            if doEnableSubFilterButtonAgain then
--d(">Enabling button again: " .. tostring(button.name))
                button.texture:SetColor(1, 1, 1, 1)
                button:SetEnabled(true)
                button.clickable = true
            end
        end
    end
end

--Check if the current panel should show the dropdown "addon filters" for "all" too
function util.checkIfPanelShouldShowAddonAllDropdownFilters(invType)
    --d("[AF]checkIfPanelShouldShowAddonAllDropdownFilters - invType: " .. tostring(invType))
    if invType == nil then return true end
    local inv2ShowAddonAllDropdownFilters = {
        [LF_ENCHANTING_CREATION]    = false,
        [LF_ENCHANTING_EXTRACTION]  = false,
        --[LF_SMITHING_REFINE]        = false,
        [LF_SMITHING_CREATION]      = false,
        [LF_JEWELRY_CREATION]       = false,
    }
    local showAtInv = true
    if inv2ShowAddonAllDropdownFilters[invType] ~= nil then
        showAtInv = inv2ShowAddonAllDropdownFilters[invType]
    end
    return showAtInv
end

--Check if the craftbag is shown as the groupName at the craftbag is different than non-craftbag
--e.g. the groupName "Alchemy" is the normal groupName "Crafting" with subfilterName "Alchemy"
function util.IsCraftBagShown()
    return not ZO_CraftBag:IsHidden()
end

function util.BuildDropdownCallbacks(groupName, subfilterName)
    local doDebugOutput = AF.settings.doDebugOutput
    local subfilterNameOrig = subfilterName
    if groupName == "Armor" and (subfilterName == "Heavy" or subfilterName == "Medium" or subfilterName == "LightArmor" or subfilterName == "Clothing") then subfilterName = "Body" end
    if doDebugOutput then
        d("=========================\n[AF]]BuildDropdownCallbacks - groupName: " .. tostring(groupName) .. ", subfilterName: " .. tostring(subfilterName) .. ", subFilterNameOrig: " ..tostring(subfilterNameOrig))
    end
    local callbackTable = {}
    local keys = AF.dropdownCallbackKeys
    local craftBagFilterGroups = AF.craftBagFilterGroups
    local subfilterCallbacks = AF.subfilterCallbacks

    ------------------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------
    local function insertAddon(addonTable, groupNameLocal, subfilterNameLocal)
        groupNameLocal = groupNameLocal or ""
        subfilterNameLocal = subfilterNameLocal or subfilterNameLocal
        if AF.settings.doDebugOutput then
            AF._addonTable = AF._addonTable or {}
            table.insert(AF._addonTable, addonTable)
        end
        local addonName = ""
        if addonTable.name ~= nil and addonTable.name ~= "" then
            addonName = addonTable.name
        elseif addonTable.submenuName ~= nil and addonTable.submenuName ~= "" then
            addonName = addonTable.submenuName
        else
            addonName = addonTable.callbackTable[1].name
        end
        if doDebugOutput then d("->insertAddon addonName: '" .. tostring(addonName) .."', groupNameLocal: '" .. tostring(groupNameLocal) .. "', subfilterNameLocal: '" .. tostring(subfilterNameLocal).. "'") end

        --generate information if necessary
        if addonTable.generator then
            local strings

            addonTable.callbackTable, strings = addonTable.generator()

            for key, string in pairs(strings) do
                AF.strings[key] = string
            end
        end

        --Is the addon filter not to be shown at some libFilter panels?
        if addonTable.excludeFilterPanels ~= nil then
            if doDebugOutput then d(">>excludeFilterPanels: Yes") end
            local filterType = util.GetCurrentFilterTypeForInventory(AF.currentInventoryType)
            if type(addonTable.excludeFilterPanels) == "table" then
                for _, filterPanelToExclude in pairs(addonTable.excludeFilterPanels) do
                    if filterType == filterPanelToExclude then
                        if doDebugOutput then d(">>>insertAddon - filterPanelToExclude: " ..tostring(filterPanelToExclude)) end
                        return
                    else
                        if doDebugOutput then d(">>>insertAddon - filterPanelToExclude: " ..tostring(filterPanelToExclude) .. " <> filterType: "..tostring(filterType)) end
                    end
                end
            else
                if filterType == addonTable.excludeFilterPanels then
                    if doDebugOutput then d(">>>insertAddon - filterPanelToExclude: " ..tostring(addonTable.excludeFilterPanels)) end
                    return
                end
            end
        end

        --Only add the entries if the group name specified "to be used" are the given ones
        if groupNameLocal ~= AF_CONST_ALL and addonTable.onlyGroups ~= nil then
            if doDebugOutput then d(">>onlyGroups: Yes") end
            if type(addonTable.onlyGroups) == "table" then
                local allowedgroupNameLocals = {}
                for _, groupNameLocalToCheck in pairs(addonTable.onlyGroups) do
                    --groupNameLocal "Craftbag" stands for several group names, so add them all
                    if groupNameLocalToCheck == "Craftbag" then
                        for _, craftBagGroup in pairs(craftBagFilterGroups) do
                            allowedgroupNameLocals[craftBagGroup] = true
                        end
                    end
                    allowedgroupNameLocals[groupNameLocalToCheck] = true
                end
                if not allowedgroupNameLocals[groupNameLocal] then
                    if doDebugOutput then d("-->insertAddon - onlyGroups, not allowed group: " ..tostring(groupNameLocal)) end
                    return
                end
            else
                if addonTable.onlyGroups == "Craftbag" then
                    local allowedgroupNameLocals = {}
                    --groupNameLocal "Craftbag" stands for several group names, so add them all
                    for _, craftBagGroup in pairs(craftBagFilterGroups) do
                        allowedgroupNameLocals[craftBagGroup] = true
                    end
                    if not allowedgroupNameLocals[groupNameLocal] then
                        if doDebugOutput then d("-->insertAddon - onlyGroups, not allowed group: " ..tostring(groupNameLocal)) end
                        return
                    end

                else
                    if groupNameLocal ~= addonTable.onlyGroups then
                        if doDebugOutput then d("-->insertAddon - onlyGroups, not allowed group: " ..tostring(addonTable.onlyGroups)) end
                        return
                    end
                end
            end
        end

        --Should any subfilter be excluded?
        if addonTable.excludeSubfilters ~= nil then
            if doDebugOutput then d(">>excludeSubfilters: Yes") end
            if type(addonTable.excludeSubfilters) == "table" then
                for _, subfilterNameLocalToExclude in pairs(addonTable.excludeSubfilters) do
                    if subfilterNameOrig == subfilterNameLocalToExclude or subfilterNameLocal == subfilterNameLocalToExclude then
                        if doDebugOutput then d("--->insertAddon - excludeSubfilters: " ..tostring(subfilterNameLocalToExclude)) end
                        return
                    else
                        if doDebugOutput then d("--->insertAddon - excludeSubfilter '" ..tostring(subfilterNameLocalToExclude) .. "' <> ' " ..tostring(subfilterNameOrig) .. "/" .. tostring(subfilterNameLocal)) end
                    end
                end
            else
                if subfilterNameOrig == addonTable.excludeSubfilters or subfilterNameLocal == addonTable.excludeSubfilters then
                    if doDebugOutput then d("--->insertAddon - excludeSubfilters: " ..tostring(subfilterNameLocal)) end
                    return
                end
            end
        end

        --was the same addon filter already added before via the "ALL" type
        --only check if the groupNameLocal not equals "ALL", and if the duplicate checks should be done
        --e.g. they are not needed as the global addon filters get added
        if groupNameLocal ~= AF_CONST_ALL then --and subfilterNameLocal == AF_CONST_ALL then
            --Build names to compare
            local compareNames = {}
            if addonTable.submenuName then
                table.insert(compareNames, addonTable.submenuName)
            else
                if addonTable.callbackTable then
                    for _, callbackTableNameEntry in ipairs(addonTable.callbackTable) do
                        table.insert(compareNames, callbackTableNameEntry.name)
                    end
                end
            end
            --Compare names with the entries in dropdownbox now
            for _, compareName in ipairs(compareNames) do
                --Check the whole callback table for entries with the same name or submenuName
                for _, callbackTableEntry in ipairs(callbackTable) do
                    if callbackTableEntry.submenuName then
                        if callbackTableEntry.submenuName == compareName then
                            if doDebugOutput then d(">Duplicate submenu entry: " .. tostring(callbackTableEntry.submenuName)) end
                            return
                        end
                    else
                        if callbackTableEntry.name and callbackTableEntry.name == compareName then
                            if doDebugOutput then d(">Duplicate entry: " .. tostring(callbackTableEntry.name)) end
                            return
                        end
                    end
                end
            end
        end

        --check to see if addon is set up for a submenu
        if addonTable.submenuName then
            --insert whole package
            table.insert(callbackTable, addonTable)
        else
            --insert all callbackTable entries
            local currentAddonTable = addonTable.callbackTable
            for _, callbackEntry in ipairs(currentAddonTable) do
                table.insert(callbackTable, callbackEntry)
            end
        end
    end -- function "insertAddon"
    ------------------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------

    -- insert global AdvancedFilters "All" filters
    for _, callbackEntry in ipairs(subfilterCallbacks.All.dropdownCallbacks) do
        table.insert(callbackTable, callbackEntry)
    end

    --insert filters that apply to a group, but not the ALL entry!
    if groupName ~= AF_CONST_ALL then
        --insert global "All" filters for a "group". e.g. Group "Jewelry", entry "All" -> subfilterCallbacks[Jewelry].All
        for _, callbackEntry in ipairs(subfilterCallbacks[groupName].All.dropdownCallbacks) do
            table.insert(callbackTable, callbackEntry)
        end
        --Subfilter is the ALL entry?
        if subfilterName == AF_CONST_ALL then
            if keys[groupName] == nil then
                d("--- ERROR --- [AF]util.BuildDropdownCallbacks-GroupName is missing in keys: " ..tostring(groupName) .. ". PLease contact the author of ".. tostring(AF.name) .. " at the website in the settings menu (link can be found at the top of the settings page)!")
                return
                --else
                --d("[AF].util.BuildDropdownCallbacks-GroupName: " ..tostring(groupName))
            end
            --insert all default filters for each subfilter
            for _, subfilterNameLoop in ipairs(keys[groupName]) do
                local currentSubfilterTable = subfilterCallbacks[groupName][subfilterNameLoop]
                for idx, callbackEntry in ipairs(currentSubfilterTable.dropdownCallbacks) do
                    table.insert(callbackTable, callbackEntry)
                end
            end

            --insert all filters provided by addons
            --but check if the current panel should show the addon filters for "all" too
            if util.checkIfPanelShouldShowAddonAllDropdownFilters(AF.currentInventoryType) then
                if doDebugOutput then d(">add addon dropdown filters to group's '" .. tostring(groupName) .."' 'ALL' filters") end
                for _, addonTable in ipairs(subfilterCallbacks[groupName].addonDropdownCallbacks) do
                    insertAddon(addonTable, groupName, subfilterName)
                end
            end
            --Subfilter is NOT the ALL entry
        else
            --insert filters for provided subfilter
            local currentSubfilterTable = subfilterCallbacks[groupName][subfilterName]
            for _, callbackEntry in ipairs(currentSubfilterTable.dropdownCallbacks) do
                table.insert(callbackTable, callbackEntry)
            end

            --insert filters provided by addons for this subfilter
            for _, addonTable in ipairs(subfilterCallbacks[groupName].addonDropdownCallbacks) do
                --scan addon to see if it applies to given subfilter
                for _, subfilter in ipairs(addonTable.subfilters) do
                    if subfilter == subfilterName or subfilter == AF_CONST_ALL then
                        --add addon filters
                        insertAddon(addonTable, groupName, subfilterName)
                    end
                end
            end
        end
    end

    --insert global addon filters
    --but check if the current panel should show the addon filters for "all" too
    if util.checkIfPanelShouldShowAddonAllDropdownFilters(AF.currentInventoryType) then
        --d(">show addon dropdown 'ALL' filters")
        for _, addonTable in ipairs(subfilterCallbacks.All.addonDropdownCallbacks) do
            insertAddon(addonTable, groupName, subfilterName)
        end
    end

    return callbackTable
end

function util.GetLanguage()
    local lang = GetCVar("language.2")
    local supported = {
        de = 1,
        en = 2,
        es = 3,
        fr = 4,
        ru = 5,
        jp = 6,
    }

    --check for supported languages
    if(supported[lang] ~= nil) then return lang end

    --return english if not supported
    return "en"
end

--thanks ckaotik
function util.Localize(text)
    if type(text) == 'number' then
        -- get the string from this constant
        text = GetString(text)
    end
    -- clean up suffixes such as ^F or ^S
    return zo_strformat(SI_TOOLTIP_ITEM_NAME, text) or " "
end

function util.ThrottledUpdate(callbackName, timer, callback, ...)
    local args = {...}
    local function Update()
        EVENT_MANAGER:UnregisterForUpdate(callbackName)
        callback(unpack(args))
    end
    EVENT_MANAGER:UnregisterForUpdate(callbackName)
    EVENT_MANAGER:RegisterForUpdate(callbackName, timer, Update)
end

function util.GetItemLink(slot)
    --Supporrt for AutoCategory AddOn ->
    -- Collapsable headers in the inventories & crafting stations
    if slot == nil or type(slot) ~= "table" or (slot.isHeader ~= nil and slot.isHeader) then return end

    if slot.bagId then
        return GetItemLink(slot.bagId, slot.slotIndex)
    else
        return GetStoreItemLink(slot.slotIndex)
    end
end

function util.BuildItemLink(itemId)
    if itemId == nil then return nil end
    return string.format("|H1:item:%d:%d:50:0:0:0:0:0:0:0:0:0:0:0:0:%d:%d:0:0:%d:0|h|h", itemId, 364, ITEMSTYLE_NONE, 0, 10000)
end

function util.IsRetraitPanelShown()
    return ZO_RETRAIT_STATION_MANAGER:IsRetraitSceneShowing() or false
end

function util.IsCraftingPanelShown()
    return (ZO_CraftingUtils_IsCraftingWindowOpen() or util.IsRetraitPanelShown()) or false
end

function util.GetCraftingType()
    --[[
        TradeskillType
        CRAFTING_TYPE_ALCHEMY
        CRAFTING_TYPE_BLACKSMITHING
        CRAFTING_TYPE_CLOTHIER
        CRAFTING_TYPE_ENCHANTING
        CRAFTING_TYPE_INVALID
        CRAFTING_TYPE_PROVISIONING
        CRAFTING_TYPE_WOODWORKING
        CRAFTING_TYPE_JEWELRYCRAFTING
    ]]
    return GetCraftingInteractionType() or CRAFTING_TYPE_INVALID
end

function util.GetInventoryFromCraftingPanel(libFiltersFilterPanelId)
    if libFiltersFilterPanelId == nil then return end
    local libFiltersFilterPanelId2Inventory = {
        [LF_SMITHING_REFINE]        = controlsForChecks.smithing.refinementPanel.inventory,
        --[LF_SMITHING_CREATION]      = controlsForChecks.smithing.creationPanel,
        [LF_SMITHING_DECONSTRUCT]   = controlsForChecks.smithing.deconstructionPanel.inventory,
        [LF_SMITHING_IMPROVEMENT]   = controlsForChecks.smithing.improvementPanel.inventory,
        [LF_SMITHING_RESEARCH]      = nil, --controlsForChecks.smithing.researchPanel.???,
        [LF_JEWELRY_REFINE]         = controlsForChecks.smithing.refinementPanel.inventory,
        --[LF_JEWELRY_CREATION]       = controlsForChecks.smithing.creationPanel,
        [LF_JEWELRY_DECONSTRUCT]    = controlsForChecks.smithing.deconstructionPanel.inventory,
        [LF_JEWELRY_IMPROVEMENT]    = controlsForChecks.smithing.improvementPanel.inventory,
        [LF_JEWELRY_RESEARCH]       = nil, --controlsForChecks.smithing.researchPanel.???,
        [LF_ENCHANTING_CREATION]    = controlsForChecks.enchanting.inventory,
        [LF_ENCHANTING_EXTRACTION]  = controlsForChecks.enchanting.inventory,
        [LF_RETRAIT]                = controlsForChecks.retrait.retraitPanel.inventory,
    }
    if libFiltersFilterPanelId2Inventory[libFiltersFilterPanelId] == nil then return nil end
    return libFiltersFilterPanelId2Inventory[libFiltersFilterPanelId]
end

function util.IsCraftingStationInventoryType(inventoryType)
    local craftingInventoryTypes = {
        [LF_SMITHING_REFINE]        = true,
        --[LF_SMITHING_CREATION]      = true,
        [LF_SMITHING_DECONSTRUCT]   = true,
        [LF_SMITHING_IMPROVEMENT]   = true,
        [LF_SMITHING_RESEARCH]      = true,
        [LF_JEWELRY_REFINE]         = true,
        --[LF_JEWELRY_CREATION]       = true,
        [LF_JEWELRY_DECONSTRUCT]    = true,
        [LF_JEWELRY_IMPROVEMENT]    = true,
        [LF_JEWELRY_RESEARCH]       = true,
        [LF_ENCHANTING_CREATION]    = true,
        [LF_ENCHANTING_EXTRACTION]  = true,
        [LF_RETRAIT]                = true,
    }
    local retVar = craftingInventoryTypes[inventoryType] or false
    return retVar
end

--Function to return a boolean value if the craftingPanel is using the worn bag ID as well.
--Use the LibFilters filterPanelid as parameter
function util.GetCraftingPanelUsesWornBag(libFiltersFilterPanelId)
    local craftingFilterPanelId2USesWornBag = {
        [LF_SMITHING_REFINE]        = true,
        --[LF_SMITHING_CREATION]      = false,
        [LF_SMITHING_DECONSTRUCT]   = true,
        [LF_SMITHING_IMPROVEMENT]   = true,
        [LF_SMITHING_RESEARCH]      = false,
        [LF_JEWELRY_REFINE]         = false,
        --[LF_JEWELRY_CREATION]       = false,
        [LF_JEWELRY_DECONSTRUCT]    = true,
        [LF_JEWELRY_IMPROVEMENT]    = true,
        [LF_JEWELRY_RESEARCH]       = false,
        [LF_ENCHANTING_CREATION]    = false,
        [LF_ENCHANTING_EXTRACTION]  = false,
        [LF_RETRAIT]                = true,
    }
    local usesWornBag = craftingFilterPanelId2USesWornBag[libFiltersFilterPanelId] or false
    return usesWornBag
end

--Function to return the "predicate" and "filter" functions of the different carfting types, as new inventory lists are build.
--Use the LibFilters filterPanelid as parameter
function util.GetPredicateAndFilterFunctionFromCraftingPanel(libFiltersFilterPanelId)
    local craftingFilterPanelId2PredicateFunc = {
        [LF_SMITHING_REFINE]        = {ZO_SharedSmithingExtraction_IsExtractableItem, ZO_SharedSmithingExtraction_DoesItemPassFilter},
        --[LF_SMITHING_CREATION]      = {nil, nil},
        [LF_SMITHING_DECONSTRUCT]   = {ZO_SharedSmithingExtraction_IsExtractableItem, ZO_SharedSmithingExtraction_DoesItemPassFilter},
        [LF_SMITHING_IMPROVEMENT]   = {ZO_SharedSmithingExtraction_IsExtractableItem, ZO_SharedSmithingImprovement_DoesItemPassFilter},
        [LF_SMITHING_RESEARCH]      = {nil, nil},
        [LF_JEWELRY_REFINE]         = {ZO_SharedSmithingExtraction_IsExtractableItem, ZO_SharedSmithingExtraction_DoesItemPassFilter},
        --[LF_JEWELRY_CREATION]       = true,
        [LF_JEWELRY_DECONSTRUCT]    = {ZO_SharedSmithingExtraction_IsExtractableItem, ZO_SharedSmithingExtraction_DoesItemPassFilter},
        [LF_JEWELRY_IMPROVEMENT]    = {ZO_SharedSmithingExtraction_IsExtractableItem, ZO_SharedSmithingImprovement_DoesItemPassFilter},
        [LF_JEWELRY_RESEARCH]       = {nil, nil},
        [LF_ENCHANTING_CREATION]    = {nil, nil},
        [LF_ENCHANTING_EXTRACTION]  = {nil, nil},
        [LF_RETRAIT]                = {ZO_RetraitStation_CanItemBeRetraited, ZO_RetraitStation_DoesItemPassFilter},
    }
    local predicateFunc, filterFunc
    local funcs = craftingFilterPanelId2PredicateFunc[libFiltersFilterPanelId] or nil
    if funcs and funcs[1] and funcs[2] then
        predicateFunc, filterFunc = funcs[1], funcs[2]
    end
    return predicateFunc, filterFunc
end

function util.MapItemFilterType2CraftingStationFilterType(itemFilterType, filterPanelId, craftingType)
    if filterPanelId == nil then return end
    --[[
        ZO_SMITHING_EXTRACTION_SHARED_FILTER_TYPE_RAW_MATERIALS = 1
        ZO_SMITHING_EXTRACTION_SHARED_FILTER_TYPE_ARMOR = 1
        ZO_SMITHING_EXTRACTION_SHARED_FILTER_TYPE_WEAPONS = 2
        ZO_SMITHING_IMPROVEMENT_SHARED_FILTER_TYPE_ARMOR = 1
        ZO_SMITHING_IMPROVEMENT_SHARED_FILTER_TYPE_WEAPONS = 2
        --
        ENCHANTING_MODE_CREATION    = 1
        ENCHANTING_MODE_EXTRACTION  = 2
    ]]
    --Map the filter type (selected button, e.g. weapons) of a crafting station to the
    --itemfilter type that is used for the filters (shown items)
    local mapIFT2CSFT = {
        --[[
        [LF_SMITHING_CREATION] = {
            [CRAFTING_TYPE_BLACKSMITHING] = {
                [ITEMFILTERTYPE_AF_CREATE_ARMOR_SMITHING]       = SMITHING_FILTER_TYPE_ARMOR,
                [ITEMFILTERTYPE_AF_CREATE_WEAPONS_SMITHING]     = SMITHING_FILTER_TYPE_WEAPONS,
            },
            [CRAFTING_TYPE_CLOTHIER] = {
                [ITEMFILTERTYPE_AF_CREATE_ARMOR_CLOTHIER]       = SMITHING_FILTER_TYPE_ARMOR,
            },
            [CRAFTING_TYPE_WOODWORKING] = {
                [ITEMFILTERTYPE_AF_CREATE_ARMOR_WOODWORKING]    = SMITHING_FILTER_TYPE_ARMOR,
                [ITEMFILTERTYPE_AF_CREATE_WEAPONS_WOODWORKING]  = SMITHING_FILTER_TYPE_WEAPONS,
            },
        },
        ]]
        [LF_SMITHING_REFINE] = {
            [CRAFTING_TYPE_BLACKSMITHING] = {
                [ITEMFILTERTYPE_AF_REFINE_SMITHING]             = ZO_SMITHING_EXTRACTION_SHARED_FILTER_TYPE_RAW_MATERIALS,
            },
            [CRAFTING_TYPE_CLOTHIER] = {
                [ITEMFILTERTYPE_AF_REFINE_CLOTHIER]             = ZO_SMITHING_EXTRACTION_SHARED_FILTER_TYPE_RAW_MATERIALS,
            },
            [CRAFTING_TYPE_WOODWORKING] = {
                [ITEMFILTERTYPE_AF_REFINE_WOODWORKING]          = ZO_SMITHING_EXTRACTION_SHARED_FILTER_TYPE_RAW_MATERIALS,
            },
        },
        [LF_SMITHING_DECONSTRUCT] = {
            [CRAFTING_TYPE_BLACKSMITHING] = {
                [ITEMFILTERTYPE_AF_WEAPONS_SMITHING]            = ZO_SMITHING_EXTRACTION_SHARED_FILTER_TYPE_WEAPONS,
                [ITEMFILTERTYPE_AF_ARMOR_SMITHING]              = ZO_SMITHING_EXTRACTION_SHARED_FILTER_TYPE_ARMOR,
            },
            [CRAFTING_TYPE_CLOTHIER] = {
                [ITEMFILTERTYPE_AF_ARMOR_CLOTHIER]              = ZO_SMITHING_EXTRACTION_SHARED_FILTER_TYPE_ARMOR,
            },
            [CRAFTING_TYPE_WOODWORKING] = {
                [ITEMFILTERTYPE_AF_WEAPONS_WOODWORKING]         = ZO_SMITHING_EXTRACTION_SHARED_FILTER_TYPE_WEAPONS,
                [ITEMFILTERTYPE_AF_ARMOR_WOODWORKING]           = ZO_SMITHING_EXTRACTION_SHARED_FILTER_TYPE_ARMOR,
            },
        },
        [LF_SMITHING_IMPROVEMENT] = {
            [CRAFTING_TYPE_BLACKSMITHING] = {
                [ITEMFILTERTYPE_AF_WEAPONS_SMITHING]            = ZO_SMITHING_IMPROVEMENT_SHARED_FILTER_TYPE_WEAPONS,
                [ITEMFILTERTYPE_AF_ARMOR_SMITHING]              = ZO_SMITHING_IMPROVEMENT_SHARED_FILTER_TYPE_ARMOR,
            },
            [CRAFTING_TYPE_CLOTHIER] = {
                [ITEMFILTERTYPE_AF_ARMOR_CLOTHIER]              = ZO_SMITHING_IMPROVEMENT_SHARED_FILTER_TYPE_ARMOR,
            },
            [CRAFTING_TYPE_WOODWORKING] = {
                [ITEMFILTERTYPE_AF_WEAPONS_WOODWORKING]         = ZO_SMITHING_IMPROVEMENT_SHARED_FILTER_TYPE_WEAPONS,
                [ITEMFILTERTYPE_AF_ARMOR_WOODWORKING]           = ZO_SMITHING_IMPROVEMENT_SHARED_FILTER_TYPE_ARMOR,
            },

        },
        --[[
        [LF_JEWELRY_CREATION] = {
            [CRAFTING_TYPE_JEWELRYCRAFTING] = {
                [ITEMFILTERTYPE_AF_CREATE_JEWELRY]             = ITEMFILTERTYPE_AF_CREATE_JEWELRY,
            },

        },
        ]]
        [LF_JEWELRY_REFINE] = {
            [CRAFTING_TYPE_JEWELRYCRAFTING] = {
                [ITEMFILTERTYPE_AF_REFINE_JEWELRY]             = ZO_SMITHING_EXTRACTION_SHARED_FILTER_TYPE_RAW_MATERIALS,
            },

        },
        [LF_JEWELRY_DECONSTRUCT] = {
            [CRAFTING_TYPE_JEWELRYCRAFTING] = {
                [ITEMFILTERTYPE_AF_JEWELRY_CRAFTING]           = SMITHING_FILTER_TYPE_JEWELRY,
            },
        },
        [LF_JEWELRY_IMPROVEMENT] = {
            [CRAFTING_TYPE_JEWELRYCRAFTING] = {
                [ITEMFILTERTYPE_AF_JEWELRY_CRAFTING]           = SMITHING_FILTER_TYPE_JEWELRY,
            },

        },
        [LF_ENCHANTING_CREATION] = {
            [CRAFTING_TYPE_ENCHANTING] = {
                --TODO: Enable if itemfiltertype subfilters for the runes work: ITEMFILTERTYPE_AF_RUNES_ENCHANTING,
                --[[
                [ITEMFILTERTYPE_AF_RUNES_ENCHANTING]       = ENCHANTING_MODE_CREATION,
                ]]
                [ITEMFILTERTYPE_ALL]                            = ENCHANTING_MODE_CREATION,
            },
        },
        [LF_ENCHANTING_EXTRACTION] = {
            [CRAFTING_TYPE_ENCHANTING] = {
                [ITEMFILTERTYPE_AF_GLYPHS_ENCHANTING]           = ENCHANTING_MODE_EXTRACTION,
            },
        },
        [LF_RETRAIT] = {
            [CRAFTING_TYPE_INVALID] = {
                [ITEMFILTERTYPE_AF_RETRAIT_WEAPONS] = SMITHING_FILTER_TYPE_WEAPONS,
                [ITEMFILTERTYPE_AF_RETRAIT_ARMOR]   = SMITHING_FILTER_TYPE_ARMOR,
                [ITEMFILTERTYPE_AF_RETRAIT_JEWELRY] = SMITHING_FILTER_TYPE_JEWELRY,
            },
        },
    }
    AF.mapIFT2CSFT = mapIFT2CSFT
    if craftingType == nil then craftingType = util.GetCraftingType() end
    if itemFilterType == nil or craftingType == nil or mapIFT2CSFT[filterPanelId] == nil or mapIFT2CSFT[filterPanelId][craftingType] == nil or mapIFT2CSFT[filterPanelId][craftingType][itemFilterType] == nil then return end
    return mapIFT2CSFT[filterPanelId][craftingType][itemFilterType]
end

function util.MapCraftingStationFilterType2ItemFilterType(craftingStationFilterType, filterPanelId, craftingType)
    if filterPanelId == nil then return end
    --[[
        ZO_SMITHING_EXTRACTION_SHARED_FILTER_TYPE_RAW_MATERIALS = 1
        ZO_SMITHING_EXTRACTION_SHARED_FILTER_TYPE_ARMOR = 1
        ZO_SMITHING_EXTRACTION_SHARED_FILTER_TYPE_WEAPONS = 2
        ZO_SMITHING_IMPROVEMENT_SHARED_FILTER_TYPE_ARMOR = 1
        ZO_SMITHING_IMPROVEMENT_SHARED_FILTER_TYPE_WEAPONS = 2
        --
        ENCHANTING_MODE_CREATION    = 1
        ENCHANTING_MODE_EXTRACTION  = 2
    ]]
    --Map the filter type (selected button, e.g. weapons) of a crafting station to the
    --itemfilter type that is used for the filters (shown items)
    local mapCSFT2IFT = {
        --[[
        [LF_SMITHING_CREATION] = {
            [CRAFTING_TYPE_BLACKSMITHING] = {
                [SMITHING_FILTER_TYPE_ARMOR]        = ITEMFILTERTYPE_AF_CREATE_ARMOR_SMITHING,
                [SMITHING_FILTER_TYPE_WEAPONS]      = ITEMFILTERTYPE_AF_CREATE_WEAPONS_SMITHING,
            },
            [CRAFTING_TYPE_CLOTHIER] = {
                [SMITHING_FILTER_TYPE_ARMOR]        = ITEMFILTERTYPE_AF_CREATE_ARMOR_CLOTHIER,
            },
            [CRAFTING_TYPE_WOODWORKING] = {
                [SMITHING_FILTER_TYPE_ARMOR]        = ITEMFILTERTYPE_AF_CREATE_ARMOR_WOODWORKING,
                [SMITHING_FILTER_TYPE_WEAPONS]      = ITEMFILTERTYPE_AF_CREATE_WEAPONS_WOODWORKING,
            },
        },
        ]]
        [LF_SMITHING_REFINE] = {
            [CRAFTING_TYPE_BLACKSMITHING] = {
                [ZO_SMITHING_EXTRACTION_SHARED_FILTER_TYPE_RAW_MATERIALS] = ITEMFILTERTYPE_AF_REFINE_SMITHING,
            },
            [CRAFTING_TYPE_CLOTHIER] = {
                [ZO_SMITHING_EXTRACTION_SHARED_FILTER_TYPE_RAW_MATERIALS] = ITEMFILTERTYPE_AF_REFINE_CLOTHIER,
            },
            [CRAFTING_TYPE_WOODWORKING] = {
                [ZO_SMITHING_EXTRACTION_SHARED_FILTER_TYPE_RAW_MATERIALS] = ITEMFILTERTYPE_AF_REFINE_WOODWORKING,
            },
        },
        [LF_SMITHING_DECONSTRUCT] = {
            [CRAFTING_TYPE_BLACKSMITHING] = {
                [ZO_SMITHING_EXTRACTION_SHARED_FILTER_TYPE_WEAPONS] = ITEMFILTERTYPE_AF_WEAPONS_SMITHING,
                [ZO_SMITHING_EXTRACTION_SHARED_FILTER_TYPE_ARMOR] = ITEMFILTERTYPE_AF_ARMOR_SMITHING,
            },
            [CRAFTING_TYPE_CLOTHIER] = {
                [ZO_SMITHING_EXTRACTION_SHARED_FILTER_TYPE_ARMOR] = ITEMFILTERTYPE_AF_ARMOR_CLOTHIER,
            },
            [CRAFTING_TYPE_WOODWORKING] = {
                [ZO_SMITHING_EXTRACTION_SHARED_FILTER_TYPE_WEAPONS] = ITEMFILTERTYPE_AF_WEAPONS_WOODWORKING,
                [ZO_SMITHING_EXTRACTION_SHARED_FILTER_TYPE_ARMOR] = ITEMFILTERTYPE_AF_ARMOR_WOODWORKING,
            },

        },
        [LF_SMITHING_IMPROVEMENT] = {
            [CRAFTING_TYPE_BLACKSMITHING] = {
                [ZO_SMITHING_IMPROVEMENT_SHARED_FILTER_TYPE_WEAPONS] = ITEMFILTERTYPE_AF_WEAPONS_SMITHING,
                [ZO_SMITHING_IMPROVEMENT_SHARED_FILTER_TYPE_ARMOR] = ITEMFILTERTYPE_AF_ARMOR_SMITHING,
            },
            [CRAFTING_TYPE_CLOTHIER] = {
                [ZO_SMITHING_IMPROVEMENT_SHARED_FILTER_TYPE_ARMOR] = ITEMFILTERTYPE_AF_ARMOR_CLOTHIER,
            },
            [CRAFTING_TYPE_WOODWORKING] = {
                [ZO_SMITHING_IMPROVEMENT_SHARED_FILTER_TYPE_WEAPONS] = ITEMFILTERTYPE_AF_WEAPONS_WOODWORKING,
                [ZO_SMITHING_IMPROVEMENT_SHARED_FILTER_TYPE_ARMOR] = ITEMFILTERTYPE_AF_ARMOR_WOODWORKING,
            },
        },
        --[[
        [LF_JEWELRY_CREATION] = {
            [CRAFTING_TYPE_JEWELRYCRAFTING] = {
                [ITEMFILTERTYPE_AF_CREATE_JEWELRY]                  = ITEMFILTERTYPE_AF_CREATE_JEWELRY,
            },

        },
        ]]
        [LF_JEWELRY_REFINE] = {
            [CRAFTING_TYPE_JEWELRYCRAFTING] = {
                [ZO_SMITHING_EXTRACTION_SHARED_FILTER_TYPE_RAW_MATERIALS] = ITEMFILTERTYPE_AF_REFINE_JEWELRY,
            },
        },
        [LF_JEWELRY_DECONSTRUCT] = {
            [CRAFTING_TYPE_JEWELRYCRAFTING] = {
                [SMITHING_FILTER_TYPE_JEWELRY] = ITEMFILTERTYPE_AF_JEWELRY_CRAFTING,
            },

        },
        [LF_JEWELRY_IMPROVEMENT] = {
            [CRAFTING_TYPE_JEWELRYCRAFTING] = {
                [SMITHING_FILTER_TYPE_JEWELRY] = ITEMFILTERTYPE_AF_JEWELRY_CRAFTING,
            },
        },
        [LF_ENCHANTING_CREATION] = {
            [CRAFTING_TYPE_ENCHANTING] = {
                [ENCHANTING_MODE_CREATION]  = ITEMFILTERTYPE_ALL, --TODO: Enable if itemfiltertype subfilters for the runes work: ITEMFILTERTYPE_AF_RUNES_ENCHANTING,
            },
        },
        [LF_ENCHANTING_EXTRACTION] = {
            [CRAFTING_TYPE_ENCHANTING] = {
                [ENCHANTING_MODE_EXTRACTION] = ITEMFILTERTYPE_AF_GLYPHS_ENCHANTING,
            },
        },
        [LF_RETRAIT] = {
            [CRAFTING_TYPE_INVALID] = {
                [SMITHING_FILTER_TYPE_WEAPONS]  = ITEMFILTERTYPE_AF_RETRAIT_WEAPONS,
                [SMITHING_FILTER_TYPE_ARMOR]    = ITEMFILTERTYPE_AF_RETRAIT_ARMOR,
                [SMITHING_FILTER_TYPE_JEWELRY]  = ITEMFILTERTYPE_AF_RETRAIT_JEWELRY,
            },
        },
    }
    AF.mapCSFT2IFT = mapCSFT2IFT
    if craftingType == nil then craftingType = util.GetCraftingType() end
    if craftingStationFilterType == nil or craftingType == nil or mapCSFT2IFT[filterPanelId] == nil or mapCSFT2IFT[filterPanelId][craftingType] == nil or mapCSFT2IFT[filterPanelId][craftingType][craftingStationFilterType] == nil then return end
    local retVar = mapCSFT2IFT[filterPanelId][craftingType][craftingStationFilterType]
    return retVar
end

function util.GetCraftingMode(inventoryType)
    inventoryType = inventoryType or AF.currentInventory
    local craftingMode
    local craftingInventory = util.GetInventoryFromCraftingPanel(inventoryType)
    local craftingModeOwner = craftingInventory.owner
    if craftingModeOwner == controlsForChecks.enchanting then
        craftingMode = craftingModeOwner.enchantingMode
    elseif craftingModeOwner == controlsForChecks.smithing then
        craftingMode = craftingInventory.filterType
    elseif craftingModeOwner == controlsForChecks.retrait then
        craftingMode = craftingInventory.filterType
    end
    return craftingMode
end

--Slot is the bagId, coming from libFilters, helper function (e.g. deconstruction).
--Prepare the slot variable with bagId and slotIndex
function util.prepareSlot(bagId, slotIndex)
    local slot = {}
    slot.bagId = bagId
    slot.slotIndex = slotIndex
    return slot
end

--Add count of shown (filtered) items to the inventory: space/total (count)
function util.getInvItemCount(freeSlotType, isCraftingInvType)
--d("[util.getInvItemCount]freeSlotType: " .. tostring(freeSlotType) .. ", isCraftingInvType: " .. tostring(isCraftingInvType))
    local itemCount
    local invType
    if freeSlotType ~= nil then
        invType = freeSlotType
    else
        invType = AF.currentInventoryType
    end
    if invType == nil then return nil end
    isCraftingInvType = isCraftingInvType or util.IsCraftingStationInventoryType(invType)
    if not isCraftingInvType then
        if PLAYER_INVENTORY.inventories[invType] == nil then return nil end
        local invListViewData = PLAYER_INVENTORY.inventories[invType].listView.data
        if invListViewData then
            itemCount = #invListViewData
        end
    else
        local craftingInvCtrl = util.GetInventoryFromCraftingPanel(freeSlotType) or nil
        if craftingInvCtrl == nil then return nil end
        local craftingInvSlotCountCtrl = craftingInvCtrl.list.data or nil
        if craftingInvSlotCountCtrl == nil then return nil end
        itemCount = #craftingInvSlotCountCtrl
    end
    return itemCount
end

--Update the inventory infobar lFreeSlot label with the item filtered count
function util.updateInventoryInfoBarCountLabel(invType, isCraftingInvType, isCalledFromExternalAddon)
    invType = invType or AF.currentInventoryType
    isCraftingInvType = isCraftingInvType or util.IsCraftingStationInventoryType(invType)
    isCalledFromExternalAddon = isCalledFromExternalAddon or false
--d("[util.updateInventoryInfoBarCountLabel]invType: " ..tostring(invType) .. ", isCraftingInvType: " .. tostring(isCraftingInvType) .. ", isCalledFromExternalAddon: " .. tostring(isCalledFromExternalAddon))
    --Update the count of shown/filtered items in the inventory FreeSlots label
    if invType ~= nil then
        if not isCraftingInvType then
            --Call the update function for the player inventories
            if PLAYER_INVENTORY.inventories ~= nil and PLAYER_INVENTORY.inventories[invType] ~= nil then
                PLAYER_INVENTORY:UpdateFreeSlots(invType)
            end
        else
            --Call the update function for the crafting tables inventories now, see file "main.lua"
            -->Overwritten function UpdateInventorySlots(infoBar)
            --Ge the infoBar first
            local craftingInvCtrl = util.GetInventoryFromCraftingPanel(invType) or nil
            if craftingInvCtrl == nil then return nil end
            local craftingInvCtrlControl = craftingInvCtrl.control or nil
            if craftingInvCtrlControl == nil then return nil end
            local infoBar = craftingInvCtrlControl:GetNamedChild("InfoBar")
            --Now call update function
            if infoBar ~= nil then
                UpdateInventorySlots(infoBar)
            end
        end
    end
end

--Check if a game scene is shown
function util.IsSceneShown(sceneName)
--d("[AF]util.IsSceneShown, sceneName: " ..tostring(sceneName))
    if sceneName == nil then return false end
    local currentSceneName = SCENE_MANAGER.currentScene.name
--d(">currentSceneName: " .. tostring(currentSceneName))
    if currentSceneName ~= nil and currentSceneName == sceneName then
        return true
    end
    return false
end

--Check if a LibFilters-2.0 filterPanelId (or a related control) is shown
function util.IsFilterPanelShown(libFiltersFilterPanelId)
--d("[AF]IsFilterPanelShown: " ..tostring(libFiltersFilterPanelId))
    if libFiltersFilterPanelId == nil then return false end
    local controlInventory = controlsForChecks.invList
    local controlVendorBuy = controlsForChecks.storeWindow
    local controlVendorBuyback = controlsForChecks.buyBackList
    local controlVendorRepair = controlsForChecks.repairWindow
    local controlBankDeposit = controlsForChecks.bankBackpack
    local controlGuildBankDeposit = controlsForChecks.guildBankBackpack
    local controlGuildStoreSell = controlsForChecks.guildStoreSellBackpack
    local scenesForChecks = AF.scenesForChecks
    local sceneNameStoreVendor = scenesForChecks.storeVendor
    local sceneNameBankDeposit = scenesForChecks.bank
    local sceneNameGuildBankDeposit = scenesForChecks.guildBank
    local sceneNameGuildStoreSell = scenesForChecks.guildStoreSell
    local filterPanelId2TrueControl = {
        [LF_VENDOR_BUY]         = function() return not controlVendorBuy:IsHidden() and controlInventory:IsHidden() and controlVendorBuyback:IsHidden() and controlVendorRepair:IsHidden() or false end,
        [LF_VENDOR_SELL]        = function() return controlVendorBuy:IsHidden() and not controlInventory:IsHidden() and controlVendorBuyback:IsHidden() and controlVendorRepair:IsHidden() or false end,
        [LF_VENDOR_BUYBACK]     = function() return controlVendorBuy:IsHidden() and controlInventory:IsHidden() and not controlVendorBuyback:IsHidden() and controlVendorRepair:IsHidden() or false end,
        [LF_VENDOR_REPAIR]      = function() return controlVendorBuy:IsHidden() and controlInventory:IsHidden() and controlVendorBuyback:IsHidden() and not controlVendorRepair:IsHidden() or false end,
        [LF_BANK_DEPOSIT]       = controlInventory,
        [LF_GUILDBANK_DEPOSIT]  = controlInventory,
        [LF_HOUSE_BANK_DEPOSIT] = controlInventory,
        [LF_GUILDSTORE_SELL]    = controlGuildStoreSell,
    }
    local filterPanelId2FalseControl = {
        [LF_BANK_DEPOSIT]       = controlBankDeposit,
        [LF_GUILDBANK_DEPOSIT]  = controlGuildBankDeposit,
        [LF_HOUSE_BANK_DEPOSIT] = controlBankDeposit,
    }
    local filterPanelId2SceneName = {
        [LF_VENDOR_BUY]         = sceneNameStoreVendor,
        [LF_VENDOR_SELL]        = sceneNameStoreVendor,
        [LF_VENDOR_BUYBACK]     = sceneNameStoreVendor,
        [LF_VENDOR_REPAIR]      = sceneNameStoreVendor,
        [LF_BANK_DEPOSIT]       = sceneNameBankDeposit,
        [LF_GUILDBANK_DEPOSIT]  = sceneNameGuildBankDeposit,
        [LF_HOUSE_BANK_DEPOSIT] = sceneNameBankDeposit,
        [LF_GUILDSTORE_SELL]    = sceneNameGuildStoreSell,
    }
    local goOn = true
    local trueSceneName = filterPanelId2SceneName[libFiltersFilterPanelId] or nil
    --Check if a scene needs to be checked
    if trueSceneName ~= nil then
        goOn = false
        --Check the active scene
        if util.IsSceneShown(trueSceneName) then
            goOn = true
        else
            --No scene found but needs one. Abort!
            return false
        end
    end
    --Scene was checked, shall we go on?
    if not goOn then return false end
    --Check if a control needs to be shown
    goOn = false
    local trueControl
    local trueControlCheck = filterPanelId2TrueControl[libFiltersFilterPanelId] or nil
    if trueControlCheck ~= nil then
        if type(trueControlCheck) == "function" then
            trueControl = trueControlCheck() or false
        elseif type(trueControlCheck) == "boolean" then
            trueControl = trueControlCheck or false
        else
            trueControl = trueControlCheck.IsHidden ~= nil and not trueControlCheck:IsHidden() or false
        end
    end
    if trueControl ~= nil and trueControl == true then
        goOn = true
    else
        --Control(s) must be shown but isn't? Abort!
        return false
    end
    --True control was checked, shall we go on?
    if not goOn then return false end
    --Check if a control needs to be hidden
    goOn = false
    local falseControl
    local falseControlCheck = filterPanelId2FalseControl[libFiltersFilterPanelId] or nil
    if falseControlCheck ~= nil then
        if type(falseControlCheck) == "function" then
            falseControl = falseControlCheck() or nil
        elseif type(trueControlCheck) == "boolean" then
            trueControl = falseControlCheck or nil
        else
            if falseControlCheck.IsHidden ~= nil then
                falseControl = falseControlCheck:IsHidden() or nil
            end
        end
    end
    if falseControlCheck ~= nil and (falseControl == nil or falseControl == false) then
        --Control must be hidden but isn't? Abort!
        return false
    --else
    --    goOn = true
    end
    --False control was checked, shall we go on?
    --if not goOn then return false end
    --Panel was determined via scene name, true and/or false control!
    return true
end

function util.CheckIfNoSubfilterBarShouldBeShown(currentFilter)
    local abort = false
    --Is the stable vendor shown? Abort, as there are no subfilter bars
    if currentFilter == ITEMFILTERTYPE_COLLECTIBLE and SCENE_MANAGER:GetCurrentScene() == STABLES_SCENE then abort = true end
    return abort
end

--Checks if other addons have registered filter functions which should be run on util.RefreshSubfilterBar as well
--to check if the subfilter bar button should be greyed out.
-->Will return true if no other addons have registered any filters for the inventoryType, craftingType and filterType
function util.CheckIfOtherAddonsProvideSubfilterBarRefreshFilters(slotData, inventoryType, craftingType, libFiltersPanelId)
    if slotData == nil or slotData.bagId == nil or slotData.slotIndex == nil
        or inventoryType == nil or craftingType == nil or libFiltersPanelId == nil then return true end
--d("[AF]util.CheckIfOtherAddonsProvideSubfilterBarRefreshFilters, inventoryType: " ..tostring(inventoryType) .. ", craftingType: " .. tostring(craftingType) .. ", libFiltersPanelId: " .. tostring(libFiltersPanelId))
    --AF.SubfilterRefreshCallbacks contain the externally registered filters, from other addons, for the refresh of subfilterBars
    local subfilterRefreshCallbacks
    if AF.SubfilterRefreshCallbacks == nil or AF.SubfilterRefreshCallbacks[inventoryType] == nil
        or AF.SubfilterRefreshCallbacks[inventoryType][craftingType] == nil or AF.SubfilterRefreshCallbacks[inventoryType][craftingType][libFiltersPanelId] == nil then return true end
    subfilterRefreshCallbacks = AF.SubfilterRefreshCallbacks[inventoryType][craftingType][libFiltersPanelId]
    if subfilterRefreshCallbacks == nil then return true end
    local retVar = true
    for externalAddonName, callbackFunc in pairs(subfilterRefreshCallbacks) do
        if callbackFunc ~= nil and type(callbackFunc) == "function" then
            local callbackFuncResult = callbackFunc(slotData)
--d(">[AF]RefreshSubFilterbar, externalAddonName: " .. tostring(externalAddonName) .. ", result: " ..tostring(callbackFuncResult))
            retVar = callbackFuncResult
            if retVar == false then return false end
        end
    end
    return retVar
end

--Update the crafting table's inventory item count etc. from external addons
function util.UpdateCraftingInventoryFilteredCount(invType)
--d("[AF]util.UpdateCraftingInventoryFilteredCount - invType: " ..tostring(invType))
    util.updateInventoryInfoBarCountLabel(invType, nil, true)
end
