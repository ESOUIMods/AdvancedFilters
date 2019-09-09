--ToDo:07.09.2019
--Max todos: #12

--______________________________________________________________________________________________________________________
--                                                  TODO
--______________________________________________________________________________________________________________________
--#10: 2019-08-16 - feature - Baertram
--Move the dropdown filter boxes from the subFilter buttons to a table containing the possible LibFiltes filterPanelIds
--for the submenu button. e.g. Move dropdown filter box of subFilter button Armor->All in the inventory to subFilter button
--Armor->All->LF_INVENTORY and also add LF_MAIL_SEND and LF_PLAYER_TRADE etc. so the dropdown boxes remember their filters
--differently for each active filterPanlId

--#11 2019-09-05 - bug - Bank withdraw panel shows all items but subfilterbar button "..." is enabled (after reopening the bank)
--

--#12 2019-09-07 - bug - Quality filter resets to All after reopenign the inventory or changing tabs
--Sorry to bother Beatram, but is there an update on a fix for the bag filter organizing?
--I set it to quality and still reverts back after changing tabs or reopening the inventory.

--______________________________________________________________________________________________________________________
--                                                  FIXED
--______________________________________________________________________________________________________________________


--______________________________________________________________________________________________________________________
--                                                  NOT REPLICABLE
--______________________________________________________________________________________________________________________
--Not replicable 2019-08-11
--1. Error message on PTS if opening the Enchanting table:
--[[
local subfilterBar = subfilterGroup[craftingType][currentFilter]
-subfilterBar was missing somehow-

user:/AddOns/AdvancedFilters/main.lua:213: attempt to index a nil value
stack traceback:
user:/AddOns/AdvancedFilters/main.lua:213: in function 'ShowSubfilterBar'
|caaaaaa<Locals> craftingType = 3, UpdateListAnchors = user:/AddOns/AdvancedFilters/main.lua:165, doDebugOutput = false, subfilterGroup = tbl </Locals>|r
user:/AddOns/AdvancedFilters/util.lua:732: in function 'Update'
]]

--Not replicable 2019-08-11
--2. Error message upon doing something at crafting station (User: Phuein)
--[[
-subfilterBar was missing somehow-
-> local subfilterBar = subfilterGroup[craftingType][currentFilter]

https://imgur.com/7btGZff
user:/AddOns/AdvancedFilters/main.lua:213 attempt o index a nil value, craftingType = 1
]]


AdvancedFilters = AdvancedFilters or {}
local AF = AdvancedFilters

local debugSpam = AF.debugSpam

--Constants in local variables
local controlsForChecks = AF.controlsForChecks
local smithingVar = controlsForChecks.smithing
local enchantingVar = controlsForChecks.enchanting
local retraitVar = controlsForChecks.retrait
--local functions for speedup
local util = AF.util
local RefreshSubfilterBar                   = util.RefreshSubfilterBar
local GetCraftingType                       = util.GetCraftingType
local ThrottledUpdate                       = util.ThrottledUpdate
local CheckIfNoSubfilterBarShouldBeShown    = util.CheckIfNoSubfilterBarShouldBeShown
local UpdateCurrentFilter                   = util.UpdateCurrentFilter
local GetInventoryFromCraftingPanel         = util.GetInventoryFromCraftingPanel
local IsCraftingStationInventoryType        = util.IsCraftingStationInventoryType
local IsCraftingPanelShown                  = util.IsCraftingPanelShown

local function delayedCall(delay, functionToCall, params)
    if functionToCall then
        delay = delay or 0
        zo_callLater(function() functionToCall(params) end, delay)
    end
end

function AF.showChatDebug(functionName, chatOutputVars)
    local functionNameStr = tostring(functionName) or "n/a"
    functionNameStr = " " .. functionNameStr
    chatOutputVars = chatOutputVars or ""
    --Center screen annonucenment
    local csaText
    if AF.strings and AF.strings["errorCheckChatPlease"] then
        csaText = AF.strings["errorCheckChatPlease"]
    else
        csaText = "|cFF0000[AdvancedFilters ERROR]|r Please read the error message in the chat!"
    end
    if csaText ~= "" then
        local params = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.GROUP_KICK)
        params:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_DISPLAY_ANNOUNCEMENT)
        params:SetText(csaText)
        CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(params)
    end

    --Chat output
    d(">====================================>")
    d("[AdvancedFilters - |cFF0000ERROR|r]" .. "|c00ccff" .. tostring(functionNameStr) .. "|r")
    d("!> Please answer the following 4 questions and send the answers (and if given: the variables shown in the lines, starting with ->, after the questions) to the addon's comments of AdvancedFilters @www.esoui.com:\nhttps://bit.ly/2IlJ56J")
    d("1) What did you do?\n2)Where did you do it?\n3)Did you test if the error happenes with only the addon AdvancedFilters UPDATED activated (please test this!)?\n4)If error happens with other addons active: Which other addons were you using as the error happened?")
    if chatOutputVars ~= "" then
        d("-> " .. chatOutputVars)
    end
    d("Thank you very much for your invested time and the will to fix this addon!")
    d("<====================================<")
end
local showChatDebug = AF.showChatDebug

local function InitializeHooks()
    AF.blockOnInventoryFilterChangedPreHookForCraftBag = false

    --TABLE TRACKER
    --[[
        this is a hacky way of knowing when items go in and out of an inventory.

        t = the tracked table (ZO_InventoryManager.isListDirty/PLAYER_INVENTORY.isListDirty)
        k = inventoryType
        v = isDirty
        pk = private key (no two empty tables are the same) where we store t
        mt = our metatable where we can do the tracking
    ]]
    --create private key
    local pk = {}
    --create metatable
    local mt = {
        __index = function(t, k)
            --d("*access to element " .. tostring(k))

            --access the tracked table
            return t[pk][k]
        end,
        __newindex = function(t, k, v)
            --d("*update of element " .. tostring(k) .. " to " .. tostring(v))

            --update the tracked table
            t[pk][k] = v

            --refresh subfilters for inventory type
            local subfilterGroup = AF.subfilterGroups[k]
            if not subfilterGroup then return end
            local craftingType = GetCraftingType()
            local invType = AF.currentInventoryType
            local currentSubfilterBar = subfilterGroup.currentSubfilterBar
            if not currentSubfilterBar then return end
            local RefreshSubfilterBarUpdaterName = "RefreshSubfilterBarMetaTable_" .. invType .. "_" .. craftingType .. currentSubfilterBar.name
            if debugSpam then
                d("[AF]Metatable proxy: Calling ThrottledUpdate: " ..tostring(RefreshSubfilterBarUpdaterName))
            end
            ThrottledUpdate(RefreshSubfilterBarUpdaterName,
                    10, RefreshSubfilterBar, currentSubfilterBar)
        end,
    }
    --tracking function. Returns a proxy table with our metatable attached.
    local function track(t)
        local proxy = {}
        proxy[pk] = t
        setmetatable(proxy, mt)
        return proxy
    end
    --untracking function. Returns the tracked table and destroys the proxy.
    local function untrack(proxy)
        local t = proxy[pk]
        proxy = nil
        return t
    end

    --As some inventories/panels use the same parents to anchor the subfilter bars to
    --the change of the panel won't change the parent and thus doesn't hide the subfilter
    --bars properly.
    --Example: ENCHANTING creation & extraction, deconstruction/improvement for woodworking/blacksmithing/clothing & jewelry deconstruction/improvement
    --This function checks the inventory type and hides the old subfilterbar if needed.
    local function hideSubfilterBarSameParent(inventoryType)
        if debugSpam then
            d("[AF]hideSubfilterBarSameParent - inventoryType: " .. inventoryType)
        end
        if not inventoryType then return end
        local mapInvTypeToInvTypeBefore = AF.mapInvTypeToInvTypeBefore
        if not mapInvTypeToInvTypeBefore then return end
        if mapInvTypeToInvTypeBefore[inventoryType] == nil then return false end
        local invTypeBefore = mapInvTypeToInvTypeBefore[inventoryType]
        if not invTypeBefore then return end
        local subfilterGroupBefore = AF.subfilterGroups[invTypeBefore]
        if subfilterGroupBefore ~= nil and subfilterGroupBefore.currentSubfilterBar then
            subfilterGroupBefore.currentSubfilterBar:SetHidden(true)
        end
    end

    --Show the subfilter abr of AdvancedFilters below the parent filter (e.g. button for armor, weapons, material, ...)
    --The subfilter bars are defined via the file constants.lua in table "subfilterGroups".
    --The contents of the subfilter bars are defined in file constants.lua in table "subfilterButtonNames"
    --The filter contents and their callback functions (see top of file data.lua) for each content of the subfilter bar are defined in file data.lua in the table "AF.subfilterCallbacks"
    --Their parents (e.g. the player inventory or the bank or the crafting smithing station) are defined in file constants.lua in table "filterBarParents"
    local function ShowSubfilterBar(currentFilter, craftingType, customInventoryFilterButtonsItemType)
        if debugSpam then d("-----------------------------------------------") end
        --Update the y offsetts in pixels for the subfilter bar, so it is shown below the parent's filter buttons
        local function UpdateListAnchors(self, shiftY, p_subFilterBar)
            if debugSpam then d(">UpdateListAnchors - shiftY: " .. tostring(shiftY)) end
            if self == nil then return end
            local layoutData = self.appliedLayout or BACKPACK_DEFAULT_LAYOUT_FRAGMENT.layoutData
            if not layoutData then return end
            local invTypeUpdateListAnchor = AF.currentInventoryType
            local list = self.list or (self.inventories ~= nil and self.inventories[invTypeUpdateListAnchor].listView)
            if not list then
                local moveInvBottomBarDown
                local anchorTo = (p_subFilterBar and p_subFilterBar.control) or nil
                list, moveInvBottomBarDown = util.GetListControlForSubfilterBarReanchor(AF.currentInventoryType)
                if not list then return end
                list:SetWidth(layoutData.width)
                list:ClearAnchors()
                list:SetAnchor(TOPLEFT, anchorTo, BOTTOMLEFT, 0, 0)
                --Move the inventory's bottom bar more down?
                if moveInvBottomBarDown then
                    --Do not move the bar if the addon PerfectPixel is active as it was moved already
                    if not PP then
                        moveInvBottomBarDown:ClearAnchors()
                        moveInvBottomBarDown:SetAnchor(TOPLEFT, list:GetParent(), BOTTOMLEFT, 0, shiftY)
                        moveInvBottomBarDown:SetAnchor(BOTTOMRIGHT)
                    end
                end
            else
                list:SetWidth(layoutData.width)
                list:ClearAnchors()
                list:SetAnchor(TOPRIGHT, nil, TOPRIGHT, 0, layoutData.backpackOffsetY + shiftY)
                list:SetAnchor(BOTTOMRIGHT)
                ZO_ScrollList_SetHeight(list, list:GetHeight())
            end

            local sortBy = self.sortHeaders or self.sortHeaderGroup
            if sortBy == nil and self.GetDisplayInventoryTable then sortBy = self:GetDisplayInventoryTable(invTypeUpdateListAnchor).sortHeaders end
            if sortBy == nil then return end
            sortBy = sortBy.headerContainer
            sortBy:ClearAnchors()
            sortBy:SetAnchor(TOPRIGHT, nil, TOPRIGHT, 0, layoutData.sortByOffsetY + shiftY)

            --Should something else be moved or re-anchored (e.g. at the research panel the horizontal scroll list part)
            --AF.util.ReAnchorControlsForSubfilterBar(self, shiftY, p_currentFilter, p_craftingType)
        end
        local invType = AF.currentInventoryType

        --Check for custom added inventory filter button
        if not customInventoryFilterButtonsItemType then
            --CraftBag
            if invType == INVENTORY_CRAFT_BAG then
                local afCBCurrentFilter = AF.craftBagCurrentFilter
                if debugSpam then
                    d("[AF]ShowSubfilterBar craftbag, currentFilter: " .. tostring(currentFilter) .. ", afCBCurrentFilter: " .. tostring(afCBCurrentFilter))
                end
                if afCBCurrentFilter and afCBCurrentFilter ~= ITEMFILTERTYPE_ALL and afCBCurrentFilter == currentFilter then
                    --Set prevention variable for function ShowSubfilterBar at the craftbag.

                    --Check if the currentFilter variable changed to 0 () now (Which happens if we opened the guild store after the craftbagm and reopening the craftbag now.
                    --See issue 7 at AdvancedFilters github:  https://github.com/Randactyl/AdvancedFilters/issues/7
                    local currentCBFilter = PLAYER_INVENTORY.inventories[INVENTORY_CRAFT_BAG].currentFilter
                    --d(">currentCBFilter: " .. tostring(currentCBFilter))
                    if currentCBFilter == ITEMFILTERTYPE_ALL then
                        --The currentfilter reset, so we need to set it to the last known value again now
                        PLAYER_INVENTORY.inventories[INVENTORY_CRAFT_BAG].currentFilter = afCBCurrentFilter
                        currentFilter = afCBCurrentFilter
                    end
                end
            end
        end
        --Is the filterType of the current menuBar button a custom addon filter function or filterType?
        local currentFilterToUse = customInventoryFilterButtonsItemType or currentFilter
        if craftingType == nil then craftingType = GetCraftingType() end
        if debugSpam then d("[AF]]ShowSubfilterBar - currentFilter: " .. tostring(currentFilter) .. ", craftingType: " .. tostring(craftingType) .. ", invType: " .. tostring(invType) .. ", customInventoryFilterButtonsItemType: " ..tostring(customInventoryFilterButtonsItemType)) end
        --[[
            --Guild store?
            if currentFilter == ITEMFILTERTYPE_TRADING_HOUSE then
    --d(">GuildStore itemfiltertype found!")
                --Set the "block inventory filter prehook" variable
                AF.blockOnInventoryFilterChangedPreHookForCraftBag = true
            else
    --d(">NO GuildStore itemfiltertype found!")
                AF.blockOnInventoryFilterChangedPreHookForCraftBag = false
            end
        ]]
        --Error handling: Hiding old subfilter bar
        -- e.g. for missing variables, or if other addons might have changed the currentFilter or currentInventoryType (indirectly by their stuff -> loadtime was increased -> filter change did not happen in time for AF due to this)
        local doDebugOutput = AF.settings.doDebugOutput
        local subfilterGroupMissingForInvType = false
        local subfilterBarMissing = false
        if doDebugOutput then
            local showErrorInChat = false
            if invType == nil then
                showErrorInChat = true
            end
            if AF.subfilterGroups[invType] == nil then
                showErrorInChat = true
                subfilterGroupMissingForInvType = true
            end
            if currentFilterToUse == nil then
                showErrorInChat = true
            end
            if craftingType == nil then
                showErrorInChat = true
            end
            if invType ~= nil and craftingType ~= nil and currentFilterToUse ~= nil then
                local nextSubfilterBar = AF.subfilterGroups[invType][craftingType][currentFilterToUse]
                if nextSubfilterBar == nil then
                    subfilterBarMissing = true
                    showErrorInChat = true
                end
            end
            --Show a debug message now and abort here?
            if showErrorInChat and AF.subFiltersBarInactive[currentFilterToUse] == nil then
                showChatDebug("ShowSubfilterBar - BEGIN", "InventoryType: " ..tostring(invType) .. ", craftingType: " ..tostring(craftingType) .. "/" .. util.GetCraftingType() .. ", currentFilter: " .. tostring(currentFilterToUse) .. ", subFilterGroupMissing: " ..tostring(subfilterGroupMissingForInvType) .. ", subfilterBarMissing: " ..tostring(subfilterBarMissing))
                return false
            end
        end

        --Get the old subfilterbar + the new subfilterbar group data
        local subfilterGroup = AF.subfilterGroups[invType]
        --hide old bar, if it exists
        if subfilterGroup.currentSubfilterBar ~= nil then
            subfilterGroup.currentSubfilterBar:SetHidden(true)
        end
        --hide old bar at same parent
        hideSubfilterBarSameParent(invType)
        --Old subfilterbar(s) was(were) hidden, so check if a new one should be shown now
        if CheckIfNoSubfilterBarShouldBeShown(currentFilterToUse, invType) then
            if debugSpam then d(">ABORT: CheckIfNoSubfilterBarShouldBeShown: true") end
            return
        end
        --do nothing if we're in a guild store and regular filters are disabled.
        if not ZO_TradingHouse:IsHidden() and util.libCIF._guildStoreSellFiltersDisabled then
            --d("[AF]Trading house libCIF:guildSToreSellFiltersDisabled!")
            return
        end

        --Get the new subFilterBar to show
        local subfilterBarBase = subfilterGroup[craftingType]
        if subfilterBarBase == nil then
            showChatDebug("ShowSubfilterBar - SubFilterBarBase missing", "InventoryType: " ..tostring(invType) .. ", craftingType: " ..tostring(craftingType) .. "/" .. util.GetCraftingType() .. ", currentFilter: " .. tostring(currentFilterToUse) .. ", subFilterGroupMissing: " ..tostring(subfilterGroupMissingForInvType) .. ", subfilterBarMissing: " ..tostring(subfilterBarMissing))
            return
        end
        local subfilterBar = subfilterBarBase[currentFilterToUse]
        if subfilterBar == nil and AF.subFiltersBarInactive[currentFilterToUse] == nil then
            --SubfilterBar is nil but maybe we do not need any like at the inventory quest items?
            if currentFilterToUse ~= nil and AF.subFiltersBarInactive[currentFilterToUse] == nil then
                showChatDebug("ShowSubfilterBar - SubFilterBar missing", "InventoryType: " ..tostring(invType) .. ", craftingType: " ..tostring(craftingType) .. "/" .. util.GetCraftingType() .. ", currentFilter: " .. tostring(currentFilterToUse) .. ", subFilterGroupMissing: " ..tostring(subfilterGroupMissingForInvType) .. ", subfilterBarMissing: " ..tostring(subfilterBarMissing))
                return
            end
        end

        --if new bar exists
        local craftingInv
        local isCraftingInventoryType = false
        if subfilterBar then
            --Crafting
            if IsCraftingPanelShown() then
                isCraftingInventoryType = IsCraftingStationInventoryType(subfilterBar.inventoryType)
                if isCraftingInventoryType then
                    craftingInv = GetInventoryFromCraftingPanel(subfilterBar.inventoryType)
                end
            end
            --set current bar reference
            subfilterGroup.currentSubfilterBar = subfilterBar
            if debugSpam then
                d(">subfilterBar exists, name: " .. tostring(subfilterBar.control:GetName()) .. ",  inventoryType: " ..tostring(subfilterBar.inventoryType))
            end
            --Update the currentFilter to the current inventory
            UpdateCurrentFilter(subfilterBar.inventoryType, currentFilter, isCraftingInventoryType, craftingInv)
            --activate current subfilter bar's button
            subfilterBar:ActivateButton(subfilterBar:GetCurrentButton())
            --show the new subfilter bar
            subfilterBar:SetHidden(false)
            --set proper inventory anchor displacement
            if subfilterBar.inventoryType == INVENTORY_TYPE_VENDOR_BUY then
                UpdateListAnchors(STORE_WINDOW, subfilterBar.control:GetHeight(), subfilterBar)
            elseif isCraftingInventoryType then
                UpdateListAnchors(craftingInv, subfilterBar.control:GetHeight(), subfilterBar)
            else
                UpdateListAnchors(PLAYER_INVENTORY, subfilterBar.control:GetHeight(), subfilterBar)
            end
        else
            --Crafting
            if IsCraftingPanelShown() then
                isCraftingInventoryType = IsCraftingStationInventoryType(invType)
                if isCraftingInventoryType then
                    craftingInv = GetInventoryFromCraftingPanel(invType)
                end
            end
            --Update the currentfilter to the inventory so it will be the correct one (e.g. if you change after this "return false" below to teh CraftBag and back to teh inventory,
            --the currentFilter will be the wrong one from before, and thus the subfilterbar of the before filter wil be shown at this currentFilter.
            --Update the currentFilter to the current inventory
            UpdateCurrentFilter(invType, currentFilter, isCraftingInventoryType, craftingInv)
            --remove all filters
            util.RemoveAllFilters()
            --set original inventory anchor displacement
            if invType == INVENTORY_TYPE_VENDOR_BUY then
                UpdateListAnchors(STORE_WINDOW, 0)
            elseif isCraftingInventoryType then
                UpdateListAnchors(craftingInv, 0)
            else
                UpdateListAnchors(PLAYER_INVENTORY, 0)
            end
            --remove current bar reference
            subfilterGroup.currentSubfilterBar = nil
            --Error handling: Showing new subfilter bar
            if doDebugOutput then
                if currentFilterToUse == nil or (currentFilterToUse ~= nil and AF.subFiltersBarInactive[currentFilterToUse] == nil) then
                    showChatDebug("ShowSubfilterBar - END", "InventoryType: " ..tostring(invType) .. ", craftingType: " ..tostring(craftingType) .. "/" .. util.GetCraftingType() .. ", currentFilter: " .. tostring(currentFilterToUse))
                end
            end
        end
    end

------------------------------------------------------------------------------------------------------------------------
    --PREHOOKS
    --Filter changing function for normal inventories
    --Recognizes if a button like armor/weapons/material/... was changed at the inventory (which is a filter change internally)
    local function ChangeFilterInventory(self, filterTab)
        --AF.filterTab = filterTab
        local tabInvType = filterTab.inventoryType
        local currentInvType = AF.currentInventoryType
        local currentFilter = self:GetTabFilterInfo(tabInvType, filterTab)
        if debugSpam then
            d("=====================================================================>")
            d("[AF]PLAYER_INVENTORY:ChangeFilter, tabInvType: " ..tostring(tabInvType) .. ", curInvType: " .. tostring(currentInvType) .. ", currentFilter: " .. tostring(currentFilter))
        end
        --CraftBag
        if currentInvType == INVENTORY_CRAFT_BAG and AF.blockOnInventoryFilterChangedPreHookForCraftBag then
            if debugSpam then
                d("-----> CraftBag: PreHook is blocked. ABORT!")
            end
            AF.blockOnInventoryFilterChangedPreHookForCraftBag = false
            return false
        end
        --Check if currentFilter is a function and then try to resolve the real filtervalue below it
        local customInventoryFilterButtonsItemType = util.CheckForCustomInventoryFilterBarButton(currentInvType, currentFilter)
        if customInventoryFilterButtonsItemType then
            if debugSpam then d("[AF]ChangeFilterInventory-Found custom inventory: " .. tostring(customInventoryFilterButtonsItemType)) end
        end
        if currentInvType ~= INVENTORY_TYPE_VENDOR_BUY then
            ThrottledUpdate("ShowSubfilterBar" .. currentInvType, 10, ShowSubfilterBar, currentFilter, nil, customInventoryFilterButtonsItemType)
        end
        --Update the total count for quest items as there are no epxlicit filterBars available until today!
        local currentFilterToCheck = customInventoryFilterButtonsItemType or currentFilter
        local inactiveSubFilterBarInventoryType = AF.subFiltersBarInactive[currentFilterToCheck] or nil
        if inactiveSubFilterBarInventoryType ~= nil and inactiveSubFilterBarInventoryType ~= false then
            if debugSpam then d(">inactiveSubFilterBarInventoryType: " ..tostring(inactiveSubFilterBarInventoryType) .. ", curInvType: " .. tostring(currentInvType) .. ", tabInvType: " ..tostring(tabInvType) .. ", currentFilterToCheck: " ..tostring(currentFilterToCheck)) end
            --Compare the inventory tab's inventoryType with the inactive inventoryType, and
            --set the inventory to update accordingly
            local invType
            if tabInvType == inactiveSubFilterBarInventoryType then
                invType = inactiveSubFilterBarInventoryType
            else
                invType = currentInvType
            end
            --Update the count of filtered/shown items in the inventory FreeSlot label
            --Delay this function call as the data needs to be filtered first!
            ThrottledUpdate("RefreshItemCount_" .. invType,
                    50, util.updateInventoryInfoBarCountLabel, invType, false)
        end
    end
    ZO_PreHook(PLAYER_INVENTORY, "ChangeFilter", ChangeFilterInventory)

    --[[
    --  Seems to not be needed anymore here as the normal inventory's function ChangeFilter is executed for "vendor sell" panels!
        local function ChangeFilterVendor(self, filterTab)
    --d("[AF]ChangeFilterVendor")
            local currentFilter = filterTab.filterType
            if CheckIfNoSubfilterBarShouldBeShown(currentFilter) then return end

            ThrottledUpdate("ShowSubfilterBar" .. tostring(INVENTORY_TYPE_VENDOR_BUY), 10, ShowSubfilterBar,
              currentFilter)
            local invType = INVENTORY_TYPE_VENDOR_BUY -- AF.currentInventoryType
            local subfilterGroup = AF.subfilterGroups[invType]
            if not subfilterGroup then return end
            local craftingType = GetCraftingType()
            local currentSubfilterBar = subfilterGroup.currentSubfilterBar
            if not currentSubfilterBar then return end

            ThrottledUpdate("RefreshSubfilterBar" .. invType .. "_" .. craftingType .. currentSubfilterBar.name, 10,
              RefreshSubfilterBar, currentSubfilterBar)
    end
    ZO_PreHook(STORE_WINDOW, "ChangeFilter", ChangeFilterVendor)
    ]]

    --Filter changing function for crafting stations and retrait station.
    --Recognizes if a button like armor/weapons was changed at the crafting station (which is a filter change internally)
    local function ChangeFilterCrafting(self, filterData)
        local invType = AF.currentInventoryType
        local craftingType = GetCraftingType()
        local filter = self.filterType or self.typeFilter
        local currentFilter = util.MapCraftingStationFilterType2ItemFilterType(filter, invType, craftingType)
        --Is the filterType of the current menuBar button a custom addon filter function or filterType?
        --Then try to resolve the real filtervalue below it
        local customInventoryFilterButtonsItemType = util.CheckForCustomInventoryFilterBarButton(AF.currentInventoryType, currentFilter)
        if customInventoryFilterButtonsItemType then
            if debugSpam then d("[AF]ChangeFilterCrafting-Found custom inventory: " .. tostring(customInventoryFilterButtonsItemType)) end
        end
        if debugSpam then
            d("=====================================================================>")
            d("[AF]ChangeFilterCrafting, invType: " .. tostring(invType) .. ", craftingType: " .. tostring(craftingType) .. ", filterType: " ..  tostring(filter) .. ", currentFilter: " .. tostring(currentFilter))
        end
        ThrottledUpdate("ShowSubfilterBar" .. invType .. "_" .. craftingType, 10,
                ShowSubfilterBar, currentFilter, craftingType, customInventoryFilterButtonsItemType)

        local subfilterGroup = AF.subfilterGroups[invType]
        if not subfilterGroup then return end
        zo_callLater(function()
            local currentSubfilterBar = subfilterGroup.currentSubfilterBar
            if not currentSubfilterBar then return end
            ThrottledUpdate("RefreshSubfilterBar" .. invType .. "_" .. craftingType .. currentSubfilterBar.name, 10,
                    RefreshSubfilterBar, currentSubfilterBar)
        end, 50)
    end
    --ZO_PreHook(smithingVar.creationPanel, "ChangeTypeFilter", changeFilterCraftingNew)
    ZO_PreHook(smithingVar.refinementPanel.inventory,       "ChangeFilter",     function(...) delayedCall(10, ChangeFilterCrafting, ...) end)
    ZO_PreHook(smithingVar.deconstructionPanel.inventory,   "ChangeFilter",     function(...) delayedCall(10, ChangeFilterCrafting, ...) end)
    ZO_PreHook(smithingVar.improvementPanel.inventory,      "ChangeFilter",     function(...) delayedCall(10, ChangeFilterCrafting, ...) end)
    ZO_PreHook(smithingVar.researchPanel,                   "ChangeTypeFilter", function(...) delayedCall(10, ChangeFilterCrafting, ...) end)
    ZO_PreHook(retraitVar.retraitPanel.inventory,           "ChangeFilter",     function(...) delayedCall(10, ChangeFilterCrafting, ...) end)


    local function ChangeFilterEnchanting(self, filterTab)
        zo_callLater(function()
            local invType = AF.currentInventoryType
            local craftingType = GetCraftingType()
            local currentFilter = util.MapCraftingStationFilterType2ItemFilterType(self.owner.enchantingMode, invType, craftingType)
            --Check if currentFilter is a function and then try to resolve the real filtervalue below it
            local customInventoryFilterButtonsItemType = util.CheckForCustomInventoryFilterBarButton(AF.currentInventoryType, currentFilter)
            if customInventoryFilterButtonsItemType then
                if debugSpam then d("[AF]ChangeFilterCrafting-Found custom inventory: " .. tostring(customInventoryFilterButtonsItemType)) end
            end
            if debugSpam then
                d("=====================================================================>")
                d("[AF]ChangeFilterEnchanting - currentFilter: " ..tostring(currentFilter) .. ", currentInventoryType: " .. tostring(invType) .. ", craftingType: " ..tostring(craftingType))
            end
            --Only show subfilters at the enchanting extraction panel
            ThrottledUpdate("ShowSubfilterBar" .. invType .. "_" .. craftingType, 10,
                    ShowSubfilterBar, currentFilter, craftingType, customInventoryFilterButtonsItemType)
            zo_callLater(function()
                local subfilterGroup = AF.subfilterGroups[invType]
                if not subfilterGroup then return end
                local currentSubfilterBar = subfilterGroup.currentSubfilterBar
                if not currentSubfilterBar then return end
                ThrottledUpdate("RefreshSubfilterBar" .. invType .. "_" .. craftingType .. currentSubfilterBar.name, 10,
                        RefreshSubfilterBar, currentSubfilterBar)
            end, 50)
        end, 10) -- called with small delay, otherwise self.filterType is nil
    end
    ZO_PreHook(enchantingVar.inventory, "ChangeFilter", ChangeFilterEnchanting)


    --FRAGMENT HOOKS
    local function hookFragment(fragment, inventoryType)
        local function onFragmentShowing()
            AF.currentInventoryType = inventoryType

            if inventoryType == INVENTORY_TYPE_VENDOR_BUY then
                --Check if currentFilter is a function and then try to resolve the real filtervalue below it
                local customInventoryFilterButtonsItemType = util.CheckForCustomInventoryFilterBarButton(AF.currentInventoryType, STORE_WINDOW.currentFilter)
                if customInventoryFilterButtonsItemType then
                    if debugSpam then d("[AF]ChangeFilterCrafting-Found custom inventory: " .. tostring(customInventoryFilterButtonsItemType)) end
                end
                ThrottledUpdate("ShowSubfilterBar" .. inventoryType, 10,
                        ShowSubfilterBar, STORE_WINDOW.currentFilter, nil, customInventoryFilterButtonsItemType)
            else
                -- fragmentType = "Inv"
                local currentFilter = PLAYER_INVENTORY.inventories[inventoryType].currentFilter

                --CraftBag
                if inventoryType == INVENTORY_CRAFT_BAG then
                    --local currentCBFilter = PLAYER_INVENTORY.inventories[INVENTORY_CRAFT_BAG].currentFilter
                    --local afCBCurrentFilter = AF.craftBagCurrentFilter
                    --d("[AF]CraftBag fragment showing, currentFilter: " .. tostring(currentCBFilter) .. ", afCBCurrentFilter: " .. tostring(afCBCurrentFilter))
                    --fragmentType = "CraftBag"
                end
                if debugSpam then
                    d("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~>")
                    d("[AF]hookFragment " .. tostring(fragment.control:GetName()) .. " - fragment OnShow -> ShowSubfilterBar")
                end
                --Check if currentFilter is a function and then try to resolve the real filtervalue below it
                local customInventoryFilterButtonsItemType = util.CheckForCustomInventoryFilterBarButton(AF.currentInventoryType, currentFilter)
                if customInventoryFilterButtonsItemType then
                    if debugSpam then d("[AF]ChangeFilterCrafting-Found custom inventory: " .. tostring(customInventoryFilterButtonsItemType)) end
                end
                ThrottledUpdate("ShowSubfilterBar" .. inventoryType, 10, ShowSubfilterBar, currentFilter, nil, customInventoryFilterButtonsItemType)
            end
            --Call RefreshSubfilterBar via "proxy" metatable function on the inventoryType
            if debugSpam then
                d("---------->Calling RefreshSubfilterBar via 'proxy' function")
            end
            PLAYER_INVENTORY.isListDirty = track(PLAYER_INVENTORY.isListDirty)
        end

        --[[
            local function onFragmentShown()
            end
        ]]
        local function onFragmentHiding()
            PLAYER_INVENTORY.isListDirty = untrack(PLAYER_INVENTORY.isListDirty)
            --CraftBag
            if inventoryType == INVENTORY_CRAFT_BAG then
                AF.craftBagCurrentFilter = PLAYER_INVENTORY.inventories[INVENTORY_CRAFT_BAG].currentFilter
                if debugSpam then d("[AF]CraftBag fragment hiding, currentFilter: " .. tostring(AF.craftBagCurrentFilter)) end
            end
            --Reset the current inventory type to the normal inventory
            AF.currentInventoryType = INVENTORY_BACKPACK
        end

        local function onFragmentStateChange(oldState, newState)
            if newState == SCENE_FRAGMENT_SHOWING then
                AF.fragmentStateHiding[inventoryType] = false
                onFragmentShowing()
                --elseif newState == SCENE_FRAGMENT_SHOWN then
                --onFragmentShown()
            elseif newState == SCENE_FRAGMENT_HIDING then
                AF.fragmentStateHiding[inventoryType] = true
                onFragmentHiding()
            end
        end
        fragment:RegisterCallback("StateChange", onFragmentStateChange)
    end
    hookFragment(INVENTORY_FRAGMENT, INVENTORY_BACKPACK)
    hookFragment(BANK_FRAGMENT, INVENTORY_BANK)
    hookFragment(HOUSE_BANK_FRAGMENT, INVENTORY_HOUSE_BANK)
    hookFragment(GUILD_BANK_FRAGMENT, INVENTORY_GUILD_BANK) -- new value is: 5
    hookFragment(CRAFT_BAG_FRAGMENT, INVENTORY_CRAFT_BAG) -- new value is: 6
    hookFragment(STORE_FRAGMENT, INVENTORY_TYPE_VENDOR_BUY)

    --Hook some scenes to register variables as the scenes show/hide.
    -->Needed to prevent function PLAYER_INVENTORY:ChangeFilter to reset the internal
    -->variables to the normal inventory, if you had the CraftBag opened last in the normal inventory.
    -->See github, issue 7:   https://github.com/Randactyl/AdvancedFilters/issues/7
    local function hookScene(scene, filterPanelId)
        local function onSceneShowing()
            if debugSpam then
                d("???????????????????????????????????????????????>>>")
                d("[AF]Scene showing: " .. tostring(SCENE_MANAGER.currentScene.name))
            end
            --Retrait
            if  filterPanelId == LF_RETRAIT then
                AF.currentInventoryType = LF_RETRAIT
            end
        end
        --[[
            local function onSceneShown()
            end
        ]]
        local function onSceneHiding()
            if debugSpam then
                d("<<<???????????????????????????????????????????????")
                d("[AF]Scene hiding: " .. tostring(SCENE_MANAGER.currentScene.name))
            end
            if filterPanelId then
                if      filterPanelId == LF_MAIL_SEND then
                    --d(">Mail send scene closing!")
                    --Set the "block inventory filter prehook" variable
                    AF.blockOnInventoryFilterChangedPreHookForCraftBag = true
                elseif  filterPanelId == LF_GUILDSTORE_BROWSE or LF_GUILDSTORE_SELL then
                    --d(">GuildStore scene closing!")
                    --Set the "block inventory filter prehook" variable
                    AF.blockOnInventoryFilterChangedPreHookForCraftBag = true
                    --Retrait
                elseif  filterPanelId == LF_RETRAIT then
                    --Reset inventory type to normal backpack
                    AF.currentInventoryType = INVENTORY_BACKPACK
                end
            end
        end

        local function onSceneStateChange(oldState, newState)
            if newState == SCENE_HIDING then
                onSceneHiding()
                --elseif newState == SCENE_SHOWN then
                --onSceneShown()
            elseif newState == SCENE_SHOWING then
                onSceneShowing()
            end
        end
        scene:RegisterCallback("StateChange", onSceneStateChange)
    end
    hookScene(MAIL_SEND_SCENE, LF_MAIL_SEND)
    hookScene(TRADING_HOUSE_SCENE, LF_GUILDSTORE_BROWSE)
    hookScene(KEYBOARD_RETRAIT_ROOT_SCENE , LF_RETRAIT)
    --Vendor, for CraftBagExtended addon as well?

    --Hook the crafting station
    --SMITHING
    local function HookSmithingSetMode(self, mode)
        --[[
            --Smithing modes
            SMITHING_MODE_ROOT = 0
            SMITHING_MODE_REFINMENT = 1
            SMITHING_MODE_CREATION = 2
            SMITHING_MODE_DECONSTRUCTION = 3
            SMITHING_MODE_IMPROVEMENT = 4
            SMITHING_MODE_RESEARCH = 5
            SMITHING_MODE_RECIPES = 6
        ]]
        local craftType = util.GetCraftingType()
        local isJewelryCrafting = (craftType == CRAFTING_TYPE_JEWELRYCRAFTING) or false
        if debugSpam then
            d("....................................................>")
            d("[AF]SMITHING:SetMode - mode: " ..tostring(mode) .. ", craftingType: " ..tostring(craftType))
        end
        if     mode == SMITHING_MODE_REFINEMENT then
            if isJewelryCrafting then
                AF.currentInventoryType = LF_JEWELRY_REFINE
            else
                AF.currentInventoryType = LF_SMITHING_REFINE
            end
        elseif     mode == SMITHING_MODE_CREATION then
            if isJewelryCrafting then
                AF.currentInventoryType = LF_JEWELRY_CREATION
            else
                AF.currentInventoryType = LF_SMITHING_CREATION
            end
        elseif     mode == SMITHING_MODE_DECONSTRUCTION then
            if isJewelryCrafting then
                AF.currentInventoryType = LF_JEWELRY_DECONSTRUCT
            else
                AF.currentInventoryType = LF_SMITHING_DECONSTRUCT
            end
        elseif mode == SMITHING_MODE_IMPROVEMENT then
            if isJewelryCrafting then
                AF.currentInventoryType = LF_JEWELRY_IMPROVEMENT
            else
                AF.currentInventoryType = LF_SMITHING_IMPROVEMENT
            end
        elseif mode == SMITHING_MODE_RESEARCH then
            if isJewelryCrafting then
                AF.currentInventoryType = LF_JEWELRY_RESEARCH
            else
                AF.currentInventoryType = LF_SMITHING_RESEARCH
            end
            --Show the subfilterbar for the research panel now as the function
            --"ChangeFilterCrafting(self, filterData)" will not be called automatically here
            util.ClearResearchPanelCustomFilters()
            ChangeFilterCrafting(self.researchPanel)
        end
        return false
    end
    --ZO_PreHook(ZO_Smithing, "SetMode", HookSmithingSetMode)
    local origSmithingSetMode = ZO_Smithing.SetMode
    ZO_Smithing.SetMode = function(...)
        origSmithingSetMode(...)
        HookSmithingSetMode(...)
    end

    --ENCHANTING
    local function HookEnchantingSetEnchantingMode(self, mode)
        if debugSpam then
            d("....................................................>")
            d("[AF]ENCHANTING:SetEnchantingMode/OnModeUpdated, mode: " .. tostring(mode))
        end
        --[[
            --Enchanting modes
            ENCHANTING_MODE_CREATION = 1
            ENCHANTING_MODE_EXTRACTION = 2
            ENCHANTING_MODE_NONE = 0
        ]]
        if     mode == ENCHANTING_MODE_CREATION then
            AF.currentInventoryType = LF_ENCHANTING_CREATION
        elseif mode == ENCHANTING_MODE_EXTRACTION then
            AF.currentInventoryType = LF_ENCHANTING_EXTRACTION
        end
        return false
    end
    --Multicraft addon breaks this addon! Disable it before you can use AdvancedFilters
    if AF.otherAddons["MultiCraft"] or MultiCraft ~= nil then
        showChatDebug("PostHook ZO_Enchanting OnModeUpdated -> PLEASE DISABLE THE ADDON \'MultiCraft\'!", AF.errorStrings["MultiCraft"])
        return
    end
    --ZO_PreHook(ZO_Enchanting, "SetEnchantingMode", HookEnchantingSetEnchantingMode)
    local origEnchantingSetEnchantMode = ZO_Enchanting.SetEnchantingMode
    if origEnchantingSetEnchantMode ~= nil then
        ZO_Enchanting.SetEnchantingMode = function(...)
            local retVar = origEnchantingSetEnchantMode(...)
            HookEnchantingSetEnchantingMode(...)
            return retVar
        end
    else
        --ZO_Enchanting:SetEnchantingMode does not exist anymore (PTS -> Scalebreaker) and was replaced by ZO_Enchanting:OnModeUpdated()
        origEnchantingSetEnchantMode = ZO_Enchanting.OnModeUpdated
        ZO_Enchanting.OnModeUpdated = function(self, ...)
            origEnchantingSetEnchantMode(self, ...)
            HookEnchantingSetEnchantingMode(self, self.enchantingMode)
        end
    end

    --Retrait
    -->Currently not working via PostHook as SetMode is not called! One needs to use the scene callback for "StateChange" (see further up!)
    local function HookRetraitSetMode(self, mode)
        if debugSpam then
            d("....................................................>")
            d("[AF]ZO_RetraitStation_Keyboard.SetMode - mode: " ..tostring(mode))
        end
        --[[
            --Retrait modes
            ZO_RETRAIT_MODE_ROOT        = 0
            ZO_RETRAIT_MODE_RETRAIT     = 1
        ]]
        --Get the current filterType at the retrait station
        if     mode == ZO_RETRAIT_MODE_RETRAIT  then
            AF.currentInventoryType = LF_RETRAIT
        end
        return false
    end
    --ZO_PreHook(ZO_RetraitStation_Keyboard, "SetMode", HookRetraitSetMode)
    local origRetraitSetMode = ZO_RetraitStation_Keyboard.SetMode
    --Is currently (2019-03-11) not called! So we need to use the scene of the retrait station to set the inventory type variable for AF
    ZO_RetraitStation_Keyboard.SetMode = function(...)
        origRetraitSetMode(...)
        HookRetraitSetMode(...)
    end

    --Overwrite the standard inventory update function for the used slots/totla slots
    local function hookInventoryInfoBar()
        --Callback function for ZO_InventoryManager:UpdateFreeSlots(inventoryType) -> Will be called with ThrottledUpdate to
        --prevent being run too often in short time
        local function ZO_InventoryManagerUpdateFreeSlotsCallback(self, inventoryType)
            if debugSpam then
                d("[AF]>>ZO_InventoryManagerUpdateFreeSlotsCallbacks, inventoryType: " ..tostring(inventoryType) .. ", infoBar: " ..tostring(self:GetContextualInfoBar():GetName()))
            end
            local inventory = self.inventories[inventoryType]
            local freeSlotType
            local altFreeSlotType
            local copyFreeSlotsInfoFromInv = INVENTORY_BACKPACK

            local cbeActive = (inventoryType == INVENTORY_CRAFT_BAG and CraftBagExtended ~= nil) or false
            --Quest/CraftBag (if addon CraftBagExtended is enabled only!) items "hack" to update the count label here too:
            -->Will use the normal inventory labels to show the output, but the itemCount from the related inventoryList
            if cbeActive or inventoryType == INVENTORY_QUEST_ITEM then
                inventory.freeSlotsLabel    = self.inventories[copyFreeSlotsInfoFromInv].freeSlotsLabel
                inventory.freeSlotType      = self.inventories[copyFreeSlotsInfoFromInv].freeSlotType
                inventory.altFreeSlotsLabel = self.inventories[copyFreeSlotsInfoFromInv].altFreeSlotsLabel
                inventory.altFreeSlotType   = self.inventories[copyFreeSlotsInfoFromInv].altFreeSlotType
            end
            if (type(inventory.freeSlotType) == "function") then
                freeSlotType = inventory.freeSlotType()
            else
                freeSlotType = inventory.freeSlotType
            end
            if (type(inventory.altFreeSlotType) == "function") then
                altFreeSlotType = inventory.altFreeSlotType()
            else
                altFreeSlotType = inventory.altFreeSlotType
            end

            local showFreeSlots    = inventory.freeSlotsLabel ~= nil
            local showAltFreeSlots = (inventory.altFreeSlotsLabel ~= nil and altFreeSlotType ~= nil)

            local settings = AF.settings
            local hideItemCount = settings.hideItemCount

            if showFreeSlots then
                local freeSlotTypeInventory = self.inventories[freeSlotType]
                local numUsedSlots, numSlots = self:GetNumSlots(freeSlotType)
                if cbeActive then freeSlotType = INVENTORY_CRAFT_BAG end
                if inventoryType == INVENTORY_QUEST_ITEM then freeSlotType = INVENTORY_QUEST_ITEM end
                local numFilteredAndShownItems = util.getInvItemCount(freeSlotType)
                local freeSlotsShown = inventoryType == freeSlotType and numFilteredAndShownItems or 0
                local freeSlotText = ""

                if(numUsedSlots < numSlots) then
                    freeSlotText = zo_strformat(freeSlotTypeInventory.freeSlotsStringId, numUsedSlots, numSlots)
                else
                    freeSlotText = zo_strformat(freeSlotTypeInventory.freeSlotsFullStringId, numUsedSlots, numSlots)
                end
                local newFreeSlotText
                if freeSlotsShown > 0 and not hideItemCount then
                    local colorString = ""
                    local itemCountLabelColor = settings.itemCountLabelColor
                    local colorStringColorDef = ZO_ColorDef:New(itemCountLabelColor["r"], itemCountLabelColor["g"], itemCountLabelColor["b"], itemCountLabelColor["a"])
                    colorString = colorStringColorDef:Colorize(colorString .. "(" .. freeSlotsShown .. ")")
                    newFreeSlotText = zo_strformat("<<1>> <<2>>", freeSlotText, colorString)
                else
                    newFreeSlotText = freeSlotText
                end
                inventory.freeSlotsLabel:SetText(newFreeSlotText)
            end

            if showAltFreeSlots then
                local numUsedSlots, numSlots = self:GetNumSlots(altFreeSlotType)
                local altFreeSlotInventory = self.inventories[altFreeSlotType] --grab the alternateInventory to use it's string id's
                local numFilteredAndShownItems = util.getInvItemCount(altFreeSlotType)
                local altFreeSlotsShown = inventoryType == altFreeSlotType and numFilteredAndShownItems or 0
                local altFreeSlotText = ""

                if(numUsedSlots < numSlots) then
                    altFreeSlotText = zo_strformat(altFreeSlotInventory.freeSlotsStringId, numUsedSlots, numSlots)
                else
                    altFreeSlotText = zo_strformat(altFreeSlotInventory.freeSlotsFullStringId, numUsedSlots, numSlots)
                end
                local newAltFreeSlotText
                if altFreeSlotsShown > 0 and not hideItemCount then
                    local colorString = ""
                    local itemCountLabelColor = settings.itemCountLabelColor
                    local colorStringColorDef = ZO_ColorDef:New(itemCountLabelColor["r"], itemCountLabelColor["g"], itemCountLabelColor["b"], itemCountLabelColor["a"])
                    colorString = colorStringColorDef:Colorize(colorString .. "(" .. altFreeSlotsShown .. ")")
                    newAltFreeSlotText = zo_strformat("<<1>> <<2>>", altFreeSlotText, colorString)
                else
                    newAltFreeSlotText = altFreeSlotText
                end
                inventory.altFreeSlotsLabel:SetText(newAltFreeSlotText)
            end
        end -- ZO_InventoryManagerUpdateFreeSlotsCallback

        --Overwrite the update function for the free slots label in inventories
        function ZO_InventoryManager:UpdateFreeSlots(inventoryType)
            ThrottledUpdate("ZO_InventoryManagerUpdateFreeSlotsCallback" .. tostring(inventoryType), 100,
                    ZO_InventoryManagerUpdateFreeSlotsCallback, self, inventoryType)
        end

        function ZO_QuickslotManager:UpdateFreeSlots()
            if debugSpam then
                d("[AF]ZO_QuickslotManager:UpdateFreeSlots")
            end
            local numUsedSlots, numSlots = PLAYER_INVENTORY:GetNumSlots(INVENTORY_BACKPACK)
            local numFilteredAndShownItems = #self.list.data
            local freeSlotsShown = numFilteredAndShownItems or 0
            local settings = AF.settings
            local hideItemCount = settings.hideItemCount

            local freeSlotText = ""
            if(numUsedSlots < numSlots) then
                freeSlotText = zo_strformat(SI_INVENTORY_BACKPACK_REMAINING_SPACES, numUsedSlots, numSlots)
            else
                freeSlotText = zo_strformat(SI_INVENTORY_BACKPACK_COMPLETELY_FULL, numUsedSlots, numSlots)
            end
            local newFreeSlotText
            if freeSlotsShown > 0 and not hideItemCount then
                local colorString = ""
                local itemCountLabelColor = settings.itemCountLabelColor
                local colorStringColorDef = ZO_ColorDef:New(itemCountLabelColor["r"], itemCountLabelColor["g"], itemCountLabelColor["b"], itemCountLabelColor["a"])
                colorString = colorStringColorDef:Colorize(colorString .. "(" .. freeSlotsShown .. ")")
                newFreeSlotText = zo_strformat("<<1>> <<2>>", freeSlotText, colorString)
            else
                newFreeSlotText = freeSlotText
            end
            self.freeSlotsLabel:SetText(newFreeSlotText)
        end

        --Overwrite the function UpdateInventorySlots from esoui/esoui/ingame/inventory/inventorytemplates.lua
        --for the crafting stations, in order to update the filter count amount properly in the infoBars
        function UpdateInventorySlots(infoBar)
            if debugSpam then
                d("[AF]UpdateInventorySlots: " .. tostring(infoBar:GetName()))
            end
            --Only for crafting station inventory types as the others are managed within function ZO_InventoryManager:UpdateFreeSlots(inventoryType) above!
            local invType = AF.currentInventoryType
            local isCraftingInvType = IsCraftingStationInventoryType(invType)
            if not isCraftingInvType then return false end
            local settings = AF.settings
            local hideItemCount = settings.hideItemCount

            local slotsLabel = infoBar:GetNamedChild("FreeSlots")
            local numUsedSlots, numSlots = PLAYER_INVENTORY:GetNumSlots(INVENTORY_BACKPACK)
            local numFilteredAndShownItems = util.getInvItemCount(invType, isCraftingInvType)
            local freeSlotsShown = ((numFilteredAndShownItems > 0) and numFilteredAndShownItems) or 0
            --d(">numUsedSlots: " .. tostring(numUsedSlots) .. ", numSlots: " .. tostring(numSlots) .. ", numFilteredAndShownItems: " .. tostring(numFilteredAndShownItems) ..", freeSlotsShown: " ..tostring(freeSlotsShown))
            local freeSlotText = ""
            if numUsedSlots < numSlots then
                freeSlotText = zo_strformat(SI_INVENTORY_BACKPACK_REMAINING_SPACES, numUsedSlots, numSlots)
            else
                freeSlotText = zo_strformat(SI_INVENTORY_BACKPACK_COMPLETELY_FULL, numUsedSlots, numSlots)
            end
            local newFreeSlotText
            if freeSlotsShown > 0 and not hideItemCount then
                local colorString = ""
                local itemCountLabelColor = settings.itemCountLabelColor
                local colorStringColorDef = ZO_ColorDef:New(itemCountLabelColor["r"], itemCountLabelColor["g"], itemCountLabelColor["b"], itemCountLabelColor["a"])
                colorString = colorStringColorDef:Colorize(colorString .. "(" .. freeSlotsShown .. ")")
                newFreeSlotText = zo_strformat("<<1>> <<2>>", freeSlotText, colorString)
                --d(">>1- newFreeSlotText: " .. tostring(newFreeSlotText))
            else
                newFreeSlotText = freeSlotText
                --d(">>2- newFreeSlotText: " .. tostring(newFreeSlotText))
            end
            slotsLabel:SetText(newFreeSlotText)
        end
    end
    --Hook the inventories info bar now for the item filtered/shown count
    hookInventoryInfoBar()

    --PreHook the QuickSlotWindow change filter function
    local function ChangeFilterQuickSlot(self, filterData)
        zo_callLater(function()
            QUICKSLOT_WINDOW:UpdateFreeSlots()
        end, 50)
    end
    ZO_PreHook(QUICKSLOT_WINDOW, "ChangeFilter", ChangeFilterQuickSlot)
    --Update the count of items filtered if text search boxes are used (ZOs or Votans Search Box)
    ZO_PreHook(ZO_InventoryManager, "UpdateEmptyBagLabel", function(ctrl, inventoryType, isEmptyList)
        if debugSpam then
            d("[AF]ZO_InventoryManager:UpdateEmptyBagLabel - inventoryType: " ..tostring(inventoryType))
        end
        --Check if the currently active focus in inside a search box
        local inventory = AF.inventories[inventoryType]
        local searchBox
        if inventory then
            local goOn = false
            local searchBoxIsEmpty = false
            searchBox = inventory.searchBox
            if searchBox and searchBox.GetText then
                local searchBoxText = searchBox:GetText()
                searchBoxIsEmpty = (searchBoxText == "") or false
                if not searchBoxIsEmpty then
                    --Check if the contents of the searchbox are not only spaces
                    local searchBoxTextWithoutSpaces = string.match(searchBoxText, "%S") -- %S = NOT a space
                    if searchBoxTextWithoutSpaces and searchBoxTextWithoutSpaces ~= "" then
                        goOn = true
                    else
                        searchBoxIsEmpty = true
                    end
                end
            end
            if not searchBoxIsEmpty then
                goOn = true
            end
            if not goOn then return false end
            --d("[AF]UpdateEmptyBagLabel, isEmptyList: " ..tostring(isEmptyList))
            --Update the count of filtered/shown items in the inventory FreeSlot label
            --Delay this function call as the data needs to be filtered first!
            ThrottledUpdate("RefreshItemCount_" .. inventoryType,
                    250, util.updateInventoryInfoBarCountLabel, inventoryType)
        end
        return false
    end)

end

local function PresetCraftingStationHookVariables()
    --Preset the crafting station panels's currentFilter variables
    local mapItemFilterType2CraftingStationFilterType = util.MapItemFilterType2CraftingStationFilterType
    smithingVar.refinementPanel.inventory.currentFilter     = mapItemFilterType2CraftingStationFilterType(ITEMFILTERTYPE_AF_REFINE_SMITHING,        LF_SMITHING_REFINE,         CRAFTING_TYPE_BLACKSMITHING)
    smithingVar.deconstructionPanel.inventory.currentFilter = mapItemFilterType2CraftingStationFilterType(ITEMFILTERTYPE_AF_WEAPONS_SMITHING,       LF_SMITHING_DECONSTRUCT,    CRAFTING_TYPE_BLACKSMITHING)
    smithingVar.improvementPanel.inventory.currentFilter    = mapItemFilterType2CraftingStationFilterType(ITEMFILTERTYPE_AF_WEAPONS_SMITHING,       LF_SMITHING_IMPROVEMENT,    CRAFTING_TYPE_BLACKSMITHING)
    smithingVar.researchPanel.currentFilter                 = mapItemFilterType2CraftingStationFilterType(ITEMFILTERTYPE_AF_WEAPONS_SMITHING,       LF_SMITHING_RESEARCH,       CRAFTING_TYPE_BLACKSMITHING)
    enchantingVar.inventory.currentFilter                   = mapItemFilterType2CraftingStationFilterType(ITEMFILTERTYPE_AF_GLYPHS_ENCHANTING,      LF_ENCHANTING_EXTRACTION,   CRAFTING_TYPE_ENCHANTING)
    retraitVar.retraitPanel.inventory.currentFilter         = mapItemFilterType2CraftingStationFilterType(ITEMFILTERTYPE_AF_RETRAIT,                LF_RETRAIT,                 CRAFTING_TYPE_INVALID)
end

local function onEndCraftingStationInteract(eventCode, craftSkill)
    --Reset the current inventory type to the normal inventory
    AF.currentInventoryType = INVENTORY_BACKPACK
end
local function onCraftingComplete(eventCode)
    --Update the counter of inventory items currently shown
    ThrottledUpdate("RefreshItemCount_" .. AF.currentInventoryType,
            50, util.updateInventoryInfoBarCountLabel, AF.currentInventoryType, true)
end

--Function to adjust/move some ZOs base game, or other addons, controls to fit into AdvancedFilters
local function AdjustZOsAndOtherAddonsVisibleStuff()
    --Move the "No items" label for an empty subfilter of the inventory a bit to the bottom
    local invEmptyLabelCtrl = ZO_PlayerInventoryEmpty
    if invEmptyLabelCtrl ~= nil then
        local origOnEffectivelyShown = invEmptyLabelCtrl.OnEffectivelyShown
        local myOnEffectivelyShownPostHook = function(...)
            --Call original func first
            local retVarOrig = origOnEffectivelyShown(...)
            --Call my code afterwards
            local boolVal, point, relTo, relPoint, x, y, constraints = invEmptyLabelCtrl:GetAnchor(0)
            local currentAnchor = {boolVal, point, relTo, relPoint, x, y, constraints}
            if relTo == ZO_PlayerInventory then
                invEmptyLabelCtrl:ClearAnchors()
                --Try to put the "No entries" to the center of the inventory.
                --Check the text's width and move the label THIS WIDTH/2 in pixels on the x axis to the left
                --so it is really in the center
                local labelsTextWidth = invEmptyLabelCtrl:GetTextWidth()
                x = (labelsTextWidth / 2) * -1
                y = 0
                invEmptyLabelCtrl:SetAnchor(TOPLEFT, relTo, CENTER, x, y, constraints)
            end
            --Return the originals return code now
            return retVarOrig
        end
    end
end

--Set variables in AF global namespace for function util.RefreshSubfilterBar
local function SetBankEventVariable(bankType, opened)
    if debugSpam then
        d("[AF]EVENT_OPEN/CLOSE_BANK, opened: " .. tostring(opened) .. ", bankType: " ..tostring(bankType))
    end
    if bankType == nil or bankType == "" then return false end
    opened = opened or false
    local bankInvType
    --Bank
    if bankType     == "b" then
        bankInvType = INVENTORY_BANK
        AF.bankOpened = opened
        --Guild bank
    elseif bankType == "gb" then
        bankInvType = INVENTORY_GUILD_BANK
        AF.guildBankOpened = opened
    --House storage
    elseif bankType == "hb" then
        bankInvType = INVENTORY_HOUSE_BANK
        AF.houseBankOpened = opened
    end
    --Save the last opened subfilterBar button to the global AF table, so it can be used later on as the bank get's opened
    --again to re-open the samel subfilterGroup and button
    if not opened and bankInvType then
        --Bank deposit
        local currentActiveSubfilterBarButtonDeposit = util.GetActiveSubfilterBarButton(INVENTORY_BACKPACK)
        if currentActiveSubfilterBarButtonDeposit then
            AF.bankLastActiveSubfilterBarButton = AF.bankLastActiveSubfilterBarButton or {}
            AF.bankLastActiveSubfilterBarButton[bankInvType] = currentActiveSubfilterBarButtonDeposit
        end
        --Bank withdraw
        local currentActiveSubfilterBarButtonWithdraw = util.GetActiveSubfilterBarButton(bankInvType)
        if currentActiveSubfilterBarButtonWithdraw then
            AF.bankLastActiveSubfilterBarButton = AF.bankLastActiveSubfilterBarButton or {}
            AF.bankLastActiveSubfilterBarButton[bankInvType] = currentActiveSubfilterBarButtonWithdraw
        end
    end
end

--Check if other addons are activated and output an error message if they brak AdvancedFilters
function AF.checkForOtherAddonErrors(eventName, initial)
    --Debug spam is enabled?
    debugSpam = false
    if AF.settings then
        debugSpam = AF.settings.debugSpam
    end
    --Check for other addons
    if not AF.otherAddons then return end
    if AF.otherAddons["MultiCraft"] or MultiCraft ~= nil then
        showChatDebug("Other addon breaks \'AdvancedFilters\' -> PLEASE DISABLE THE ADDON \'MultiCraft\'!", AF.errorStrings["MultiCraft"])
        return
    end
end

local function AdvancedFilters_Loaded(eventCode, addonName)
    if addonName == "MultiCraft" then
        AF.otherAddons[addonName] = true
    end
    if addonName ~= AF.name then return end
    EVENT_MANAGER:UnregisterForEvent(AF.name .. "_Loaded", EVENT_ADD_ON_LOADED)
    EVENT_MANAGER:RegisterForEvent(AF.name .. "_PlayerActivated", EVENT_PLAYER_ACTIVATED,   AF.checkForOtherAddonErrors)
    --Do not load anything further if the addon MultiCraft is enabled
    if AF.otherAddons["MultiCraft"] or MultiCraft ~= nil then
        return
    end

    --Register a callback function for crafting stations: If you leave them reseet the current inventory type to INVENTORY_BACKPACK
    EVENT_MANAGER:RegisterForEvent(AF.name .. "_CraftingStationLeave",          EVENT_END_CRAFTING_STATION_INTERACT,    onEndCraftingStationInteract)
    EVENT_MANAGER:RegisterForEvent(AF.name .. "_CraftingStationCraftFinished",  EVENT_CRAFT_COMPLETED,                  onCraftingComplete)
    EVENT_MANAGER:RegisterForEvent(AF.name .. "_CraftingStationCraftFailed",    EVENT_CRAFT_FAILED,                     onCraftingComplete)
    --Events for the bank and guild bank open and close, to set variables for function util.RefreshSubfilterBar
    AF.bankOpened       = false
    AF.guildBankOpened  = false
    AF.houseBankOpened  = false
    EVENT_MANAGER:RegisterForEvent(AF.name .. "_BankOpened", EVENT_OPEN_BANK,               function() SetBankEventVariable("b", true) end)
    EVENT_MANAGER:RegisterForEvent(AF.name .. "_BankClosed", EVENT_CLOSE_BANK,              function() SetBankEventVariable("b", false) end)
    EVENT_MANAGER:RegisterForEvent(AF.name .. "_GuildBankOpened", EVENT_OPEN_GUILD_BANK,    function() SetBankEventVariable("gb", true) end)
    EVENT_MANAGER:RegisterForEvent(AF.name .. "_GuildBankClosed", EVENT_CLOSE_GUILD_BANK,   function() SetBankEventVariable("gb", false) end)
    --Bufix to reset "store"'s currentFilter as stable closes
    EVENT_MANAGER:RegisterForEvent(AF.name .. "_StableClosed", EVENT_STABLE_INTERACT_END,   function() controlsForChecks.store.currentFilter = ITEMFILTERTYPE_ALL end)

    --Create instance of library libFilters
    util.LibFilters:InitializeLibFilters()
    --SavedVariables
    AF.settings = ZO_SavedVars:NewAccountWide(AF.name .. "_Settings", AF.savedVarsVersion, "Settings", AF.defaultSettings, GetWorldName())
    --Create the subfilter bars below the normal inventories filters
    AF.CreateSubfilterBars()
    --Initialize the prehooks etc. for inventories to react on filter changes etc.
    InitializeHooks()
    --Preset some needed variables for the crafting stations
    PresetCraftingStationHookVariables()
    --Adjust some stuff for other addon compatibility, or ZOs code compatibility
    AdjustZOsAndOtherAddonsVisibleStuff()
    --Build the LAM settingsmenu if LAM is loaded
    AF.LAMSettingsMenu()

    --For debugging
    if GetDisplayName() == "@Baertram" then
        --Enable short global variable for AdvancedFilters
        A_F = AF
    end
end
--Load the addon
EVENT_MANAGER:RegisterForEvent("AdvancedFilters_Loaded", EVENT_ADD_ON_LOADED, AdvancedFilters_Loaded)