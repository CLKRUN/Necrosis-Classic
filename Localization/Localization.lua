--[[
    Necrosis LdC
    Copyright (C) 2005-2008  Lom Enfroy

    This file is part of Necrosis LdC.

    Necrosis LdC is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    Necrosis LdC is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Necrosis LdC; if not, write to the Free Software
    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
--]]

------------------------------------------------------------------------------------------------------
-- Necrosis LdC
-- Par Lomig (Kael'Thas EU/FR) & Tarcalion (Nagrand US/Oceanic) 
-- Contributions deLiadora et Nyx (Kael'Thas et Elune EU/FR)
--
-- Skins et voix Françaises : Eliah, Ner'zhul
--
-- Version Allemande par Geschan
-- Version Espagnole par DosS (Zul’jin)
-- Version Russe par Komsomolka
--
-- Version $LastChangedDate: 2010-08-04 12:04:27 +1000 (Wed, 04 Aug 2010) $
------------------------------------------------------------------------------------------------------

-- Ensure Localization namespace exists
if not Localization then
    Localization = {}
    print("Necrosis: WARNING - Localization was nil, recreating")
end

-- Available languages and translated texts
Localization.Languages = {
    ["frFR"] = {
        ["code"] = "frFR",
        ["lang"] = "Français",
        ["init"] = Localization.frFR
    },
    ["enUS"] = {
        ["code"] = "enUS",
        ["lang"] = "English",
        ["init"] = Localization.enUS
    },
    ["deDE"] = {
        ["code"] = "deDE",
        ["lang"] = "Deutsch",
        ["init"] = Localization.deDE
    },
    ["zhTW"] = {
        ["code"] = "zhTW",
        ["lang"] = "Taiwan",
        ["init"] = Localization.zhTW
    },
    ["zhCN"] = {
        ["code"] = "zhCN",
        ["lang"] = "Chinese",
        ["init"] = Localization.zhCN
    },
    ["esES"] = {
        ["code"] = "esES",
        ["lang"] = "Español",
        ["init"] = Localization.esES
    },
    ["ruRU"] = {
        ["code"] = "ruRU",
        ["lang"] = "Русский",
        ["init"] = Localization.ruRU
    }
}

-- Debug: Verify the table was created
if Localization.Languages then
    print("Necrosis: Localization.Languages created successfully with " .. table.getn(Localization.Languages) .. " entries")
else
    print("Necrosis: ERROR - Localization.Languages failed to create!")
end
