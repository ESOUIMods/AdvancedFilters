if AdvancedFilters == nil then AdvancedFilters = {} end
local AF = AdvancedFilters

--Addon base variables
AF.name = "AdvancedFilters"
AF.author = "ingeniousclown, Randactyl, Baertram"
AF.version = "1.5.2.3"
AF.savedVarsVersion = 1.511
AF.website = "http://www.esoui.com/downloads/info245-AdvancedFilters.html"
AF.feedback = "https://www.esoui.com/portal.php?id=136&a=faq"
AF.donation = "https://www.esoui.com/portal.php?id=136&a=faq&faqid=131"
AF.currentInventoryType = INVENTORY_BACKPACK

AF.clientLang = GetCVar("language.2")

--SavedVariables default settings
AF.defaultSettings = {
    doDebugOutput                           = false,
    hideItemCount                           = false,
    itemCountLabelColor = {
        ["r"] = 1,
        ["g"] = 1,
        ["b"] = 1,
        ["a"] = 1,
    },
    hideSubFilterLabel                      = false,
    grayOutSubFiltersWithNoItems            = true,
    showIconsInFilterDropdowns              = true,
    rememberFilterDropdownsLastSelection    = true,
}

--Libraries
AF.util = AF.util or {}
local util = AF.util
------------------------------------------------------------------------------------------------------------------------
-- Libraries - BEGIN
------------------------------------------------------------------------------------------------------------------------
--LibCommonInventoryFilters
util.libCIF = LibCIF
------------------------------------------------------------------------------------------------------------------------
--LibFilters-3.0
util.LibFilters = LibFilters3
if not util.LibFilters then d("[AdvancedFilters]ERROR: Needed library LibFilters-3.0 is not loaded. This addon will not work properly!") return end
--LibAddonMenu-2.0
AF.LAM = LibAddonMenu2
if AF.LAM == nil and LibStub then AF.LAM = LibStub('LibAddonMenu-2.0', true) end
------------------------------------------------------------------------------------------------------------------------
--LibMotifCategories-1.0
util.LibMotifCategories = LibMotifCategories
if not util.LibMotifCategories and LibStub then util.LibMotifCategories = LibStub("LibMotifCategories-1.0", true) end
if not util.LibMotifCategories then d("[AdvancedFilters]ERROR: Needed library LibMotifCategories-1.0 is not loaded. This addon will not work properly!") return end
------------------------------------------------------------------------------------------------------------------------
-- Libraries - END
---------------------------------------------------------------------------------------------------------------------------

--Other addons
AF.otherAddons = {}

--Error strings for thrown addon errors and chat output
AF.errorStrings = {}
AF.errorStrings["MultiCraft"] = "PLEASE DISABLE THE ADDON \'MultiCraft\'! AdvancedFilters cannot work if this addon is enabled. \'Multicraft\' has been replaced by ZOs own multi crafting UI so you do not need it anymore!"

--Scene names for the SCENE_MANAGER.currentScene.name check
local scenesForChecks = {
    storeVendor     = "store",
    bank            = "bank",
    guildBank       = "guildBank",
    guildStoreSell  = "tradinghouse",
}
AF.scenesForChecks = scenesForChecks

local sceneNameStoreVendor      = ""
local sceneNameBankDeposit      = ""
local sceneNameGuildBankDeposit = ""
--Control names for the "which panel is shown" checks
local controlsForChecks = {
    inv                     = ZO_PlayerInventory,
    invList                 = ZO_PlayerInventoryList,
    bank                    = ZO_PlayerBank,
    bankBackpack            = ZO_PlayerBankBackpack,
    guildBank               = ZO_GuildBank,
    guildBankBackpack       = ZO_GuildBankBackpack,
    storeWindow             = ZO_StoreWindow,
    buyBackList             = ZO_BuyBackListContents,
    repairWindow            = ZO_RepairWindowList,
    craftBag                = ZO_CraftBag,
    houseBank               = ZO_HouseBank,
    retraitControl          = ZO_RETRAIT_STATION_KEYBOARD.retraitPanel.control, --needed for the filterBar parent control
    guildStoreSellBackpack  = ZO_PlayerInventory,
    --Keyboard variables
    store                   = STORE_WINDOW,
    smithing                = SMITHING,
    enchanting              = ENCHANTING,
    retrait                 = ZO_RETRAIT_STATION_KEYBOARD, -- needed for the other retrait related filter stuff (hooks, util functions)
}
controlsForChecks.researchPanel     =   controlsForChecks.smithing.researchPanel
controlsForChecks.researchLineList  =   controlsForChecks.researchPanel.researchLineList
AF.controlsForChecks = controlsForChecks

--Inventories and their searchBox controls
local inventories =
{
    [INVENTORY_BACKPACK] =
    {
        searchBox = ZO_PlayerInventorySearchBox,
    },
    [INVENTORY_QUEST_ITEM] =
    {
        searchBox = ZO_PlayerInventorySearchBox,
    },
    [INVENTORY_BANK] =
    {
        searchBox = ZO_PlayerBankSearchBox,
    },
    [INVENTORY_HOUSE_BANK] =
    {
        searchBox = ZO_HouseBankSearchBox,
    },
    [INVENTORY_GUILD_BANK] =
    {
        searchBox = ZO_GuildBankSearchBox,
    },
    [INVENTORY_CRAFT_BAG] =
    {
        searchBox = ZO_CraftBagSearchBox,
    },
}
AF.inventories = inventories

--Constant for the "All" subfilters
AF_CONST_ALL = 'All'
--Constant for the dropdown filter box LibFilters filter
AF_CONST_BUTTON_FILTER      = "AF_ButtonFilter"
AF_CONST_DROPDOWN_FILTER    = "AF_DropdownFilter"

--New defined vendor buy inventory type
INVENTORY_TYPE_VENDOR_BUY = 900
--Abort the subfilter bar refresh for the following inventory types
AF.abortSubFilterRefreshInventoryTypes = {
    [INVENTORY_TYPE_VENDOR_BUY] = true, --Vendor buy
    [INVENTORY_QUEST_ITEM]      = true, --Quest items
}

--Get the current maximum itemfiltertye
AF.maxItemFilterType = ITEMFILTERTYPE_MAX_VALUE -- 26 is the maximum at API 100026 "Wrathstone"
--Build new "virtual" itemfiltertypes for crafting stations so one can distinguish the different subfilter bars
local itemFilterTypesDefinedForAdvancedFilters = {
    --Refine
    ITEMFILTERTYPE_AF_REFINE_CLOTHIER               = 0,
    ITEMFILTERTYPE_AF_REFINE_SMITHING               = 0,
    ITEMFILTERTYPE_AF_REFINE_WOODWORKING            = 0,
    ITEMFILTERTYPE_AF_REFINE_JEWELRY                = 0,
    --Create
    --ITEMFILTERTYPE_AF_CREATE_ARMOR_CLOTHIER         = 0,
    --ITEMFILTERTYPE_AF_CREATE_ARMOR_SMITHING         = 0,
    --ITEMFILTERTYPE_AF_CREATE_ARMOR_WOODWORKING      = 0,
    --ITEMFILTERTYPE_AF_CREATE_WEAPONS_SMITHING       = 0,
    --ITEMFILTERTYPE_AF_CREATE_WEAPONS_WOODWORKING    = 0,
    --ITEMFILTERTYPE_AF_CREATE_JEWELRY                = 0,
    ITEMFILTERTYPE_AF_RUNES_ENCHANTING              = 0,
    --Deconstruct / Improve / Research
    ITEMFILTERTYPE_AF_ARMOR_CLOTHIER                = 0,
    ITEMFILTERTYPE_AF_ARMOR_SMITHING                = 0,
    ITEMFILTERTYPE_AF_ARMOR_WOODWORKING             = 0,
    ITEMFILTERTYPE_AF_WEAPONS_SMITHING              = 0,
    ITEMFILTERTYPE_AF_WEAPONS_WOODWORKING           = 0,
    ITEMFILTERTYPE_AF_JEWELRY_CRAFTING              = 0,
    ITEMFILTERTYPE_AF_GLYPHS_ENCHANTING             = 0,
    --Retrait
    ITEMFILTERTYPE_AF_RETRAIT_ARMOR                 = 0,
    ITEMFILTERTYPE_AF_RETRAIT_WEAPONS               = 0,
    ITEMFILTERTYPE_AF_RETRAIT_JEWELRY               = 0,
}
local counter = AF.maxItemFilterType
for itemFilterTypeName, _ in pairs(itemFilterTypesDefinedForAdvancedFilters) do
    counter = counter + 1
    _G[itemFilterTypeName] = counter
end

--The names of the inventories. Needed to build the unique subfilter panel names.
local inventoryNames = {
    [INVENTORY_BACKPACK]        = "PlayerInventory",
    [INVENTORY_BANK]            = "PlayerBank",
    [INVENTORY_GUILD_BANK]      = "GuildBank",
    [INVENTORY_CRAFT_BAG]       = "CraftBag",
    [INVENTORY_TYPE_VENDOR_BUY] = "VendorBuy",
    [LF_SMITHING_CREATION]      = "SmithingCreate",
    [LF_SMITHING_REFINE]        = "SmithingRefine",
    [LF_SMITHING_DECONSTRUCT]   = "SmithingDeconstruction",
    [LF_SMITHING_IMPROVEMENT]   = "SmithingImprovement",
    [LF_SMITHING_RESEARCH]      = "SmithingResearch",
    [LF_JEWELRY_CREATION]       = "JewelryCraftingCreate",
    [LF_JEWELRY_REFINE]         = "JewelryCraftingRefine",
    [LF_JEWELRY_DECONSTRUCT]    = "JewelryCraftingDeconstruction",
    [LF_JEWELRY_IMPROVEMENT]    = "JewelryCraftingImprovement",
    [LF_JEWELRY_RESEARCH]       = "JewelryCraftingResearch",
    [LF_ENCHANTING_CREATION]    = "EnchantingCreation",
    [LF_ENCHANTING_EXTRACTION]  = "EnchantingExtraction",
    [INVENTORY_HOUSE_BANK]      = "HouseBankWithdraw",
    [LF_RETRAIT]                = "Retrait"
}
AF.inventoryNames = inventoryNames

--The names of the trade skills. Needed to build the unique subfilter panel names.
local tradeSkillNames = {
    [CRAFTING_TYPE_INVALID]         = "_",
    [CRAFTING_TYPE_ALCHEMY]         = "_ALCHEMY_",
    [CRAFTING_TYPE_BLACKSMITHING]   = "_BLACKSMITH_",
    [CRAFTING_TYPE_CLOTHIER]        = "_CLOTHIER_",
    [CRAFTING_TYPE_ENCHANTING]      = "_ENCHANTING_",
    [CRAFTING_TYPE_PROVISIONING]    = "_PROVISIONING_",
    [CRAFTING_TYPE_WOODWORKING]     = "_WOODWORKING_",
    [CRAFTING_TYPE_JEWELRYCRAFTING] = "_JEWELRY_",
}
AF.tradeSkillNames = tradeSkillNames

--The names of the filter types. Needed to build the unique subfilter panel names.
local filterTypeNames = {
    [ITEMFILTERTYPE_ALL]                            = AF_CONST_ALL,
    [ITEMFILTERTYPE_WEAPONS]                        = "Weapons",
    [ITEMFILTERTYPE_ARMOR]                          = "Armor",
    [ITEMFILTERTYPE_CONSUMABLE]                     = "Consumables",
    [ITEMFILTERTYPE_CRAFTING]                       = "Crafting",
    [ITEMFILTERTYPE_MISCELLANEOUS]                  = "Miscellaneous",
    [ITEMFILTERTYPE_JUNK]                           = "Junk",
    [ITEMFILTERTYPE_BLACKSMITHING]                  = "Blacksmithing",
    [ITEMFILTERTYPE_CLOTHING]                       = "Clothing",
    [ITEMFILTERTYPE_WOODWORKING]                    = "Woodworking",
    [ITEMFILTERTYPE_ALCHEMY]                        = "Alchemy",
    [ITEMFILTERTYPE_ENCHANTING]                     = "Enchanting",
    [ITEMFILTERTYPE_PROVISIONING]                   = "Provisioning",
    [ITEMFILTERTYPE_STYLE_MATERIALS]                = "Style",
    [ITEMFILTERTYPE_TRAIT_ITEMS]                    = "Traits",
    [ITEMFILTERTYPE_FURNISHING]                     = "Furnishings",
    [ITEMFILTERTYPE_JEWELRYCRAFTING]                = "JewelryCrafting",
    [ITEMFILTERTYPE_JEWELRY]                        = "Jewelry",
    [ITEMFILTERTYPE_AF_WEAPONS_SMITHING]            = "WeaponsSmithing",
    --[ITEMFILTERTYPE_AF_CREATE_ARMOR_SMITHING]       = "CreateArmorSmithing",
    [ITEMFILTERTYPE_AF_REFINE_SMITHING]             = "RefineSmithing",
    [ITEMFILTERTYPE_AF_ARMOR_WOODWORKING]           = "ArmorWoodworking",
    --[ITEMFILTERTYPE_AF_CREATE_WEAPONS_SMITHING]     = "CreateWeaponsSmithing",
    [ITEMFILTERTYPE_AF_GLYPHS_ENCHANTING]           = "Glyphs",
    [ITEMFILTERTYPE_AF_REFINE_WOODWORKING]          = "RefineWoodworking",
    --[ITEMFILTERTYPE_AF_CREATE_ARMOR_CLOTHIER]       = "CreateArmorClothier",
    [ITEMFILTERTYPE_AF_REFINE_CLOTHIER]             = "RefineClothier",
    [ITEMFILTERTYPE_AF_JEWELRY_CRAFTING]            = "JewelryCraftingStation",
    [ITEMFILTERTYPE_AF_RUNES_ENCHANTING]            = "Runes",
    [ITEMFILTERTYPE_AF_ARMOR_SMITHING]              = "ArmorSmithing",
    [ITEMFILTERTYPE_AF_WEAPONS_WOODWORKING]         = "WeaponsWoodworking",
    --[ITEMFILTERTYPE_AF_CREATE_WEAPONS_WOODWORKING]  = "CreateWeaponsWoodworking",
    --[ITEMFILTERTYPE_AF_CREATE_ARMOR_WOODWORKING]    = "CreateArmorWoodworking",
    [ITEMFILTERTYPE_AF_ARMOR_CLOTHIER]              = "ArmorClothier",
    --[ITEMFILTERTYPE_AF_CREATE_JEWELRY]              = "CreateJewelryCraftingStation",
    [ITEMFILTERTYPE_AF_REFINE_JEWELRY]              = "RefineJewelryCraftingStation",
    [ITEMFILTERTYPE_AF_RETRAIT_ARMOR]               = "ArmorRetrait",
    [ITEMFILTERTYPE_AF_RETRAIT_WEAPONS]             = "WeaponsRetrait",
    [ITEMFILTERTYPE_AF_RETRAIT_JEWELRY]             = "JewelryRetrait",
}
AF.filterTypeNames = filterTypeNames

--Mapping for filter types to crafting AdvancedFilter types
local normalFilterNames = {
    [filterTypeNames[ITEMFILTERTYPE_ARMOR]]   = true, -- Armor
    [filterTypeNames[ITEMFILTERTYPE_WEAPONS]] = true, -- Weapons
    [filterTypeNames[ITEMFILTERTYPE_JEWELRY]] = true, -- Jewelry
}
AF.normalFilterNames = normalFilterNames
local normalFilter2CraftingFilter = {
    [filterTypeNames[ITEMFILTERTYPE_ARMOR]] = {
        [filterTypeNames[ITEMFILTERTYPE_AF_ARMOR_WOODWORKING]]    = true, --ArmorWoodworking
        [filterTypeNames[ITEMFILTERTYPE_AF_ARMOR_SMITHING]]       = true, --ArmorSmithing
        [filterTypeNames[ITEMFILTERTYPE_AF_ARMOR_CLOTHIER]]       = true, --ArmorClothier
        [filterTypeNames[ITEMFILTERTYPE_AF_RETRAIT_ARMOR]]        = true, --ArmorRetrait
    },
    [filterTypeNames[ITEMFILTERTYPE_WEAPONS]] = {
        [filterTypeNames[ITEMFILTERTYPE_AF_WEAPONS_WOODWORKING]]  = true, --WeaponsWoodworking
        [filterTypeNames[ITEMFILTERTYPE_AF_WEAPONS_SMITHING]]     = true, --WeaponsSmithing
        [filterTypeNames[ITEMFILTERTYPE_AF_RETRAIT_WEAPONS]]      = true, --WeaponsRetrait
    },
    [filterTypeNames[ITEMFILTERTYPE_JEWELRY]] = {
        [filterTypeNames[ITEMFILTERTYPE_AF_JEWELRY_CRAFTING]]     = true, --JewelryCraftingStation
        [filterTypeNames[ITEMFILTERTYPE_AF_RETRAIT_JEWELRY]]      = true, --JewelryRetrait
    },
}
AF.normalFilter2CraftingFilter = normalFilter2CraftingFilter

--There are no subfilter bars active at the following inventory panels. Used for debug messages!
local subFiltersBarInactive = {
    [ITEMFILTERTYPE_QUEST]          = INVENTORY_QUEST_ITEM,  -- Inventory: Quest items
    --[ITEMFILTERTYPE_TRADING_HOUSE]  = false,                 -- No inventory! Trading house search
}
AF.subFiltersBarInactive = subFiltersBarInactive

--The possible subfilter groups for each inventory type, trade skill type and filtertype.
local subfilterGroups = {
    --Player inventory
    [INVENTORY_BACKPACK] = {
        [CRAFTING_TYPE_INVALID] = {
            [ITEMFILTERTYPE_ALL] = {},
            [ITEMFILTERTYPE_WEAPONS] = {},
            [ITEMFILTERTYPE_ARMOR] = {},
            [ITEMFILTERTYPE_JEWELRY] = {},
            [ITEMFILTERTYPE_JEWELRYCRAFTING] = {},
            [ITEMFILTERTYPE_CONSUMABLE] = {},
            [ITEMFILTERTYPE_CRAFTING] = {},
            [ITEMFILTERTYPE_FURNISHING] = {},
            [ITEMFILTERTYPE_MISCELLANEOUS] = {},
            [ITEMFILTERTYPE_JUNK] = {},
        },
    },
    --Bank
    [INVENTORY_BANK] = {
        [CRAFTING_TYPE_INVALID] = {
            [ITEMFILTERTYPE_ALL] = {},
            [ITEMFILTERTYPE_WEAPONS] = {},
            [ITEMFILTERTYPE_ARMOR] = {},
            [ITEMFILTERTYPE_JEWELRY] = {},
            [ITEMFILTERTYPE_JEWELRYCRAFTING] = {},
            [ITEMFILTERTYPE_CONSUMABLE] = {},
            [ITEMFILTERTYPE_CRAFTING] = {},
            [ITEMFILTERTYPE_FURNISHING] = {},
            [ITEMFILTERTYPE_MISCELLANEOUS] = {},
            [ITEMFILTERTYPE_JUNK] = {},
        },
    },
    --Guild bank
    [INVENTORY_GUILD_BANK] = {
        [CRAFTING_TYPE_INVALID] = {
            [ITEMFILTERTYPE_ALL] = {},
            [ITEMFILTERTYPE_WEAPONS] = {},
            [ITEMFILTERTYPE_ARMOR] = {},
            [ITEMFILTERTYPE_JEWELRY] = {},
            [ITEMFILTERTYPE_JEWELRYCRAFTING] = {},
            [ITEMFILTERTYPE_CONSUMABLE] = {},
            [ITEMFILTERTYPE_CRAFTING] = {},
            [ITEMFILTERTYPE_FURNISHING] = {},
            [ITEMFILTERTYPE_MISCELLANEOUS] = {},
        },
    },
    --Craft bag
    [INVENTORY_CRAFT_BAG] = {
        [CRAFTING_TYPE_INVALID] = {
            [ITEMFILTERTYPE_ALL] = {},
            [ITEMFILTERTYPE_BLACKSMITHING] = {},
            [ITEMFILTERTYPE_CLOTHING] = {},
            [ITEMFILTERTYPE_WOODWORKING] = {},
            [ITEMFILTERTYPE_ALCHEMY] = {},
            [ITEMFILTERTYPE_ENCHANTING] = {},
            [ITEMFILTERTYPE_PROVISIONING] = {},
            [ITEMFILTERTYPE_JEWELRYCRAFTING] = {},
            [ITEMFILTERTYPE_STYLE_MATERIALS] = {},
            [ITEMFILTERTYPE_TRAIT_ITEMS] = {},
        },
    },
    --Vendor buy
    [INVENTORY_TYPE_VENDOR_BUY] = {
        [CRAFTING_TYPE_INVALID] = {
            [ITEMFILTERTYPE_ALL] = {},
            [ITEMFILTERTYPE_WEAPONS] = {},
            [ITEMFILTERTYPE_ARMOR] = {},
            [ITEMFILTERTYPE_CONSUMABLE] = {},
            [ITEMFILTERTYPE_CRAFTING] = {},
            [ITEMFILTERTYPE_MISCELLANEOUS] = {},
        },
    },

    --Crafting SMITHING: Create
    --[[
    [LF_SMITHING_CREATION] = {
        [CRAFTING_TYPE_BLACKSMITHING] = {
            [ITEMFILTERTYPE_ALL] = {},
            [ITEMFILTERTYPE_AF_CREATE_ARMOR_SMITHING] = {},
            [ITEMFILTERTYPE_AF_CREATE_WEAPONS_SMITHING] = {},
        },
        [CRAFTING_TYPE_WOODWORKING] = {
            [ITEMFILTERTYPE_ALL] = {},
            [ITEMFILTERTYPE_AF_CREATE_ARMOR_WOODWORKING] = {},
            [ITEMFILTERTYPE_AF_CREATE_WEAPONS_WOODWORKING] = {},
        },
        [CRAFTING_TYPE_CLOTHIER] = {
            [ITEMFILTERTYPE_ALL] = {},
            [ITEMFILTERTYPE_AF_CREATE_ARMOR_CLOTHIER] = {},
        },
    },
    ]]

    --Crafting SMITHING: Refine
    [LF_SMITHING_REFINE] = {
        [CRAFTING_TYPE_BLACKSMITHING] = {
            [ITEMFILTERTYPE_ALL] = {},
            [ITEMFILTERTYPE_AF_REFINE_SMITHING] = {},
        },
        [CRAFTING_TYPE_WOODWORKING] = {
            [ITEMFILTERTYPE_ALL] = {},
            [ITEMFILTERTYPE_AF_REFINE_WOODWORKING] = {},
        },
        [CRAFTING_TYPE_CLOTHIER] = {
            [ITEMFILTERTYPE_ALL] = {},
            [ITEMFILTERTYPE_AF_REFINE_CLOTHIER] = {},
        },
    },

    --Crafting SMITHING: Deconstruction
    [LF_SMITHING_DECONSTRUCT] = {
        [CRAFTING_TYPE_BLACKSMITHING] = {
            [ITEMFILTERTYPE_ALL] = {},
            [ITEMFILTERTYPE_AF_WEAPONS_SMITHING] = {},
            [ITEMFILTERTYPE_AF_ARMOR_SMITHING] = {},
        },
        [CRAFTING_TYPE_WOODWORKING] = {
            [ITEMFILTERTYPE_ALL] = {},
            [ITEMFILTERTYPE_AF_WEAPONS_WOODWORKING] = {},
            [ITEMFILTERTYPE_AF_ARMOR_WOODWORKING] = {},
        },
        [CRAFTING_TYPE_CLOTHIER] = {
            [ITEMFILTERTYPE_ALL] = {},
            [ITEMFILTERTYPE_AF_ARMOR_CLOTHIER] = {},
        },
    },

    --Crafting SMITHING: Improvement
    [LF_SMITHING_IMPROVEMENT] = {
        [CRAFTING_TYPE_BLACKSMITHING] = {
            [ITEMFILTERTYPE_ALL] = {},
            [ITEMFILTERTYPE_AF_WEAPONS_SMITHING] = {},
            [ITEMFILTERTYPE_AF_ARMOR_SMITHING] = {},
        },
        [CRAFTING_TYPE_WOODWORKING] = {
            [ITEMFILTERTYPE_ALL] = {},
            [ITEMFILTERTYPE_AF_WEAPONS_WOODWORKING] = {},
            [ITEMFILTERTYPE_AF_ARMOR_WOODWORKING] = {},
        },
        [CRAFTING_TYPE_CLOTHIER] = {
            [ITEMFILTERTYPE_ALL] = {},
            [ITEMFILTERTYPE_AF_ARMOR_CLOTHIER] = {},
        },
    },

    --Crafting SMITHING: Research
    [LF_SMITHING_RESEARCH] = {
        [CRAFTING_TYPE_BLACKSMITHING] = {
            [ITEMFILTERTYPE_ALL] = {},
            [ITEMFILTERTYPE_AF_WEAPONS_SMITHING] = {},
            [ITEMFILTERTYPE_AF_ARMOR_SMITHING] = {},
        },
        [CRAFTING_TYPE_WOODWORKING] = {
            [ITEMFILTERTYPE_ALL] = {},
            [ITEMFILTERTYPE_AF_WEAPONS_WOODWORKING] = {},
            [ITEMFILTERTYPE_AF_ARMOR_WOODWORKING] = {},
        },
        [CRAFTING_TYPE_CLOTHIER] = {
            [ITEMFILTERTYPE_ALL] = {},
            [ITEMFILTERTYPE_AF_ARMOR_CLOTHIER] = {},
        },
    },

    --Crafting JEWELRY: Create
    --[[
    [LF_JEWELRY_CREATION] = {
        [CRAFTING_TYPE_JEWELRYCRAFTING] = {
            [ITEMFILTERTYPE_ALL] = {},
            [ITEMFILTERTYPE_AF_CREATE_JEWELRY] = {},
        },
    },
    ]]

    --Crafting JEWELRY: Refine
    [LF_JEWELRY_REFINE] = {
        [CRAFTING_TYPE_JEWELRYCRAFTING] = {
            [ITEMFILTERTYPE_ALL] = {},
            [ITEMFILTERTYPE_AF_REFINE_JEWELRY] = {},
        },
    },

    --Crafting JEWELRY: Deconstruction
    [LF_JEWELRY_DECONSTRUCT] = {
        [CRAFTING_TYPE_JEWELRYCRAFTING] = {
            [ITEMFILTERTYPE_ALL] = {},
            [ITEMFILTERTYPE_AF_JEWELRY_CRAFTING] = {},
        },
    },
    --Crafting JEWELRY: Improvement
    [LF_JEWELRY_IMPROVEMENT] = {
        [CRAFTING_TYPE_JEWELRYCRAFTING] = {
            [ITEMFILTERTYPE_ALL] = {},
            [ITEMFILTERTYPE_AF_JEWELRY_CRAFTING] = {},
        },
    },

    --Crafting JEWELRY: Research
    [LF_JEWELRY_RESEARCH] = {
        [CRAFTING_TYPE_JEWELRYCRAFTING] = {
            [ITEMFILTERTYPE_ALL] = {},
            [ITEMFILTERTYPE_AF_JEWELRY_CRAFTING] = {},
        },
    },

    --Crafting ENCHANTING: Creation
    [LF_ENCHANTING_CREATION] = {
        [CRAFTING_TYPE_ENCHANTING] = {
            [ITEMFILTERTYPE_ALL] = {},
            --[ITEMFILTERTYPE_AF_RUNES_ENCHANTING] = {}, TODO: Currently disabled as no extra filters are needed/possible
        },
    },
    --Crafting ENCHANTING: Extraction
    [LF_ENCHANTING_EXTRACTION] = {
        [CRAFTING_TYPE_ENCHANTING] = {
            [ITEMFILTERTYPE_ALL] = {},
            [ITEMFILTERTYPE_AF_GLYPHS_ENCHANTING] = {},
        },
    },
    --Houes bank withdraw
    [INVENTORY_HOUSE_BANK] = {
        [CRAFTING_TYPE_INVALID] = {
            [ITEMFILTERTYPE_ALL] = {},
            [ITEMFILTERTYPE_WEAPONS] = {},
            [ITEMFILTERTYPE_ARMOR] = {},
            [ITEMFILTERTYPE_CONSUMABLE] = {},
            [ITEMFILTERTYPE_CRAFTING] = {},
            [ITEMFILTERTYPE_FURNISHING] = {},
            [ITEMFILTERTYPE_MISCELLANEOUS] = {},
            [ITEMFILTERTYPE_JUNK] = {},
            [ITEMFILTERTYPE_JEWELRY] = {},
            [ITEMFILTERTYPE_JEWELRYCRAFTING] = {},
        },
    },
    --Retrait
    [LF_RETRAIT] = {
        [CRAFTING_TYPE_INVALID] = {
            [ITEMFILTERTYPE_ALL] = {},
            [ITEMFILTERTYPE_AF_RETRAIT_ARMOR]   = {},
            [ITEMFILTERTYPE_AF_RETRAIT_WEAPONS] = {},
            [ITEMFILTERTYPE_AF_RETRAIT_JEWELRY] = {},
        },
    },
}
AF.subfilterGroups = subfilterGroups

--The filter bar parent controls
local filterBarParents = {
    [inventoryNames[INVENTORY_BACKPACK]]        = controlsForChecks.inv,
    [inventoryNames[INVENTORY_BANK]]            = controlsForChecks.bank,
    [inventoryNames[INVENTORY_GUILD_BANK]]      = controlsForChecks.guildBank,
    [inventoryNames[INVENTORY_TYPE_VENDOR_BUY]] = controlsForChecks.storeWindow,
    [inventoryNames[INVENTORY_CRAFT_BAG]]       = controlsForChecks.craftBag,
    --[inventoryNames[LF_SMITHING_CREATION]]      = controlsForChecks.smithing.creationPanel.control,
    [inventoryNames[LF_SMITHING_REFINE]]        = controlsForChecks.smithing.refinementPanel.control,
    [inventoryNames[LF_SMITHING_DECONSTRUCT]]   = controlsForChecks.smithing.deconstructionPanel.control,
    [inventoryNames[LF_SMITHING_IMPROVEMENT]]   = controlsForChecks.smithing.improvementPanel.control,
    [inventoryNames[LF_SMITHING_RESEARCH]]      = controlsForChecks.smithing.researchPanel.control,
    --[inventoryNames[LF_JEWELRY_CREATION]]       = controlsForChecks.smithing.creationPanel.control,
    [inventoryNames[LF_JEWELRY_REFINE]]         = controlsForChecks.smithing.refinementPanel.control,
    [inventoryNames[LF_JEWELRY_DECONSTRUCT]]    = controlsForChecks.smithing.deconstructionPanel.control,
    [inventoryNames[LF_JEWELRY_IMPROVEMENT]]    = controlsForChecks.smithing.improvementPanel.control,
    [inventoryNames[LF_JEWELRY_RESEARCH]]       = controlsForChecks.smithing.researchPanel.control,
    [inventoryNames[LF_ENCHANTING_CREATION]]    = controlsForChecks.enchanting.inventoryControl,
    [inventoryNames[LF_ENCHANTING_EXTRACTION]]  = controlsForChecks.enchanting.inventoryControl,
    [inventoryNames[INVENTORY_HOUSE_BANK]]      = controlsForChecks.houseBank,
    [inventoryNames[LF_RETRAIT]]                = controlsForChecks.retraitControl,
}
AF.filterBarParents = filterBarParents

--The subfilter bars button names
local subfilterButtonNames = {
    [ITEMFILTERTYPE_ALL] = {
        AF_CONST_ALL,
    },
    [ITEMFILTERTYPE_WEAPONS] = {
        "HealStaff", "DestructionStaff", "Bow", "TwoHand", "OneHand", AF_CONST_ALL,
    },
    --[[
    [ITEMFILTERTYPE_AF_CREATE_ARMOR_CLOTHIER] = {
        "Heavy", AF_CONST_ALL
    },
    [ITEMFILTERTYPE_AF_CREATE_ARMOR_SMITHING] = {
        "Medium", "LightArmor", AF_CONST_ALL
    },
    [ITEMFILTERTYPE_AF_CREATE_ARMOR_WOODWORKING] = {
        "Shield", AF_CONST_ALL
    },
    [ITEMFILTERTYPE_AF_CREATE_WEAPONS_SMITHING] = {
        "OneHand", "TwoHand", AF_CONST_ALL
    },
    [ITEMFILTERTYPE_AF_CREATE_WEAPONS_WOODWORKING] = {
        "Bow", "DestructionStaff", "HealStaff", AF_CONST_ALL
    },
    [ITEMFILTERTYPE_AF_CREATE_JEWELRY] = {
        "Ring", "Neck", AF_CONST_ALL,
    },
    ]]
    [ITEMFILTERTYPE_AF_REFINE_CLOTHIER] = {
        "RawMaterialClothier", AF_CONST_ALL,
    },
    [ITEMFILTERTYPE_AF_REFINE_SMITHING] = {
        "RawMaterialSmithing", AF_CONST_ALL,
    },
    [ITEMFILTERTYPE_AF_REFINE_WOODWORKING] = {
        "RawMaterialWoodworking", AF_CONST_ALL,
    },
    [ITEMFILTERTYPE_AF_WEAPONS_SMITHING] = {
        "TwoHand", "OneHand", AF_CONST_ALL,
    },
    [ITEMFILTERTYPE_AF_WEAPONS_WOODWORKING] = {
        "HealStaff", "DestructionStaff", "Bow", AF_CONST_ALL,
    },
    [ITEMFILTERTYPE_ARMOR] = {
        --"Vanity", --> Moved to Miscelaneous
        "Shield", "Clothing", "LightArmor", "Medium",
        "Heavy", AF_CONST_ALL,
    },
    [ITEMFILTERTYPE_JEWELRY] = {
        "Neck", "Ring", AF_CONST_ALL,
    },
    [ITEMFILTERTYPE_AF_ARMOR_SMITHING] = {
        "Heavy", AF_CONST_ALL,
    },
    [ITEMFILTERTYPE_AF_ARMOR_CLOTHIER] = {
        "LightArmor", "Medium", AF_CONST_ALL,
    },
    [ITEMFILTERTYPE_AF_ARMOR_WOODWORKING] = {
        "Shield", AF_CONST_ALL,
    },
    [ITEMFILTERTYPE_AF_RUNES_ENCHANTING] = {
        AF_CONST_ALL,
    },
    [ITEMFILTERTYPE_AF_GLYPHS_ENCHANTING] = {
        "WeaponGlyph", "ArmorGlyph", "JewelryGlyph", AF_CONST_ALL,
    },
    [ITEMFILTERTYPE_CONSUMABLE] = {
        "Trophy", "Repair", "Container", "Writ", "Motif", "Poison",
        "Potion", "Recipe", "Drink", "Food", "Crown", AF_CONST_ALL,
    },
    [ITEMFILTERTYPE_CRAFTING] = {
        "FurnishingMat", "AllTraits", --"JewelryTrait", "WeaponTrait", "ArmorTrait", -> Removed due to not enough place! Combined within "AllTraits"
        "Style",
        "JewelryCrafting", "Provisioning", "Enchanting", "Alchemy", "Woodworking",
        "Clothier", "Blacksmithing", AF_CONST_ALL,
    },
    [ITEMFILTERTYPE_FURNISHING] = {
        "TargetDummy", "Seating", "Ornamental", "Light", "CraftingStation",
        AF_CONST_ALL,
    },
    [ITEMFILTERTYPE_MISCELLANEOUS] = {
        "Vanity", "Trash", "Fence", "Trophy", "Tool", "Bait", "Siege", "SoulGem",
        "Glyphs", AF_CONST_ALL,
    },
    [ITEMFILTERTYPE_JUNK] = {
        "Miscellaneous", "Furnishings", "Materials", "Consumable", "Jewelry", "Armor", "Weapon",
        AF_CONST_ALL,
    },
    [ITEMFILTERTYPE_BLACKSMITHING] = {
        "FurnishingMat", "Temper", "RefinedMaterialSmithing", "RawMaterialSmithing", AF_CONST_ALL,
    },
    [ITEMFILTERTYPE_CLOTHING] = {
        "FurnishingMat", "Tannin", "RefinedMaterialClothier", "RawMaterialClothier", AF_CONST_ALL,
    },
    [ITEMFILTERTYPE_WOODWORKING] = {
        "FurnishingMat", "Resin", "RefinedMaterialWoodworking", "RawMaterialWoodworking", AF_CONST_ALL,
    },
    [ITEMFILTERTYPE_ALCHEMY] = {
        "FurnishingMat", "Oil", "Water", "Reagent", AF_CONST_ALL,
    },
    [ITEMFILTERTYPE_ENCHANTING] = {
        "FurnishingMat", "Potency", "Essence", "Aspect", AF_CONST_ALL,
    },
    [ITEMFILTERTYPE_PROVISIONING] = {
        "FurnishingMat", "Bait", "RareIngredient", "OldIngredient",
        "DrinkIngredient", "FoodIngredient", AF_CONST_ALL,
    },
    [ITEMFILTERTYPE_JEWELRYCRAFTING] = {
        "FurnishingMat", "Plating", "RefinedMaterialJewelry", "RawPlating", "RawMaterialJewelry", AF_CONST_ALL,
    },
    [ITEMFILTERTYPE_AF_JEWELRY_CRAFTING] = {
        "Ring", "Neck", AF_CONST_ALL,
    },
    [ITEMFILTERTYPE_AF_REFINE_JEWELRY] = {
        "RawMaterialJewelry", "RawPlating", "JewelryRawTrait", AF_CONST_ALL,
    },
    [ITEMFILTERTYPE_STYLE_MATERIALS] = {
        "CrownStyle", "ExoticStyle", "AllianceStyle", "RareStyle",
        "NormalStyle", AF_CONST_ALL,
    },
    [ITEMFILTERTYPE_TRAIT_ITEMS] = {
        "JewelryAllTrait", "WeaponTrait", "ArmorTrait", AF_CONST_ALL,
    },
    [ITEMFILTERTYPE_AF_RETRAIT_ARMOR] = {
        "Shield", "LightArmor", "Medium", "Heavy", AF_CONST_ALL,
    },
    [ITEMFILTERTYPE_AF_RETRAIT_WEAPONS] = {
        "HealStaff", "DestructionStaff", "Bow", "TwoHand", "OneHand", AF_CONST_ALL,
    },
    [ITEMFILTERTYPE_AF_RETRAIT_JEWELRY] = {
        "Neck", "Ring", AF_CONST_ALL,
    },
}
--Exclude some of the buttons at an inventory type, craft type, and filter type?
--If you add entries be sure to add the other ones, sharing the same AF.subfilterCallbacks[groupName][subfilterName]
--as well!
--[[
local excludeButtonNamesfromSubFilterBar = {
    --InventoryName
    [INVENTORY_CRAFT_BAG] = {
        --TradeSkillNames
        [CRAFTING_TYPE_INVALID] = {
            --FilterTypeNames
            [ITEMFILTERTYPE_CRAFTING] =
                --Exclude this single buttons here:
                "AllTraits"
        }
    },
    [INVENTORY_BACKPACK] = {
        [CRAFTING_TYPE_INVALID] = {
            [ITEMFILTERTYPE_CRAFTING] = {
                --Exclude these buttons here:
                {"JewelryTrait", "WeaponTrait", "ArmorTrait"}
            }
        }
    },
    [INVENTORY_BANK] = {
        [CRAFTING_TYPE_INVALID] = {
            [ITEMFILTERTYPE_CRAFTING] = {
                --Exclude these buttons here:
                {"JewelryTrait", "WeaponTrait", "ArmorTrait"}
            }
        }
    },
    [INVENTORY_GUILD_BANK] = {
        [CRAFTING_TYPE_INVALID] = {
            [ITEMFILTERTYPE_CRAFTING] = {
                --Exclude these buttons here:
                {"JewelryTrait", "WeaponTrait", "ArmorTrait"}
            }
        }
    },
    [INVENTORY_HOUSE_BANK] = {
        [CRAFTING_TYPE_INVALID] = {
            [ITEMFILTERTYPE_CRAFTING] = {
                --Exclude these buttons here:
                {"JewelryTrait", "WeaponTrait", "ArmorTrait"}
            }
        }
    },
    [INVENTORY_TYPE_VENDOR_BUY] = {
        [CRAFTING_TYPE_INVALID] = {
            [ITEMFILTERTYPE_CRAFTING] = {
                --Exclude these buttons here:
                {"JewelryTrait", "WeaponTrait", "ArmorTrait"}
            }
        }
    },
}
]]
AF.subfilterButtonNames = subfilterButtonNames

--SubfilterButton entries which should not be added to dropdownCallback entries
local subfilterButtonEntriesNotForDropdownCallback = {
    [ITEMFILTERTYPE_ARMOR] = {
        ["doNotAdd"] = {"Clothing", "LightArmor", "Medium", "Heavy"}, --These are combined into the entry "Body"
        ["replaceWith"] = "Body",
    },
}

--Build the keys for the dropdown callback tables used in AF.util.BuildDropdownCallbacks()
--[[
local keys = {
    All = {},
    Weapons = {
        "OneHand", "TwoHand", "Bow", "DestructionStaff", "HealStaff",
    },
    WeaponsSmithing = {
        "OneHand", "TwoHand",
    },
    WeaponsWoodworking = {
        "Bow", "DestructionStaff", "HealStaff",
    },
    Armor = {
        "Body", "Shield", --"Vanity", --> Moved to Miscelaneous
    },
    ArmorWoodworking = {
        "Shield",
    },
    ArmorSmithing = {
        "Heavy",
    },
    ArmorClothier = {
        "LightArmor", "Medium",
    },
    Consumables = {
        "Crown", "Food", "Drink", "Recipe", "Potion", "Poison", "Motif", "Writ", "Container", "Repair", "Trophy",
    },
    Crafting = {
        "Blacksmithing", "Clothier", "Woodworking", "Alchemy", "Enchanting", "Provisioning", "JewelryCrafting", "Style", "AllTraits", --"WeaponTrait", "ArmorTrait", "JewelryTrait",
    },
    Furnishings = {
        "CraftingStation", "Light", "Ornamental", "Seating", "TargetDummy",
    },
    Miscellaneous = {
        "Glyphs", "SoulGem", "Siege", "Bait", "Tool", "Trophy", "Fence", "Trash", "Vanity",
    },
    Junk = {
        "Weapon", "Armor", "Jewelry", "Consumable", "Materials", "Furnishings", "Miscellaneous",
    },
    Blacksmithing = {
        "RawMaterial", "RefinedMaterial", "Temper",
    },
    Clothing = {
        "RawMaterial", "RefinedMaterial", "Tannin",
    },
    Woodworking = {
        "RawMaterial", "RefinedMaterial", "Resin",
    },
    Alchemy = {
        "Reagent", "Water", "Oil",
    },
    Enchanting = {
        "Aspect", "Essence", "Potency",
    },
    --TODO: Currently disabled as rune filters at the enchanting creation panel on ITEMFILTERTYPE_ base are not possible at the moment
    --Runes = {
    --},
    Glyphs  = {
        "WeaponGlyph", "ArmorGlyph", "JewelryGlyph",
    },
    Provisioning = {
        "FoodIngredient", "DrinkIngredient", "OldIngredient", "RareIngredient", "Bait",
    },
    Style = {
        "NormalStyle", "RareStyle", "AllianceStyle", "ExoticStyle", "CrownStyle",
    },
    Traits = {
        "ArmorTrait", "WeaponTrait", "JewelryTrait",
    },
    Jewelry = {
        "Neck", "Ring"
    },
    JewelryCrafting = {
        "RawPlating", "RawMaterial", "Plating", "RefinedMaterial",
    },
    JewelryCraftingStation = {
        "Neck", "Ring"
    },
    JewelryCraftingStationRefine = {
        "RawMaterial", "RawPlating", "RawTrait",
    },
    RefineSmithing = {
        "RawMaterial",
    },
    RefineClothier = {
        "RawMaterial",
    },
    RefineWoodworking = {
        "RawMaterial",
    },
    CreateArmorSmithing = {
        "Armor",
    },
    CreateWeaponsSmithing = {
        "OneHand", "TwoHand",
    },
    CreateArmorClothier = {
        "Medium", "LightArmor",
    },
    CreateWeaponsWoodworking = {
        "Bow", "DestructionStaff", "HealStaff",
    },
    CreateArmorWoodworking = {
        "Shield",
    },
    CreateJewelryCraftingStation = {
        "Ring", "Neck",
    },
}
]]
local keys = {
    [AF_CONST_ALL] = {},
}
--For each entry in subfilterButtonNames:
--Get the "key name" by mapping the subfilterButton key to it's name using filterTypeNames
for subfilterButtonKey, subfilterButtonData in pairs(subfilterButtonNames) do
    local dropDownCallbackKeyName = filterTypeNames[subfilterButtonKey] or ""
    if dropDownCallbackKeyName ~= "" then
        keys[dropDownCallbackKeyName] = {}
        local keysDropDownCallbackKeyName = keys[dropDownCallbackKeyName]
        local doNotAddToDropdownCallbacks = subfilterButtonEntriesNotForDropdownCallback[subfilterButtonKey]
        local replacementWasAdded = false
        --Loop over the subfilterButtonData and get each key, except the ALL entry
        for _, keyName in ipairs(subfilterButtonData) do
            if keyName ~= AF_CONST_ALL then
                local doAdd = true
                if doNotAddToDropdownCallbacks ~= nil then
                    for _, doNotAddToDropdownCallbackEntry in ipairs(doNotAddToDropdownCallbacks.doNotAdd) do
                        if keyName == doNotAddToDropdownCallbackEntry then
                            doAdd = false
                            break -- end the loop
                        end
                    end
                end
                if doAdd == true then
                    table.insert(keysDropDownCallbackKeyName, keyName)
                else
                    if not replacementWasAdded and doNotAddToDropdownCallbacks ~= nil and doNotAddToDropdownCallbacks["replaceWith"] ~= nil then
                        table.insert(keysDropDownCallbackKeyName, doNotAddToDropdownCallbacks["replaceWith"])
                        replacementWasAdded = true
                    end
                end
            end
        end
    end
end
AF.dropdownCallbackKeys = keys

--The different filter groups for the CraftBag
local craftBagFilterGroups = {
    filterTypeNames[ITEMFILTERTYPE_BLACKSMITHING],
    filterTypeNames[ITEMFILTERTYPE_CLOTHING],
    filterTypeNames[ITEMFILTERTYPE_WOODWORKING],
    filterTypeNames[ITEMFILTERTYPE_ALCHEMY],
    filterTypeNames[ITEMFILTERTYPE_ENCHANTING],
    filterTypeNames[ITEMFILTERTYPE_PROVISIONING],
    filterTypeNames[ITEMFILTERTYPE_STYLE_MATERIALS],
    filterTypeNames[ITEMFILTERTYPE_TRAIT_ITEMS],
    filterTypeNames[ITEMFILTERTYPE_JEWELRYCRAFTING],
}
AF.craftBagFilterGroups = craftBagFilterGroups

--The list controls for the reanchoring of subfilter bars
local listControlForSubfilterBarReanchor = {
    [LF_SMITHING_RESEARCH]  =
    {
        control                 = ZO_SmithingTopLevelResearchPanelResearchLineList,
        moveInvBottomBarDown    = ZO_SmithingTopLevelResearchPanelInfoBar,
    },
    [LF_JEWELRY_RESEARCH]   =
    {
        control                 = ZO_SmithingTopLevelResearchPanelResearchLineList,
        moveInvBottomBarDown    = ZO_SmithingTopLevelResearchPanelInfoBar,
    },
}
AF.listControlForSubfilterBarReanchor = listControlForSubfilterBarReanchor

--The indices of the research horizontal scrollList for the different weapontypes
local researchLineListIndicesOfWeaponOrArmorOrJewelryTypes = {
    [CRAFTING_TYPE_BLACKSMITHING] = {
        --1hd
        [WEAPONTYPE_AXE]                = 0,
        [WEAPONTYPE_HAMMER]             = -1,
        [WEAPONTYPE_SWORD]              = -2,
        [WEAPONTYPE_DAGGER]             = -6,
        --2hd
        [WEAPONTYPE_TWO_HANDED_AXE]     = -3,
        [WEAPONTYPE_TWO_HANDED_HAMMER]  = -4,
        [WEAPONTYPE_TWO_HANDED_SWORD]   = -5,
    },
    [CRAFTING_TYPE_WOODWORKING] = {
        --2hd bow
        [WEAPONTYPE_BOW]                = 0,
        --2hd staffs
        [WEAPONTYPE_FIRE_STAFF]         = -1,
        [WEAPONTYPE_FROST_STAFF]        = -2,
        [WEAPONTYPE_LIGHTNING_STAFF]    = -3,
        [WEAPONTYPE_HEALING_STAFF]      = -4,
    },
    [CRAFTING_TYPE_CLOTHIER] = {
    },
}
AF.researchLineListIndicesOfWeaponOrArmorOrJewelryTypes = researchLineListIndicesOfWeaponOrArmorOrJewelryTypes

--The possible research lines and their item filter types
local blacksmithResearchLines = {
    --Weapons
    [1]=WEAPONTYPE_AXE, --
    [2]=WEAPONTYPE_HAMMER, --
    [3]=WEAPONTYPE_SWORD, --
    [4]=WEAPONTYPE_TWO_HANDED_AXE, --
    [5]=WEAPONTYPE_TWO_HANDED_HAMMER, --
    [6]=WEAPONTYPE_TWO_HANDED_SWORD, --
    [7]=WEAPONTYPE_DAGGER, --
    --Armor
    [8]=EQUIP_TYPE_CHEST, --
    [9]=EQUIP_TYPE_FEET, --
    [10]=EQUIP_TYPE_HAND, --
    [11]=EQUIP_TYPE_HEAD, --
    [12]=EQUIP_TYPE_LEGS, --
    [13]=EQUIP_TYPE_SHOULDERS, --
    [14]=EQUIP_TYPE_WAIST, --
}
local blacksmithResearchLinesArmorType = {
    --Armor
    [8]=ARMORTYPE_HEAVY, --
    [9]=ARMORTYPE_HEAVY, --
    [10]=ARMORTYPE_HEAVY, --
    [11]=ARMORTYPE_HEAVY, --
    [12]=ARMORTYPE_HEAVY, --
    [13]=ARMORTYPE_HEAVY, --
    [14]=ARMORTYPE_HEAVY, --
}
local clothierResearchLines = {
    --Light armor
    [1]=EQUIP_TYPE_CHEST, --
    [2]=EQUIP_TYPE_FEET, --
    [3]=EQUIP_TYPE_HAND, --
    [4]=EQUIP_TYPE_HEAD, --
    [5]=EQUIP_TYPE_LEGS, --
    [6]=EQUIP_TYPE_SHOULDERS, --
    [7]=EQUIP_TYPE_WAIST, --
    --Medium armor
    [8]=EQUIP_TYPE_CHEST, --
    [9]=EQUIP_TYPE_FEET, --
    [10]=EQUIP_TYPE_HAND, --
    [11]=EQUIP_TYPE_HEAD, --
    [12]=EQUIP_TYPE_LEGS, --
    [13]=EQUIP_TYPE_SHOULDERS, --
    [14]=EQUIP_TYPE_WAIST, --
}
local clothierResearchLinesArmorTypes = {
    --Light Armor
    [1]=ARMORTYPE_LIGHT, --
    [2]=ARMORTYPE_LIGHT, --
    [3]=ARMORTYPE_LIGHT, --
    [4]=ARMORTYPE_LIGHT, --
    [5]=ARMORTYPE_LIGHT, --
    [6]=ARMORTYPE_LIGHT, --
    [7]=ARMORTYPE_LIGHT, --
    --Medium armor
    [8]=ARMORTYPE_MEDIUM, --
    [9]=ARMORTYPE_MEDIUM, --
    [10]=ARMORTYPE_MEDIUM, --
    [11]=ARMORTYPE_MEDIUM, --
    [12]=ARMORTYPE_MEDIUM, --
    [13]=ARMORTYPE_MEDIUM, --
    [14]=ARMORTYPE_MEDIUM, --
}

local woodworkingResearchLines = {
    --Weapons
    [1]=WEAPONTYPE_BOW,             -- Bow
    [2]=WEAPONTYPE_FIRE_STAFF,      -- Fire staff
    [3]=WEAPONTYPE_FROST_STAFF,     -- Ice staff
    [4]=WEAPONTYPE_LIGHTNING_STAFF, -- Lightning staff
    [5]=WEAPONTYPE_HEALING_STAFF,   -- Heal staff
    --Armor
    [6]=EQUIP_TYPE_OFF_HAND,        -- Shield
}
local woodworkingResearchLinesArmorType = {
    --Armor
    [6]=ARMORTYPE_NONE,             -- Shield
}
AF.researchLinesToFilterTypes = {}
AF.researchLinesToFilterTypes[CRAFTING_TYPE_BLACKSMITHING]  = blacksmithResearchLines
AF.researchLinesToFilterTypes[CRAFTING_TYPE_CLOTHIER]       = clothierResearchLines
AF.researchLinesToFilterTypes[CRAFTING_TYPE_WOODWORKING]    = woodworkingResearchLines
AF.researchLinesToArmorType = {}
AF.researchLinesToArmorType[CRAFTING_TYPE_BLACKSMITHING]    = blacksmithResearchLinesArmorType
AF.researchLinesToArmorType[CRAFTING_TYPE_CLOTHIER]         = clothierResearchLinesArmorTypes
AF.researchLinesToArmorType[CRAFTING_TYPE_WOODWORKING]      = woodworkingResearchLinesArmorType
