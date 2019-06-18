local util = AdvancedFilters.util
local enStrings = AdvancedFilters.strings
local strings = {
    --SHARED
    All = util.Localize(SI_ITEMFILTERTYPE0),
    Trophy = util.Localize(SI_ITEMTYPE5),

    --WEAPON
    OneHand = util.Localize(SI_EQUIPTYPE5),
    TwoHand = util.Localize(SI_EQUIPTYPE6),
    Bow = util.Localize(SI_WEAPONTYPE8),
    DestructionStaff = util.Localize(SI_GAMEPADWEAPONCATEGORY4),
    HealStaff = util.Localize(SI_WEAPONTYPE9),

    Axe = util.Localize(SI_WEAPONTYPE1),
    Sword = util.Localize(SI_WEAPONTYPE3),
    Hammer = util.Localize(SI_WEAPONTYPE2),
    TwoHandAxe = util.Localize(zo_strformat("<<1>> <<2>>", GetString(SI_EQUIPTYPE6), GetString(SI_WEAPONTYPE1))),
    TwoHandSword = util.Localize(zo_strformat("<<1>> <<2>>", GetString(SI_EQUIPTYPE6), GetString(SI_WEAPONTYPE3))),
    TwoHandHammer = util.Localize(zo_strformat("<<1>> <<2>>", GetString(SI_EQUIPTYPE6), GetString(SI_WEAPONTYPE2))),
    Dagger = util.Localize(SI_WEAPONTYPE11),
    Fire = util.Localize(SI_WEAPONTYPE12),
    Frost = util.Localize(SI_WEAPONTYPE13),
    Lightning = util.Localize(SI_WEAPONTYPE15),

    --ARMOR
    Heavy = util.Localize(SI_ARMORTYPE3),
    Medium = util.Localize(SI_ARMORTYPE2),
    LightArmor = util.Localize(SI_ARMORTYPE1),
    Clothing = util.Localize(SI_VISUALARMORTYPE5),
    Shield = zo_strformat("<<m:1>>", GetString(SI_ITEMSTYLECHAPTER13)),
    Jewelry = util.Localize(SI_ITEMFILTERTYPE25),
    Vanity = util.Localize(SI_ITEMTYPE14),

    Head = util.Localize(SI_OUTFITSLOT0),
    Chest = util.Localize(SI_OUTFITSLOT1),
    Shoulders = util.Localize(SI_OUTFITSLOT2),
    Hand = util.Localize(SI_OUTFITSLOT3),
    Waist = util.Localize(SI_OUTFITSLOT4),
    Legs = util.Localize(SI_OUTFITSLOT5),
    Feet = util.Localize(SI_OUTFITSLOT6),
    Ring = util.Localize(SI_EQUIPTYPE12),
    Neck = util.Localize(SI_EQUIPSLOT1),

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
    Repair = util.Localize(SI_ITEMTYPE9),

    --MATERIALS
    Blacksmithing = util.Localize(SI_ITEMFILTERTYPE13),
    Clothier = util.Localize(SI_ITEMFILTERTYPE14),
    Woodworking = util.Localize(SI_ITEMFILTERTYPE15),
    Alchemy = util.Localize(SI_ITEMFILTERTYPE16),
    Enchanting = util.Localize(SI_ITEMFILTERTYPE17),
    Provisioning = util.Localize(SI_ITEMFILTERTYPE18),
    Style = util.Localize(SI_ITEMTYPE44),
    WeaponTrait = util.Localize(SI_ITEMTYPE46),
    ArmorTrait = util.Localize(SI_ITEMTYPE45),
    JewelryTrait = util.Localize(SI_ITEMTYPE66),
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
    Glyphs = util.Localize(SI_GAMEPADITEMCATEGORY13),
    SoulGem = util.Localize(SI_ITEMTYPE19),
    Siege = util.Localize(SI_ITEMTYPE6),
    Bait = util.Localize(SI_GAMEPADITEMCATEGORY3),
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
    ResetToAll = util.Localize(SI_GAMEPAD_GUILD_HISTORY_SUBCATEGORY_ALL),
    InvertDropdownFilter = "Filter umdrehen",

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
    RawTemper = util.Localize(SI_ITEMTYPE17),

    --Jewelry Crafting
    JewelryCrafting = util.Localize(SI_ITEMFILTERTYPE24),
    Plating = util.Localize(SI_ITEMTYPE65),
    RawPlating = util.Localize(SI_ITEMTYPE67),

    --CLOTHING
    Resin = util.Localize(SI_ITEMTYPE42),

    --WOODWORKING
    Tannin = util.Localize(SI_ITEMTYPE43),

    --Transmutation
    Retrait = util.Localize(SI_RETRAIT_STATION_ITEM_TO_RETRAIT_HEADER),

    --LAM settings menu
    lamDescription = "Zeige zusätzliche Filter Kategorien in den Inventaren, um Gegenstandstypen zu unterscheiden",
    lamHideItemCount = "Verstecke Gegenstand Anzahl",
    lamHideItemCountTT = "Versteckt die Gegenstand Anzahl, welche als \"(...)\" am unteren Inventar Rand angezeigt wird",
    lamHideItemCountColor = "Farbe der Gegenstand Anzahl",
    lamHideItemCountColorTT = "Setze die Farbe der Gegenstand Anzahl",
    lamHideSubFilterLabel = "Verstecke Filter Kategorie Label",
    lamHideSubFilterLabelTT = "Versteckt den Filter Kategorie Beschreibungstext Label, welcher sich links am Inventar Rand befindet",
    lamGrayOutSubFiltersWithNoItems = "Deaktiviere Kategorien ohne Gegenstände",
    lamGrayOutSubFiltersWithNoItemsTT = "Deaktiviert die Filter Kategorien, welche aktuell keine Gegegnstände besitzen.",
    lamShowIconsInFilterDropdowns = "Zeige Symbole in Filter Boxen",
    lamShowIconsInFilterDropdownsTT = "Zeige Symbole in den Filter Aufklapp Boxen an",
}

setmetatable(strings, {__index = enStrings})
AdvancedFilters.strings = strings