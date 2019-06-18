local util = AdvancedFilters.util
local enStrings = AdvancedFilters.strings
local strings = {
    --SHARED
    All = "Todo",
    Trophy = util.Localize(SI_ITEMTYPE5),

    --WEAPON
    OneHand = "Una Mano",
    TwoHand = "Dos Manos",
    Bow = util.Localize(SI_WEAPONTYPE8),
    DestructionStaff = "Vara de destrucci\195\179n",
    HealStaff = util.Localize(SI_WEAPONTYPE9),

    Axe = util.Localize(SI_WEAPONTYPE1),
    Sword = util.Localize(SI_WEAPONTYPE3),
    Hammer = util.Localize(SI_WEAPONTYPE2),
    TwoHandAxe = "2H "..util.Localize(SI_WEAPONTYPE1),
    TwoHandSword = "2H "..util.Localize(SI_WEAPONTYPE3),
    TwoHandHammer = "2H "..util.Localize(SI_WEAPONTYPE2),
    Dagger = util.Localize(SI_WEAPONTYPE11),
    Fire = util.Localize(SI_WEAPONTYPE12),
    Frost = util.Localize(SI_WEAPONTYPE13),
    Lightning = util.Localize(SI_WEAPONTYPE15),

    --ARMOR
    Heavy = util.Localize(SI_ARMORTYPE3),
    Medium = util.Localize(SI_ARMORTYPE2),
    LightArmor = util.Localize(SI_ARMORTYPE1),
    --Clothing = ,
    Shield = "Escudos",
    Jewelry = "Joyas",
    Vanity = "Varios",

    Head = "Cabeza",
    Chest = "Pecho",
    Shoulders = "Hombros",
    Hand = "Manos",
    Waist = "Cintura",
    Legs = "Piernas",
    Feet = "Pies",
    Ring = "Anillo",
    Neck = "Cuello",

    --CONSUMABLES
    Crown = util.Localize(SI_ITEMTYPE57),
    Food = util.Localize(SI_ITEMTYPE4),
    Drink = util.Localize(SI_ITEMTYPE12),
    Recipe = util.Localize(SI_ITEMTYPE29),
    Potion = util.Localize(SI_ITEMTYPE7),
    Poison = util.Localize(SI_ITEMTYPE30),
    Motif = util.Localize(SI_ITEMTYPE8),
    Writ = util.Localize(SI_ITEMTYPE60),
    Container = util.Localize(SI_ITEMTYPE18),
    Repair = "Reparaci\195\179n",

    --MATERIALS
    Blacksmithing = "Herrer\195\173a",
    Clothier = "Sastrer\195\173a",
    Woodworking = "Carpinter\195\173a",
    Alchemy = "Alquimia",
    Enchanting = "Encantamiento",
    Provisioning = "Cocina",
    Style = util.Localize(SI_ITEMTYPE44),
    WeaponTrait = util.Localize(SI_ITEMTYPE46),
    ArmorTrait = util.Localize(SI_ITEMTYPE45),
    FurnishingMat = util.Localize(SI_ITEMTYPE62),

    Reagent = util.Localize(SI_ITEMTYPE31),
    Water = util.Localize(SI_ITEMTYPE33),
    Oil = util.Localize(SI_ITEMTYPE58),
    Aspect = util.Localize(SI_ENCHANTINGRUNECLASSIFICATION1),
    Essence = util.Localize(SI_ENCHANTINGRUNECLASSIFICATION2),
    Potency = util.Localize(SI_ENCHANTINGRUNECLASSIFICATION3),
    FoodIngredient = zo_strformat("<<1>> - <<2>>", GetString("SI_ITEMTYPE", ITEMTYPE_INGREDIENT), GetString("SI_ITEMTYPE", ITEMTYPE_FOOD)),
    DrinkIngredient = zo_strformat("<<1>> - <<2>>", GetString("SI_ITEMTYPE", ITEMTYPE_INGREDIENT), GetString("SI_ITEMTYPE", ITEMTYPE_DRINK)),
    OldIngredient = zo_strformat("<<1>> - <<2>>", GetString("SI_ITEMTYPE", ITEMTYPE_INGREDIENT), GetString("SI_ITEMTYPE", ITEMTYPE_NONE)),
    RareIngredient = util.Localize(SI_SPECIALIZEDITEMTYPE48),

    --FURNISHINGS
    CraftingStation = util.Localize(SI_SPECIALIZEDITEMTYPE213),
    Light = util.Localize(SI_SPECIALIZEDITEMTYPE211),
    Ornamental = util.Localize(SI_SPECIALIZEDITEMTYPE210),
    Seating = util.Localize(SI_SPECIALIZEDITEMTYPE212),
    TargetDummy = util.Localize(SI_SPECIALIZEDITEMTYPE214),

    --MISCELLANEOUS
    Glyphs = "Glifos",
    SoulGem = util.Localize(SI_ITEMTYPE19),
    Siege = util.Localize(SI_ITEMTYPE6),
    Bait = "Cebo",
    Tool = util.Localize(SI_ITEMTYPE9),
    Fence = util.Localize(SI_INVENTORY_STOLEN_ITEM_TOOLTIP),
    Trash = util.Localize(SI_ITEMTYPE48),

    ArmorGlyph = util.Localize(SI_ITEMTYPE21),
    JewelryGlyph = util.Localize(SI_ITEMTYPE26),
    WeaponGlyph = util.Localize(SI_ITEMTYPE20),

    Runes = util.Localize(SI_WEAPONMODELTYPE11),

    --JUNK
    Weapon = util.Localize(SI_ITEMFILTERTYPE1),
    Apparel = util.Localize(SI_ITEMFILTERTYPE2),
    Consumable = util.Localize(SI_ITEMFILTERTYPE3),
    Materials = util.Localize(SI_ITEMFILTERTYPE4),
    Miscellaneous = util.Localize(SI_ITEMFILTERTYPE5),

    --DROPDOWN CONTEXT MENU
    ResetToAll = "Reset to All",
    InvertDropdownFilter = "Invert Dropdown Filter",

    --LibMotifCategories
    NormalStyle = AdvancedFilters.util.LibMotifCategories:GetLocalizedCategoryName(LMC_MOTIF_CATEGORY_NORMAL),
    RareStyle = AdvancedFilters.util.LibMotifCategories:GetLocalizedCategoryName(LMC_MOTIF_CATEGORY_RARE),
    AllianceStyle = AdvancedFilters.util.LibMotifCategories:GetLocalizedCategoryName(LMC_MOTIF_CATEGORY_ALLIANCE),
    ExoticStyle = AdvancedFilters.util.LibMotifCategories:GetLocalizedCategoryName(LMC_MOTIF_CATEGORY_EXOTIC),
    DroppedStyle = AdvancedFilters.util.LibMotifCategories:GetLocalizedCategoryName(LMC_MOTIF_CATEGORY_DROPPED),
    CrownStyle = AdvancedFilters.util.LibMotifCategories:GetLocalizedCategoryName(LMC_MOTIF_CATEGORY_CROWN),

    --CRAFT BAG
    --BLACKSMITHING
    RawMaterial = util.Localize(SI_ITEMTYPE17),
    RefinedMaterial = util.Localize(SI_ITEMTYPE36),
    Temper = util.Localize(SI_ITEMTYPE41),

    --CLOTHING
    Resin = util.Localize(SI_ITEMTYPE42),

    --WOODWORKING
    Tannin = util.Localize(SI_ITEMTYPE43),

    --Transmutation
    Retrait = util.Localize(SI_RETRAIT_STATION_ITEM_TO_RETRAIT_HEADER),

    --LAM settings menu
    lamDescription = "Show additional filter buttons in the inventories to seperate item types",
    lamHideItemCount = "Hide item count",
    lamHideItemCountTT = "Hide the item count information, shown in \"(...)\", at the bottom line of the inventories",
    lamHideItemCountColor = "Color of item count",
    lamHideItemCountColorTT = "Set the color of the item counter at the inventories bottom line",
    lamHideSubFilterLabel = "Hide subfilter label",
    lamHideSubFilterLabelTT = "Hide the subfilter's description label at the top line of the inventories (left to the subfilters buttons).",
}
setmetatable(strings, {__index = enStrings})

local light = " (ligera)"
local medium = " (media)"
strings.Head_Light = strings.Head ..  light
strings.Chest_Light = strings.Chest ..  light
strings.Shoulders_Light = strings.Shoulders ..  light
strings.Hand_Light = strings.Hand ..  light
strings.Waist_Light = strings.Waist ..  light
strings.Legs_Light = strings.Legs ..  light
strings.Feet_Light = strings.Feet ..  light
strings.Head_Light = strings.Head ..  medium
strings.Chest_Medium = strings.Chest ..  medium
strings.Shoulders_Medium = strings.Shoulders ..  medium
strings.Hand_Medium = strings.Hand ..  medium
strings.Waist_Medium = strings.Waist ..  medium
strings.Legs_Medium = strings.Legs ..  medium
strings.Feet_Medium = strings.Feet ..  medium
local ringStr = " (" .. strings.Ring .. ")"
strings.Arcane_Ring = strings.Arcane .. ringStr
strings.Bloodthirsty_Ring = strings.Bloodthirsty .. ringStr
strings.Harmony_Ring = strings.Harmony .. ringStr
strings.Healthy_Ring = strings.Healthy .. ringStr
strings.Infused_Ring = strings.Infused .. ringStr
strings.Intricate_Ring = strings.Intricate .. ringStr
strings.Ornate_Ring = strings.Ornate .. ringStr
strings.Robust_Ring = strings.Robust .. ringStr
strings.Swift_Ring = strings.Swift .. ringStr
strings.Triune_Ring = strings.Triune .. ringStr
local neckStr = " (" .. strings.Neck .. ")"
strings.Arcane_Neck = strings.Arcane .. neckStr
strings.Bloodthirsty_Neck = strings.Bloodthirsty .. neckStr
strings.Harmony_Neck = strings.Harmony .. neckStr
strings.Healthy_Neck = strings.Healthy .. neckStr
strings.Infused_Neck = strings.Infused .. neckStr
strings.Intricate_Neck = strings.Intricate .. neckStr
strings.Ornate_Neck = strings.Ornate .. neckStr
strings.Robust_Neck = strings.Robust .. neckStr
strings.Swift_Neck = strings.Swift .. neckStr
strings.Triune_Neck = strings.Triune .. neckStr

AdvancedFilters.strings = strings