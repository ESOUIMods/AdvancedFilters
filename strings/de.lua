local util = AdvancedFilters.util
local enStrings = AdvancedFilters.strings
local strings = {
    TwoHandAxe = util.Localize(zo_strformat("<<1>> <<2>>", GetString(SI_EQUIPTYPE6), GetString(SI_WEAPONTYPE1))),
    TwoHandSword = util.Localize(zo_strformat("<<1>> <<2>>", GetString(SI_EQUIPTYPE6), GetString(SI_WEAPONTYPE3))),
    TwoHandHammer = util.Localize(zo_strformat("<<1>> <<2>>", GetString(SI_EQUIPTYPE6), GetString(SI_WEAPONTYPE2))),
    Shield = zo_strformat("<<m:1>>", GetString(SI_ITEMSTYLECHAPTER13)),

    ResetToAll           = util.Localize(SI_ITEMFILTERTYPE0) .. " anzeigen",
    InvertDropdownFilter = "Filter umdrehen",

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
