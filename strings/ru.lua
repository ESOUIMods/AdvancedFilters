local util = AdvancedFilters.util
local enStrings = AdvancedFilters.strings
local strings = {
    --SHARED
    All = "Все",
    Trophy = util.Localize(SI_ITEMTYPE5),

    --WEAPON
    OneHand = "Одноручное",
    TwoHand = "Двуручное",
    Bow = util.Localize(SI_WEAPONTYPE8),
    DestructionStaff = "Посох разрушения",
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
    Shield = "Щит",
    Jewelry = "Бижутерия",
    Vanity = "Разное",

    Head = "Голова",
    Chest = "Торс",
    Shoulders = "Плечи",
    Hand = "Руки",
    Waist = "Пояс",
    Legs = "Ноги",
    Feet = "Ступни",
    Ring = "Кольцо",
    Neck = "Шея",

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
    Repair = "Ремонт",

    --MATERIALS
    Blacksmithing = "Кузнечество",
    Clothier = "Шитье",
    Woodworking = "Древообработка",
    Alchemy = "Алхимия",
    Enchanting = "Зачарование",
    Provisioning = "Кулинария",
    Style = util.Localize(SI_ITEMTYPE44),
    WeaponTrait = util.Localize(SI_ITEMTYPE46),
    ArmorTrait = util.Localize(SI_ITEMTYPE45),
    FurnishingMat = util.Localize(SI_ITEMTYPE62),

    Reagent = util.Localize(SI_ITEMTYPE31),
    Solvent = util.Localize(SI_ITEMTYPE33),
    Aspect = util.Localize(SI_ENCHANTINGRUNECLASSIFICATION1),
    Essence = util.Localize(SI_ENCHANTINGRUNECLASSIFICATION2),
    Potency = util.Localize(SI_ENCHANTINGRUNECLASSIFICATION3),

    --FURNISHINGS
    CraftingStation = util.Localize(SI_SPECIALIZEDITEMTYPE213),
    Light = util.Localize(SI_SPECIALIZEDITEMTYPE211),
    Ornamental = util.Localize(SI_SPECIALIZEDITEMTYPE210),
    Seating = util.Localize(SI_SPECIALIZEDITEMTYPE212),
    TargetDummy = util.Localize(SI_SPECIALIZEDITEMTYPE214),

    --MISCELLANEOUS
    Glyphs = "Глифы",
    SoulGem = util.Localize(SI_ITEMTYPE19),
    Siege = util.Localize(SI_ITEMTYPE6),
    Bait = "Наживка",
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
    ResetToAll = "Сбросить все",
    InvertDropdownFilter = "Инверт.выпадающий фильтр",
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
    lamDescription = "Показывать дополнительные фильтры в инвентаре, для разделения типов предметов",
    lamHideItemCount = "Скрыть количество предметов",
    lamHideItemCountTT = "Скрыть информацию о количестве предметов, показанных в \" (...) \", в нижней строке инвентаря",
    lamHideItemCountColor = "Цвет количество предметов",
    lamHideItemCountColorTT = "Установить цвет количество предметов в нижней строке инвентаря",
    lamHideSubFilterLabel = "Скрыть метку подфильтра",
    lamHideSubFilterLabelTT = "Скрыть метку описания подфильтра в верхней строке инвентаря (слева от кнопок подфильтров).",
}
setmetatable(strings, {__index = enStrings})

local light = " (Легкий)"
local medium = " (средний)"
strings.Head_Light = strings.Head .. light
strings.Chest_Light = strings.Chest .. light
strings.Shoulders_Light = strings.Shoulders .. light
strings.Hand_Light = strings.Hand .. light
strings.Waist_Light = strings.Waist .. light
strings.Legs_Light = strings.Legs .. light
strings.Feet_Light = strings.Feet .. light
strings.Head_Light = strings.Head .. medium
strings.Chest_Medium = strings.Chest .. medium
strings.Shoulders_Medium = strings.Shoulders .. medium
strings.Hand_Medium = strings.Hand .. medium
strings.Waist_Medium = strings.Waist .. medium
strings.Legs_Medium = strings.Legs .. medium
strings.Feet_Medium = strings.Feet .. medium
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