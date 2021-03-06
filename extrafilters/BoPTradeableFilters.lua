local AF = AdvancedFilters
local util = AF.util
local checkCraftingStationSlot = AF.checkCraftingStationSlot
local function BoPCallback(slot, slotIndex)
    slot = checkCraftingStationSlot(slot, slotIndex)
    local bagId, slotIndex = slot.bagId, slot.slotIndex

    if not bagId or not slotIndex then return false end

    if IsItemBoPAndTradeable(bagId, slotIndex) then return true end

    return false
end

local dropdownCallback = {
    {name = "BoPTrade", filterCallback = BoPCallback},
}

local strings = {
    ["BoPTrade"] = "Bound but Tradeable",
}
local stringsDE = {
    ["BoPTrade"] = "Gebunden & handelbar",
}

local filterInformation = {
    callbackTable = dropdownCallback,
    filterType = ITEMFILTERTYPE_WEAPONS,
    subfilters = {"All",},
    excludeFilterPanels = {
        LF_ENCHANTING_CREATION, LF_ENCHANTING_EXTRACTION,
        LF_SMITHING_REFINE, LF_SMITHING_CREATION,
        LF_ALCHEMY_CREATION, LF_CRAFTBAG, LF_PROVISIONING_BREW, LF_PROVISIONING_COOK, LF_QUICKSLOT
    },
    deStrings = stringsDE,
    enStrings = strings,
}

AdvancedFilters_RegisterFilter(filterInformation)

filterInformation = {
    callbackTable = dropdownCallback,
    filterType = ITEMFILTERTYPE_ARMOR,
    subfilters = {"All",},
    excludeFilterPanels = {
        LF_ENCHANTING_CREATION, LF_ENCHANTING_EXTRACTION,
        LF_SMITHING_REFINE, LF_SMITHING_CREATION,
        LF_ALCHEMY_CREATION, LF_CRAFTBAG, LF_PROVISIONING_BREW, LF_PROVISIONING_COOK, LF_QUICKSLOT
    },
    deStrings = stringsDE,
    enStrings = strings,
}

AdvancedFilters_RegisterFilter(filterInformation)