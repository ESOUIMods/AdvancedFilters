local util = AdvancedFilters.util
local enStrings = AdvancedFilters.strings
local strings = {
    --SHARED
    All = "Tout",
    Trophy = util.Localize(SI_ITEMTYPE5),
    TreasureMaps = util.Localize(SI_SPECIALIZEDITEMTYPE100),
    SurveyReport = util.Localize(SI_SPECIALIZEDITEMTYPE101),
    KeyFragment = util.Localize(SI_SPECIALIZEDITEMTYPE102),
    MuseumPiece = util.Localize(SI_SPECIALIZEDITEMTYPE103),
    RecipeFragment = util.Localize(SI_SPECIALIZEDITEMTYPE104),
    Scroll = util.Localize(SI_SPECIALIZEDITEMTYPE105),

    --WEAPON
    OneHand = "Une main",
    TwoHand = "Deux mains",
    Bow = util.Localize(SI_WEAPONTYPE8),
    DestructionStaff = util.Localize(SI_GAMEPADWEAPONCATEGORY4),
    HealStaff = util.Localize(SI_WEAPONTYPE9),

    Axe = util.Localize(SI_WEAPONTYPE1),
    Sword = util.Localize(SI_WEAPONTYPE3),
    Hammer = util.Localize(SI_WEAPONTYPE2),
    TwoHandAxe = "2M "..util.Localize(SI_WEAPONTYPE1),
    TwoHandSword = "2M "..util.Localize(SI_WEAPONTYPE3),
    TwoHandHammer = "2M "..util.Localize(SI_WEAPONTYPE2),
    Dagger = util.Localize(SI_WEAPONTYPE11),
    Fire = util.Localize(SI_WEAPONTYPE12),
    Frost = util.Localize(SI_WEAPONTYPE13),
    Lightning = util.Localize(SI_WEAPONTYPE15),

    --ARMOR
    Heavy = util.Localize(SI_ARMORTYPE3),
    Medium = util.Localize(SI_ARMORTYPE2),
    LightArmor = util.Localize(SI_ARMORTYPE1),
    Clothing = util.Localize(SI_VISUALARMORTYPE5),
    Shield = util.Localize(SI_WEAPONTYPE14),
    Jewelry = util.Localize(SI_GAMEPADITEMCATEGORY38),

    Head = util.Localize(SI_EQUIPSLOT0), --"Head",
    Chest = util.Localize(SI_EQUIPTYPE3), --"Chest",
    Shoulders = util.Localize(SI_EQUIPTYPE4), --"Shoulders",
    Hand = util.Localize(SI_EQUIPTYPE13), --"Hand",
    Waist = util.Localize(SI_EQUIPTYPE8), --"Waist",
    Legs = util.Localize(SI_EQUIPTYPE9), --"Legs",
    Feet = util.Localize(SI_EQUIPTYPE10), --"Feet",
    Ring = util.Localize(SI_EQUIPTYPE12), --"Ring",
    Neck = util.Localize(SI_EQUIPSLOT1), --"Neck",
    --Jewelry
    Arcane  = util.Localize(SI_ITEMTRAITTYPE22),
    Bloodthirsty  = util.Localize(SI_ITEMTRAITTYPE31),
    Harmony  = util.Localize(SI_ITEMTRAITTYPE29),
    Healthy  = util.Localize(SI_ITEMTRAITTYPE21),
    Infused  = util.Localize(SI_ITEMTRAITTYPE33),
    Intricate  = util.Localize(SI_ITEMTRAITTYPE27),
    Ornate  = util.Localize(SI_ITEMTRAITTYPE24),
    Robust  = util.Localize(SI_ITEMTRAITTYPE23),
    Swift  = util.Localize(SI_ITEMTRAITTYPE28),
    Triune = util.Localize(SI_ITEMTRAITTYPE30),
    Protective = util.Localize(SI_ITEMTRAITTYPE32),
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
    Repair = "Réparation",

    --MATERIALS
    Blacksmithing = "Forge",
    Clothier = "Couture",
    Woodworking = "Travail du bois",
    Alchemy = "Alchimie",
    Enchanting = "Enchantement",
    Provisioning = "Approvisionnement",
    Style = util.Localize(SI_ITEMTYPE44),
    WeaponTrait = util.Localize(SI_ITEMTYPE46),
    ArmorTrait = util.Localize(SI_ITEMTYPE45),
    AllTraits = util.Localize(SI_ITEMFILTERTYPE20),
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
    Furnishings = util.Localize(SI_ITEMFILTERTYPE21),

    --MISCELLANEOUS
    Runes = util.Localize(SI_WEAPONMODELTYPE11),
    Glyphs = "Glyphes",
    ArmorGlyph = util.Localize(SI_ITEMTYPE21),
    JewelryGlyph = util.Localize(SI_ITEMTYPE26),
    WeaponGlyph = util.Localize(SI_ITEMTYPE20),
    SoulGem = util.Localize(SI_ITEMTYPE19),
    Siege = util.Localize(SI_ITEMTYPE6),
    Bait = util.Localize(SI_GAMEPADITEMCATEGORY3), --Bait",
    Tool = util.Localize(SI_ITEMTYPE9),
    Fence = util.Localize(SI_INVENTORY_STOLEN_ITEM_TOOLTIP),
    Trash = util.Localize(SI_ITEMTYPE48),

    --Vanity = "Vanity",
    Costume = util.Localize(SI_ITEMTYPE13),
    Disguise = util.Localize(SI_ITEMTYPE14),
    Tabard = util.Localize(SI_ITEMTYPE15),
    --JUNK
    Weapon = util.Localize(SI_ITEMFILTERTYPE1),
    Armor = util.Localize(SI_ITEM_FORMAT_STR_ARMOR), -- Armor
    Apparel = util.Localize(SI_ITEMFILTERTYPE2),
    Consumable = util.Localize(SI_ITEMFILTERTYPE3),
    Materials = util.Localize(SI_ITEMFILTERTYPE4),
    Miscellaneous = util.Localize(SI_ITEMFILTERTYPE5),

    --DROPDOWN CONTEXT MENU
    ResetToAll = "Tout réinitialiser",
    InvertDropdownFilter = "Inverser la sélection",

    --LibMotifCategories
    NormalStyle = AdvancedFilters.util.LibMotifCategories:GetLocalizedCategoryName(LMC_MOTIF_CATEGORY_NORMAL),
    RareStyle = AdvancedFilters.util.LibMotifCategories:GetLocalizedCategoryName(LMC_MOTIF_CATEGORY_RARE),
    AllianceStyle = AdvancedFilters.util.LibMotifCategories:GetLocalizedCategoryName(LMC_MOTIF_CATEGORY_ALLIANCE),
    ExoticStyle = AdvancedFilters.util.LibMotifCategories:GetLocalizedCategoryName(LMC_MOTIF_CATEGORY_EXOTIC),
    DroppedStyle = AdvancedFilters.util.LibMotifCategories:GetLocalizedCategoryName(LMC_MOTIF_CATEGORY_DROPPED),
    CrownStyle = AdvancedFilters.util.LibMotifCategories:GetLocalizedCategoryName(LMC_MOTIF_CATEGORY_CROWN),

    --CRAFT BAG
    --BLACKSMITHING
    RawMaterialSmithing = util.Localize(SI_ITEMTYPE17),
    RefinedMaterialSmithing = util.Localize(SI_ITEMTYPE36),
    Temper = util.Localize(SI_ITEMTYPE41),
    RawTemper = util.Localize(SI_ITEMTYPE17),
    --Clothier
    RawMaterialClothier = util.Localize(SI_ITEMTYPE17),
    RefinedMaterialClothier = util.Localize(SI_ITEMTYPE36),

    --Woodworking
    RawMaterialWoodworking = util.Localize(SI_ITEMTYPE17),
    RefinedMaterialWoodworking = util.Localize(SI_ITEMTYPE36),

    --Jewelry Crafting
    JewelryCrafting = util.Localize(SI_ITEMFILTERTYPE24),
    Plating = util.Localize(SI_ITEMTYPE65),
    RawPlating = util.Localize(SI_ITEMTYPE67),
    JewelryAllTrait = util.Localize(SI_ITEMTYPE66),
    JewelryRawTrait = util.Localize(SI_ITEMTYPE68),
    JewelryRefinedTrait = util.Localize(SI_ITEMTYPE66),
    RefinedMaterialJewelry = util.Localize(SI_ITEMTYPE64),
    RawMaterialJewelry = util.Localize(SI_ITEMTYPE63),

    RawMaterialStyle = util.Localize(SI_ITEMTYPE17),

    --CLOTHING
    Resin = util.Localize(SI_ITEMTYPE42),

    --WOODWORKING
    Tannin = util.Localize(SI_ITEMTYPE43),

    --Transmutation
    Retrait = util.Localize(SI_RETRAIT_STATION_ITEM_TO_RETRAIT_HEADER),

    --LAM settings menu
    lamDescription = "",
    lamHideItemCount = "Cacher le compteur d'objet",
    lamHideItemCountTT = "Cache le nombre d'objets présents dans la sous-catégorie (affiché entre parenthèses en bas de l'inventaire à côté du nombre d'objet total).",
    lamHideItemCountColor = "Couleur du compteur d'objet",
    lamHideItemCountColorTT = "Détermine la couleur du compteur d'objet affiché en bas de l'inventaire.",
    lamHideSubFilterLabel = "Cacher le nom de la sous-catégorie",
    lamHideSubFilterLabelTT = "Retire le texte indiquant le nom de la sous-catégorie (affiché en haut de l'inventaire à gauche).",
    lamGrayOutSubFiltersWithNoItems = "Désactiver les sous-catégories sans objets",
    lamGrayOutSubFiltersWithNoItemsTT = "Masque le bouton des sous-catégories ne comportant aucun objet.",
    lamShowIconsInFilterDropdowns = "Afficher les icônes dans le menu déroulant",
    lamShowIconsInFilterDropdownsTT = "Affiche les icônes des sous-catégories d'objet dans le menu déroulant de filtrage par type d'objet.",
    lamDebugOutput = "Déboguage"
}
setmetatable(strings, {__index = enStrings})

local light = " (légère)"
local medium = " (moyenne)"
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
strings.Protective_Ring = strings.Protective .. ringStr
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
strings.Protective_Neck = strings.Protective .. neckStr

AdvancedFilters.strings = strings