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
-- French Skins and voices: Eliah, Ner'zhul
--
-- Version Allemande par Geschan
-- Version Espagnole par DosS (Zul’jin)
-- Version Russe par Komsomolka
--
-- Version $LastChangedDate: 2010-08-04 12:04:27 +1000 (Wed, 04 Aug 2010) $
------------------------------------------------------------------------------------------------------

-- local new, del
-- do
-- 	local cache = setmetatable({}, {__mode='k'})
-- 	function new(populate, ...)
-- 		local tbl
-- 		local t = next(cache)
-- 		if ( t ) then
-- 			cache[t] = nil
-- 			tbl = t
-- 		else
-- 			tbl = {}
-- 		end
-- 		if ( populate ) then
-- 			local num = select("#", ...)
-- 			if ( populate == "hash" ) then
-- 				assert(math.fmod(num, 2) == 0)
-- 				local key
-- 				for i = 1, num do
-- 					local v = select(i, ...)
-- 					if not ( math.fmod(i, 2) == 0 ) then
-- 						key = v
-- 					else
-- 						tbl[key] = v
-- 						key = nil
-- 					end
-- 				end
-- 			elseif ( populate == "array" ) then
-- 				for i = 1, num do
-- 					local v = select(i, ...)
-- 					table.insert(tbl, i, v)
-- 				end
-- 			end
-- 		end
-- 		return tbl
-- 	end
-- 	function del(t)
-- 		for k in next, t do
-- 			t[k] = nil
-- 		end
-- 		cache[t] = true
-- 	end
-- end


Necrosis.Spells = {
	-- Number of spells found in the chars spellbook
	SpellsCount = 0,
	-- True if spell count changed since last check
	SpellsChanged = true
}

local _sp = Necrosis.Spells

function _sp:GetSoulShatterCooldown()
	return self:GetSpellCooldownTime(Necrosis.Spell[49].GlobalId)
end

function _sp:GetFelDominationCooldown()
	return self:GetSpellCooldownTime(Necrosis.Spell[15].GlobalId)
end

function _sp:GetShadowWardCooldown()
	return self:GetSpellCooldownTime(Necrosis.Spell[43].GlobalId)
end

function _sp:GetRitualOfSoulsCooldown()
	return self:GetSpellCooldownTime(Necrosis.Spell[50].GlobalId)
end

function _sp:GetSpellCooldownTime(spellId)
	local secs = self:GetSpellCooldownInSecs(spellId)
	return (secs > 0), Necrosis.Timers:GetFormattedTime(secs)
end

function _sp:GetSpellCooldownInSecs(spellId)
	if not spellId then
		-- Some spells may not be available
		return 0
	end
	local startTime, duration, enable = GetSpellCooldown(spellId)
	if enable == 0 then
		return 0
	end
	if startTime == 0 then
		return 0
	end
	local remainingSecs = math.floor(duration - (GetTime() - startTime))
	return remainingSecs
end

function _sp:GetRankNumberFromSubName(subName)
	local _, _, rank = subName:find("(%d+)")
	if rank then
		return tonumber(rank)
	end
	return nil
end


local function MakeSpellIdRanks(root)
    -- i is the rank of the item
    -- Create an entry in the form of [itemId] = rank
    for i,id in ipairs(root.SpellIds) do
        root[id] = i
    end
end

local function AddAuraDuration(spellIds, duration, type)
	-- v is one spellID
	-- assign the duration to each spellID
	for i,v in ipairs(spellIds) do
		Necrosis.Spell.AuraDuration[v] = duration
		if (type) then
			Necrosis.Spell.AuraType[v] = type
		end
	end
end

-- Function to automatically relocate elements based on the client
function Necrosis:SpellLocalize(tooltip) 

	------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	-- Relocalisation des Sorts
	------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	if not tooltip then
		self.Spell = {
			[1] = {Name = GetSpellInfo(5784), 	GlobalId = 5784, 	Mana = 50,	Rank = 0,	Duration = 0,	Type = nil,      Usage = "mount"}, -- Felsteed
			[2] = {Name = GetSpellInfo(23161), 	GlobalId = 23161,	Mana = 50,	Rank = 0,	Duration = 0,	Type = nil,      Usage = "mount"}, -- Dreadsteed
			-- Pets
			[3] = {Name = GetSpellInfo(688), 	GlobalId = 688,		Mana = 50,	Rank = 0,	Duration = 0,	Type = nil,      Usage = "imp", PetId = 416}, -- Imp || Diablotin 
			[4] = {Name = GetSpellInfo(697),	GlobalId = 697,		Mana = 50,	Rank = 0,	Duration = 0,	Type = nil,      Usage = "voidwalker", PetId = 1860, reagent = "soul_shard"}, -- Voidwalker
			[5] = {Name = GetSpellInfo(712),	GlobalId = 712,		Mana = 50,	Rank = 0,	Duration = 0,	Type = nil,      Usage = "succubus", PetId = 1863, reagent = "soul_shard"}, -- Succubus || Succube
			[60] = {Name = GetSpellInfo(713),	GlobalId = 713,		Mana = 50,	Rank = 0,	Duration = 0,	Type = nil,      Usage = "incubus", PetId = 185317, reagent = "soul_shard"}, -- Incubus
			[6] = {Name = GetSpellInfo(691),	GlobalId = 691,		Mana = 50,	Rank = 0,	Duration = 0,	Type = nil,      Usage = "felhunter", PetId = 417, reagent = "soul_shard"}, -- Fellhunter
			[7] = {Name = GetSpellInfo(30146),	GlobalId = 30146,	Mana = 50,	Rank = 0,	Duration = 0,	Type = nil,      Usage = "felguard", PetId = 17252, reagent = "soul_shard"}, -- Felguard -- Fellhunter now
			[8] = {Name = GetSpellInfo(1122),	GlobalId = 1122,	Mana = 50,	Rank = 0,	Duration = 600,	Type = "single", Usage = "inferno", reagent = "infernal_stone"}, -- Infernal
			-- Banish / Enslave
			[9]  = {Name = GetSpellInfo(710),	GlobalId = 710,		Mana = 50,	Rank = 0,	Duration = 30,	Type = "debuff", Usage = "banish"}, -- Banish
			[10] = {Name = GetSpellInfo(1098),	GlobalId = 1098,	Mana = 50,	Rank = 0,	Duration = 300,	Type = "single", Usage = "enslave"}, -- Enslave

			[11] = {Name = GetSpellInfo(29722),	GlobalId = 29722,	Mana = 50,	Rank = 0,	Duration = 0,	Type = nil,      Usage = "incinerate"}, -- TBC: Incinerate
			[12] = {Name = GetSpellInfo(348),	GlobalId = 348,		Mana = 50,	Rank = 0,	Duration = 15,	Type = "debuff", Usage = "immolate"}, -- Immolate
			[13] = {Name = GetSpellInfo(5782),	GlobalId = 5782,	Mana = 50,	Rank = 0,	Duration = 20,	Type = "debuff", Usage = "fear"}, -- Fear
			[14] = {Name = GetSpellInfo(172),   GlobalId = 172,		Mana = 50,	Rank = 0,	Duration = 18,	Type = "debuff", Usage = "corruption"}, -- Corruption
			[15] = {Name = GetSpellInfo(18708),	GlobalId = 18708,	Mana = 50,	Rank = 0,	Duration = 0, 	Type = "self",   Usage = "domination"}, -- Fel Domination
			[16] = {Name = GetSpellInfo(603),   GlobalId = 603,		Mana = 50,	Rank = 0,	Duration = 60,	Type = "debuff", Usage = "doom"}, -- Curse of Doom || Malédiction funeste
			[17] = {Name = GetSpellInfo(30283),	GlobalId = 30283,	Mana = 50,	Rank = 0,	Duration = 0,	Type = nil,      Usage = "shadowfury"}, -- NOPE NOT IN Classic, BUT in TBC: Shadowfury
			[18] = {Name = GetSpellInfo(6353),	GlobalId = 6353,	Mana = 50,	Rank = 0,	Duration = 0, 	Type = nil,      Usage = "soul_fire"}, -- Soul Fire || Feu de l'âme
			[19] = {Name = GetSpellInfo(6789),	GlobalId = 6789,	Mana = 50,	Rank = 0,	Duration = 3,	Type = "debuff", Usage = "death_coil"}, -- Death Coil || Voile mortel
			[20] = {Name = GetSpellInfo(17877),	GlobalId = 17877,	Mana = 50,	Rank = 0,	Duration = 5,	Type = "debuff", Usage = "shadowburn"}, -- Shadowburn
			[21] = {Name = GetSpellInfo(17962),	GlobalId = 17962,	Mana = 50,	Rank = 0,	Duration = 0,	Type = nil,      Usage = "conflagration"}, -- Conflagration
			-- Curses
			[22] = {Name = GetSpellInfo(980),	GlobalId = 980,		Mana = 50,	Rank = 0,	Duration = 24,	Type = "debuff", Usage = "agony"}, -- Curse of Agony
			[23] = {Name = GetSpellInfo(702),	GlobalId = 702,		Mana = 50,	Rank = 0,	Duration = 120,	Type = "debuff", Usage = "weakness"}, -- Curse of Weakness
			[24] = {Name = GetSpellInfo(704),	GlobalId = 704,		Mana = 0 ,  Rank = 0,   Duration = 120, Type = "debuff", Usage = "recklessness"}, -- Curse of Recklessness - removed in patch 3.1
			[25] = {Name = GetSpellInfo(1714),	GlobalId = 1714,	Mana = 50,	Rank = 0,	Duration = 30,	Type = "debuff", Usage = "tongues"}, -- Curse of Tongues
			[26] = {Name = GetSpellInfo(1490),	GlobalId = 1490,	Mana = 50,	Rank = 0,	Duration = 300,	Type = "debuff", Usage = "elements"}, -- Curse of the Elements

			[27] = {Name = GetSpellInfo(133),	GlobalId = 133,		Mana = 50,	Rank = 0,	Duration = 180,	Type = nil,      Usage = "#none#"}, -- NOPE NOT IN Classic  Metamorphosis || Metamorphose
			[28] = {Name = GetSpellInfo(18265),	GlobalId = 18265,	Mana = 50,	Rank = 0,	Duration = 30,	Type = "debuff", Usage = "siphon_life"}, -- Siphon Life || Syphon de vie
			[29] = {Name = GetSpellInfo(5484),	GlobalId = 5484,	Mana = 50,	Rank = 0,	Duration = 0, 	Type = nil,      Usage = "howl"}, -- Howl of Terror || Hurlement de terreur
			[30] = {Name = GetSpellInfo(18540),	GlobalId = 18540,	Mana = 50,	Rank = 0,	Duration = 0,   Type = nil,      Usage = "rit_of_doom", reagent = "demonic_figurine"}, -- Ritual of Doom || Rituel funeste
			[31] = {Name = GetSpellInfo(696),	GlobalId = 696,		Mana = 50,	Rank = 0,	Duration = 1800,Type = "self",   Usage = "armor"}, -- Demon Skin || Peau de démon 
			[32] = {Name = GetSpellInfo(5697),	GlobalId = 5697,	Mana = 50,	Rank = 0,	Duration = 600,	Type = "single", Usage = "breath"}, -- Unending Breath
			[33] = {Name = GetSpellInfo(132),	GlobalId = 132,		Mana = 50,	Rank = 0,	Duration = 600,	Type = "single", Usage = "invisible"}, -- Detect Invisibility || Détection de l'invisibilité
			[34] = {Name = GetSpellInfo(126),	GlobalId = 126,		Mana = 50,	Rank = 0,	Duration = 45,	Type = "single", Usage = "eye"}, -- Eye of Kilrogg
			[35] = {Name = GetSpellInfo(1098),	GlobalId = 1098,	Mana = 50,	Rank = 0,	Duration = 300,	Type = "single", Usage = "enslave"}, -- Enslave Demon
			[36] = {Name = GetSpellInfo(706),	GlobalId = 706,		Mana = 50,	Rank = 0,	Duration = 1800,Type = "self",   Usage = "armor"}, -- Demon Armor
			[37] = {Name = GetSpellInfo(698),	GlobalId = 698,		Mana = 50,	Rank = 0,	Duration = 0,	Type = nil,      Usage = "summoning"}, -- Ritual of Summoning
			[38] = {Name = GetSpellInfo(19028),	GlobalId = 19028,	Mana = 50,	Rank = 0,	Duration = 0,	Type = nil,      Usage = "link"}, -- Soul Link
			[39] = {Name = GetSpellInfo(133),	GlobalId = 133,		Mana = 50,	Rank = 0,	Duration = 45,	Type = nil,      Usage = "#none#"}, -- NOPE NOT IN Classic  Demon Charge
			[40] = {Name = GetSpellInfo(18223),	GlobalId = 18223,	Mana = 50,	Rank = 0,	Duration = 12,	Type = "debuff", Usage = "exhaustion"}, -- Curse of Exhaustion
			[41] = {Name = GetSpellInfo(1454),	GlobalId = 1454,	Mana = 50,	Rank = 0,	Duration = 0,	Type = nil,      Usage = "life_tap"}, -- Life Tap || Connexion
			[42] = {Name = GetSpellInfo(133),	GlobalId = 133,		Mana = 50,	Rank = 0,	Duration = 12,	Type = nil,      Usage = "#none#"}, -- NOPE NOT IN Classic  Haunt || Hanter
			[43] = {Name = GetSpellInfo(6229),	GlobalId = 6229,	Mana = 50,	Rank = 0,	Duration = 30,	Type = "single", Usage = "ward"}, -- Shadow Ward
			[44] = {Name = GetSpellInfo(18788),	GlobalId = 18788,	Mana = 50,	Rank = 0,	Duration = 1800,Type = nil,      Usage = "sacrifice"}, -- Demonic Sacrifice || Sacrifice démoniaque 
			[45] = {Name = GetSpellInfo(686),	GlobalId = 686,		Mana = 50,	Rank = 0,	Duration = 0,	Type = nil,      Usage = "bolt"}, -- Shadow Bolt
			[46] = {Name = GetSpellInfo(30108),	GlobalId = 30108,	Mana = 50,	Rank = 0,	Duration = 18,	Type = "debuff", Usage = "affliction"}, -- NOPE NOT IN Classic, BUT in TBC: Unstable Affliction || Affliction instable
			[47] = {Name = GetSpellInfo(28176),	GlobalId = 28176,	Mana = 50,	Rank = 0,	Duration = 1800,Type = "self",   Usage = "armor"}, -- NOPE NOT IN Classic, BUT in TBC: Fel Armor || Gangrarmure
			[48] = {Name = GetSpellInfo(27243),	GlobalId = 27243,	Mana = 50,	Rank = 0,	Duration = 18,	Type = "debuff", Usage = "seed"}, -- NOPE NOT IN Classic, BUT in TBC: Seed of Corruption || Graine de Corruption
			[49] = {Name = GetSpellInfo(29858),	GlobalId = 29858,	Mana = 50,	Rank = 0,	Duration = 300,	Type = "self",   Usage = "shatter"}, -- NOPE NOT IN Classic, BUT in TBC: SoulShatter || Brise âme
			[50] = {Name = GetSpellInfo(29893),	GlobalId = 29893,	Mana = 50,	Rank = 0,	Duration = 0,	Type = nil,      Usage = "ritual_souls"}, -- NOPE NOT IN Classic, BUT in TBC: Ritual of Souls || Rituel des âmes
			[51] = {Name = GetSpellInfo(27239),	GlobalId = 27239,	Mana = 50,	Rank = 0,	Duration = 0,   Type = nil,      Usage = "soulstone"}, -- Create Soulstone (R1=693 @18, R2=20752 @28, R3=20755 @38, R4=20756 @48, R5=20757 @58, R6=27239 @60)
			[52] = {Name = GetSpellInfo(11729),	GlobalId = 11729,	Mana = 50,	Rank = 0,	Duration = 0,	Type = nil,      Usage = "healthstone"}, -- Create Healthstone (R1=6201 @10, R2=6202 @22, R3=5699 @34, R4=11729 @46, R5=11730 @58, R6=27230 @60)
			[53] = {Name = GetSpellInfo(17728),	GlobalId = 17728,	Mana = 50,	Rank = 0,	Duration = 0,	Type = nil,      Usage = "spellstone"}, -- Create Spellstone (R1=2362 @36, R2=17727 @48, R3=17728 @60)
			[54] = {Name = GetSpellInfo(17953),	GlobalId = 17953,	Mana = 50,	Rank = 0,	Duration = 0,	Type = nil,      Usage = "firestone"}, -- Create Firestone (R1=6366 @28, R2=17951 @36, R3=17952 @46, R4=17953 @56)
			[55] = {Name = GetSpellInfo(18220),	GlobalId = 18220,	Mana = 50,	Rank = 0,	Duration = 0,	Type = nil,      Usage = "pact"}, -- Dark Pact || Pacte noir
			[56] = {Name = GetSpellInfo(133),	GlobalId = 133,		Mana = 50,	Rank = 0,	Duration = 30,	Type = nil,      Usage = "#none#"}, -- NOPE NOT IN Classic  Shadow Cleave || Enchainement d'ombre
			[57] = {Name = GetSpellInfo(133),	GlobalId = 133,		Mana = 50,	Rank = 0,	Duration = 30,	Type = nil,      Usage = "#none#"}, -- NOPE NOT IN Classic  Immolation Aura || Aura d'immolation
			[58] = {Name = GetSpellInfo(133),	GlobalId = 133,		Mana = 50,	Rank = 0,	Duration = 15,	Type = nil,      Usage = "#none#"}, --  NOPE NOT IN Classic Challenging Howl || Hurlement de défi
			[59] = {Name = GetSpellInfo(133),	GlobalId = 133,		Mana = 50,	Rank = 0,   Duration = 60,	Type = nil,      Usage = "#none#"}, --NOPE NOT IN Classic   Demonic Empowerment || Renforcement démoniaque
			-- These aren't needed here, since they're not in the spellbook
			-- [60] = {Name = GetSpellInfo(18789),	GlobalId = 18789,	Mana = 50,	Rank = 0,	Duration = 1800,Type = "self",   Usage = "sacrifice"}, -- Demonic Sacrifice 
			-- [61] = {Name = GetSpellInfo(18790),	GlobalId = 18790,	Mana = 50,	Rank = 0,	Duration = 1800,Type = "self",   Usage = "sacrifice"}, -- Demonic Sacrifice 
			-- [62] = {Name = GetSpellInfo(18791),	GlobalId = 18791,	Mana = 50,	Rank = 0,	Duration = 1800,Type = "self",   Usage = "sacrifice"}, -- Demonic Sacrifice 
			-- [63] = {Name = GetSpellInfo(18792),	GlobalId = 18792,	Mana = 50,	Rank = 0,	Duration = 1800,Type = "self",   Usage = "sacrifice"}, -- Demonic Sacrifice 
			-- [64] = {Name = GetSpellInfo(35701),	GlobalId = 35701,	Mana = 50,	Rank = 0,	Duration = 1800,Type = "self",   Usage = "sacrifice"}, -- Demonic Sacrifice 

			-- See https://tbc.wowhead.com/spell=20707/soulstone-resurrection
			SoulstoneRez = {
				SpellIds = {
					20707, -- Minor
					20762, -- Lesser
					20763, -- Normal
					20764, -- Greater
					20765, -- Major
					27239  -- Master
				}
			},
			DemonicSacrifices = {
				SpellIds = {
					18789, -- Burning Wish (Imp)
					18790, -- Fel Stamina (Void Walker)
					18791, -- Touch of Shadow (Succubus / Incubus)
					18792, -- Fel Energy (Fel Hunter)
					35701  -- Touch of Shadow (Fel Guard)
				}
			},

			AuraDuration = {},
			AuraType = {}
		}

		-- These durations are special, either vary by spell rank like banish, or are no spell, like Demonic Sacrifice.
		-- All other durations are constant and automatically added by the Duration from the Spell list above.
		-- Inspired by LibClassicDurations to hard-code it since UnitDebuff(..) API always returns 0
		-- Affliction
		AddAuraDuration({172}, 12, "debuff") -- Corruption 1
		AddAuraDuration({6222}, 15, "debuff") -- Corruption 2
		AddAuraDuration({5782}, 10, "debuff") -- Fear 1
		AddAuraDuration({6213}, 15, "debuff") -- Fear 2
		AddAuraDuration({5484}, 10, "debuff") -- Howl of Terror 1
		-- Demonology
		AddAuraDuration({710}, 20, "single") -- Banish 1
		AddAuraDuration(Necrosis.Spell.DemonicSacrifices.SpellIds, 1800, "self") -- Demonic Sacrifices
		AddAuraDuration(Necrosis.Spell.SoulstoneRez.SpellIds, 1800, "soulstone") -- Soulstone Resurrection 1-5
		-- Destruction
		AddAuraDuration({17794, 17797, 17798, 17799, 17800}, 12, "debuff") -- Shadow Vulnerability
	end
end

-- https://github.com/WeakAuras/WeakAuras2/wiki/Useful-Snippets
function Necrosis:GetManaCostForSpell(spellID)
	if (not spellID) then return end
	local cost = 0
	local costTable = GetSpellPowerCost(spellID);
	if (costTable == nil) then
		return false
	end
	return table.foreach(costTable,
		function(k,v)
			-- print("Cost: "..tostring(spellID)..", "..tostring(v.type)..", "..tostring(v.name))
			if (v.name  == "MANA") then
				return v.cost;
			end 
		end
	)
end

local function UpdateSpellIfHigherRank(index, spellRank, spellID, spellNameOrg, globalId)
	-- Only update the spell stats if a higher rank has been found
	if (Necrosis.Spell[index].Rank < spellRank) then
		Necrosis.Spell[index].ID = spellID
		Necrosis.Spell[index].Rank = spellRank
		Necrosis.Spell[index].NameOrg = spellNameOrg
		Necrosis.Spell[index].GlobalId = globalId
		Necrosis.Spell[index].Mana = Necrosis:GetManaCostForSpell(globalId)
		-- Add a duration and type for the specific spellId if it's a debuff etc.
		if (Necrosis.Spell.AuraDuration[globalId] == nil and
			Necrosis.Spell[index].Duration > 0)
		then
			AddAuraDuration({globalId}, Necrosis.Spell[index].Duration, Necrosis.Spell[index].Type)
		end
	end
end

local function SetSpellsChanged(countSpells)
	_sp.SpellsChanged = _sp.SpellsCount ~= countSpells
	_sp.SpellsCount = countSpells
end

-- My favourite feature! Create a list of spells known by the warlock sorted by name & rank
-- Select the highest available spell in the case of stones.
function Necrosis:SpellSetup()
	for index in ipairs(Necrosis.Spell) do
		Necrosis.Spell[index].ID = nil
		Necrosis.Spell[index].Rank = -1
	end

	local spellID = 1

	-- Search for all spells known by the warlock
	while true do
		local spellName, subSpellName, globalId = NecrosisCompat.GetSpellBookItemName(spellID, BOOKTYPE_SPELL)

		if (not spellName) then
			do break end
		end

		local spellNameOrg = spellName
		if (subSpellName and subSpellName ~= " " and subSpellName ~= "" and subSpellName ~= "Summon") then
			-- For spells with numbered ranks, compare each one
			-- And preserve the highest rank
			local spellRank = Necrosis.Spells:GetRankNumberFromSubName(subSpellName)
			if (spellRank ~= nil) then
				for index = 1, #Necrosis.Spell, 1 do
					-- A version of the spell is already in our table
					if (Necrosis.Spell[index].Name == spellName) then
						UpdateSpellIfHigherRank(index, spellRank, spellID, spellNameOrg, globalId)
						break
					end
				end
			end
		else
			-- The spell has no subSpellName, like Ritual of Summoning or
			-- unavailable / not learned spells like Conflagrate
			-- Set rank = 0 for those spells
			for index = 1, #Necrosis.Spell, 1 do
				-- a version of the spell is already in our table
				if (Necrosis.Spell[index].Name == spellName) then
					UpdateSpellIfHigherRank(index, 0, spellID, spellNameOrg, globalId)
					break
				end
			end
		end

		spellID = spellID + 1
	end

	SetSpellsChanged(spellID)

	-- Populate usage list
	for index = 1, #Necrosis.Spell, 1 do
		local s = Necrosis.Spell[index]
		if (s ~= nil and s.Usage ~= nil) then
			if (s.Rank >= 0) then
				Necrosis.Warlock_Spell_Use[s.Usage] = {
					GlobalId = s.GlobalId,
					Name     = s.Name,
					Rank     = s.Rank,
					Mana     = s.Mana
				}
			end
		end
	end

	-- associate the mounts to the sphere button
	Necrosis.CurrentEnv.FelsteedAvailable = Necrosis.Spell[1].ID ~= nil
	Necrosis.CurrentEnv.FelsteedName = Necrosis.Spell[1].Name
	Necrosis.CurrentEnv.DreadsteedAvailable = Necrosis.Spell[2].ID ~= nil
	Necrosis.CurrentEnv.DreadsteedName = Necrosis.Spell[2].Name
	Necrosis.CurrentEnv.SteedAvailable = Necrosis.CurrentEnv.FelsteedAvailable or Necrosis.CurrentEnv.DreadsteedAvailable
	-- Set info about available armor spells for buttons
	Necrosis.CurrentEnv.DemonArmorAvailable = Necrosis.Spell[36].ID ~= nil
	Necrosis.CurrentEnv.DemonArmorName = Necrosis.Spell[36].Name
	Necrosis.CurrentEnv.FelArmorAvailable = Necrosis.Spell[47].ID ~= nil
	Necrosis.CurrentEnv.FelArmorName = Necrosis.Spell[47].Name

	-- if (not InCombatLockdown()) then
	-- 	Necrosis:MainButtonAttribute()
	-- 	Necrosis:BuffSpellAttribute()
	-- 	Necrosis:PetSpellAttribute()
	-- 	Necrosis:CurseSpellAttribute()
	-- 	Necrosis:StoneAttribute(Necrosis.CurrentEnv.SteedAvailable)
	-- end

	Necrosis:BindName()
end

--[==[ Necrosis tables
Translation items are in Dialog.lua!

This file and Dialog.lua are the two places WoW ids are specified. Then short names, localized names, or passed ids are used.

These include item names and labels set manual and programmatic.
Notes: 
- Translation strings are held via a mix of variables in Dialog and Spells (this file). 
   The rule of thumb is items, labels, and 'dialog' to the player are in Dialog; spell info in Spells
- The code to set them is in Necrosis as part of the initialization code.

There are 4 main tables that form the basis of Necrosis:
- Warlock_Spells
- Warlock_Buttons
- Warlock_Lists
- Warlock_Spell_Use

Note: Spell lists are in this file. This keeps them in one, maintainable place.

::: Warlock_Spells
Specifies all the warlock spells we process (and more).

::: Warlock_Lists
This table hold various lists needed; importantly it specifies the button order and grouping of the Necrosis buttons;
it also holds other lists that are explained in comments inside the table.

::: Warlock_Buttons
Holds the frame information of the Necrosis buttons

::: Warlock_Spell_Use
This table holds ALL the warlock spells listed in Warlock_Spells. Names of some spells are needed even if not known by the warlock.
This table is created on the fly at initialization and rebuilt when spells are learned or changed.
Use IsSpellKnown below to determine if a spell is known / in the spell book.

======
The set of tables allows the highest spells of a type to be gathered and referenced easily using a 'usage' string id, such as "armor".
There is no need to remember spell ids or table indexes.

A group of helper routines are at the bottom of this file to get get spell info, see if a spell is known, and more.
These encapsulates the rather long statements to get data.

Basing the spells on WoW ids and 'usage' allows spell info to be localized automatically without relying on manual translations.
The UsageRank abstracts what highest means and eliminates a lot of hard coding. An example is Demon Skin becoming Demon Armor.

--]==]
--[===[ ::: Add a new spell to existing list
To add a new spell do the following:

Warlock_Spells
- Add the spell by id, including all its levels
- Set the UsageRank and SpellRank manually
- Set Usage to link to lists (Warlock_Lists)
- Set the Type depending on what, if any timer, is needed. 
- Set Length and Cooldown if Timer

Warlock_Buttons
- Create a button entry for the spell
- Set the index (short name) which will be used in Warlock_Lists
- Set Tip for tool tip in Necrosis.lua 
- Set anchor, relative to its
- Set the texture norm; high / push if needed; New files in /UI may need to created

Warlock_Lists
- Determine which list it will be in
- Set f_ptr to the button short name 
- Set high_of the same as Usage in Warlock_Spells

TooltipData (Dialog.lua)
- Add an entry whose index is the same as tip in Warlock_Buttons
- Add a Label entry under index
- Add Text / Text2 / Ritual as needed; these are hard coded into BuildButtonTooltip in Necrosis.lua
   Update localization files for any new strings

Other
- Look at Attributes.lua to see if the right attributes would be set for the new spell.
--]===]

--[===[ ::: Add a new menu
To add a new menu do the following:
- Follow steps to add new spell(s) (above) for the new menu - Warlock_Spells / Warlock_Buttons / TooltipData

Warlock_Buttons
- Create a button entry for the menu
- Set the index (short name) which will be used in Warlok_Lists
- Set f to the frame name to use. This needs to unique across all frames. using Necrosis as a prefix is a good start.
   This is NOT used for any logic, that the names include numbers is a hold over to original coding. 
- Set Tip for tool tip in Necrosis.lua 
- Set anchor, relative to its
- Set the texture norm; high / push if needed; New files in UI may need to be created for graphics
- Set menu so any special logic can be added
   Check other menu values to see where the logic needs to be, especially XML.lua

Warlock_Lists: 
- Add an entry to "on_sphere" for the new menu; set menu to new entry in Warlock_Lists
- Add a entry to hold spells (copy buffs as an example)
- Add an entry for each spell in the menu
- For each spell in the menu - Set f_ptr to the button short name 
- For each spell in the menuSet high_of the same as Usage in Warlock_Spells

Necrosis.TooltipData (Dialog.lua)
- Add an entry whose index is the same as tip for the menu in Warlock_Buttons
- Add a Label entry under index
- Add Text / Text2 / Ritual as needed; these are hard coded into BuildButtonTooltip in Necrosis.lua
   Update localization files for any new strings

Other
- Look at Attributes.lua to see if the right attributes would be set for the new spell buttons and menu button.
   New routines may be needed.
- Look at Local.DefaultConfig- add the new buttons with default positions
- Look at option code in XML folder. Likely new options or check boxes will be needed
--]===]

--========================================================
--[[ Warlock_Spell_Use
Fields
- index is string and are the same values as Usage in Warlock_Spells.

Built on the fly on at initialize / spell change. 
By 'Usage', will contain highest id of each 'Usage' known by the warlock or the 'lowest' if not known
--]]
Necrosis.Warlock_Spell_Use = {} 

--[[ Warlock_Spells
 This table lists the spells used by Necrosis with rank. To Get Ids Use: https://classicdb.ch and GetItemInfo.

 The API to return spell info does NOT return the rank which sucks BIG time so this table will 
 hard code them.
 This is the overall list, the player spell book will also be parsed.
 
Fields:
- The index is the spell ID. GetSpellInfo is used to pull the localized name. 
- SpellRank: The spell rank was added by hand based on the spell id. NOTE: The rank returned by GetSpellInfo is always nil... 
- UsageRank: allows spells of different names to ranked appropriately. Creating health stones and demon skin / armor 
- Usage: is the link to the other tables.
- Timer: true / false whether a timer is desired
Note: As of 7.2, some timers were made selectable (optional) by users. They are in the config / saved variables
- Length / Cooldown / Group are used to create timers
Added fields by code:
- Name: localized spell name from GetSpellBookItemName
- Rank: localized spell rank from GetSpellBookItemName
- CastName: made from <Name>(<Rank>)
- Mana: Cost from GetSpellPowerCost
- InSpellBook: true if found in the player spell book

Notes:
- Created stones are looked for by localized name. The name does NOT include the rank / quality of the stone.
  The stone ids & links are provided but may not be used in the code

Timers:
Spell timers have different aspects:
- Cool down: Can NOT be canceled
- Duration - Buff: Can be canceled manually or by losing aura
- Duration - Spell: Can be canceled by losing aura or dropping out of combat
- Removal - casting: When cast what needs to be removed?
   - Always remove a timer with same Usage AND same target
- Removal - aura:
   - Always remove a timer with same Usage AND same target
   - This will handle curses (one per target)

Notes:
- Banish could be treated as spell or buff duration. WoW calls it a buff.
- For cross spell interaction such as curses (one per target)
  rely on events to remove the spell by name (SPELL_AURA_REMOVED);
  meaning the addon does not have to code this!


-- --]]
-- Necrosis.Warlock_Spells = {
-- --[[
-- Notes:
-- - Ritual of Souls (90429) was removed when Mists of Pandaria released
-- --]]
-- 	-- ::: Summon something
-- 	[5784]	= {UsageRank = 1, SpellRank = 1, Timer = false, Usage = "mount"}, -- 40 Felsteed  mount
-- 	[23161]	= {UsageRank = 2, SpellRank = 2, Timer = false, Usage = "mount"}, -- 60 Dreadsteed mount
-- 	[688]	= {UsageRank = 1, SpellRank = 1, Timer = false, Usage = "imp", PetId = 416,}, -- Imp || Diablotin
-- 	[697]	= {UsageRank = 1, SpellRank = 1, Timer = false, Usage = "voidwalker", PetId = 1860, reagent = "soul_shard", }, -- Voidwalker || Marcheur Pet-0-4379-0-47-1860-1700179E68
-- 	[712]	= {UsageRank = 1, SpellRank = 1, Timer = false, Usage = "succubus", PetId = 1863, reagent = "soul_shard", }, -- Succubus || Succube
-- 	[691]	= {UsageRank = 1, SpellRank = 1, Timer = false, Usage = "felhunter", PetId = 417, reagent = "soul_shard", }, -- Felhunter
-- 	[1122]	= {UsageRank = 1, SpellRank = 1, Timer = true, Usage = "inferno", 
-- 			Length = 5, Cooldown = 3600, reagent = "infernal_stone", }, -- 5852 Inferno || https://classicdb.ch/?spell=1122 -- Infernals https://classic.wowhead.com/spell=23426 Needs research
-- 	[18540] = {UsageRank = 1, SpellRank = 1, Timer = true, Usage = "rit_of_doom", 
-- 			Length = 0, Cooldown = 3600, reagent = "demonic_figurine", }, -- 11859 Ritual of Doom || Rituel funeste || https://classicdb.ch/?spell=18540
	
-- 	-- ::: Stones
-- 	-- Create Soulstone minor || Création pierre d'âme
-- 	[693]   = {UsageRank = 1, SpellRank = 1, Timer = false, Usage = "soulstone",}, -- minor 18|| https://classicdb.ch/?spell=693 || https://classicdb.ch/?item=5232
-- 	[20752] = {UsageRank = 2, SpellRank = 2, Timer = false, Usage = "soulstone",}, -- lesser 30|| https://classicdb.ch/?spell=20752 || https://classicdb.ch/?item=16892
-- 	[20755] = {UsageRank = 3, SpellRank = 3, Timer = false, Usage = "soulstone",}, -- 40 || https://classicdb.ch/?spell=20755 || https://classicdb.ch/?item=16893
-- 	[20756] = {UsageRank = 4, SpellRank = 4, Timer = false, Usage = "soulstone",}, -- greater 50|| https://classicdb.ch/?spell=20756 || https://classicdb.ch/?item=16895
-- 	[20757] = {UsageRank = 5, SpellRank = 5, Timer = false, Usage = "soulstone",}, -- major 60|| https://classicdb.ch/?spell=20757 || https://classicdb.ch/?item=16896
-- 	-- Create Healthstone minor || Création pierre de soin
-- 	[6201]	= {UsageRank = 1, SpellRank = 1, Timer = false, Usage = "healthstone",}, -- minor 10 || https://classicdb.ch/?spell=6201 ||
-- 	[6202]	= {UsageRank = 2, SpellRank = 2, Timer = false, Usage = "healthstone",}, -- lesser 22 || https://classicdb.ch/?spell=6202 ||
-- 	[5699]	= {UsageRank = 3, SpellRank = 3, Timer = false, Usage = "healthstone",}, -- 34 || https://classicdb.ch/?spell=5699 ||
-- 	[11729]	= {UsageRank = 4, SpellRank = 4, Timer = false, Usage = "healthstone",}, -- greater 46 || https://classicdb.ch/?spell=11729||
-- 	[11730]	= {UsageRank = 5, SpellRank = 5, Timer = false, Usage = "healthstone",}, -- major 58 || https://classicdb.ch/?spell=11730 ||

-- 	-- Create Spellstone || Création pierre de sort
-- 	[2362]	= {UsageRank = 1, SpellRank = 1, Timer = false, Usage = "spellstone", Length = 60, Cooldown = 180,}, -- 36 || https://classicdb.ch/?spell=2362 || https://classicdb.ch/?item=5522
-- 	[17727]	= {UsageRank = 2, SpellRank = 2, Timer = false, Usage = "spellstone", Length = 60, Cooldown = 180,}, -- 48 || https://classicdb.ch/?spell=17727 || https://classicdb.ch/?item=13602
-- 	[17728]	= {UsageRank = 3, SpellRank = 3, Timer = false, Usage = "spellstone", Length = 60, Cooldown = 180,}, -- 60 || https://classicdb.ch/?spell=17728 || https://classicdb.ch/?item=13603
-- 	-- Create Firestone || Création pierre de feu
-- 	[6366]  = {UsageRank = 1, SpellRank = 1, Timer = false, Usage = "firestone",}, -- 28 || https://classicdb.ch/?spell=6366 || http://classicdb.ch/?item=1254
-- 	[17951] = {UsageRank = 2, SpellRank = 2, Timer = false, Usage = "firestone",}, -- 36 || https://classicdb.ch/?spell=17951 || https://classicdb.ch/?item=13699
-- 	[17952] = {UsageRank = 3, SpellRank = 3, Timer = false, Usage = "firestone",}, -- 46 || https://classicdb.ch/?spell=17952 || https://classicdb.ch/?item=13700
-- 	[17953] = {UsageRank = 4, SpellRank = 4, Timer = false, Usage = "firestone",}, -- 56 || https://classicdb.ch/?spell=17953 || https://classicdb.ch/?item=13701

-- 	-- ::: Buffs
-- 	[687]	= {UsageRank = 1, SpellRank = 1, Timer = true, Usage = "armor", Length = 1800, Buff = true, SelfOnly = true, }, -- Demon Skin || Peau de démon 
-- 	[696]	= {UsageRank = 2, SpellRank = 2, Timer = true, Usage = "armor", Length = 1800, Buff = true, SelfOnly = true, }, --  
-- 	[706]	= {UsageRank = 3, SpellRank = 1, Timer = false, Usage = "armor", Length = 1800, Buff = true, SelfOnly = true, }, -- Demon Armor || Armure démoniaque
-- 	[1086]	= {UsageRank = 4, SpellRank = 2, Timer = false, Usage = "armor", Length = 1800, Buff = true, SelfOnly = true, }, -- 
-- 	[11733] = {UsageRank = 5, SpellRank = 3, Timer = false, Usage = "armor", Length = 1800, Buff = true, SelfOnly = true, }, -- 
-- 	[11734] = {UsageRank = 6, SpellRank = 4, Timer = false, Usage = "armor", Length = 1800, Buff = true, SelfOnly = true, }, -- 
-- 	[11735] = {UsageRank = 7, SpellRank = 5, Timer = false, Usage = "armor", Length = 1800, Buff = true, SelfOnly = true, }, -- 
-- 	[5697]	= {UsageRank = 1, SpellRank = 1, Timer = true, Usage = "breath", Length = 600, Buff = true, }, -- Unending Breath || Respiration interminable
-- 	[126]	= {UsageRank = 1, SpellRank = 1, Timer = true, Usage = "eye", Length = 45, Buff = true, SelfOnly = true, }, -- Eye of Kilrogg
-- 	[698]	= {UsageRank = 1, SpellRank = 1, Timer = true, Usage = "summoning", Length = 600, Buff = true, }, -- Ritual of Summoning || Rituel d'invocation
-- 	[19028] = {UsageRank = 1, SpellRank = 1, Timer = false, Usage = "link", Buff = true, SelfOnly = true, }, -- Soul Link || Lien spirituel

-- 	[6229]	= {UsageRank = 1, SpellRank = 1, Timer = true, Usage = "ward", Length = 30, Buff = true, }, -- Shadow Ward || Gardien de l'ombre
-- 	[11739] = {UsageRank = 2, SpellRank = 2, Timer = true, Usage = "ward", Length = 30, Buff = true, }, -- 
-- 	[11740] = {UsageRank = 3, SpellRank = 3, Timer = true, Usage = "ward", Length = 30, Buff = true, }, -- 
-- 	[28610] = {UsageRank = 4, SpellRank = 4, Timer = true, Usage = "ward", Length = 30, Buff = true, }, -- 

-- 	[1098] 	= {UsageRank = 1, SpellRank = 1, Timer = true, Usage = "enslave", Length = 300, Buff = true, }, -- Enslave Demon
-- 	[11725] = {UsageRank = 2, SpellRank = 2, Timer = true, Usage = "enslave", Length = 300, Buff = true, }, -- 
-- 	[11726] = {UsageRank = 3, SpellRank = 3, Timer = true, Usage = "enslave", Length = 300, Buff = true, }, --  

-- 	[710]	= {UsageRank = 1, SpellRank = 1, Timer = true, Usage = "banish", Length = 20, Buff = true, }, -- Banish 
-- 	[18647] = {UsageRank = 2, SpellRank = 2, Timer = true, Usage = "banish", Length = 30, Buff = true, }, --  

-- 	[132]	= {UsageRank = 1, SpellRank = 1, Timer = true, Usage = "invisible", Length = 600, Buff = true, }, -- 26 || Detect Invisibility || https://classicdb.ch/?spell=132
-- 	[2970]	= {UsageRank = 2, SpellRank = 2, Timer = true, Usage = "invisible", Length = 600, Buff = true, }, -- 38 || https://classicdb.ch/?spell=2970
-- 	[11743]	= {UsageRank = 3, SpellRank = 3, Timer = true, Usage = "invisible", Length = 600, Buff = true, }, -- 50 || https://classicdb.ch/?spell=11743
	
-- 	-- ::: Curses
-- 	[702]	= {UsageRank = 1, SpellRank = 1, Timer = true, Usage = "weakness", Length = 120, }, -- Curse of Weakness || Malédiction Faiblesse 
-- 	[1108]	= {UsageRank = 2, SpellRank = 2, Timer = true, Usage = "weakness", Length = 120, }, --  
-- 	[6205]	= {UsageRank = 3, SpellRank = 3, Timer = true, Usage = "weakness", Length = 120, }, --  
-- 	[7646]	= {UsageRank = 4, SpellRank = 4, Timer = true, Usage = "weakness", Length = 120, }, --  
-- 	[11707] = {UsageRank = 5, SpellRank = 5, Timer = true, Usage = "weakness", Length = 120, }, --  
-- 	[11708] = {UsageRank = 6, SpellRank = 6, Timer = true, Usage = "weakness", Length = 120, }, --  

-- 	[980]	= {UsageRank = 1, SpellRank = 1, Timer = true, Usage = "agony", Length = 24, }, -- Curse of Agony || Malédiction Agonie 
-- 	[1014]	= {UsageRank = 2, SpellRank = 2, Timer = true, Usage = "agony", Length = 24, }, --  
-- 	[6217]	= {UsageRank = 3, SpellRank = 3, Timer = true, Usage = "agony", Length = 24, }, --  
-- 	[11711] = {UsageRank = 4, SpellRank = 4, Timer = true, Usage = "agony", Length = 24, }, --  
-- 	[11712] = {UsageRank = 5, SpellRank = 5, Timer = true, Usage = "agony", Length = 24, }, --  
-- 	[11713] = {UsageRank = 6, SpellRank = 6, Timer = true, Usage = "agony", Length = 24, }, --  

-- 	[1714]	= {UsageRank = 1, SpellRank = 1, Timer = true, Usage = "tongues", Length = 30, }, -- Curse of Tongues || Malédiction Langage 
-- 	[11719] = {UsageRank = 2, SpellRank = 2, Timer = true, Usage = "tongues", Length = 30, }, --  

-- 	[18223] = {UsageRank = 1, SpellRank = 1, Timer = true, Usage = "exhaustion", Length = 12, }, -- Curse of Exhaustion || Malédiction de fatigue || improved via talent points

-- 	[1490]	= {UsageRank = 1, SpellRank = 1, Timer = true, Usage = "elements", Length = 300, }, -- Curse of the Elements || Malédiction Eléments 
-- 	[11721] = {UsageRank = 2, SpellRank = 2, Timer = true, Usage = "elements", Length = 300, }, --  
-- 	[11722] = {UsageRank = 3, SpellRank = 3, Timer = true, Usage = "elements", Length = 300, }, --  

-- 	[17862]	= {UsageRank = 1, SpellRank = 1, Timer = true, Usage = "shadow", Length = 300, }, -- Curse of Shadow 
-- 	[17937] = {UsageRank = 2, SpellRank = 2, Timer = true, Usage = "shadow", Length = 300, }, --  

-- 	[603]	= {UsageRank = 1, SpellRank = 1, Timer = true, Usage = "doom", Length = 60, Cooldown = 60,}, -- Curse of Doom || Malédiction funeste 

-- 	[704]	= {UsageRank = 1, SpellRank = 1 , Timer = true, Usage = "recklessness", Length = 120, }, -- Curse of Recklessness - removed in patch 3.1 || Malédiction Témérité || 
-- 	[7658]	= {UsageRank = 2, SpellRank = 2 , Timer = true, Usage = "recklessness", Length = 120, }, --  
-- 	[7659]	= {UsageRank = 3, SpellRank = 3 , Timer = true, Usage = "recklessness", Length = 120, }, -- 
-- 	[11717] = {UsageRank = 4, SpellRank = 4 , Timer = true, Usage = "recklessness", Length = 120, }, -- 

-- 	[172]	= {UsageRank = 1, SpellRank = 1, Timer = true, Usage = "corruption", Length = 12, }, -- Corruption 
-- 	[6222]	= {UsageRank = 2, SpellRank = 2, Timer = true, Usage = "corruption", Length = 15, }, --  
-- 	[6223]	= {UsageRank = 3, SpellRank = 3, Timer = true, Usage = "corruption", Length = 18, }, --  
-- 	[7648]	= {UsageRank = 4, SpellRank = 4, Timer = true, Usage = "corruption", Length = 18, }, --  
-- 	[11671] = {UsageRank = 5, SpellRank = 5, Timer = true, Usage = "corruption", Length = 18, }, --  
-- 	[11672] = {UsageRank = 6, SpellRank = 6, Timer = true, Usage = "corruption", Length = 18, }, --  
-- 	[25311] = {UsageRank = 7, SpellRank = 7, Timer = true, Usage = "corruption", Length = 18, }, --  

-- 	-- ::: Spells
-- 	[348]	= {UsageRank = 1, SpellRank = 1, Timer = true, Usage = "immolate", Length = 15, }, -- Immolate 
-- 	[707]	= {UsageRank = 2, SpellRank = 2, Timer = true, Usage = "immolate", Length = 15, }, --  
-- 	[1094]	= {UsageRank = 3, SpellRank = 3, Timer = true, Usage = "immolate", Length = 15, }, --  
-- 	[2941]	= {UsageRank = 4, SpellRank = 4, Timer = true, Usage = "immolate", Length = 15, }, --  
-- 	[11665] = {UsageRank = 5, SpellRank = 5, Timer = true, Usage = "immolate", Length = 15, }, --  
-- 	[11667] = {UsageRank = 6, SpellRank = 6, Timer = true, Usage = "immolate", Length = 15, }, --  
-- 	[11668] = {UsageRank = 7, SpellRank = 7, Timer = true, Usage = "immolate", Length = 15, }, --  
-- 	[25309] = {UsageRank = 8, SpellRank = 8, Timer = true, Usage = "immolate", Length = 15, }, --  
-- 	[5782]	= {UsageRank = 1, SpellRank = 1, Timer = true, Usage = "fear", Length = 10, }, -- Fear 
-- 	[6213]	= {UsageRank = 2, SpellRank = 2, Timer = true, Usage = "fear", Length = 15, }, --  
-- 	[6215]	= {UsageRank = 3, SpellRank = 3, Timer = true, Usage = "fear", Length = 20, }, --  
-- 	[18708] = {UsageRank = 1, SpellRank = 1, Timer = true, Usage = "domination", Length = 15, Cooldown = 900,}, -- Fel Domination || Domination corrompue 
-- 	[6353]	= {UsageRank = 1, SpellRank = 1, Timer = true, Usage = "soul_fire", Cooldown = 60,}, -- Soul Fire || Feu de l'âme 
-- 	[17924] = {UsageRank = 2, SpellRank = 2, Timer = true, Usage = "soul_fire", Cooldown = 60,}, --  
-- 	[6789]	= {UsageRank = 1, SpellRank = 1, Timer = true, Usage = "death_coil", Length = 3, Cooldown = 180,}, -- Death Coil || Voile mortel 
-- 	[17925] = {UsageRank = 2, SpellRank = 2, Timer = true, Usage = "death_coil", Length = 3, Cooldown = 180,}, --  
-- 	[17926] = {UsageRank = 3, SpellRank = 3, Timer = true, Usage = "death_coil", Length = 3, Cooldown = 180,}, --  
-- 	[17877] = {UsageRank = 1, SpellRank = 1, Timer = true, Usage = "shadowburn", Cooldown = 15,}, -- Shadowburn || Brûlure de l'ombre 
-- 	[18867] = {UsageRank = 2, SpellRank = 2, Timer = true, Usage = "shadowburn", Cooldown = 15,}, --  
-- 	[18868] = {UsageRank = 3, SpellRank = 3, Timer = true, Usage = "shadowburn", Cooldown = 15,}, --  
-- 	[18869] = {UsageRank = 4, SpellRank = 4, Timer = true, Usage = "shadowburn", Cooldown = 15,}, --  
-- 	[18870] = {UsageRank = 5, SpellRank = 5, Timer = true, Usage = "shadowburn", Cooldown = 15,}, --  
-- 	[18871] = {UsageRank = 6, SpellRank = 6, Timer = true, Usage = "shadowburn", Cooldown = 15,}, --  
-- 	[17962] = {UsageRank = 1, SpellRank = 1, Timer = false, Usage = "conflagration"}, -- Conflagration 
-- 	[18930] = {UsageRank = 2, SpellRank = 2, Timer = false, Usage = "conflagration"}, --  
-- 	[18931] = {UsageRank = 3, SpellRank = 3, Timer = false, Usage = "conflagration"}, --  
-- 	[18932] = {UsageRank = 4, SpellRank = 4, Timer = false, Usage = "conflagration"}, --  
-- 	[18265] = {UsageRank = 1, SpellRank = 1, Timer = true, Usage = "siphon_life", Length = 30, }, -- Siphon Life || Syphon de vie 
-- 	[18879] = {UsageRank = 2, SpellRank = 2, Timer = true, Usage = "siphon_life", Length = 30, }, --  
-- 	[18880] = {UsageRank = 3, SpellRank = 3, Timer = true, Usage = "siphon_life", Length = 30, }, --  
-- 	[18881] = {UsageRank = 4, SpellRank = 4, Timer = true, Usage = "siphon_life", Length = 30, }, --  
-- 	[5484]	= {UsageRank = 1, SpellRank = 1, Timer = true, Usage = "howl", Length = 10, Cooldown = 40}, -- Howl of Terror || Hurlement de terreur 
-- 	[17928] = {UsageRank = 2, SpellRank = 2, Timer = true, Usage = "howl", Length = 15, Cooldown = 40}, --  
-- 	[1454]	= {UsageRank = 1, SpellRank = 1, Timer = false, Usage = "life_tap"}, -- Life Tap || Connexion
-- 	[1455]	= {UsageRank = 2, SpellRank = 2, Timer = false, Usage = "life_tap"}, -- 
-- 	[1456]	= {UsageRank = 3, SpellRank = 3, Timer = false, Usage = "life_tap"}, -- 
-- 	[11687] = {UsageRank = 4, SpellRank = 4, Timer = false, Usage = "life_tap"}, -- 
-- 	[11688] = {UsageRank = 5, SpellRank = 5, Timer = false, Usage = "life_tap"}, -- 
-- 	[11689] = {UsageRank = 6, SpellRank = 6, Timer = false, Usage = "life_tap"}, -- 
-- 	[7812]	= {UsageRank = 1, SpellRank = 1, Timer = true, Usage = "sacrifice", Length = 30,  NeedPet = true, }, -- Sacrifice || Sacrifice démoniaque 
-- 	[19438] = {UsageRank = 2, SpellRank = 2, Timer = true, Usage = "sacrifice", Length = 30,  NeedPet = true,}, --  
-- 	[19440] = {UsageRank = 3, SpellRank = 3, Timer = true, Usage = "sacrifice", Length = 30,  NeedPet = true,}, --  
-- 	[19441] = {UsageRank = 4, SpellRank = 4, Timer = true, Usage = "sacrifice", Length = 30,  NeedPet = true,}, --  
-- 	[19442] = {UsageRank = 5, SpellRank = 5, Timer = true, Usage = "sacrifice", Length = 30,  NeedPet = true,}, --  
-- 	[19443] = {UsageRank = 6, SpellRank = 6, Timer = true, Usage = "sacrifice", Length = 30,  NeedPet = true,}, --  
-- 	[686]	= {UsageRank = 1, SpellRank = 1, Timer = false, Usage = "bolt"}, -- Shadow Bolt
-- 	[695]	= {UsageRank = 2, SpellRank = 2, Timer = false, Usage = "bolt"}, -- 
-- 	[705]	= {UsageRank = 3, SpellRank = 3, Timer = false, Usage = "bolt"}, -- 
-- 	[1088]	= {UsageRank = 4, SpellRank = 4, Timer = false, Usage = "bolt"}, -- 
-- 	[1106]	= {UsageRank = 5, SpellRank = 5, Timer = false, Usage = "bolt"}, -- 
-- 	[7641]	= {UsageRank = 6, SpellRank = 6, Timer = false, Usage = "bolt"}, -- 
-- 	[11659] = {UsageRank = 7, SpellRank = 7, Timer = false, Usage = "bolt"}, -- 
-- 	[11660] = {UsageRank = 8, SpellRank = 8, Timer = false, Usage = "bolt"}, -- 
-- 	[11661] = {UsageRank = 9, SpellRank = 9, Timer = false, Usage = "bolt"}, -- 
-- 	[25307] = {UsageRank = 10, SpellRank = 10, Timer = false, Usage = "bolt"}, -- 
-- 	[18220] = {UsageRank = 1, SpellRank = 1, Timer = false, Usage = "pact"}, -- Dark Pact || Pacte noir
-- 	[18937] = {UsageRank = 2, SpellRank = 2, Timer = false, Usage = "pact"}, 
-- 	[18938] = {UsageRank = 3, SpellRank = 3, Timer = false, Usage = "pact"}, 
-- 	[1120] = {UsageRank = 1, SpellRank = 1, Timer = true, Usage = "drain_soul", Length = 15,}, -- Ignore Improved Drain Soul (Affliction talent points)
-- 	[8288] = {UsageRank = 2, SpellRank = 2, Timer = true, Usage = "drain_soul", Length = 15,}, 
-- 	[8289] = {UsageRank = 3, SpellRank = 3, Timer = true, Usage = "drain_soul", Length = 15,}, 
	
-- 	-- ::: Spells from using objects: These are spells we look for to create timers. They are not assigned to buttons.
-- 	-- Blizzard has several ids in the DB for each, not sure which are used for Classic...
-- 	-- However, when capturing the event, only the name will used so pick one of listed ids to get the right localized name
	
-- 	-- Soulstone Resurrection || Résurrection de pierre d'ame
-- 	--[[ When a soul stone is used it could be one of several spells because each gives different health and mana amounts
-- 	The timer is on USING a soul stone, not the stone itself.  
-- 	So use the lowest soul stone 'resurrection' spell the warlock can learn just for the timer.
-- 	Take advantage that the various 'resurrection' spells share the same localized name AND the same cool down time. 
-- 	From the id, WoW knows the health and mana to give if the soul stone is used.
-- 	Note: WoW will only allow one soul stone at a time so we do not have to worry about multiple stones...
-- 	--]] 
-- 	[20707] = {UsageRank = 1, SpellRank = 1, Timer = true, Usage = "minor_ss_used", Result = true, Cooldown = 1800, Group = 1, }, -- ss_rez
-- 	[20762] = {UsageRank = 1, SpellRank = 1, Timer = false, Usage = "lesser_ss_used", Result = true, Cooldown = 1800, Group = 1, }, -- 
-- 	[20763] = {UsageRank = 1, SpellRank = 1, Timer = false, Usage = "ss_used", Result = true, Cooldown = 1800, Group = 1, }, -- 
-- 	[20764] = {UsageRank = 1, SpellRank = 1, Timer = false, Usage = "greater_ss_used", Result = true, Cooldown = 1800, Group = 1, }, -- 
-- 	[20765] = {UsageRank = 1, SpellRank = 1, Timer = false, Usage = "major_ss_used", Result = true, Cooldown = 1800, Group = 1, }, -- 

-- 	-- Health stone
-- 	-- When a health stone is used it could be one of several spells because each gives different health amounts
-- 	[6262] = {UsageRank = 1, SpellRank = 1, Timer = true, Usage = "minor_hs_used", Result = true, Cooldown = 120, Group = 2, }, -- minor 120
-- 	[6263] = {UsageRank = 1, SpellRank = 1, Timer = true, Usage = "lesser_hs_used", Result = true, Cooldown = 120, Group = 2, }, -- lesser 250
-- 	[5720] = {UsageRank = 1, SpellRank = 1, Timer = true, Usage = "hs_used", Result = true, Cooldown = 120, Group = 2, }, -- 500
-- 	[5723] = {UsageRank = 1, SpellRank = 1, Timer = true, Usage = "greater_hs_used", Result = true, Cooldown = 120, Group = 2, }, -- greater 800
-- 	[11732] = {UsageRank = 1, SpellRank = 1, Timer = true, Usage = "major_hs_used", Result = true, Cooldown = 120, Group = 2, }, -- major 1200
-- 	}

--[[ Warlock_Buttons
Frames for the various buttons created and used.
Does NOT include timers and config!

Fields
- index is the same string used for Usage in Warlock_Spells.
- f: is the frame name to use. The intent is isolate frame names from usage (such as ...Menu1 through ...Menu9).
- tip: the string reference to the tool tip table.
- menu: The menu 'name', exists only if the frame is used as a menu of buttons.
- anchor: where to anchor the tool tip frame relative to the button.
- norm / high / push: holds the textures to use when creating the frame.

Note: Button name - as a string - are in:
- Initialize.lua to prevent a catch-22 to reference them
- Necrosis.lua config / saved variables for proper referencing
- in config /XML routines as part of anonymous functions

The intention is to use the index to reference the frames rather than coding indexes into the names.
This allows a more flexible scheme and should reduce maintenance and impact if WoW Classic changes over time.
--]]
Necrosis.Warlock_Buttons = {
	-- timer 		= {f = "NecrosisSpellTimerButton", tip = "SpellTimer", menu = "Timer", anchor = "ANCHOR_RIGHT",
	-- 				norm = GraphicsHelper:GetTexture("SpellTimerButton-Normal"),
	-- 				high = GraphicsHelper:GetTexture("SpellTimerButton-Highlight"),
	-- 				push = GraphicsHelper:GetTexture("SpellTimerButton-Pushed"),
	-- 				}, --
	main 		= {f = "NecrosisButton", tip = "Main", anchor = "ANCHOR_LEFT",
					norm = GraphicsHelper:GetTexture("Shard"),
					}, --

	fire_stone 	= {f = "NecrosisFirestoneButton", tip = "Firestone", anchor = "ANCHOR_LEFT",
					norm = GraphicsHelper:GetTexture("FirestoneButton-01"),
					high = GraphicsHelper:GetTexture("FirestoneButton-03"),
					}, --
	spell_stone = {f = "NecrosisSpellstoneButton", tip = "Spellstone", anchor = "ANCHOR_LEFT",
					norm = GraphicsHelper:GetTexture("SpellstoneButton-01"),
					high = GraphicsHelper:GetTexture("SpellstoneButton-03"),
					}, --
	health_stone= {f = "NecrosisHealthstoneButton", tip = "Healthstone", anchor = "ANCHOR_LEFT",
					norm = GraphicsHelper:GetTexture("HealthstoneButton-01"),
					high = GraphicsHelper:GetTexture("HealthstoneButton-03"),
					}, --
	hearth_stone= {f = "NecrosisHearthstoneButton", tip = "Hearthstone", anchor = "ANCHOR_LEFT",
					norm = GraphicsHelper:GetTexture("INV_Misc_Rune_01"),
					high = GraphicsHelper:GetTexture("INV_Misc_Rune_01"),
					}, --
	destroy_shards = {f = "NecrosisDestroyShardsButton", tip = "DestroyShards", anchor = "ANCHOR_LEFT",
					norm = GraphicsHelper:GetTexture("ShardDestroy"),
					high = GraphicsHelper:GetTexture("ShardDestroy"),
					func = function() BagHelper:DestroyShards(NecrosisConfig.DestroyCount) end
					}, --
	soul_stone 	= {f = "NecrosisSoulstoneButton", tip = "Soulstone", anchor = "ANCHOR_LEFT",
					norm = GraphicsHelper:GetTexture("SoulstoneButton-01"),
					high = GraphicsHelper:GetTexture("SoulstoneButton-04"),
					}, --
	mounts 		= {f = "NecrosisMountButton", tip = "Mount", anchor = "ANCHOR_LEFT",
					norm = GraphicsHelper:GetTexture("MountButton-01"),
					high = GraphicsHelper:GetTexture("MountButton-02"),
					}, --

	buffs 		= {f = "NecrosisBuffMenuButton", tip = "BuffMenu", menu = "Buff",
					norm = GraphicsHelper:GetTexture("BuffMenuButton-01"),
					high = GraphicsHelper:GetTexture("BuffMenuButton-02"),
					}, --
	pets 		= {f = "NecrosisPetMenuButton", tip = "PetMenu", menu = "Pet",
					norm = GraphicsHelper:GetTexture("PetMenuButton-01"),
					high = GraphicsHelper:GetTexture("PetMenuButton-02"),
					}, --
	curses 		= {f = "NecrosisCurseMenuButton", tip = "CurseMenu", menu = "Curse",
					norm = GraphicsHelper:GetTexture("CurseMenuButton-01"),
					high = GraphicsHelper:GetTexture("CurseMenuButton-02"),
					}, --

	armor 		= {f = "NecrosisBuffMenu01", tip = "Armor", anchor = "ANCHOR_RIGHT",
					norm = GraphicsHelper:GetTexture("Armor-01"),
					high = GraphicsHelper:GetTexture("Armor-02"),
					}, --
	breath 		= {f = "NecrosisBuffMenu02", tip = "Aqua", anchor = "ANCHOR_RIGHT", can_target = true,
					norm = GraphicsHelper:GetTexture("Aqua-01"),
					high = GraphicsHelper:GetTexture("Aqua-02"),
					}, --
	invisible	= {f = "NecrosisBuffMenu03", tip = "Invisible", anchor = "ANCHOR_RIGHT", can_target = true,
					norm = GraphicsHelper:GetTexture("Invisible-01"),
					high = GraphicsHelper:GetTexture("Invisible-02"),
					}, --
	eye 		= {f = "NecrosisBuffMenu04", tip = "Kilrogg", anchor = "ANCHOR_RIGHT",
					norm = GraphicsHelper:GetTexture("Kilrogg-01"),
					high = GraphicsHelper:GetTexture("Kilrogg-02"),
					}, --
	summoning 	= {f = "NecrosisBuffMenu05", tip = "TP", anchor = "ANCHOR_RIGHT", can_target = true,
					norm = GraphicsHelper:GetTexture("TP-01"),
					high = GraphicsHelper:GetTexture("TP-02"),
					}, --
	link 		= {f = "NecrosisBuffMenu06", tip = "SoulLink", anchor = "ANCHOR_RIGHT",
					norm = GraphicsHelper:GetTexture("SoulLink-01"),
					high = GraphicsHelper:GetTexture("SoulLink-02"),
					}, --
	ward 		= {f = "NecrosisBuffMenu07", tip = "ShadowProtection", anchor = "ANCHOR_RIGHT",
					norm = GraphicsHelper:GetTexture("ShadowProtection-01"),
					high = GraphicsHelper:GetTexture("ShadowProtection-02"),
					}, --
	renforcement= {f = "NecrosisBuffMenu08", tip = "Renforcement", anchor = "ANCHOR_RIGHT",
					norm = GraphicsHelper:GetTexture("Renforcement-01"),
					high = GraphicsHelper:GetTexture("Renforcement-02"),
					}, --
	banish 		= {f = "NecrosisBuffMenu09", tip = "Banish", anchor = "ANCHOR_RIGHT",
					norm = GraphicsHelper:GetTexture("Banish-01"),
					high = GraphicsHelper:GetTexture("Banish-02"),
					}, --
	shatter 	= {f = "NecrosisBuffMenu10", tip = "Shatter", anchor = "ANCHOR_RIGHT",
					norm = GraphicsHelper:GetTexture("PetMenuButton-01"),
					high = GraphicsHelper:GetTexture("PetMenuButton-02"),
					}, --

	domination 	= {f = "NecrosisPetMenu01", tip = "Domination", anchor = "ANCHOR_RIGHT",
					norm = GraphicsHelper:GetTexture("Domination-01"),
					high = GraphicsHelper:GetTexture("Domination-02"),
					}, --
	imp 		= {f = "NecrosisPetMenu02", tip = "Imp", anchor = "ANCHOR_RIGHT", pet = true,
					norm = GraphicsHelper:GetTexture("Imp-01"),
					high = GraphicsHelper:GetTexture("Imp-02"),
					}, --
	voidwalker 	= {f = "NecrosisPetMenu03", tip = "Voidwalker", anchor = "ANCHOR_RIGHT", pet = true,
					norm = GraphicsHelper:GetTexture("Voidwalker-01"),
					high = GraphicsHelper:GetTexture("Voidwalker-02"),
					}, --
	succubus 	= {f = "NecrosisPetMenu04", tip = "Succubus", anchor = "ANCHOR_RIGHT", pet = true,
					norm = GraphicsHelper:GetTexture("Succubus-01"),
					high = GraphicsHelper:GetTexture("Succubus-02"),
					}, --
	incubus 	= {f = "NecrosisPetMenu05", tip = "Incubus", anchor = "ANCHOR_RIGHT", pet = true,
					norm = GraphicsHelper:GetTexture("Succubus-01"),
					high = GraphicsHelper:GetTexture("Succubus-02"),
					}, --
	felguard 	= {f = "NecrosisPetMenu06", tip = "Felguard", anchor = "ANCHOR_RIGHT", pet = true,
					norm = GraphicsHelper:GetTexture("Felguard-01"),
					high = GraphicsHelper:GetTexture("Felguard-02"),
					}, --
	felhunter 	= {f = "NecrosisPetMenu07", tip = "Felhunter", anchor = "ANCHOR_RIGHT", pet = true,
					norm = GraphicsHelper:GetTexture("Felhunter-01"),
					high = GraphicsHelper:GetTexture("Felhunter-02"),
					}, --
	inferno 	= {f = "NecrosisPetMenu08", tip = "Infernal", anchor = "ANCHOR_RIGHT", 
					norm = GraphicsHelper:GetTexture("Infernal-01"),
					high = GraphicsHelper:GetTexture("Infernal-02"),
					}, --
	rit_of_doom	= {f = "NecrosisPetMenu09", tip = "Doomguard", anchor = "ANCHOR_RIGHT", 
					norm = GraphicsHelper:GetTexture("Doomguard-01"),
					high = GraphicsHelper:GetTexture("Doomguard-02"),
					}, --
	enslave 	= {f = "NecrosisPetMenu10", tip = "Enslave", anchor = "ANCHOR_RIGHT",
					norm = GraphicsHelper:GetTexture("Enslave-01"),
					high = GraphicsHelper:GetTexture("Enslave-02"),
					}, --
	sacrifice 	= {f = "NecrosisPetMenu11", tip = "Sacrifice", anchor = "ANCHOR_RIGHT",
					norm = GraphicsHelper:GetTexture("Sacrifice-01"),
					high = GraphicsHelper:GetTexture("Sacrifice-02"),
					}, --

	weakness 	= {f = "NecrosisCurseMenu01", tip = "Weakness", anchor = "ANCHOR_RIGHT",
					norm = GraphicsHelper:GetTexture("Weakness-01"),
					high = GraphicsHelper:GetTexture("Weakness-02"),
					}, --
	agony 		= {f = "NecrosisCurseMenu02", tip = "Agony", anchor = "ANCHOR_RIGHT",
					norm = GraphicsHelper:GetTexture("Agony-01"),
					high = GraphicsHelper:GetTexture("Agony-02"),
					}, --
	tongues 	= {f = "NecrosisCurseMenu03", tip = "Tongues", anchor = "ANCHOR_RIGHT",
					norm = GraphicsHelper:GetTexture("Tongues-01"),
					high = GraphicsHelper:GetTexture("Tongues-02"),
					}, --
	exhaustion 	= {f = "NecrosisCurseMenu04", tip = "Exhaust", anchor = "ANCHOR_RIGHT",
					norm = GraphicsHelper:GetTexture("Exhaust-01"),
					high = GraphicsHelper:GetTexture("Exhaust-02"),
					}, --
	elements 	= {f = "NecrosisCurseMenu05", tip = "Elements", anchor = "ANCHOR_RIGHT",
					norm = GraphicsHelper:GetTexture("Elements-01"),
					high = GraphicsHelper:GetTexture("Elements-02"),
					}, --
	doom 		= {f = "NecrosisCurseMenu06", tip = "Doom", anchor = "ANCHOR_RIGHT",
					norm = GraphicsHelper:GetTexture("Doom-01"),
					high = GraphicsHelper:GetTexture("Doom-02"),
					}, --
	corruption 	= {f = "NecrosisCurseMenu07", tip = "Corruption", anchor = "ANCHOR_RIGHT",
					norm = GraphicsHelper:GetTexture("Corruption-01"),
					high = GraphicsHelper:GetTexture("Corruption-02"),
					}, --
	recklessness= {f = "NecrosisCurseMenu08", tip = "Reckless", anchor = "ANCHOR_RIGHT",
					norm = GraphicsHelper:GetTexture("Reckless-01"),
					high = GraphicsHelper:GetTexture("Reckless-02"),
					}, --
	shadow		= {f = "NecrosisCurseMenu09", tip = "Shadow", anchor = "ANCHOR_RIGHT",
					norm = GraphicsHelper:GetTexture("Shadow-01"),
					high = GraphicsHelper:GetTexture("Shadow-02"),
					}, --

	trance 		= {f = "NecrosisShadowTranceButton", anchor = "ANCHOR_RIGHT",
					norm = GraphicsHelper:GetTexture("ShadowTrance-Icon"),
					pos = {"CENTER", "UIParent", "CENTER", 20, 0},}, --
	backlash 	= {f = "NecrosisBacklashButton", anchor = "ANCHOR_RIGHT",
					norm = GraphicsHelper:GetTexture("Backlash-Icon"),
					pos = {"CENTER", "UIParent", "CENTER", 60, 0},}, --
	elemental 	= {f = "NecrosisCreatureAlertButton",
					norm = GraphicsHelper:GetTexture("ElemAlert"),
					pos = {"CENTER", "UIParent", "CENTER", -60, 0},}, --
	anti_fear 	= {f = "NecrosisAntiFearButton",
					norm = GraphicsHelper:GetTexture("AntiFear-01"),
					pos = {"CENTER", "UIParent", "CENTER", -20, 0},}, --
}

--[=[
This table contains various lists, some that need to ordered.
We could have created the Necrosis buttons via tables IF the buttons had similar actions and structure.
It seemed better to collect the various lists in one place for ease of change.

: Button lists : on_sphere | buffs | curses | pets
- index is numeric and specifies the order frames should be in.
- f_ptr: The frame to use (index to Warlock_Buttons)
- high_of: Use the highest of the referenced spell(s). Same values as Usage in Warlock_Spells.

--]=]
Necrosis.Warlock_Lists = {
	["on_sphere"] = {
		[1] = {f_ptr = "fire_stone", high_of = "firestone",},
		[2] = {f_ptr = "spell_stone", high_of = "spellstone",},
		[3] = {f_ptr = "health_stone", high_of = "healthstone",},
		[4] = {f_ptr = "soul_stone", high_of = "soulstone",},
		[5] = {f_ptr = "buffs",	menu = "buffs", },
		[6] = {f_ptr = "mounts", high_of = "mount",},
		[7] = {f_ptr = "pets", menu = "pets", },
		[8] = {f_ptr = "curses", menu = "curses", },
		[9] = {f_ptr = "destroy_shards" },
--		[9] = {f_ptr = "hearth_stone", item = "Hearthstone",},
	},
-- 31=Demon Armor | 47=Fel Armor | 32=Unending Breath | 33=Detect Invis | 34=Eye of Kilrogg | 37=Ritual of Summoning | 38=Soul Link | 43=Shadow Ward | 35=Enslave Demon | 59=Demonic Empowerment | 9=Banish
--	local buffID = {31, 47, 32, 33, 34, 37, 38, 43, 59, 9}
	["buffs"] = {
		[1] = {f_ptr = "armor", high_of = "armor", },
		[2] = {f_ptr = "breath", high_of = "breath", },
		[3] = {f_ptr = "invisible", high_of = "invisible", },
		[4] = {f_ptr = "eye", high_of = "eye", },
		[5] = {f_ptr = "summoning", high_of = "summoning", },
		[6] = {f_ptr = "link", high_of = "link", },
		[7] = {f_ptr = "ward", high_of = "ward", },
		[8] = {f_ptr = "banish", high_of = "banish", },
		[9] = {f_ptr = "shatter", high_of = "shatter", },
	},
-- 			15, 3, 4, 5, 6, 8, 30, 35, 44, 59
	["pets"] = { -- 2 types: summon pet and (buff or temporary) pet
		[1]  = {f_ptr = "domination", high_of = "domination",},
		[2]  = {f_ptr = "imp", high_of = "imp", s_type = "summon", },
		[3]  = {f_ptr = "voidwalker", high_of = "voidwalker", },
		[4]  = {f_ptr = "succubus", high_of = "succubus", },
		[5]  = {f_ptr = "incubus", high_of = "incubus", },
		[6]  = {f_ptr = "felhunter", high_of = "felhunter", },
		[7]  = {f_ptr = "felguard", high_of = "felguard", },
		[8]  = {f_ptr = "inferno", high_of = "inferno", },
		[9]  = {f_ptr = "rit_of_doom", high_of = "rit_of_doom", },
		[10]  = {f_ptr = "enslave", high_of = "enslave", },
		[11] = {f_ptr = "sacrifice", high_of = "sacrifice", },
	},
-- 23, -- Curse of weakness 22, -- Curse of agony 25, -- Curse of tongues 40, -- Curse of exhaustion 26, -- Curse of the elements 16, -- Curse of doom 14 -- Corruption
	["curses"] = {
		[1] = {f_ptr = "weakness", high_of = "weakness", },
		[2] = {f_ptr = "agony", high_of = "agony", },
		[3] = {f_ptr = "tongues", high_of = "tongues", },
		[4] = {f_ptr = "exhaustion", high_of = "exhaustion", },
		[5] = {f_ptr = "elements", high_of = "elements", },
		[6] = {f_ptr = "doom", high_of = "doom", },
		[7] = {f_ptr = "corruption", high_of = "corruption", },
		[8] = {f_ptr = "recklessness", high_of = "recklessness", },
--		[9] = {f_ptr = "shadow", high_of = "shadow", },
	},
	-- {19, 31, 37, 41, 43, 44, 55} See GetMainSpellList
	["config_main_spell"] = {
		[1] = {high_of = "death_coil", },
		[2] = {high_of = "armor", },
		[3] = {high_of = "summoning", },
		[4] = {high_of = "life_tap", },
		[5] = {high_of = "ward", },
		[6] = {high_of = "sacrifice", },
		[7] = {high_of = "pact", },
		[8] = {high_of = "banish", },
	},
	-- Only using ids for comparison. Dialog contains localized strings
	["reagents"] = {
		soul_shard			= {id = 6265, count = 0, }, --
		infernal_stone		= {id = 5565, count = 0, }, -- 
		demonic_figurine	= {id = 16583, count = 0, }, --
	},
	["soul_bags"] = {
		soul_pouch			= {id = 21340, }, --
		small_soul_pouch	= {id = 22243, }, -- 
		box_of_souls		= {id = 22244, }, --
		felcloth_bag		= {id = 21341, }, --
	},
	["health_stones"] = { -- these have multiple possible ids, not sure which are used...
		minor_hs_1			= {id = 5511, }, --
		minor_hs_2			= {id = 19004, }, --
		minor_hs_3			= {id = 19005, }, --
		lesser_hs_1			= {id = 5512, }, -- 
		lesser_hs_2			= {id = 19006, }, -- 
		lesser_hs_3			= {id = 19007, }, -- 
		hs_1				= {id = 5509, }, --
		hs_2				= {id = 19008, }, --
		hs_3				= {id = 19009, }, --
		greater_hs_1		= {id = 5510, }, --
		greater_hs_2		= {id = 19010, }, --
		greater_hs_3		= {id = 19011, }, --
		major_hs_1			= {id = 9421, }, --
		major_hs_2			= {id = 19012, }, --
		major_hs_3			= {id = 19013, }, --
	},
	["soul_stones"] = {
		minor_hs			= {id = 5232, }, --
		lesser_hs			= {id = 16892, }, -- 
		hs					= {id = 16893, }, --
		greater_hs			= {id = 16895, }, --
		major_hs			= {id = 16896, }, --
	},
	["spell_stones"] = {
		spell				= {id = 5522, }, --
		greater_spell		= {id = 13602, }, --
		major_spell			= {id = 13603, }, --
	},
	["fire_stones"] = {
		lesser_fire			= {id = 1254, }, -- 
		fire				= {id = 13699, }, --
		greater_fire		= {id = 13700, }, --
		major_fire			= {id = 13701, }, --
	},
	["auras"] = { -- buffs and debuffs
		fear_ward			= {id = 19337, }, -- Dwarf priest racial trait
		forsaken			= {id = 7744, }, -- Forsaken racial trait
		fearless			= {id = 12733, }, -- Trinket
		berserk				= {id = 18499, }, -- Warrior Fury talent
		reckless			= {id = 1719, }, -- Warrior Fury talent
		wish				= {id = 12328, }, -- Warrior Fury talent
		wrath				= {id = 19574, }, -- Hunter Beast Mastery talent
		ice					= {id = 11958, }, -- Mage Ice talent
		protect				= {id = 498, }, -- Paladin Holy buff
		shield				= {id = 642, }, -- Paladin Holy buff
		tremor				= {id = 8143, }, -- Shaman totem
		abolish				= {id = 776, }, -- Majordomo (NPC) spell
		recklessness		= {id = 704, }, -- Warlock spell grants anti-fear
	},
	["recall"] = {
		main				= {f_ptr = "main", x = 0, y = -100, show = true,}, -- 
		timer				= {f_ptr = "timer", x = 0, y = 100, show = true,}, -- 
		anti_fear			= {f_ptr = "anti_fear", x = 20, y = 0,}, -- 
		elemental			= {f_ptr = "elemental", x = 60, y = 0,}, -- 
		backlash			= {f_ptr = "backlash", x = -60, y = 0,}, -- 
		trance				= {f_ptr = "trance", x = -20, y = 0,}, -- 
	},
}

-- helper routines to get spell info / determine if a spell is usable
function Necrosis.IsSpellKnown(usage)
	if Necrosis.Warlock_Spell_Use[usage] -- get spell id
	then
		return
			Necrosis.Warlock_Spell_Use[usage] ~= nil and
			Necrosis.Warlock_Spell_Use[usage].Rank >= 0
	else
		return false -- safety
	end
end

function Necrosis.GetSpellName(usage)
	if Necrosis.Warlock_Spell_Use[usage] -- 
	then
		return Necrosis.Warlock_Spell_Use[usage].Name
	else
		return ""
	end
end

function Necrosis.GetSpellCastName(usage)
	if Necrosis.Warlock_Spell_Use[usage] -- 
	then
		return Necrosis.Warlock_Spell_Use[usage].Name
	else
		return ""
	end
end

-- Get the spell ID (GlobalId) for use with secure action buttons
-- TBC Anniversary may require spell IDs instead of spell names
function Necrosis.GetSpellId(usage)
	if Necrosis.Warlock_Spell_Use[usage] -- 
	then
		return Necrosis.Warlock_Spell_Use[usage].GlobalId
	else
		return nil
	end
end

function Necrosis.GetSpellRank(usage)
	if Necrosis.Warlock_Spell_Use[usage] -- 
	then
		return Necrosis.Warlock_Spell_Use[usage].Rank
	else
		return ""
	end
end

function Necrosis.GetSpellMana(usage)
	if Necrosis.Warlock_Spell_Use[usage] -- 
	then
		return Necrosis.Warlock_Spell_Use[usage].Mana
	else
		return ""
	end
end
