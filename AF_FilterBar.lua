if AdvancedFilters == nil then AdvancedFilters = {} end
local AF = AdvancedFilters
AF.AF_FilterBar = ZO_Object:Subclass()
local AF_FilterBar = AF.AF_FilterBar
local BuildDropdownCallbacks = AF.util.BuildDropdownCallbacks

function AF_FilterBar:New(inventoryName, tradeSkillname, groupName, subfilterNames, excludeTheseButtons)
    local obj = ZO_Object.New(self)
    obj:Initialize(inventoryName, tradeSkillname, groupName, subfilterNames, excludeTheseButtons)
    return obj
end

function AF_FilterBar:Initialize(inventoryName, tradeSkillname, groupName, subfilterNames, excludeTheseButtons)
    --d("=============================================\n[AF]AF_FilterBarInitialize - inventoryName: " .. tostring(inventoryName) .. ", tradeSkillname: " .. tostring(tradeSkillname) .. ", groupName: " ..tostring(groupName) .. ", subfilterNames: " .. tostring(subfilterNames))
    --get upper anchor position for subfilter bar
    local _,_,_,_,_,offsetY = ZO_PlayerInventorySortBy:GetAnchor()

    --parent for the subfilter bar control
    local parents = AF.filterBarParents
    local parent = parents[inventoryName]
    if parent == nil then
        d("[AdvancedFilters] ERROR: Parent for subfilterbar missing! InventoryName: " .. tostring(inventoryName) .. ", tradeSkillname: " .. tostring(tradeSkillname) .. ", groupName: " ..tostring(groupName) .. ", subfilterNames: " .. tostring(subfilterNames))
--[[
    else
        if parent.GetName then
            d(">parent name: " ..tostring(parent:GetName()))
        end
]]
    end

    --unique identifier
    self.name = inventoryName .. tradeSkillname .. groupName
    self.control = WINDOW_MANAGER:CreateControlFromVirtual("AF_FilterBar" .. self.name, parent, "AF_Base")
    self.control:SetAnchor(TOPLEFT, parent, TOPLEFT, 0, offsetY)

    self.label = self.control:GetNamedChild("Label")
    self.label:SetModifyTextType(MODIFY_TEXT_TYPE_UPPERCASE)
    local allText = AF.strings[AF_CONST_ALL] or AF_CONST_ALL
    self.label:SetText(allText)

    self.divider = self.control:GetNamedChild("Divider")

    self.subfilterButtons = {}
    self.activeButton = nil

    self.dropdown = WINDOW_MANAGER:CreateControlFromVirtual("AF_FilterBar" .. self.name .. "DropdownFilter", self.control, "ZO_ComboBox")
    self.dropdown:SetAnchor(RIGHT, self.control, RIGHT)
    self.dropdown:SetHeight(24)
    self.dropdown:SetWidth(104)
    local function DropdownOnMouseUpHandler(dropdown, mouseButton, upInside)
        local comboBox = dropdown.m_comboBox

        if mouseButton == MOUSE_BUTTON_INDEX_LEFT and upInside then
            if comboBox.m_isDropdownVisible then
                comboBox:HideDropdownInternal()
            else
                comboBox:ShowDropdownInternal()
            end
        elseif mouseButton == MOUSE_BUTTON_INDEX_RIGHT and upInside then
            local entries = {
                [1] = {
                    name = AF.strings.ResetToAll,
                    callback = function()
                        comboBox:SelectFirstItem()

                        local button = self:GetCurrentButton()
                        button.previousDropdownSelection = comboBox.m_sortedItems[1]

                        local filterType = AF.util.GetCurrentFilterTypeForInventory(self.inventoryType)
                        AF.util.LibFilters:RequestUpdate(filterType)

                        PlaySound(SOUNDS.MENU_BAR_CLICK)
                    end,
                },
                [2] = {
                    name = AF.strings.InvertDropdownFilter,
                    callback = function()
                        local button = self:GetCurrentButton()

                        local filterType = AF.util.GetCurrentFilterTypeForInventory(self.inventoryType)
                        local originalCallback = AF.util.LibFilters:GetFilterCallback("AF_DropdownFilter", filterType)
                        local filterCallback = function(slot, slotIndex)
                            return not originalCallback(slot, slotIndex)
                        end

                        AF.util.LibFilters:UnregisterFilter("AF_DropdownFilter", filterType)
                        AF.util.LibFilters:RegisterFilter("AF_DropdownFilter", filterType, filterCallback)
                        AF.util.LibFilters:RequestUpdate(filterType)

                        PlaySound(SOUNDS.MENU_BAR_CLICK)

                        --Update the count of filtered/shown items in the inventory FreeSlot label
                        --Delay this function call as the data needs to be filtered first!
                        zo_callLater(function()
                            AF.util.updateInventoryInfoBarCountLabel(AF.currentInventoryType)
                        end, 50)
                    end,
                },
            }

            ClearMenu()
            for _, entry in ipairs(entries) do
                AddCustomMenuItem(entry.name, entry.callback, MENU_ADD_OPTION_LABEL)
            end
            ShowMenu(dropdown)
        end
    end
    self.dropdown:SetHandler("OnMouseUp", DropdownOnMouseUpHandler)

    local comboBox = self.dropdown.m_comboBox
    comboBox:SetSortsItems(false)
    comboBox.AddMenuItems = function(comboBox)
        local button = self:GetCurrentButton()
        local self = comboBox

        for i = 1, #self.m_sortedItems do
            -- The variable item must be defined locally here, otherwise it won't work as an upvalue to the selection helper
            local item = self.m_sortedItems[i]

            local function OnSelect()
                ZO_ComboBox_Base_ItemSelectedClickHelper(self, item)

                button.previousDropdownSelection = item

                PlaySound(SOUNDS.MENU_BAR_CLICK)
            end

            AddCustomMenuItem(item.name, OnSelect, nil, self.m_font,
                    self.m_normalColor, self.m_highlightColor)
        end

        local submenuCandidates = self.submenuCandidates

        for _, submenuCandidate in ipairs(submenuCandidates) do
            local entries = {}
            for _, callbackEntry in ipairs(submenuCandidate.callbackTable) do
                local entry = {
                    label = AF.strings[callbackEntry.name],
                    callback = function()
                        AF.util.ApplyFilter(callbackEntry, "AF_DropdownFilter", true)
                        button.forceNextDropdownRefresh = true
                        self.m_selectedItemText:SetText(AF.strings[callbackEntry.name])
                        self.m_selectedItemData = self:CreateItemEntry(AF.strings[callbackEntry.name],
                                function(comboBox, itemName, item, selectionChanged)
                                    AF.util.ApplyFilter(callbackEntry,
                                            "AF_DropdownFilter",
                                            selectionChanged or button.forceNextDropdownRefresh)
                                end)
                        button.previousDropdownSelection = self.m_selectedItemData

                        PlaySound(SOUNDS.MENU_BAR_CLICK)

                        ClearMenu()
                    end,
                }
                table.insert(entries, entry)
            end
            AddCustomSubMenuItem(AF.strings[submenuCandidate.submenuName], entries, "ZoFontGameSmall")
        end
    end

    for _, subfilterName in ipairs(subfilterNames) do
        --Check if this subfilterName (button) is excluded at the current groupName
        local doNotAddButtonNow = false
        if excludeTheseButtons ~= nil then
            if type(excludeTheseButtons) == "table" then
                local buttonNamesToExclude = excludeTheseButtons[1]
                for _, buttonNameToExclude in pairs(buttonNamesToExclude) do
                    doNotAddButtonNow = (buttonNameToExclude == subfilterName) or false
                    if doNotAddButtonNow then
                        break
                    end
                end
            elseif type(excludeTheseButtons) == "string" then
                doNotAddButtonNow = (excludeTheseButtons == subfilterName) or false
            end
        end
        if not doNotAddButtonNow then
            self:AddSubfilter(groupName, subfilterName)
            --        else
            --d(">>>Not adding button: " .. tostring(subfilterName) .. ", at inventory: " .. tostring(inventoryName) .. ", groupName: " .. tostring(groupName))
        end
    end
end

function AF_FilterBar:AddSubfilter(groupName, subfilterName)
    local iconPath = AF.textures[subfilterName]
    if iconPath == nil then
        d("[AdvancedFilters] ERROR: Texture for subfilter " .. tostring(subfilterName) .. " is missing! Please add textures." .. tostring(subfilterName) .. " to file textures.lua.")
        return
    end
    local icon = {
        up = string.format(iconPath, "up"),
        down = string.format(iconPath, "down"),
        over = string.format(iconPath, "over"),
    }
--d("[AF_FilterBar:AddSubfilter]groupName: " ..tostring(groupName) .. ", subfilterName: " ..tostring(subfilterName))
    if AF.subfilterCallbacks[groupName] == nil or AF.subfilterCallbacks[groupName][subfilterName] == nil then return nil  end
    local callback = AF.subfilterCallbacks[groupName][subfilterName].filterCallback

    local anchorX = -116 + #self.subfilterButtons * -32

    local button = WINDOW_MANAGER:CreateControlFromVirtual(self.control:GetName() .. subfilterName .. "Button", self.control, "AF_Button")
    local texture = button:GetNamedChild("Texture")
    local highlight = button:GetNamedChild("Highlight")

    texture:SetTexture(icon.up)
    highlight:SetTexture(icon.over)

    button:SetAnchor(RIGHT, self.control, RIGHT, anchorX, 0)
    button:SetClickSound(SOUNDS.MENU_BAR_CLICK)

    local function OnClicked(thisButton)
        if(not thisButton.clickable) then return end

        self:ActivateButton(thisButton)
    end

    local function OnMouseEnter(thisButton)
        ZO_Tooltips_ShowTextTooltip(thisButton, TOP, AF.strings[subfilterName])

        local clickable = thisButton.clickable
        local active = self:GetCurrentButton() == thisButton

        if clickable and not active then
            highlight:SetHidden(false)
        end
    end

    local function OnMouseExit()
        ZO_Tooltips_HideTextTooltip()

        highlight:SetHidden(true)
    end

    button:SetHandler("OnClicked", OnClicked)
    button:SetHandler("OnMouseEnter", OnMouseEnter)
    button:SetHandler("OnMouseExit", OnMouseExit)

    button.name = subfilterName
    button.groupName = groupName
    button.texture = texture
    button.clickable = true
    button.filterCallback = callback
    button.up = icon.up
    button.down = icon.down

    self.activeButton = button

    table.insert(self.subfilterButtons, button)
end

function AF_FilterBar:ActivateButton(newButton)
    local function PopulateDropdown()
        local comboBox = self.dropdown.m_comboBox
        newButton.dropdownCallbacks = BuildDropdownCallbacks(newButton.groupName, newButton.name)

        comboBox.submenuCandidates = {}
        for _, v in ipairs(newButton.dropdownCallbacks) do
            if v.submenuName then
                table.insert(comboBox.submenuCandidates, v)
            else
                local dropdownEntryName = v.name
                if v.addString ~= nil and v.addString ~= "" then
                    dropdownEntryName = dropdownEntryName .. "_" .. v.addString
                end
                local iconForDropdownCallbackEntry = ""
                if AF.settings.showIconsInFilterDropdowns and v.showIcon ~= nil and v.showIcon == true then
                    local textureName = AF.textures[v.name] or ""
                    if textureName ~= "" then
                        --Remove the placeholder %s
                        textureName = string.format(textureName, "up")
                        iconForDropdownCallbackEntry = zo_iconFormat(textureName, 28, 28)
                    end
                end
                local itemEntryName = AF.strings[dropdownEntryName] or ""
                if itemEntryName == "" then
                    d("[AdvancedFilters]Translation missing for dropdown filter entry: " .. tostring(dropdownEntryName))
                else
                    if AF.settings.showIconsInFilterDropdowns and iconForDropdownCallbackEntry ~= "" then
                        itemEntryName = iconForDropdownCallbackEntry .. " " .. itemEntryName
                    end
                    local itemEntry = ZO_ComboBox:CreateItemEntry(itemEntryName,
                            function(comboBox, itemName, item, selectionChanged)
                                AF.util.ApplyFilter(v, "AF_DropdownFilter", selectionChanged or newButton.forceNextDropdownRefresh)
                            end)
                    comboBox:AddItem(itemEntry)
                end
            end
        end
        comboBox:SetSelectedItemFont("ZoFontGameSmall")
        comboBox:SetDropdownFont("ZoFontGameSmall")
    end

    local name = newButton.name
    self.label:SetText(AF.strings[name])
    local settings = AF.settings
    self.label:SetHidden(settings.hideSubFilterLabel)

    local oldButton = self.activeButton

    --hide old down texture
    oldButton:GetNamedChild("Texture"):SetTexture(oldButton.up)
    oldButton:SetEnabled(true)

    --show new down texture
    newButton:GetNamedChild("Texture"):SetTexture(newButton.down)
    newButton:SetEnabled(false)

    --refresh filter
    AF.util.ApplyFilter(newButton, "AF_ButtonFilter", true)

    --set new active button reference
    self.activeButton = newButton

    --clear old dropdown data
    self.dropdown.m_comboBox.m_sortedItems = {}
    --add new dropdown data
    PopulateDropdown()
    --restore previous dropdown selection
    self.dropdown.m_comboBox:SelectItem(newButton.previousDropdownSelection)
    --select the first item if there is no previos selection
    if not newButton.previousDropdownSelection then
        self.dropdown.m_comboBox:SelectFirstItem()
        newButton.previousDropdownSelection = self.dropdown.m_comboBox.m_sortedItems[1]
    end
end

function AF_FilterBar:GetCurrentButton()
    return self.activeButton
end

function AF_FilterBar:SetHidden(shouldHide)
    self.control:SetHidden(shouldHide)
end

function AF_FilterBar:SetInventoryType(inventoryType)
    self.inventoryType = inventoryType
end


------------------------------------------------------------------------------------------------------------------------
--Create the subfilter bars below the inventory's filters (e.g. the weapons filters from the game will get a subfilter bar with 1hd, 2hd, staffs, shields)
function AF.CreateSubfilterBars()
    --local variables for a speedUp on access on addon's global table variables
    local doDebugOutput         = AF.settings.doDebugOutput
    local inventoryNames        = AF.inventoryNames
    local tradeSkillNames       = AF.tradeSkillNames
    local filterTypeNames       = AF.filterTypeNames
    local subfilterGroups       = AF.subfilterGroups
    local subfilterButtonNames  = AF.subfilterButtonNames
    local excludeButtonNamesfromSubFilterBar
    --Build each subfilterBar for the parent game filter controls
    for inventoryType, tradeSkillTypeSubFilterGroup in pairs(subfilterGroups) do
        for tradeSkillType, subfilterGroup in pairs(tradeSkillTypeSubFilterGroup) do
            for itemFilterType, _ in pairs(subfilterGroup) do
                if inventoryType and tradeSkillType and itemFilterType then
                    --Exclusion check
                    local excludeTheseButtons
                    if excludeButtonNamesfromSubFilterBar and excludeButtonNamesfromSubFilterBar[inventoryType] and excludeButtonNamesfromSubFilterBar[inventoryType][tradeSkillType] and excludeButtonNamesfromSubFilterBar[inventoryType][tradeSkillType][itemFilterType] then
                        excludeTheseButtons = excludeButtonNamesfromSubFilterBar[inventoryType][tradeSkillType][itemFilterType]
                    end
                    if inventoryNames[inventoryType] and tradeSkillNames[tradeSkillType] and filterTypeNames[itemFilterType] and subfilterButtonNames[itemFilterType] then
                        --Build the subfilterBar with the buttons now
                        local subfilterBar = AF.AF_FilterBar:New(
                                inventoryNames[inventoryType],
                                tradeSkillNames[tradeSkillType],
                                filterTypeNames[itemFilterType],
                                subfilterButtonNames[itemFilterType],
                                excludeTheseButtons                     --subFilterButtons which should not be shown
                        )
                        subfilterBar:SetInventoryType(inventoryType)
                        subfilterGroups[inventoryType][tradeSkillType][itemFilterType] = subfilterBar
                    else
                        if doDebugOutput then
                            d("[AF]CreateSubfilterBars, missing names - inventoryName: " ..tostring(inventoryNames[inventoryType]) .. ", tradeSkillName: " .. tostring(tradeSkillNames[tradeSkillType]) .. ", filterTypeName:" .. tostring(filterTypeNames[itemFilterType]) .. ", subfilterButtonName:" .. tostring(subfilterButtonNames[itemFilterType]))
                        end
                    end
                else
                    if doDebugOutput then
                        d("[AF]CreateSubfilterBars, missing data - inventoryType: " ..tostring(inventoryType) .. ", tradeSkillType: " .. tostring(tradeSkillType) .. ", itemFilterType:" .. tostring(itemFilterType))
                    end
                end
            end
        end
    end
end