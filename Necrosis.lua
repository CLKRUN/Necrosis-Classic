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

-- Local variables || Variables locales
local L = LibStub("AceLocale-3.0"):GetLocale(NECROSIS_ID, true)

local Local = {}
local _G = getfenv(0)
------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS || FONCTIONS LOCALES
------------------------------------------------------------------------------------------------------

-- Creating two functions, new and del || Création de deux fonctions, new et del
-- New creates a temporary array, del destroys it || new crée un tableau temporaire, del le détruit
-- These temporary tables are stored for reuse without having to recreate them. || Ces tableaux temporaires sont stockés pour être réutilisés sans être obligés de les recréer.
local new, del
do
	local cache = setmetatable({}, {__mode='k'})
	function new(populate, ...)
		local tbl
		local t = next(cache)
		if ( t ) then
			cache[t] = nil
			tbl = t
		else
			tbl = {}
		end
		if ( populate ) then
			local num = select("#", ...)
			if ( populate == "hash" ) then
				assert(math.fmod(num, 2) == 0)
				local key
				for i = 1, num do
					local v = select(i, ...)
					if not ( math.fmod(i, 2) == 0 ) then
						key = v
					else
						tbl[key] = v
						key = nil
					end
				end
			elseif ( populate == "array" ) then
				for i = 1, num do
					local v = select(i, ...)
					table.insert(tbl, i, v)
				end
			end
		end
		return tbl
	end
	function del(t)
		for k in next, t do
			t[k] = nil
		end
		cache[t] = true
	end
end

-- Define a metatable which will be applied to any table object that uses it. || Métatable permettant d'utiliser les tableaux qui l'utilisent comme des objets
-- Common functions = :insert, :remove & :sort || Je définis les opérations :insert, :remove et :sort
-- Any table declared as follows "a = setmetatable({}, metatable)" will be able to use the common functions. || Tout tableau qui aura pour déclaration a = setmetatable({}, metatable) pourra utiliser ces opérateurs
local metatable = {
	__index = {
		["insert"] = table.insert,
		["remove"] = table.remove,
		["sort"] = table.sort,
	}
}

-- Create the spell metatable. || Création de la métatable contenant les sorts de nécrosis
Necrosis.Spell = setmetatable({}, metatable)

------------------------------------------------------------------------------------------------------
-- DECLARATION OF VARIABLES || DÉCLARATION DES VARIABLES
------------------------------------------------------------------------------------------------------

-- Detection of initialisation || Détection des initialisations du mod
Local.LoggedIn = false
Local.InWorld = true


-- Configuration defaults || Configuration par défaut
-- To be used if the configuration savedvariables is missing, or if the NecrosisConfig.Version number is changed. || Se charge en cas d'absence de configuration ou de changement de version
Local.DefaultConfig = {
	SoulshardContainer = 4,
	ShadowTranceAlert = true,
	ShowSpellTimers = true,
	AntiFearAlert = true,
	CreatureAlert = true,
	NecrosisLockServ = true,
	NecrosisAngle = 180,
	StonePosition = {1, 2, 3, 4, 5, 6, 7, 8, 9},
		-- 1 = Firestone
		-- 2 = Spellstone
		-- 3 = Healthstone
		-- 4 = Soulstone
		-- 5 = Buff menu
		-- 6 = Mounts
		-- 7 = Demon menu
		-- 8 = Curse menu
		-- 9 = Destroy Shards
	CurseSpellPosition = {1, 2, 3, 4, 5, 6, 7},
		-- 1 = Weakness || Faiblesse
		-- 2 = Agony || Agonie
		-- 3 = Tongues || Langage
		-- 4 = Exhaustion || Fatigue
		-- 5 = Elements
		-- 6 = Doom || Funeste
		-- 7 = Corruption (not really a curse, but hey - its useful :)
	DemonSpellPosition = {1, 2, 3, 4, 5, 6, 8, 9, -10, -11},
		-- 1 = Fel Domination || Domination corrompue
		-- 2 = Summon Imp
		-- 3 = Summon Voidwalker || Marcheur
		-- 4 = Summon Succubus
		-- 5 = Summon Felhunter
		-- 6 = Felguard || Gangregarde
		-- 7 = Infernal
		-- 8 = Doomguard
		-- 9 = Enslave || Asservissement
		-- 10 = Sacrifice
		-- 11 = Demonic Empowerment || Renforcement
	BuffSpellPosition = {1, 2, 3, 4, 5, 6, 7, 8, -9, 10},
		-- 1 = Demon Armor || Armure
		-- 2 = Fel Armor || Gangrarmure
		-- 3 = Unending Breath || Respiration
		-- 4 = Detect Invisibility || Invisibilité
		-- 5 = Eye of Kilrogg
		-- 6 = Ritual of Summoning || TP
		-- 7 = Soul Link || Lien Spirituel
		-- 8 = Shadow Ward || Protection contre l'ombre
		-- 9 = Demonic Empowerment || Renforcement démoniaque --
		-- 10 = Banish || Bannir
	NecrosisToolTip = true,

	MainSpell = 41,

	PetMenuPos = {x=1, y=0, direction=1},
	PetMenuDecalage = {x=1, y=26},

	BuffMenuPos = {x=1, y=0, direction=1},
	BuffMenuDecalage = {x=1, y=26},

	CurseMenuPos = {x=1, y=0, direction=1},
	CurseMenuDecalage = {x=1, y=-26},

	ChatMsg = true,
	ChatType = true,
	Language = GetLocale(),
	ShowCount = true,
	CountType = "Soulshards",
	ShadowTranceScale = 100,
	NecrosisButtonScale = 90,
	NecrosisColor = "Rose",
	Sound = true,
	SpellTimerPos = 1,
	SpellTimerJust = "LEFT",
	Circle = "Soulshards",
	TimerType = 1,
	SensListe = 1,
	PetName = {},
	DemonSummon = true,
	BanishScale = 100,
	-- ItemSwitchCombat = {},
	DestroyCount = 6,
	FramePosition = {
		["NecrosisSpellTimerButton"] = {"CENTER", "UIParent", "CENTER", 100, 300},
		["NecrosisButton"] = {"CENTER", "UIParent", "CENTER", 0, -200},
		["NecrosisCreatureAlertButton"] = {"CENTER", "UIParent", "CENTER", -60, 0},
		["NecrosisAntiFearButton"] = {"CENTER", "UIParent", "CENTER", -20, 0},
		["NecrosisShadowTranceButton"] = {"CENTER", "UIParent", "CENTER", 20, 0},
		["NecrosisBacklashButton"] = {"CENTER", "UIParent", "CENTER", 60, 0},
		["NecrosisFirestoneButton"] = {"CENTER", "UIParent", "CENTER", -121,-100},
		["NecrosisSpellstoneButton"] = {"CENTER", "UIParent", "CENTER", -87,-100},
		["NecrosisHealthstoneButton"] = {"CENTER", "UIParent", "CENTER", -53,-100},
		["NecrosisSoulstoneButton"] = {"CENTER", "UIParent", "CENTER", -17,-100},
		["NecrosisBuffMenuButton"] = {"CENTER", "UIParent", "CENTER", 17,-100},
		["NecrosisMountButton"] = {"CENTER", "UIParent", "CENTER", 53,-100},
		["NecrosisPetMenuButton"] = {"CENTER", "UIParent", "CENTER", 87,-100},
		["NecrosisCurseMenuButton"] = {"CENTER", "UIParent", "CENTER", 121,-100},
		["NecrosisMobTimerAnchor"] = {"CENTER", "UIParent", "CENTER", -200,-100},
		["NecrosisSingleTimerAnchor"] = {"CENTER", "UIParent", "CENTER", 200,-100},
	},
}

-- Timers variables || Variables des timers
Local.TimerManagement = {
	-- Spells to timer || Sorts à timer
	SpellTimer = setmetatable({}, metatable),
	-- Association of timers to Frames || Association des timers aux Frames
	TimerTable = setmetatable({}, metatable),
	-- Groups of timers by mobs || Groupes de timers par mobs
	SpellGroup = setmetatable(
		{
			{Name = "Rez", SubName = " ", Visible = 0},
			{Name = "Main", SubName = " ", Visible = 0},
			{Name = "Cooldown", SubName = " ", Visible = 0}
		},
		metatable
	),
	-- Last cast spell || Dernier sort casté
	LastSpell = {}
}

-- Variables used for managing summoning and stone buttons || Variables utilisées pour la gestion des boutons d'invocation et d'utilisation des pierres
Local.Stone = {
	Soul = {Mode = 1, Location = {}},
	Health = {Mode = 1, Location = {}},
	Spell = {Mode = 1, Location = {}},
	Hearth = {Location = {}},
	Fire = {Mode = 1},
}
Local.SomethingOnHand = "Truc"

-- Component count variable || Variable de comptage des composants
Local.Reagent = {Infernal = 0, Demoniac = 0}

-- List of buttons available in each menu || Liste des boutons disponibles dans chaque menu
Local.Menu = {
	Pet = setmetatable({}, metatable),
	Buff = setmetatable({}, metatable),
	Curse = setmetatable({}, metatable)
}

-- Active Buffs Variable || Variable des Buffs Actifs
Local.BuffActif = {}

-- Variable of the state of the buttons (grayed or not) || Variable de l'état des boutons (grisés ou non)
Local.Desatured = {}

-- Last image used for the sphere || Dernière image utilisée pour la sphere
Local.LastSphereSkin = "Aucune"

-- Variables of care stone exchanges || Variables des échanges de pierres de soins
Local.Trade = {}

-- Variables used for the management of soul fragments || Variables utilisées pour la gestion des fragments d'âme
Local.Soulshard = {Count = 0, Move = 0}
Local.BagIsSoulPouch = {}

-- Variables used for warnings || Variables utilisées pour les avertissements
-- Antifear and Demonic or Elemental Target || Antifear et Cible démoniaque ou élémentaire
Local.Warning = {
	Antifear = {
		Toggle = 2,
		Icon = {"", "Immu", "Prot"}
	}
}

-- Time elapsed between two OnUpdate events || Temps écoulé entre deux event OnUpdate
Local.LastUpdate = {0, 0}

------------------------------------------------------------------------------------------------------
-- NECROSIS FUNCTIONS APPLIED TO ENTRY IN THE GAME || FONCTIONS NECROSIS APPLIQUEES A L'ENTREE DANS LE JEU
------------------------------------------------------------------------------------------------------

local function InitializeMyself()
	Necrosis.CurrentEnv.PlayerFullName = UnitName("player").."-"..GetNormalizedRealmName()
	-- print("init myself "..Necrosis.CurrentEnv.PlayerFullName)
	-- Initialization of the mod || Initialisation du mod
	Necrosis:Initialize(Local.DefaultConfig)
	-- Recording of the events used || Enregistrement des events utilisés
	NecrosisButton:RegisterEvent("PLAYER_ENTERING_WORLD")
	NecrosisButton:RegisterEvent("PLAYER_LEAVING_WORLD")
	EventHelper:AttachApiEvents()
	-- Detecting the type of demon present at the connection || Détection du Type de démon présent à la connexion
	Necrosis.CurrentEnv.DemonType = UnitCreatureFamily("pet")
	Necrosis.Chat:_Msg("Initialized", "USER")
	-- _G["NecrosisButton"]:Show()
end

local function InitWhenOutOfCombat()
	ItemHelper:RegisterStonesLoadedHandler(
		function()
			InitializeMyself()
		end
	)
	ItemHelper:Initialize()
	EventHelper:UnregisterOnCombatStopHandler(InitWhenOutOfCombat)
end

local initialized = false

-- Function applied to loading || Fonction appliquée au chargement
function Necrosis:OnLoad(event)
	if (event == "PLAYER_LOGIN" and not Local.LoggedIn) then
		-- Logon is fired once, wait for it
		local _, Class = UnitClass("player")
		if (Class == "WARLOCK") then
			Local.LoggedIn = true
		end
-- <<<<<<< HEAD

-- 	elseif (event == "SKILL_LINES_CHANGED") and Local.LoggedIn and not weCanStart--) then
-- 	then
-- 		-- Skill changed is fired more than once, seems like a more stable
-- 		-- indicator that tells when the spellbook is ready.
-- 		-- Call ItemHelper first here, it uses async methods for loading item info
-- 		-- and we have to wait for the callbacks.
-- 		ItemHelper:RegisterStonesLoadedHandler(
-- 			function()
-- 				InitializeMyself()
-- 				weCanStart = true
-- 			end
-- 		)
-- 		ItemHelper:Initialize()

-- 	elseif (event == "SPELLS_CHANGED" and weCanStart) then
-- 		-- Spells changed fires each time a new spell is learned etc.
-- 		Necrosis:SpellSetup()
-- 		Necrosis:ButtonSetup()
-- 	end
-- end

-- ------------------------------------------------------------------------------------------------------
-- -- NECROSIS FUNCTIONS || FONCTIONS NECROSIS
-- ------------------------------------------------------------------------------------------------------
-- -- Function started when updating the interface (main) - every 0.1 seconds || Fonction lancée à la mise à jour de l'interface (main) -- Toutes les 0,1 secondes environ
-- function Necrosis:OnUpdate(elapsed)--something,

-- 	if (elapsed) then
-- 		Local.LastUpdate[1] = Local.LastUpdate[1] + elapsed
-- 		Local.LastUpdate[2] = Local.LastUpdate[2] + elapsed
-- 	end

-- 	-- -- If smooth scroll timers, we update them as soon as possible || Si défilement lisse des timers, on les met à jours le plus vite possible
-- 	-- NecrosisUpdateTimer(Local.TimerManagement.SpellTimer)

-- 	-- -- If timers texts, we update them very quickly also || Si timers textes, on les met à jour très vite également
-- 	-- if NecrosisConfig.TimerType == "Textual" then
-- 	-- 	self:TextTimerUpdate(Local.TimerManagement.SpellTimer, Local.TimerManagement.SpellGroup)
-- 	-- end

-- 	-- Every second || Toutes les secondes
-- 	if (Local.LastUpdate[1] > 1) then
-- 	-- If configured, sorting fragments every second || Si configuré, tri des fragment toutes les secondes
-- 		if (NecrosisConfig.SoulshardSort and Local.Soulshard.Move > 0) then
-- 			Necrosis:SoulshardSwitch("MOVE")
-- =======
	elseif (event == "SPELLS_CHANGED" and Local.LoggedIn and not initialized) then
		-- Init only once upon login
		initialized = true
		if (EventHelper:IsCombatLocked()) then
			EventHelper:RegisterOnCombatStopHandler(InitWhenOutOfCombat)
		else
			InitWhenOutOfCombat()
-- >>>>>>> 686e04f19f3de2b28961fbe67dd2ea6b10066740
		end
	elseif (event == "PLAYER_REGEN_ENABLED" and Local.LoggedIn) then
		-- This is required to finish initialization if we log on and
		-- combat is active.
		EventHelper.OnCombatStop()
		Local.PlayerInCombat = false
	end
end


-- <<<<<<< HEAD
-- 	-- Update raid icon in timers
-- 	if (NecrosisConfig.EnableTimerBars) then
-- 		local destIcon = GraphicsHelper:GetRaidIconNumber(destRaidFlags)
-- 		Necrosis.Timers:UpdateRaidIcon(destGUID, destIcon)
-- 	end

-- 	-- Detection of Shadow Trance and Contrecoup || Détection de la transe de l'ombre et de  Contrecoup
-- 	if (subevent == "UNIT_DIED"
-- 		or subevent == "UNIT_DESTROYED"
-- 		or subevent == "UNIT_DISSIPATES")
-- 	then
-- 		if (NecrosisConfig.EnableTimerBars) then
-- 			Necrosis.Timers:RemoveSpellTimerTarget(destGUID)
-- 		end
	
-- 	elseif (subevent == "SPELL_AURA_APPLIED")
-- 	then
-- 		if (destGUID == Necrosis.CurrentEnv.PlayerGuid) then
-- 			Necrosis:SelfEffect("BUFF", spellName)
-- 		end

-- 		if (sourceGUID == Necrosis.CurrentEnv.PlayerGuid) then

-- 			if (NecrosisConfig.EnableTimerBars) then
-- 				if (not destGUID) then
-- 					-- If target is empty the spell (likely soustone) hits ourself
-- 					destGUID = Necrosis.CurrentEnv.PlayerGuid
-- 					destName = Necrosis.CurrentEnv.PlayerName
-- 				end

-- 				-- print("Debuff applied: "..spellName)
-- 				-- Necrosis:CheckUnitDebuff(destGUID, spellName)
	
-- 				-- Capture the icon of the spell target
-- 				local destIconNumber = GetRaidTargetIndex("target")
-- 				local spellData = Necrosis.CurrentEnv.SpellCast[spellName]
-- 				if (spellData) then
-- 					Necrosis.Timers:InsertSpellTimer(
-- 						Necrosis.CurrentEnv.PlayerGuid,
-- 						Necrosis.CurrentEnv.PlayerName,
-- 						destGUID, destName, 0, destIconNumber,
-- 						spellData.id,
-- 						spellName,
-- 						spellData.duration,
-- 						Necrosis.Spell.AuraType[spellData.id]
-- 					)
-- 					Necrosis.CurrentEnv.SpellCast[spellName] = nil
-- 				end
-- 			end
-- 		end

-- 	elseif (subevent == "SPELL_AURA_REFRESH"
-- 		and sourceGUID == Necrosis.CurrentEnv.PlayerGuid
-- 		and destGUID == UnitGUID("target"))
-- 	then
-- 		if (NecrosisConfig.EnableTimerBars) then
-- 			-- Reset a timer if a duration is available
-- 			local spellData = Necrosis.CurrentEnv.SpellCast[spellName]
-- 			if (spellData) then
-- 				Necrosis.Timers:UpdateTimer(
-- 					Necrosis.CurrentEnv.PlayerGuid,
-- 					destGUID,
-- 					spellData.id,
-- 					spellData.duration
-- 				)
-- 				Necrosis.CurrentEnv.SpellCast[spellName] = nil
-- 			end
-- 		end

-- 	-- Detection of the end of Shadow Trance and Contrecoup || Détection de la fin de la transe de l'ombre et de Contrecoup
-- 	elseif (subevent == "SPELL_AURA_REMOVED")
-- 	then
-- 		if (destGUID == Necrosis.CurrentEnv.PlayerGuid) then
-- 			Necrosis:SelfEffect("DEBUFF", spellName)
-- 		end

-- 		if (NecrosisConfig.EnableTimerBars) then
-- 			if (sourceGUID == Necrosis.CurrentEnv.PlayerGuid) then
-- 				Necrosis.Timers:RemoveSpellTimerTargetName(Necrosis.CurrentEnv.PlayerGuid, destGUID, spellName)
-- 			end
-- 		end

-- 		if (destGUID == UnitGUID("focus")
-- 			and Local.TimerManagement.Banish
-- 			and spellName == Necrosis.Spell[9].Name)
-- 		then
-- 			Necrosis.Chat:_Msg("BAN ! BAN ! BAN !")
-- 			-- Necrosis:RetraitTimerParNom(Necrosis.Spell[9], Local.TimerManagement)
-- 			Local.TimerManagement.Banish = false
-- 		end	

-- 	-- Debian Detection || Détection du Déban
-- 	-- elseif (subevent == "SPELL_AURA_REMOVED" and destGUID == UnitGUID("focus") and Local.TimerManagement.Banish and spellName == Necrosis.Spell[9].Name)
-- 	-- then
-- 	-- 	Necrosis.Chat:_Msg("BAN ! BAN ! BAN !")
-- 	-- 	Necrosis:RetraitTimerParNom(Necrosis.Spell[9], Local.TimerManagement)
-- 	-- 	Local.TimerManagement.Banish = false

-- 	-- Resist / immune detection || Détection des résists / immunes
-- 	elseif (subevent == "SPELL_MISSED"
-- 			and sourceGUID == Necrosis.CurrentEnv.PlayerGuid
-- 			and destGUID == UnitGUID("target"))
-- 	then
-- print("Necrosis - Spell resisted: "..tostring(spellName))

-- 		Necrosis.CurrentEnv.SpellCast[spellName] = nil
	
-- 		if NecrosisConfig.AntiFearAlert
-- 			and (spellName == Necrosis.Spell[13].Name or spellName == Necrosis.Spell[19].Name)
-- 			and arg12 == "IMMUNE"
-- 		then
-- 			Local.Warning.Antifear.Immune = true
-- 		end
-- 		if spellName == Local.TimerManagement.LastSpell.Name
-- 			and GetTime() <= (Local.TimerManagement.LastSpell.Time + 1.5)
-- 		then
-- 			-- Necrosis:RetraitTimerParIndex(Local.TimerManagement.LastSpell.Index, Local.TimerManagement)
-- 		end

-- 	-- Detection application of a spell / fire stone on a weapon || Détection application d'une pierre de sort/feu sur une arme
-- 	elseif (subevent == "ENCHANT_APPLIED"
-- 		and destGUID == UnitGUID("player")
-- 		and ((BagHelper.Spellstone_Name and arg9 == BagHelper.Spellstone_Name)
-- 			or (BagHelper.Firestone_Name and arg9 == BagHelper.Firestone_Name)))
-- 	then
-- 	-- print("ENCHANT_APPLIED: "..arg9)
-- 			Local.SomethingOnHand = arg9
-- 			Necrosis:UpdateIcons()
-- 	-- End of enchantment detection || Détection fin d'enchant
-- 	elseif (subevent == "ENCHANT_REMOVE"
-- 		and destGUID == UnitGUID("player")
-- 		and ((BagHelper.Spellstone_Name and arg9 == BagHelper.Spellstone_Name)
-- 		or (BagHelper.Firestone_Name and arg9 == BagHelper.Firestone_Name)))
-- 	then
-- 			Local.SomethingOnHand = "Rien"
-- 			Necrosis:UpdateIcons()
-- 	end
-- end

-- function CheckGroupStatus()
-- 	local groupMembersCount = GetNumGroupMembers()
-- 	if (groupMembersCount > 5) then
-- 		Necrosis.CurrentEnv.InRaid = true
-- 		Necrosis.CurrentEnv.InParty = false
-- 	elseif (groupMembersCount > 0) then
-- 		Necrosis.CurrentEnv.InRaid = false
-- 		Necrosis.CurrentEnv.InParty = true
-- 	else
-- 		Necrosis.CurrentEnv.InRaid = false
-- 		Necrosis.CurrentEnv.InParty = false
-- 	end
-- end

-- function Necrosis:CheckUnitDebuff(destGUID, spellName)
-- 	local i = 1
-- 	local maxSlots = 40
-- 	-- while (i < maxSlots) do
-- 		-- Duration is always 0 despite API descriptions, bug?
-- 		local name, icon, count, debuffType, duration, expirationTime, source, isStealable, 
-- 			nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, castByPlayer, nameplateShowAll, timeMod
-- 			-- = UnitDebuff(destGUID, i, "PLAYER")
-- 			= UnitDebuff("target", i, "PLAYER")
-- 		if (spellName == name) then
-- 			print("Debuff found at "..i..": "..name..", "..duration..", "..spellId..", "..expirationTime..", "..timeMod)
-- 			return name, duration, spellId, timeMod
-- 		end
-- 		i = i + 1
-- 	-- end
-- 	print ("Debuff not found")
	
-- 	-- print("UnitDebuff: "..tostring(name)..", "..tostring(icon)..", "..tostring(count)..", "
-- 	-- 	..tostring(debuffType)..", "..tostring(duration)..", "..tostring(expirationTime)..", "
-- 	-- 	..tostring(source)..", "..tostring(isStealable)..", "..tostring(nameplateShowPersonal)..", "
-- 	-- 	..tostring(spellId)..", "..tostring(canApplyAura)..", "..tostring(isBossDebuff)
-- 	-- )
-- end

-- ------------------------------------------------------------------------------------------------------
-- -- FUNCTIONS NECROSIS "ON EVENT" || FONCTIONS NECROSIS "ON EVENT"
-- ------------------------------------------------------------------------------------------------------

-- -- Event : UNIT_PET
-- -- Allows the servo to be timed, as well as to prevent for servo breaks || Permet de timer les asservissements, ainsi que de prévenir pour les ruptures d'asservissement
-- -- Also change the name of the pet to the replacement of it || Change également le nom du pet au remplacement de celui-ci
-- function Necrosis:ChangeDemon()
-- 	-- If the new demon is a slave demon, we put a 5 minute timer || Si le nouveau démon est un démon asservi, on place un timer de 5 minutes
-- 	if (self:UnitHasEffect("pet", self.Spell[10].Name)) then
-- 		if (not Necrosis.CurrentEnv.DemonEnslaved) then
-- 			Necrosis.CurrentEnv.DemonEnslaved = true
-- 		end
-- 	else
-- 		-- When the enslaved demon is lost, remove the timer and warn the warlock || Quand le démon asservi est perdu, on retire le Timer et on prévient le Démoniste
-- 		if (Necrosis.CurrentEnv.DemonEnslaved) then
-- 			Necrosis.CurrentEnv.DemonEnslaved = false
-- 			if NecrosisConfig.Sound then PlaySoundFile(self.Sound.EnslaveEnd) end
-- 			self.Chat:_Msg(self.ChatMessage.Information.EnslaveBreak, "USER")
-- 		end
-- 	end

-- 	-- If the demon is not enslaved we define its title, and we update its name in Necrosis || Si le démon n'est pas asservi on définit son titre, et on met à jour son nom dans Necrosis
-- 	Necrosis.CurrentEnv.LastDemonType = Necrosis.CurrentEnv.DemonType
-- 	Necrosis.CurrentEnv.DemonType = UnitCreatureFamily("pet")

-- 	if Necrosis.CurrentEnv.DemonType then
-- 		NecrosisConfig.PetName[Necrosis.CurrentEnv.DemonType] = UnitName("pet")
-- 	end

-- 	for i = 1, #self.Translation.DemonName, 1 do
-- 		if Necrosis.CurrentEnv.DemonType == self.Translation.DemonName[i] and not (NecrosisConfig.PetName[i] or (UnitName("pet") == UNKNOWNOBJECT)) then
-- 			NecrosisConfig.PetName[i] = UnitName("pet")
-- 			--self:Localization()
-- 			break
-- 		end
-- 	end
-- 	self:UpdateMana()

-- 	return
-- end

-- -- Events : CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS, CHAT_MSG_SPELL_AURA_GONE_SELF et CHAT_MSG_SPELL_BREAK_AURA
-- -- Manage the appearing and disappearing effects on the warlock || Permet de gérer les effets apparaissants et disparaissants sur le démoniste
-- -- Based on CombatLog || Basé sur le CombatLog
-- function Necrosis:SelfEffect(action, nom)
-- 	if NecrosisConfig.LeftMount then
-- 		local NomCheval1 = GetSpellInfo(NecrosisConfig.LeftMount)
-- 	else
-- 		local NomCheval1 = Necrosis.Spell[2].Name
-- 	end
-- 	if NecrosisConfig.RightMount then
-- 		local NomCheval2 = GetSpellInfo(NecrosisConfig.RightMount)
-- 	else
-- 		local NomCheval2 = Necrosis.Spell[1].Name
-- 	end

-- 	if action == "BUFF" then
-- 		-- Changing the mount button when the Warlock is disassembled || Changement du bouton de monture quand le Démoniste est démonté
-- 		if nom == Necrosis.Spell[1].Name or  nom == Necrosis.Spell[2].Name or nom == "NomCheval1" or nom == "NomCheval2" then
-- 			Local.BuffActif.Mount = true
-- 			if _G["NecrosisMountButton"] then
-- 				NecrosisMountButton:SetNormalTexture(GraphicsHelper:GetTexture("MountButton-02"))
-- 				NecrosisMountButton:GetNormalTexture():SetDesaturated(nil)
-- 			end
-- 		-- Change Dominated Domination Button if Enabled + Cooldown Timer || Changement du bouton de la domination corrompue si celle-ci est activée + Timer de cooldown
-- 		elseif  nom == Necrosis.Spell[15].Name then
-- 			Local.BuffActif.Domination = true
-- 			if _G["NecrosisPetMenu1"] then
-- 				NecrosisPetMenu1:SetNormalTexture(GraphicsHelper:GetTexture("Domination-02"))
-- 				NecrosisPetMenu1:GetNormalTexture():SetDesaturated(nil)
-- 			end
-- 		-- Change the spiritual link button if it is enabled || Changement du bouton du lien spirituel si celui-ci est activé
-- 		elseif nom == Necrosis.Spell[38].Name then
-- 			Local.BuffActif.SoulLink = true
-- 			if _G["NecrosisBuffMenu7"] then
-- 				NecrosisBuffMenu7:SetNormalTexture(GraphicsHelper:GetTexture("SoulLink-02"))
-- 				NecrosisBuffMenu7:GetNormalTexture():SetDesaturated(nil)
-- 			end
-- 		-- If Backlash, to display the icon and we proc the sound || si Contrecoup, pouf on affiche l'icone et on proc le son
-- 		-- If By-effect, one-on-one icon and one proc the sound || if By-effect, pouf one posts the icon and one proc the sound
-- 		elseif nom == Necrosis.Translation.Proc.Backlash and NecrosisConfig.ShadowTranceAlert then
-- 			self.Chat:_Msg(self.ProcText.Backlash, "USER")
-- 			if NecrosisConfig.Sound then PlaySoundFile(Necrosis.Sound.Backlash) end
-- 			NecrosisBacklashButton:Show()
-- 		-- If Twilight, to display the icon and sound || si Crépuscule, pouf on affiche l'icone et on proc le son
-- 		-- If Twilight / Nightfall, puff one posts the icon and one proc the sound || if Twilight/Nightfall, pouf one posts the icon and one proc the sound
-- 		elseif nom == Necrosis.Translation.Proc.ShadowTrance and NecrosisConfig.ShadowTranceAlert then
-- 			self.Chat:_Msg(self.ProcText.ShadowTrance, "USER")
-- 			if NecrosisConfig.Sound then PlaySoundFile(Necrosis.Sound.ShadowTrance) end
-- 			NecrosisShadowTranceButton:Show()
-- 		end
-- 	else
-- 		-- Changing the mount button when the Warlock is disassembled || Changement du bouton de monture quand le Démoniste est démonté
-- 		if nom == Necrosis.Spell[1].Name or  nom == Necrosis.Spell[2].Name or nom == "NomCheval1" or nom == "NomCheval2" then
-- 			Local.BuffActif.Mount = false
-- 			if _G["NecrosisMountButton"] then
-- 				NecrosisMountButton:SetNormalTexture(GraphicsHelper:GetTexture("MountButton-01"))
-- 			end
-- 		-- Domination button change when Warlock is no longer under control || Changement du bouton de Domination quand le Démoniste n'est plus sous son emprise
-- 		elseif  nom == Necrosis.Spell[15].Name then
-- 			Local.BuffActif.Domination = false
-- 			if _G["NecrosisPetMenu1"] then
-- 				NecrosisPetMenu1:SetNormalTexture(GraphicsHelper:GetTexture("Domination-01"))
-- 			end
-- 		-- Changing the Spiritual Link button when the Warlock is no longer under control || Changement du bouton du Lien Spirituel quand le Démoniste n'est plus sous son emprise
-- 		elseif nom == Necrosis.Spell[38].Name then
-- 			Local.BuffActif.SoulLink = false
-- 			if _G["NecrosisBuffMenu7"] then
-- 				NecrosisBuffMenu7:SetNormalTexture(GraphicsHelper:GetTexture("SoulLink-01"))
-- 			end
-- 		-- Hide the shadowtrance (nightfall) or backlash buttons when the state is ended
-- 		elseif nom == Necrosis.Translation.Proc.ShadowTrance or nom == Necrosis.Translation.Proc.Backlash then
-- 			NecrosisShadowTranceButton:Hide()
-- 			NecrosisBacklashButton:Hide()
-- 		end
-- 	end
-- 	Necrosis:UpdateMana()
-- 	return
-- end

-- -- -- Event : UNIT_SPELLCAST_SUCCEEDED
-- -- -- Manages everything related to successful spell casts || Permet de gérer tout ce qui touche aux sorts une fois leur incantation réussie
-- -- function Necrosis:SpellManagement()
-- -- 	-- -- print (Local.SpellCasted.Name)
-- -- 	-- local SortActif = false
-- -- 	-- if (Local.SpellCasted.Name) then
-- -- 	-- 	-- print ('casting on target '..Local.SpellCasted.TargetName)
-- -- 	-- 	-- Messages Posts Cast (Démons et TP)
-- -- 	-- 	-- Necrosis.Chat:AfterSpellCast()

-- -- 	-- 	-- Create a timer when a soulstone has been used || Si le sort lancé à été une Résurrection de Pierre d'âme, on place un timer
-- -- 	-- 	if (Local.SpellCasted.Name == self.Spell[11].Name) then
-- -- 	-- 		if Local.SpellCasted.TargetName == UnitName("player") then
-- -- 	-- 			Local.SpellCasted.TargetName = ""
-- -- 	-- 			Local.SpellCasted.TargetGUID = ""
-- -- 	-- 		end
-- -- 	-- 	-- Create a timer if a healthstone was used || Si le sort était une pierre de soin
-- -- 	-- 	elseif Local.SpellCasted.Name:find(self.Translation.Item.Healthstone) and not Local.SpellCasted.Name:find(self.Translation.Misc.Create) then
-- -- 	-- 		-- Local.TimerManagement = self:InsertTimerStone("Healthstone", nil, nil, Local.TimerManagement)
-- -- 	-- 	-- Create a timer for any other spell cast (if valid) || Pour les autres sorts castés, tentative de timer si valable
-- -- 	-- 	else
-- -- 	-- 		for spell=1, #self.Spell, 1 do
-- -- 	-- 			if Local.SpellCasted.Name == self.Spell[spell].Name and not (spell == 10) then
-- -- 	-- 				-- Update the timer if it already exists || Si le timer existe déjà sur la cible, on le met à jour
-- -- 	-- 				if Local.TimerManagement.SpellTimer[1] then
-- -- 	-- 					for thisspell=1, #Local.TimerManagement.SpellTimer, 1 do
-- -- 	-- 						if Local.TimerManagement.SpellTimer[thisspell].Name == Local.SpellCasted.Name
-- -- 	-- 							and Local.TimerManagement.SpellTimer[thisspell].TargetGUID == Local.SpellCasted.TargetGUID
-- -- 	-- 							and not (self.Spell[spell].Type == 4)	-- not a curse
-- -- 	-- 							and not (self.Spell[spell].Type == 5) -- not corruption
-- -- 	-- 							and not (spell == 16)
-- -- 	-- 							and not (spell == 41)
-- -- 	-- 							then
-- -- 	-- 							-- If it is spell launched already present on a mob, we put the timer back to the bottom ||Si c'est sort lancé déjà présent sur un mob, on remet le timer à fond
-- -- 	-- 							if not (spell == 9) or (spell == 9 and not self:UnitHasEffect("focus", Local.SpellCasted.Name)) then
-- -- 	-- 								Local.TimerManagement.SpellTimer[thisspell].Time = self.Spell[spell].Length
-- -- 	-- 								Local.TimerManagement.SpellTimer[thisspell].TimeMax = floor(GetTime() + self.Spell[spell].Length)
-- -- 	-- 								if (spell == 9) and (Local.SpellCasted.Rank:find("1")) then
-- -- 	-- 									Local.TimerManagement.SpellTimer[thisspell].Time = 20
-- -- 	-- 									Local.TimerManagement.SpellTimer[thisspell].TimeMax = floor(GetTime() + 20)
-- -- 	-- 								end
-- -- 	-- 							end
-- -- 	-- 							SortActif = true
-- -- 	-- 							break
-- -- 	-- 						end


-- -- 	-- 						-- If we have banished a new target, then remove the previous timer. || Si c'est un banish sur une nouvelle cible, on supprime le timer précédent
-- -- 	-- 						if Local.TimerManagement.SpellTimer[thisspell].Name == Local.SpellCasted.Name and spell == 9
-- -- 	-- 							and not
-- -- 	-- 								(Local.TimerManagement.SpellTimer[thisspell].TargetGUID == Local.SpellCasted.TargetGUID)
-- -- 	-- 							then
-- -- 	-- 							-- Local.TimerManagement = self:RetraitTimerParIndex(thisspell, Local.TimerManagement)
-- -- 	-- 							SortActif = false
-- -- 	-- 							break
-- -- 	-- 						end

-- -- 	-- 						-- If we have cast fear, then remove the previous timer || Si c'est un fear, on supprime le timer du fear précédent
-- -- 	-- 						if Local.TimerManagement.SpellTimer[thisspell].Name == Local.SpellCasted.Name and spell == 13 then
-- -- 	-- 							-- Local.TimerManagement = self:RetraitTimerParIndex(thisspell, Local.TimerManagement)
-- -- 	-- 							SortActif = false
-- -- 	-- 							break
-- -- 	-- 						end

-- -- 	-- 						if SortActif then
-- -- 	-- 							break
-- -- 	-- 						end
-- -- 	-- 					end
-- -- 	-- 					-- If the timer is a curse, one removes the preceding curse on the target || Si le timer est une malédiction, on enlève la précédente malédiction sur la cible
-- -- 	-- 					if (self.Spell[spell].Type == 4) or (spell == 16) then
-- -- 	-- 						for thisspell=1, #Local.TimerManagement.SpellTimer, 1 do
-- -- 	-- 							-- But we keep the cooldown of the evil curse || Mais on garde le cooldown de la malédiction funeste
-- -- 	-- 							if Local.TimerManagement.SpellTimer[thisspell].Name == self.Spell[16].Name then
-- -- 	-- 								Local.TimerManagement.SpellTimer[thisspell].TargetGUID = Local.SpellCasted.TargetGUID
-- -- 	-- 								Local.TimerManagement.SpellTimer[thisspell].TargetLevel = Local.SpellCasted.TargetLevel
-- -- 	-- 							end
-- -- 	-- 							if Local.TimerManagement.SpellTimer[thisspell].Type == 4
-- -- 	-- 								and Local.TimerManagement.SpellTimer[thisspell].TargetGUID == Local.SpellCasted.TargetGUID
-- -- 	-- 								then
-- -- 	-- 								-- Local.TimerManagement = self:RetraitTimerParIndex(thisspell, Local.TimerManagement)
-- -- 	-- 								break
-- -- 	-- 							end
-- -- 	-- 						end
-- -- 	-- 						SortActif = false
-- -- 	-- 					-- If its a corruption timer, remove the previous one || Si le timer est une corruption, on enlève la précédente corruption sur la cible
-- -- 	-- 					elseif (self.Spell[spell].Type == 5) then
-- -- 	-- 						for thisspell=1, #Local.TimerManagement.SpellTimer, 1 do
-- -- 	-- 							if Local.TimerManagement.SpellTimer[thisspell].Type == 5
-- -- 	-- 								and Local.TimerManagement.SpellTimer[thisspell].TargetGUID == Local.SpellCasted.TargetGUID
-- -- 	-- 								then
-- -- 	-- 								-- Local.TimerManagement = self:RetraitTimerParIndex(thisspell, Local.TimerManagement)
-- -- 	-- 								break
-- -- 	-- 							end
-- -- 	-- 						end
-- -- 	-- 						SortActif = false
-- -- 	-- 					end
-- -- 	-- 				end
-- -- 	-- 				if not SortActif
-- -- 	-- 					and not (self.Spell[spell].Type == 0)
-- -- 	-- 					and not (spell == 10)
-- -- 	-- 					and not (spell == 1)
-- -- 	-- 					and not (spell == 2)
-- -- 	-- 					then

-- -- 	-- 					if (spell == 9) then

-- -- 	-- 						if Necrosis.Spell[9].Rank then
-- -- 	-- 							self.Spell[spell].Length = 20
-- -- 	-- 						else
-- -- 	-- 							self.Spell[spell].Length = 30
-- -- 	-- 						end
-- -- 	-- 						Local.TimerManagement.Banish = true
-- -- 	-- 					end
-- -- 	-- 					-- now insert a timer for the spell that has been casted
-- -- 	-- 					-- Local.TimerManagement = Necrosis:InsertTimerParTable(spell, Local.SpellCasted.TargetName, Local.SpellCasted.TargetLevel, Local.TimerManagement,Local.SpellCasted.TargetGUID)
-- -- 	-- 					break
-- -- 	-- 				end
-- -- 	-- 			end
-- -- 	-- 		end
-- -- 	-- 	end
-- -- 	-- end
-- -- 	-- Local.SpellCasted = {}
-- -- 	-- return
-- -- end

-- ------------------------------------------------------------------------------------------------------
-- -- INTERFACE FUNCTIONS - XML ​​LINKS || FONCTIONS DE L'INTERFACE -- LIENS XML
-- ------------------------------------------------------------------------------------------------------

-- -- Function to move Necrosis elements on the screen ||Fonction permettant le déplacement d'éléments de Necrosis sur l'écran
-- function Necrosis.OnDragStart(uiElement)
-- 	uiElement:StartMoving()
-- end

-- -- Function stopping the movement of Necrosis elements on the screen ||Fonction arrêtant le déplacement d'éléments de Necrosis sur l'écran
-- function Necrosis.OnDragStop(uiElement)
-- 	-- We stop the movement effectively ||On arrête le déplacement de manière effective
-- 	uiElement:StopMovingOrSizing()
-- 	-- We save the location of the button ||On sauvegarde l'emplacement du bouton
-- 	local name = uiElement:GetName()
-- 	local AncreBouton, BoutonParent, AncreParent, BoutonX, BoutonY = uiElement:GetPoint()
-- 	if not BoutonParent then
-- 		BoutonParent = "UIParent"
-- 	else
-- 		BoutonParent = BoutonParent:GetName()
-- 	end
-- 	NecrosisConfig.FramePosition[name] = {AncreBouton, BoutonParent, AncreParent, BoutonX, BoutonY}
-- end

-- -- Function managing the help bubbles ||Fonction gérant les bulles d'aide
-- function Necrosis:BuildTooltip(button, Type, anchor, sens)
-- 	-- If the display of help bubbles is disabled, Bye bye! ||Si l'affichage des bulles d'aide est désactivé, Bye bye !
-- 	if not NecrosisConfig.NecrosisToolTip then
-- 		return
-- 	end

-- 	-- If the tooltip is associated with a menu button, we change the anchoring of the tooltip according to its meaning ||Si la bulle d'aide est associée à un bouton de menu, on change l'ancrage de la tooltip suivant son sens
-- 	if sens then
-- 		if (sens == "Pet" and NecrosisConfig.PetMenuPos.direction < 0)
-- 			or
-- 				(sens == "Buff" and NecrosisConfig.BuffMenuPos.direction < 0)
-- 			or
-- 				(sens == "Curse" and NecrosisConfig.CurseMenuPos.direction < 0)
-- 			or
-- 				(sens == "Timer" and NecrosisConfig.SpellTimerJust == "RIGHT")
-- 			then
-- 				anchor = "ANCHOR_LEFT"
-- 		end
-- 	end

-- 	-- We look at whether corrupt domination, shadow guard or curse amplification are up (for tooltips) ||On regarde si la domination corrompue, le gardien de l'ombre ou l'amplification de malédiction sont up (pour tooltips)
-- 	-- local start, duration
-- 	-- local start2, duration2

-- 	local felDomCooldown, felDomCooldownTime = Necrosis.Spells:GetFelDominationCooldown()

-- 	-- if self.Spell[15].ID then
-- 	-- 	start, duration = GetSpellCooldown(self.Spell[15].ID, BOOKTYPE_SPELL)
-- 	-- else
-- 	-- 	start = 1
-- 	-- 	duration = 1
-- 	-- end

-- 	-- if self.Spell[43].ID then
-- 	-- 	start2, duration2 = GetSpellCooldown(self.Spell[43].ID, BOOKTYPE_SPELL)
-- 	-- 	if not start2 then start2 = 1 end
-- 	-- 	if not duration2 then duration2 = 1 end
-- 	-- else
-- 	-- 	start2 = 1
-- 	-- 	duration2 = 1
-- 	-- end

-- 	-- local start3, duration3
-- 	-- if self.Spell[50].ID then
-- 	-- 	start3, duration3 = GetSpellCooldown(self.Spell[50].ID, BOOKTYPE_SPELL)
-- 	-- else
-- 	-- 	start3 = 1
-- 	-- 	duration3 = 1
-- 	-- end

-- 	-- Creating help bubbles .... ||Création des bulles d'aides....
-- 	GameTooltip:SetOwner(button, anchor)
-- 	GameTooltip:SetText(self.TooltipData[Type].Label)

-- 	-- ..... for the main button ||..... pour le bouton principal
-- 	if (Type == "Main") then
-- 		GameTooltip:AddLine(self.TooltipData.Main.Soulshard..Local.Soulshard.Count)
-- 		GameTooltip:AddLine(self.TooltipData.Main.InfernalStone..Local.Reagent.Infernal)
-- 		GameTooltip:AddLine(self.TooltipData.Main.DemoniacStone..Local.Reagent.Demoniac)
-- 		GameTooltip:AddLine(" ") -- Add empy line
-- 		GameTooltip:AddLine(self.TooltipData.Main.Soulstone..self.TooltipData[Type].Stone[BagHelper.Soulstone_IsAvailable])
-- 		GameTooltip:AddLine(self.TooltipData.Main.Healthstone..self.TooltipData[Type].Stone[BagHelper.Healthstone_IsAvailable])
-- 		GameTooltip:AddLine(self.TooltipData.Main.Spellstone..self.TooltipData[Type].Stone[BagHelper.Spellstone_IsAvailable])
-- 		GameTooltip:AddLine(self.TooltipData.Main.Firestone..self.TooltipData[Type].Stone[BagHelper.Firestone_IsAvailable])

-- 		-- View the name of the daemon, or if it is slave, or "None" if no daemon is present ||Affichage du nom du démon, ou s'il est asservi, ou "Aucun" si aucun démon n'est présent
-- 		if (Necrosis.CurrentEnv.DemonType) then
-- 			GameTooltip:AddLine(self.TooltipData.Main.CurrentDemon..Necrosis.CurrentEnv.DemonType)
-- 		elseif Necrosis.CurrentEnv.DemonEnslaved then
-- 			GameTooltip:AddLine(self.TooltipData.Main.EnslavedDemon)
-- 		else
-- 			GameTooltip:AddLine(self.TooltipData.Main.NoCurrentDemon)
-- 		end

-- 	-- ..... for stone buttons ||..... pour les boutons de pierre
-- 	elseif Type:find("stone") then

-- 		-- Soul Stone ||Pierre d'âme
-- 		if (Type == "Soulstone") then
-- 			-- We display the name of the stone and the action that will produce the click on the button ||On affiche le nom de la pierre et l'action que produira le clic sur le bouton
-- 			-- And also the cooldown ||Et aussi le Temps de recharge
-- 			GameTooltip:AddLine(self.Spell[51].Mana.." Mana")
-- 			if BagHelper.Soulstone_IsAvailable then
-- 				local isOnCooldown, formattedCooldown = ItemHelper:GetSoulstoneCooldown()
-- 				if isOnCooldown then
-- 					GameTooltip:AddLine(Necrosis.TooltipData.OnCooldown..formattedCooldown)
-- 				else
-- 					GameTooltip:AddLine(Necrosis.TooltipData.Use)
-- 				end
-- =======
-- Function to check the presence of a buff on the unit.
-- Strictly identical to UnitHasEffect, but as WoW distinguishes Buff and DeBuff, so we have to.
local function UnitHasBuff(unit, effect)
	--		print(("%d=%s, %s, %.2f minutes left."):format(i,name,icon,(etime-GetTime())/60))
	local res = false
	for i=1,40 do
		local name, icon, count, debuffType, duration, 
		expirationTime, source, isStealable, nameplateShowPersonal, spellId, 
		canApplyAura, isBossDebuff, castByPlayer, nameplateShowAll, timeMod 
		= UnitBuff(unit,i)
		if name then
			if name == effect then
				res = true
				break
-- >>>>>>> 686e04f19f3de2b28961fbe67dd2ea6b10066740
			else
				-- continue
			end
		else
			break -- no more
		end
	end
	
	return res
end

-- Function to check the presence of a debuff on the unit || Fonction pour savoir si une unité subit un effet
-- F(string, string)->bool
local function UnitHasEffect(unit, effect)
	local res = false
	for i=1,40 do
		local name, icon, count, debuffType, duration, 
			expirationTime, source, isStealable, nameplateShowPersonal, spellId, 
			canApplyAura, isBossDebuff, castByPlayer, nameplateShowAll, timeMod 
			= UnitDebuff(unit,i)
		if name then
			if name == effect then
				res = true
				break
			else
				-- continue
			end
		else
			break -- no more
		end
	end
	
	return res
end

-- Display the antifear button / warning || Affiche ou cache le bouton de détection de la peur suivant la cible.
local function ShowAntiFearWarning()
	local Actif = false -- Must be False, or a number from 1 to Local.Warning.Antifear.Icon[] max element.

	-- Checking if we have a target. Any fear need a target to be casted on
	if UnitExists("target") and UnitCanAttack("player", "target") and not UnitIsDead("target") then
		-- Checking if the target has natural immunity (only NPC target)
		if not UnitIsPlayer("target") and ( UnitCreatureType("target") == Necrosis.Unit.Undead or UnitCreatureType("target") == "Mechanical" ) then
			Actif = 2 -- Immun
		end
		-- We'll start to parse the target buffs, as his class doesn't give him natural permanent immunity
		if not Actif then
			for index=1, #Necrosis.AntiFear.Buff, 1 do
				if UnitHasBuff("target",Necrosis.AntiFear.Buff[index]) then
					Actif = 3 -- Prot
					break
				end
			end

			-- No buff found, let's try the debuffs
			for index=1, #Necrosis.AntiFear.Debuff, 1 do
				if UnitHasEffect("target",Necrosis.AntiFear.Debuff[index]) then
					Actif = 3 -- Prot
					break
				end
			end
		end

		-- An immunity has been detected before, but we still don't know why => show the button anyway
		if Local.Warning.Antifear.Immune and not Actif then
			Actif = 1
		end
	end

	if Actif then
		-- Antifear button is currently not visible, we have to change that
		if not Local.Warning.Antifear.Actif then
			Local.Warning.Antifear.Actif = true
			Necrosis.Chat:_Msg(Necrosis.ChatMessage.Information.FearProtect, "USER")
			NecrosisAntiFearButton:SetNormalTexture(GraphicsHelper:GetTexture("AntiFear")..Local.Warning.Antifear.Icon[Actif].."-02")
			if NecrosisConfig.Sound then PlaySoundFile(Necrosis.Sound.Fear) end
--			ShowUIPanel(NecrosisAntiFearButton)
			NecrosisAntiFearButton:Show()
			Local.Warning.Antifear.Blink = GetTime() + 0.6
			Local.Warning.Antifear.Toggle = 2

		-- Timer to make the button blink
		elseif GetTime() >= Local.Warning.Antifear.Blink then
			if Local.Warning.Antifear.Toggle == 1 then
				Local.Warning.Antifear.Toggle = 2
			else
				Local.Warning.Antifear.Toggle = 1
			end
			Local.Warning.Antifear.Blink = GetTime() + 0.4
			NecrosisAntiFearButton:SetNormalTexture(GraphicsHelper:GetTexture("AntiFear")..Local.Warning.Antifear.Icon[Actif].."-0"..Local.Warning.Antifear.Toggle)
		end

	elseif Local.Warning.Antifear.Actif then	-- No antifear on target, but the button is still visible => gonna hide it
		Local.Warning.Antifear.Actif = false
--		HideUIPanel(NecrosisAntiFearButton)
		NecrosisAntiFearButton:Hide()
	end
end

-- Function updating the buttons Necrosis and giving the state of the button of the soul stone || Fonction mettant à jour les boutons Necrosis et donnant l'état du bouton de la pierre d'âme
local function UpdateIcons()
	
	-- If the function was called to detect an enchantment, it is detected! || Si la fonction a été appelée pour détecter un enchantement, on le détecte !
	if (Local.SomethingOnHand == "Truc") then
		-- self:MoneyToggle()
		NecrosisTooltip:SetInventoryItem("player", 16)
		local itemName = tostring(NecrosisTooltipTextLeft8:GetText())
		if (itemName and BagHelper.Spellstone_Name) then
			if (itemName:find(BagHelper.Spellstone_Name)) then
				Local.SomethingOnHand = BagHelper.Spellstone_Name
			end
		end
		if (itemName and BagHelper.Firestone_Name) then
			if (itemName:find(BagHelper.Firestone_Name)) then
				Local.SomethingOnHand = BagHelper.Firestone_Name
			end
		end
	end

	-- Soul Stone || Pierre d'âme
	-----------------------------------------------

	-- We inquire to know if a stone of soul was used -> verification in the timers || On se renseigne pour savoir si une pierre d'âme a été utilisée --> vérification dans les timers
	-- local SoulstoneInUse = false
	-- if Local.TimerManagement.SpellTimer then
	-- 	for index = 1, #Local.TimerManagement.SpellTimer, 1 do
	-- 		if (Local.TimerManagement.SpellTimer[index].Name == self.Spell[11].Name)  and Local.TimerManagement.SpellTimer[index].TimeMax > 0 then
	-- 			SoulstoneInUse = true
	-- 			break
	-- 		end
	-- 	end
	-- end
	local soulstoneInUse = ItemHelper:IsSoulstoneOnCooldown()

	if BagHelper.Soulstone_IsAvailable then
		if soulstoneInUse then
			Local.Stone.Soul.Mode = 4
		else
			Local.Stone.Soul.Mode = 2
		end
	else
		if soulstoneInUse then
			Local.Stone.Soul.Mode = 3
		else
			-- If the stone was not used, and there is no stone in inventory -> Mode 1 || Si la Pierre n'a pas été utilisée, et qu'il n'y a pas de pierre en inventaire -> Mode 1
			Local.Stone.Soul.Mode = 1
		end
	end

-- 	-- If the stone was not used, and there is no stone in inventory -> Mode 1 || Si la Pierre n'a pas été utilisée, et qu'il n'y a pas de pierre en inventaire -> Mode 1
-- 	-- if not (Local.Stone.Soul.OnHand or SoulstoneInUse) then
-- 	if not (BagHelper.Soulstone_IsAvailable or SoulstoneInUse) then
-- print("Local.Stone.Soul.Mode = 1")
-- 		Local.Stone.Soul.Mode = 1
-- 	end

-- 	-- If the stone was not used, but there is a stone in inventory || Si la Pierre n'a pas été utilisée, mais qu'il y a une pierre en inventaire
-- 	-- if Local.Stone.Soul.OnHand and (not SoulstoneInUse) then
-- 	if BagHelper.Soulstone_IsAvailable and (not SoulstoneInUse) then
-- 		-- If the stone in inventory contains a timer, and we leave a RL -> Mode 4 || Si la pierre en inventaire contient un timer, et qu'on sort d'un RL --> Mode 4
-- 		-- local start, duration = GetContainerItemCooldown(Local.Stone.Soul.Location[1],Local.Stone.Soul.Location[2])
-- 		local start, duration = GetContainerItemCooldown(BagHelper.Soulstone_BagId, BagHelper.Soulstone_SlotId)
-- 		if Local.LoggedIn and start > 0 and duration > 0 then
-- 			Local.TimerManagement = self:InsertTimerStone("Soulstone", start, duration, Local.TimerManagement)
-- 			Local.Stone.Soul.Mode = 4
-- 			Local.LoggedIn = false
-- 		-- If the stone does not contain a timer, or you do not leave an RL -> Mode 2 || Si la pierre ne contient pas de timer, ou qu'on ne sort pas d'un RL --> Mode 2
-- 		else
-- 			Local.Stone.Soul.Mode = 2
-- 			Local.LoggedIn = false
-- 		end
-- 	end

-- 	-- If the stone was used but there is no stone in inventory -> Mode 3 || Si la Pierre a été utilisée mais qu'il n'y a pas de pierre en inventaire --> Mode 3
-- 	-- if (not Local.Stone.Soul.OnHand) and SoulstoneInUse then
-- 	if (not BagHelper.Soulstone_IsAvailable) and SoulstoneInUse then
-- 		Local.Stone.Soul.Mode = 3
-- 	end

-- 	-- If the stone was used and there is a stone in inventory || Si la Pierre a été utilisée et qu'il y a une pierre en inventaire
-- 	-- if Local.Stone.Soul.OnHand and SoulstoneInUse then
-- 	if BagHelper.Soulstone_IsAvailable and SoulstoneInUse then
-- 		Local.Stone.Soul.Mode = 4
-- 	end

	-- If out of combat and we can create a stone, we associate the left button to create a stone. || Si hors combat et qu'on peut créer une pierre, on associe le bouton gauche à créer une pierre.
	if (Necrosis.Spell[51].ID
		and BagHelper.Soulstone_Name
		and (Local.Stone.Soul.Mode == 1 or Local.Stone.Soul.Mode == 3))
	then
		SphereButtonHelper:SoulstoneUpdateAttribute("NoStone")
	end

	-- Display of the mode icon || Affichage de l'icone liée au mode
	local f = _G[Necrosis.Warlock_Buttons.soul_stone.f]
	if f then
		f:SetNormalTexture(GraphicsHelper:GetTexture("SoulstoneButton-0")..Local.Stone.Soul.Mode)
	end
	-- -- Display of the mode icon || Affichage de l'icone liée au mode
	-- if (_G["NecrosisSoulstoneButton"]) then
	-- 	NecrosisSoulstoneButton:SetNormalTexture(GraphicsHelper:GetTexture("SoulstoneButton-0")..Local.Stone.Soul.Mode)
	-- end

	-- Stone of life || Pierre de vie
	-----------------------------------------------

	-- Mode "I have one" (2) / "I have none" (1) || Mode "j'en ai une" (2) / "j'en ai pas" (1)
	if (not BagHelper.Healthstone_IsAvailable) then
		-- If out of combat and we can create a stone, we associate the left button to create a stone. || Si hors combat et qu'on peut créer une pierre, on associe le bouton gauche à créer une pierre.
		if (Necrosis.Spell[52].ID and BagHelper.Healthstone_Name) then
			SphereButtonHelper:HealthstoneUpdateAttribute("NoStone")
		end
	end

	--Display of the mode icon || Affichage de l'icone liée au mode
	local f = _G[Necrosis.Warlock_Buttons.health_stone.f]
	if f then
		if (BagHelper.Healthstone_IsAvailable) then
			f:SetNormalTexture(GraphicsHelper:GetTexture("HealthstoneButton-02"))
		else
			f:SetNormalTexture(GraphicsHelper:GetTexture("HealthstoneButton-01"))
		end
	end
	-- --Display of the mode icon || Affichage de l'icone liée au mode
	-- if (_G["NecrosisHealthstoneButton"]) then
	-- 	if (BagHelper.Healthstone_IsAvailable) then
	-- 		NecrosisHealthstoneButton:SetNormalTexture(GraphicsHelper:GetTexture("HealthstoneButton-02"))
	-- 	else
	-- 		NecrosisHealthstoneButton:SetNormalTexture(GraphicsHelper:GetTexture("HealthstoneButton-01"))
	-- 	end
	-- end

	-- Stone of spell || Pierre de sort
	-----------------------------------------------

	-- Stone in the inventory ... || Pierre dans l'inventaire...
	-- if Local.Stone.Spell.OnHand then
	if (BagHelper.Spellstone_IsAvailable) then
		-- ... and on the weapon = mode 3, otherwise = mode 2 || ... et sur l'arme = mode 3, sinon = mode 2
		if (Local.SomethingOnHand == BagHelper.Spellstone_Name) then
			Local.Stone.Spell.Mode = 3
		else
			Local.Stone.Spell.Mode = 2
		end
	-- Stone nonexistent ... || Pierre inexistante...
	else
		-- ... but on the weapon = mode 4, otherwise = mode 1 || ... mais sur l'arme = mode 4, sinon = mode 1
		if (Local.SomethingOnHand == BagHelper.Spellstone_Name) then
			Local.Stone.Spell.Mode = 4
		else
			Local.Stone.Spell.Mode = 1
		end
		-- If out of combat and we can create a stone, we associate the left button to create a stone. || Si hors combat et qu'on peut créer une pierre, on associe le bouton gauche à créer une pierre.
		if (Necrosis.Spell[53].ID and BagHelper.Spellstone_Name) then
			SphereButtonHelper:SpellstoneUpdateAttribute("NoStone")
		end
	end

	-- Display of the mode icon || Affichage de l'icone liée au mode
	local f = _G[Necrosis.Warlock_Buttons.spell_stone.f]
	if f then
		f:SetNormalTexture(GraphicsHelper:GetTexture("SpellstoneButton-0"..Local.Stone.Spell.Mode))
	end
	-- -- Display of the mode icon || Affichage de l'icone liée au mode
	-- if _G["NecrosisSpellstoneButton"] then
	-- 	NecrosisSpellstoneButton:SetNormalTexture(GraphicsHelper:GetTexture("SpellstoneButton-0"..Local.Stone.Spell.Mode))
	-- end

	-- Fire stone || Pierre de feu
	-----------------------------------------------

	-- Stone in the inventory ... || Pierre dans l'inventaire...
	-- if Local.Stone.Fire.OnHand then
	if (BagHelper.Firestone_IsAvailable) then
		-- ... and on the weapon = mode 3, otherwise = mode 2 || ... et sur l'arme = mode 3, sinon = mode 2
		if (Local.SomethingOnHand == BagHelper.Firestone_Name) then
			Local.Stone.Fire.Mode = 3
		else
			Local.Stone.Fire.Mode = 2
		end
	-- Stone nonexistent ... || Pierre inexistante...
	else
		-- ... but on the weapon = mode 4, otherwise = mode 1 || ... mais sur l'arme = mode 4, sinon = mode 1
		if (Local.SomethingOnHand == BagHelper.Firestone_Name) then
			Local.Stone.Fire.Mode = 4
		else
			Local.Stone.Fire.Mode = 1
		end
		-- If out of combat and we can create a stone, we associate the left button to create a stone. || Si hors combat et qu'on peut créer une pierre, on associe le bouton gauche à créer une pierre.
		if (Necrosis.Spell[54].ID and BagHelper.Firestone_Name) then
			SphereButtonHelper:FirestoneUpdateAttribute("NoStone")
		end
	end

	-- Display of the mode icon || Affichage de l'icone liée au mode
	local f = _G[Necrosis.Warlock_Buttons.fire_stone.f]
	if f then
		f:SetNormalTexture(GraphicsHelper:GetTexture("FirestoneButton-0"..Local.Stone.Fire.Mode))
	end
	-- -- Display of the mode icon || Affichage de l'icone liée au mode
	-- if _G["NecrosisFirestoneButton"] then
	-- 	NecrosisFirestoneButton:SetNormalTexture(GraphicsHelper:GetTexture("FirestoneButton-0"..Local.Stone.Fire.Mode))
	-- end
	

	-- local hsCooldown = ItemHelper:GetHearthstoneCooldown()
	-- if hsCooldown then
	-- 	NecrosisSpellTimerButton:GetNormalTexture():SetDesaturated(1)
	-- else
	-- 	NecrosisSpellTimerButton:GetNormalTexture():SetDesaturated(nil)
	-- end
end
	

-- Events : CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS, CHAT_MSG_SPELL_AURA_GONE_SELF et CHAT_MSG_SPELL_BREAK_AURA
-- Manage the appearing and disappearing effects on the warlock || Permet de gérer les effets apparaissants et disparaissants sur le démoniste
-- Based on CombatLog || Basé sur le CombatLog
local function SelfEffect(action, nom)
	local felsteedName   = Necrosis.Spell[1].Name
	local dreadsteedName = Necrosis.Spell[2].Name

	if NecrosisConfig.LeftMount then
		local NomCheval1 = GetSpellInfo(NecrosisConfig.LeftMount)
	else
		local NomCheval1 = dreadsteedName
		-- local NomCheval1 = Necrosis.Warlock_Spells[23161].Name
	end
	if NecrosisConfig.RightMount then
		local NomCheval2 = GetSpellInfo(NecrosisConfig.RightMount)
	else
		local NomCheval2 = felsteedName
		-- local NomCheval2 = Necrosis.Warlock_Spells[5784].Name
	end

	local f = _G[Necrosis.Warlock_Buttons.mounts.f]
	if action == "BUFF" then
		local fs = _G[Necrosis.Warlock_Buttons.trance.f]
		local fb = _G[Necrosis.Warlock_Buttons.backlash.f]
		-- Changing the mount button when the Warlock is disassembled || Changement du bouton de monture quand le Démoniste est démonté
		if nom == felsteedName or nom == dreadsteedName or nom == "NomCheval1" or nom == "NomCheval2" then
		-- if nom == Necrosis.Warlock_Spells[5784].Name or  nom == Necrosis.Warlock_Spells[23161].Name or nom == "NomCheval1" or nom == "NomCheval2" then
			Local.BuffActif.Mount = true
			if f then
				f:SetNormalTexture(Necrosis.Warlock_Buttons.mounts.high)
				f:GetNormalTexture():SetDesaturated(nil)
			end
		-- Change Dominated Domination Button if Enabled + Cooldown Timer || Changement du bouton de la domination corrompue si celle-ci est activée + Timer de cooldown
		elseif Necrosis.IsSpellKnown("domination") 
			and (nom == Necrosis.GetSpellName("domination")) 
			then -- 15
			Local.BuffActif.Domination = true
			local f = _G[Necrosis.Warlock_Buttons.domination.f]
			if f then
				f:SetNormalTexture(Necrosis.Warlock_Buttons.domination.high)
				f:GetNormalTexture():SetDesaturated(nil)
			end
		-- Change the spiritual link button if it is enabled || Changement du bouton du lien spirituel si celui-ci est activé
		elseif Necrosis.IsSpellKnown("link") 
			and (nom == Necrosis.GetSpellName("link")) 
			then -- 38
			Local.BuffActif.SoulLink = true
			local f = _G[Necrosis.Warlock_Buttons.link.f]
			if f then
				f:SetNormalTexture(Necrosis.Warlock_Buttons.link.high)
				f:GetNormalTexture():SetDesaturated(nil)
			end
		-- If Backlash, to display the icon and we proc the sound || si Contrecoup, pouf on affiche l'icone et on proc le son
		-- If By-effect, one-on-one icon and one proc the sound || if By-effect, pouf one posts the icon and one proc the sound
		elseif nom == Necrosis.Translation.Proc.Backlash and NecrosisConfig.ShadowTranceAlert then
			Necrosis.Chat:_Msg(Necrosis.ProcText.Backlash, "USER")
			if NecrosisConfig.Sound then PlaySoundFile(Necrosis.Sound.Backlash) end
			fb:Show()
		-- If Twilight, to display the icon and sound || si Crépuscule, pouf on affiche l'icone et on proc le son
		-- If Twilight / Nightfall, puff one posts the icon and one proc the sound || if Twilight/Nightfall, pouf one posts the icon and one proc the sound
		elseif nom == Necrosis.Translation.Proc.ShadowTrance and NecrosisConfig.ShadowTranceAlert then
			Necrosis.Chat:_Msg(Necrosis.ProcText.ShadowTrance, "USER")
			if NecrosisConfig.Sound then PlaySoundFile(Necrosis.Sound.ShadowTrance) end
			fs:Show()
		end
	else
		-- Changing the mount button when the Warlock is disassembled || Changement du bouton de monture quand le Démoniste est démonté
		if nom == felsteedName or nom == dreadsteedName or nom == "NomCheval1" or nom == "NomCheval2" then
		-- if nom == Necrosis.Warlock_Spells[5784].Name or  nom == Necrosis.Warlock_Spells[23161].Name or nom == "NomCheval1" or nom == "NomCheval2" then
			Local.BuffActif.Mount = false
			if f then
				f:SetNormalTexture(Necrosis.Warlock_Buttons.mounts.norm)
			end
		-- Domination button change when Warlock is no longer under control || Changement du bouton de Domination quand le Démoniste n'est plus sous son emprise
		elseif Necrosis.IsSpellKnown("domination") -- known
			and (nom == Necrosis.GetSpellName("domination")) 
			then -- 15
			Local.BuffActif.Domination = false
			local f = _G[Necrosis.Warlock_Buttons.domination.f]
			if f then
				f:SetNormalTexture(Necrosis.Warlock_Buttons.mounts.norm)
			end
		-- Changing the Spiritual Link button when the Warlock is no longer under control || Changement du bouton du Lien Spirituel quand le Démoniste n'est plus sous son emprise
		elseif Necrosis.IsSpellKnown("link") -- known
			and (nom == Necrosis.GetSpellName("link")) 
			then -- 38
			Local.BuffActif.SoulLink = false
			local f = _G[Necrosis.Warlock_Buttons.link.f]
			if f then
				f:SetNormalTexture(Necrosis.Warlock_Buttons.link.norm)
			end
		-- Hide the shadowtrance (nightfall) or backlash buttons when the state is ended
		elseif nom == Necrosis.Translation.Proc.ShadowTrance or nom == Necrosis.Translation.Proc.Backlash then
			local fs = _G[Necrosis.Warlock_Buttons.trance.f]
			local fb = _G[Necrosis.Warlock_Buttons.backlash.f]
			fs:Hide()
			fb:Hide()
		end
	end
	Necrosis:UpdateMana()
	return
end

-- local function SatList(list, val)
-- 	for i, v in pairs(list) do
-- 		local menuVariable = _G[Necrosis.Warlock_Buttons[v.f_ptr].f]
-- 		if menuVariable then
-- 			menuVariable:GetNormalTexture():SetDesaturated(val)
-- 		end
-- 	end
-- end

-- Event : UNIT_PET
-- Allows the servo to be timed, as well as to prevent for servo breaks || Permet de timer les asservissements, ainsi que de prévenir pour les ruptures d'asservissement
-- Also change the name of the pet to the replacement of it || Change également le nom du pet au remplacement de celui-ci
local function ChangeDemon()
	-- If the new demon is a slave demon, we put a 5 minute timer || Si le nouveau démon est un démon asservi, on place un timer de 5 minutes
	if (UnitHasEffect("pet", Necrosis.Spell[10].Name)) then
		if (not Necrosis.CurrentEnv.DemonEnslaved) then
			Necrosis.CurrentEnv.DemonEnslaved = true
		end
	else
		-- When the enslaved demon is lost, remove the timer and warn the warlock || Quand le démon asservi est perdu, on retire le Timer et on prévient le Démoniste
		if (Necrosis.CurrentEnv.DemonEnslaved) then
			Necrosis.CurrentEnv.DemonEnslaved = false
			
			if NecrosisConfig.Sound then PlaySoundFile(Necrosis.Sound.EnslaveEnd) end
			Necrosis.Chat:_Msg(Necrosis.ChatMessage.Information.EnslaveBreak, "USER")
		end
	end

	-- If the demon is not enslaved we define its title, and we update its name in Necrosis || Si le démon n'est pas asservi on définit son titre, et on met à jour son nom dans Necrosis
	Necrosis.CurrentEnv.LastDemonType = Necrosis.CurrentEnv.DemonType
	Necrosis.CurrentEnv.DemonType = UnitCreatureFamily("pet")

	if Necrosis.CurrentEnv.DemonType then
		NecrosisConfig.PetName[Necrosis.CurrentEnv.DemonType] = UnitName("pet")
	end

	for i = 1, #Necrosis.Translation.DemonName, 1 do
		if Necrosis.CurrentEnv.DemonType == Necrosis.Translation.DemonName[i] and not (NecrosisConfig.PetName[i] or (UnitName("pet") == UNKNOWNOBJECT)) then
			NecrosisConfig.PetName[i] = UnitName("pet")
			--self:Localization()
			break
		end
	end
	Necrosis:UpdateMana()

	return
end


------------------------------------------------------------------------------------------------------
-- NECROSIS FUNCTIONS || FONCTIONS NECROSIS
------------------------------------------------------------------------------------------------------
-- Function started when updating the interface (main) - every 0.1 seconds || Fonction lancée à la mise à jour de l'interface (main) -- Toutes les 0,1 secondes environ
function Necrosis:OnUpdate(elapsed)--something,

	if (elapsed) then
		Local.LastUpdate[1] = Local.LastUpdate[1] + elapsed
		Local.LastUpdate[2] = Local.LastUpdate[2] + elapsed
	end

	-- -- If smooth scroll timers, we update them as soon as possible || Si défilement lisse des timers, on les met à jours le plus vite possible
	-- NecrosisUpdateTimer(Local.TimerManagement.SpellTimer)

	-- -- If timers texts, we update them very quickly also || Si timers textes, on les met à jour très vite également
	-- if NecrosisConfig.TimerType == "Textual" then
	-- 	self:TextTimerUpdate(Local.TimerManagement.SpellTimer, Local.TimerManagement.SpellGroup)
	-- end

	-- Every second || Toutes les secondes
	if (Local.LastUpdate[1] > 1) then
	-- If configured, sorting fragments every second || Si configuré, tri des fragment toutes les secondes
		if (NecrosisConfig.SoulshardSort and Local.Soulshard.Move > 0) then
			Necrosis:SoulshardSwitch("MOVE")
		end

		-- Timers Table Course || Parcours du tableau des Timers
		if Local.TimerManagement.SpellTimer[1] then
			for index = 1, #Local.TimerManagement.SpellTimer, 1 do
				if Local.TimerManagement.SpellTimer[index] then
					-- We remove the completed timers || On enlève les timers terminés
					local TimeLocal = GetTime()
					if TimeLocal >= (Local.TimerManagement.SpellTimer[index].TimeMax - 0.5) then
						local StoneFade = false
						-- If the timer was that of Soul Stone, warn the Warlock || Si le timer était celui de la Pierre d'âme, on prévient le Démoniste
						if Local.TimerManagement.SpellTimer[index].Name == self.Spell[51].Name then
							self.Chat:_Msg(self.ChatMessage.Information.SoulstoneEnd)
							if NecrosisConfig.Sound then PlaySoundFile(self.Sound.SoulstoneEnd) end
							StoneFade = true
						elseif Local.TimerManagement.SpellTimer[index].Name == self.Spell[9].Name then
							Local.TimerManagement.Banish = false
						end
						-- Otherwise we remove the timer silently (but not in case of enslave) || Sinon on enlève le timer silencieusement (mais pas en cas d'enslave)
						if not (Local.TimerManagement.SpellTimer[index].Name == self.Spell[10].Name) then
							-- Local.TimerManagement = self:RetraitTimerParIndex(index, Local.TimerManagement)
							index = 0
							if StoneFade then
								-- We update the appearance of the button of the soul stone || On met à jour l'apparence du bouton de la pierre d'âme
								UpdateIcons()
							end
							break
						end
					end
				end
			end
		end
		Local.LastUpdate[1] = 0
	-- Every half second || Toutes les demies secondes
	elseif Local.LastUpdate[2] > 0.5 then
		-- If configured, display warnings from Antifear || Si configuré, affichage des avertissements d'Antifear
		if NecrosisConfig.AntiFearAlert then
			Necrosis:ShowAntiFearWarning()
		end
		-- If configured, the Sphere is transfected into a Ground Chrono || Si configuré, on transfome la Sphere en Chrono de Rez
		if (NecrosisConfig.CountType == "RezTimer" or NecrosisConfig.Circle == "RezTimer")
			and (Local.Stone.Soul.Mode == 3 or Local.Stone.Soul.Mode == 4)
		then
			-- Local.LastSphereSkin = self:RezTimerUpdate(Local.TimerManagement.SpellTimer, Local.LastSphereSkin)
		end
		Local.LastUpdate[2] = 0
	end
end


local function AddSpellTimer(spellData)
	if (NecrosisConfig.EnableTimerBars) then
		-- local spellData = Necrosis.CurrentEnv.SpellCast[spellId]
-- print("AddSpellTimer:"
-- .."\n "..tostring(spellData.SpellId)
-- .."\n "..tostring(spellData.SpellType)
-- .."\n "..tostring(spellData.Duration)
-- .."\n "..tostring(spellData.Name)
-- .."\n "..tostring(spellData.TargetGuid)
-- .."\n "..tostring(spellData.TargetName)
-- )
		if (spellData and spellData.SpellType) then
			if (not spellData.TargetGuid
				or not spellData.TargetName
				or spellData.SpellType == "self"
				or spellData.TargetIsDead
				or (spellData.SpellType == "single" and not spellData.TargetIsFriend))
			then
				-- If target is empty the spell (likely soustone etc.) hits ourself
				spellData.TargetGuid = Necrosis.CurrentEnv.PlayerGuid
				spellData.TargetName = Necrosis.CurrentEnv.PlayerName
			end
			-- Capture the icon of the spell target
			local destIconNumber = GetRaidTargetIndex("target")
			-- Try to update an existing timer first
			local updated = Necrosis.Timers:UpdateTimer(
				Necrosis.CurrentEnv.PlayerGuid,
				spellData.TargetGuid,
				spellData.SpellId,
				spellData.Duration
			)
			-- If none was present, add a new timer
			if (not updated) then
				Necrosis.Timers:InsertSpellTimer(
					Necrosis.CurrentEnv.PlayerGuid,
					Necrosis.CurrentEnv.PlayerName,
					spellData.TargetGuid, spellData.TargetName, 0, destIconNumber,
					spellData.SpellId,
					spellData.Name,
					spellData.Duration,
					spellData.SpellType
				)
			end
		end
	end
end

local function AddDeBuffTimer(spellId, auraType, spellData)
	-- The DS effects are not casted, only applied.
	-- Add the corresponding buff as spell timer.
	if ((Necrosis.CurrentEnv.SpellCast["CastGuid"] -- We casted something
		 and tContains(Necrosis.Spell.DemonicSacrifices.SpellIds, spellId)) -- We casted DS
		or auraType == "DEBUFF")
	then
		AddSpellTimer(spellData)
	end
end

-- Function started according to the intercepted event || Fonction lancée selon l'événement intercepté
function Necrosis.OnEvent(self, event, ...)
	local arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8,arg9 = ...

	if (event == "PLAYER_ENTERING_WORLD") then
		EventHelper:AttachApiEvents()
		Local.InWorld = true
	elseif (event == "PLAYER_LEAVING_WORLD") then
		EventHelper:ReleaseApiEvents()
		Local.InWorld = false
	end

	-- Is the game well loaded? || Le jeu est-il bien chargé ?
	if (not Local.InWorld) then
		return
	end

	-- Some bag slot changed
	if (event == "BAG_UPDATE") then
		Necrosis:BagExplore(arg1)
		if (NecrosisConfig.SoulshardSort) then
			Necrosis:SoulshardSwitch("CHECK")
		end

	-- If the player wins or loses mana || Si le joueur gagne ou perd de la mana
	elseif (event == "UNIT_MANA" and arg1 == "player") then
		Necrosis:UpdateMana()

	-- If the player wins or loses his life || Si le joueur gagneou perd de la vie
	elseif (event == "UNIT_HEALTH" and arg1 == "player") then
		Necrosis:UpdateHealth()

	-- If the player dies || Si le joueur meurt
	elseif (event == "PLAYER_DEAD") then
		-- It may hide the Twilight or Backlit buttons. || On cache éventuellement les boutons de Crépuscule ou Contrecoup.
		Local.Dead = true
		NecrosisShadowTranceButton:Hide()
		NecrosisBacklashButton:Hide()
		-- We gray all the spell buttons || On grise tous les boutons de sort
		if _G["NecrosisMountButton"] then
			NecrosisMountButton:GetNormalTexture():SetDesaturated(1)
		end
		for i = 1, 15, 1 do
			if _G["NecrosisBuffMenu"..i] then
				_G["NecrosisBuffMenu"..i]:GetNormalTexture():SetDesaturated(1)
			end
			if _G["NecrosisPetMenu"..i] then
				_G["NecrosisPetMenu"..i]:GetNormalTexture():SetDesaturated(1)
			end
			if _G["NecrosisCurseMenu"..i] then
				_G["NecrosisCurseMenu"..i]:GetNormalTexture():SetDesaturated(1)
			end
		end

	-- If the player resurrects || Si le joueur ressucite
	elseif (event == "PLAYER_ALIVE" or event == "PLAYER_UNGHOST") then
		-- We are sobering all the spell buttons || On dégrise tous les boutons de sort
		if _G["NecrosisMountButton"] then
			NecrosisMountButton:GetNormalTexture():SetDesaturated(nil)
		end
		for i = 1, 15, 1 do
			if _G["NecrosisBuffMenu"..i] then
				_G["NecrosisBuffMenu"..i]:GetNormalTexture():SetDesaturated(nil)
			end
			if _G["NecrosisPetMenu"..i] then
				_G["NecrosisPetMenu"..i]:GetNormalTexture():SetDesaturated(nil)
			end
			if _G["NecrosisCurseMenu"..i] then
				_G["NecrosisCurseMenu"..i]:GetNormalTexture():SetDesaturated(nil)
			end
		end
		-- We reset the gray button list || On réinitialise la liste des boutons grisés
		Local.Desatured = {}
		Local.Dead = false

	-- When the warlock begins to cast a spell, we intercept the spell's name || Quand le démoniste commence à incanter un sort, on intercepte le nom de celui-ci
	-- We also save the name of the target of the spell as well as its level || On sauve également le nom de la cible du sort ainsi que son niveau
	elseif (event == "UNIT_SPELLCAST_SENT" and arg1 == "player")
	then
		-- arg1 = unit
		-- arg2 = targetName
		-- arg3 = castGUID
		-- arg4 = spellID

		-- print('spellcast send : arg 1 =   ' .. tostring(arg1) )
		-- print('spellcast send : arg 2 =   ' .. tostring(arg2) )
		-- print('spellcast send : arg 3 =   ' .. tostring(arg3) )
		-- print('spellcast send : arg 4 =   ' .. tostring(arg4) )
		-- print('spellcast send : arg 5 =   ' .. tostring(arg5) )
		-- print('spellcast send : arg 6 =   ' .. tostring(arg6) )

		local spellData = {
			CastGuid = arg3,
			SpellId = arg4,
			Name = GetSpellInfo(arg4),
			Duration = Necrosis.Spell.AuraDuration[arg4],
			SpellType = Necrosis.Spell.AuraType[arg4],
			TargetName = UnitName("target"),
			TargetGuid = UnitGUID("target"),
			TargetIsDead = UnitIsDead("target"),
			TargetIsFriend = UnitIsFriend("player", "target")
		}
		Necrosis.CurrentEnv.SpellCast["CastGuid"] = arg3
		-- Check if timers are enabled
		if (NecrosisConfig.EnableTimerBars) then
			if (spellData.Duration ~= nil) then
				Necrosis.CurrentEnv.SpellCast[arg3] = spellData
			end
		end
		Necrosis.Chat:BeforeSpellCast(spellData)

	-- Successful spell casting management || Gestion de l'incantation des sorts réussie
	elseif (event == "UNIT_SPELLCAST_SUCCEEDED" and arg1 == "player")
	then
		-- arg2: castGUID
		-- arg3: spellID

		-- The event SPELL_AURA_REFRESH is not raised when we have no target,
		-- f.e. when casting Unending Breath on ourselves.
		-- So try to add a timer here as well.
		if (Necrosis.CurrentEnv.SpellCast[arg2]) then
			if (Necrosis.CurrentEnv.SpellCast[arg2].SpellType ~= "debuff") then
				-- print("Debuff success: "..tostring(arg3))
			-- else --if (Necrosis.CurrentEnv.SpellCast[arg3].CastGuid)
				-- print("Spell success: "..tostring(arg3))
				-- AddSpellTimer(arg3)
-- print("Success: "..tostring(arg3)..", "..tostring(Necrosis.CurrentEnv.SpellCast[arg2]))
				AddSpellTimer(Necrosis.CurrentEnv.SpellCast[arg2])
				Necrosis.CurrentEnv.SpellCast[arg2] = nil
			end
		end
		Necrosis.CurrentEnv.SpellCast["CastGuid"] = nil
		Necrosis.Chat:AfterSpellCast()

	-- When the warlock stops his incantation, we release the name of it || Quand le démoniste stoppe son incantation, on relache le nom de celui-ci
	elseif ((event == "UNIT_SPELLCAST_FAILED" or event == "UNIT_SPELLCAST_INTERRUPTED") and arg1 == "player")
	then
		-- arg1: unit (player etc)
		-- arg2: castGUID
		-- arg3: spellID
		Necrosis.CurrentEnv.SpellCast[arg2] = nil
		Necrosis.CurrentEnv.SpellCast["CastGuid"] = nil
		Necrosis.Chat:ClearMessages()

	-- Flag if a Trade window is open, so you can automatically trade the healing stones || Flag si une fenetre de Trade est ouverte, afin de pouvoir trader automatiquement les pierres de soin
	elseif event == "TRADE_REQUEST" or event == "TRADE_SHOW" then
		Local.Trade.Request = true

	elseif event == "TRADE_REQUEST_CANCEL" or event == "TRADE_CLOSED" then
		Local.Trade.Request = false

	elseif event=="TRADE_ACCEPT_UPDATE" then
		if Local.Trade.Request and Local.Trade.Complete then
			AcceptTrade()
			Local.Trade.Request = false
			Local.Trade.Complete = false
		end

		-- AntiFear button hide on target change || AntiFear button hide on target change
	elseif event == "PLAYER_TARGET_CHANGED" then
		if NecrosisConfig.AntiFearAlert and Local.Warning.Antifear.Immune then
			Local.Warning.Antifear.Immune = false
		end

		if NecrosisConfig.BanishAlert
			and UnitCanAttack("player", "target")
			and not UnitIsDead("target") then
				Local.Warning.Banishable = true
				if UnitCreatureType("target") == Necrosis.Unit.Demon then
					NecrosisCreatureAlertButton:Show()
					NecrosisCreatureAlertButton:SetNormalTexture(GraphicsHelper:GetTexture("DemonAlert"))
				elseif UnitCreatureType("target") == Necrosis.Unit.Elemental then
					NecrosisCreatureAlertButton:Show()
					NecrosisCreatureAlertButton:SetNormalTexture(GraphicsHelper:GetTexture("ElemAlert"))
				end
		elseif Local.Warning.Banishable then
			Local.Warning.Banishable = false
			NecrosisCreatureAlertButton:Hide()
		end

	-- If the Warlock learns a new spell / spell, we get the new spells list || Si le Démoniste apprend un nouveau sort / rang de sort, on récupère la nouvelle liste des sorts
	-- If the Warlock learns a new buff or summon spell, the buttons are recreated || Si le Démoniste apprend un nouveau sort de buff ou d'invocation, on recrée les boutons
	elseif (event == "LEARNED_SPELL_IN_TAB" or event == "SPELLS_CHANGED") then
		Necrosis:SpellSetup()
		if (Necrosis.Spells.SpellsChanged) then
			Necrosis:CreateMenu()
			Necrosis:ButtonSetup()
		end

	-- At the end of the fight, we stop reporting Twilight || A la fin du combat, on arrête de signaler le Crépuscule
	-- We remove the spell timers and the names of mobs || On enlève les timers de sorts ainsi que les noms des mobs
	elseif (event == "PLAYER_REGEN_ENABLED") then
		-- EventHelper.OnCombatStop()
		-- Local.PlayerInCombat = false
		-- We are redefining the attributes of spell buttons in a situational way || On redéfinit les attributs des boutons de sorts de manière situationnelle
		Necrosis:NoCombatAttribute(Local.Menu.Pet, Local.Menu.Buff, Local.Menu.Curse)
		UpdateIcons()

	-- When the warlock changes demon || Quand le démoniste change de démon
	elseif (event == "UNIT_PET" and arg1 == "player") then
		ChangeDemon()

	-- Reading the combat log || Lecture du journal de combat
	elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then

		Necrosis:OnCombatLogEvent(event, CombatLogGetCurrentEventInfo())

	-- If we change weapons, we look at whether a spell / fire enchantment is on the new || Si on change d'arme, on regarde si un enchantement de sort / feu est sur la nouvelle
	elseif event == "SKILL_LINES_CHANGED" then
		local hasMainHandEnchant = GetWeaponEnchantInfo()
		if hasMainHandEnchant then
			Local.SomethingOnHand = "Truc"
		else
			Local.SomethingOnHand = "Rien"
		end
		UpdateIcons()

	-- If we come back into combat || Si on rentre en combat
	elseif event == "PLAYER_REGEN_DISABLED" then
		
		EventHelper.OnCombatStart()

		Local.PlayerInCombat = true
		-- Close the options menu || On ferme le menu des options
		if _G["NecrosisGeneralFrame"] and NecrosisGeneralFrame:IsVisible() then
			NecrosisGeneralFrame:Hide()
		end
		-- Spell button attributes are negated situational || On annule les attributs des boutons de sorts de manière situationnelle
		Necrosis:InCombatAttribute(Local.Menu.Pet, Local.Menu.Buff, Local.Menu.Curse)

	-- elseif (event == "RAID_TARGET_UPDATE") then
	-- 	print("RAID_TARGET_UPDATE: "..tostring(arg1)..", "..tostring(GetRaidTargetIndex("target")))
	-- 	local icon = GetRaidTargetIndex("unit")

	-- 	elseif (event == "UNIT_FLAGS") then
	-- print("UNIT_FLAGS: "..tostring(arg1)..", "..tostring(arg2)..", "..tostring(arg3))

	-- Keep track of party/raid status
	elseif (event == "GROUP_ROSTER_UPDATE") then
		CheckGroupStatus()

	-- Used for receiving raid and party messages from other warlocks that use this addon
	elseif (event == "CHAT_MSG_ADDON") then
		-- "prefix", "text", "channel", "sender", "target", zoneChannelID, localID, "name", instanceID
		if (arg1 == Necrosis.CurrentEnv.ChatPrefix) then
			-- print("CHAT_MSG_ADDON: "
			-- 	.."\nprefix: "..tostring(arg1)
			-- 	.."\n, text: "..tostring(arg2)
			-- 	.."\n, channel: "..tostring(arg3)
			-- 	.."\n, sender: "..tostring(arg4)
			-- 	.."\n, target: "..tostring(arg5)
			-- 	.."\n, zoneChannelID: "..tostring(arg6)
			-- 	.."\n, localID: "..tostring(arg7)
			-- 	.."\n, name: "..tostring(arg8)
			-- 	.."\n, instanceID: "..tostring(arg9)
			-- )
			-- Don't talk to ourself
			if (arg4 ~= Necrosis.CurrentEnv.PlayerFullName) then
				EventHelper:ProcessAddonMessage(arg2)
			end
		end
	end
end

function Necrosis:OnCombatLogEvent(event, ...)
	local timestamp, subevent, hideCaster,
		  sourceGUID, sourceName, sourceFlags, sourceRaidFlags,
		  destGUID, destName, destFlags, destRaidFlags,
		  -- Spell event specific values
		  spellId, spellName, spellSchool, auraType, amount, zzz =  ...

	-- Update raid icon in timers
	if (NecrosisConfig.EnableTimerBars) then
		local destIcon = GraphicsHelper:GetRaidIconNumber(destRaidFlags)
		Necrosis.Timers:UpdateRaidIcon(destGUID, destIcon)
	end

	-- Detection of Shadow Trance and Contrecoup || Détection de la transe de l'ombre et de  Contrecoup
	if (subevent == "UNIT_DIED"
		or subevent == "UNIT_DESTROYED"
		or subevent == "UNIT_DISSIPATES")
	then
		if (NecrosisConfig.EnableTimerBars) then
			Necrosis.Timers:RemoveSpellTimerTarget(destGUID)
		end
	
	elseif (subevent == "SPELL_AURA_APPLIED")
	then
		if (destGUID == Necrosis.CurrentEnv.PlayerGuid) then
			SelfEffect("BUFF", spellName)
		end

		if (sourceGUID == Necrosis.CurrentEnv.PlayerGuid) then
			AddDeBuffTimer(spellId, auraType, {
				SpellId = spellId,
				Name = spellName,
				Duration = Necrosis.Spell.AuraDuration[spellId],
				SpellType = Necrosis.Spell.AuraType[spellId],
				TargetName = destName,
				TargetGuid = destGUID,
				TargetIsDead = false,
				TargetIsFriend = true
			})
		end

	elseif (subevent == "SPELL_AURA_REFRESH"
		and sourceGUID == Necrosis.CurrentEnv.PlayerGuid)
	then
		AddDeBuffTimer(spellId, auraType, {
			SpellId = spellId,
			Name = spellName,
			Duration = Necrosis.Spell.AuraDuration[spellId],
			SpellType = Necrosis.Spell.AuraType[spellId],
			TargetName = destName,
			TargetGuid = destGUID,
			TargetIsDead = false,
			TargetIsFriend = true
		})

	-- Detection of the end of Shadow Trance and Contrecoup || Détection de la fin de la transe de l'ombre et de Contrecoup
	elseif (subevent == "SPELL_AURA_REMOVED")
	then
		if (destGUID == Necrosis.CurrentEnv.PlayerGuid) then
			SelfEffect("DEBUFF", spellName)
		end

		if (NecrosisConfig.EnableTimerBars) then
			if (sourceGUID == Necrosis.CurrentEnv.PlayerGuid) then
				Necrosis.Timers:RemoveSpellTimerTargetName(Necrosis.CurrentEnv.PlayerGuid, destGUID, spellName)
			end
		end

		if (destGUID == UnitGUID("focus")
			and Local.TimerManagement.Banish
			and spellName == Necrosis.Spell[9].Name)
		then
			Necrosis.Chat:_Msg("BAN ! BAN ! BAN !")
			-- Necrosis:RetraitTimerParNom(Necrosis.Spell[9], Local.TimerManagement)
			Local.TimerManagement.Banish = false
		end	

	-- Debian Detection || Détection du Déban
	-- elseif (subevent == "SPELL_AURA_REMOVED" and destGUID == UnitGUID("focus") and Local.TimerManagement.Banish and spellName == Necrosis.Spell[9].Name)
	-- then
	-- 	Necrosis.Chat:_Msg("BAN ! BAN ! BAN !")
	-- 	Necrosis:RetraitTimerParNom(Necrosis.Spell[9], Local.TimerManagement)
	-- 	Local.TimerManagement.Banish = false

	-- Resist / immune detection || Détection des résists / immunes
	elseif (subevent == "SPELL_MISSED"
			and sourceGUID == Necrosis.CurrentEnv.PlayerGuid
			and destGUID == UnitGUID("target"))
	then
		local castGuid = Necrosis.CurrentEnv.SpellCast["CastGuid"]
print("Necrosis - Spell resisted: "..tostring(spellName))

		-- Necrosis.CurrentEnv.SpellCast[spellId] = nil
		if (castGuid) then
			Necrosis.CurrentEnv.SpellCast[castGuid] = nil
		end
		Necrosis.CurrentEnv.SpellCast["CastGuid"] = nil
	
		if NecrosisConfig.AntiFearAlert
			and (spellName == Necrosis.Spell[13].Name or spellName == Necrosis.Spell[19].Name)
			and arg12 == "IMMUNE"
		then
			Local.Warning.Antifear.Immune = true
		end
		if spellName == Local.TimerManagement.LastSpell.Name
			and GetTime() <= (Local.TimerManagement.LastSpell.Time + 1.5)
		then
			-- Necrosis:RetraitTimerParIndex(Local.TimerManagement.LastSpell.Index, Local.TimerManagement)
		end

	-- Detection application of a spell / fire stone on a weapon || Détection application d'une pierre de sort/feu sur une arme
	elseif (subevent == "ENCHANT_APPLIED"
		and destGUID == UnitGUID("player")
		and ((BagHelper.Spellstone_Name and arg9 == BagHelper.Spellstone_Name)
			or (BagHelper.Firestone_Name and arg9 == BagHelper.Firestone_Name)))
	then
	-- print("ENCHANT_APPLIED: "..arg9)
			Local.SomethingOnHand = arg9
			UpdateIcons()
	-- End of enchantment detection || Détection fin d'enchant
	elseif (subevent == "ENCHANT_REMOVE"
		and destGUID == UnitGUID("player")
		and ((BagHelper.Spellstone_Name and arg9 == BagHelper.Spellstone_Name)
		or (BagHelper.Firestone_Name and arg9 == BagHelper.Firestone_Name)))
	then
			Local.SomethingOnHand = "Rien"
			UpdateIcons()
	end
end

function CheckGroupStatus()
	local groupMembersCount = GetNumGroupMembers()
	if (groupMembersCount > 5) then
		Necrosis.CurrentEnv.InRaid = true
		Necrosis.CurrentEnv.InParty = false
	elseif (groupMembersCount > 0) then
		Necrosis.CurrentEnv.InRaid = false
		Necrosis.CurrentEnv.InParty = true
	else
		Necrosis.CurrentEnv.InRaid = false
		Necrosis.CurrentEnv.InParty = false
	end
end

------------------------------------------------------------------------------------------------------
-- INTERFACE FUNCTIONS - XML ​​LINKS || FONCTIONS DE L'INTERFACE -- LIENS XML
------------------------------------------------------------------------------------------------------

-- Function to move Necrosis elements on the screen ||Fonction permettant le déplacement d'éléments de Necrosis sur l'écran
function Necrosis:OnDragStart(uiElement)
	uiElement:StartMoving()
end

-- Function stopping the movement of Necrosis elements on the screen ||Fonction arrêtant le déplacement d'éléments de Necrosis sur l'écran
function Necrosis:OnDragStop(uiElement)
	-- We stop the movement effectively ||On arrête le déplacement de manière effective
	uiElement:StopMovingOrSizing()
	-- We save the location of the button ||On sauvegarde l'emplacement du bouton
	local name = uiElement:GetName()
	local AncreBouton, BoutonParent, AncreParent, BoutonX, BoutonY = uiElement:GetPoint()
	if not BoutonParent then
		BoutonParent = "UIParent"
	else
		BoutonParent = BoutonParent:GetName()
	end
	NecrosisConfig.FramePosition[name] = {AncreBouton, BoutonParent, AncreParent, BoutonX, BoutonY}
end

-- helpers to reduce maintenance
local function ManaLocalize(mana)
	if GetLocale() == "ruRU" then
		GameTooltip:AddLine(L["MANA"]..": "..mana)
	else
		GameTooltip:AddLine(mana.." "..L["MANA"])
	end
end
local function AddCastAndCost(usage)
	GameTooltip:AddLine(Necrosis.GetSpellCastName(usage))
	local manaCost = Necrosis.GetSpellMana(usage)
	if (manaCost) then
		ManaLocalize(Necrosis.GetSpellMana(usage))
	end
end
local function AddShard()
	if BagHelper.Soulshard_Count == 0 then
		GameTooltip:AddLine("|c00FF4444"..Necrosis.TooltipData.Main.Soulshard..BagHelper.Soulshard_Count.."|r")
	else
		GameTooltip:AddLine(Necrosis.TooltipData.Main.Soulshard..BagHelper.Soulshard_Count)
	end
end
local function AddDominion()
	local start,  duration  = Necrosis.Spells:GetFelDominationCooldown()
	if not (start and duration) then
		GameTooltip:AddLine(Necrosis.TooltipData.DominationCooldown)
	end
end
local function AddMenuTip(Type)
	if Local.PlayerInCombat and NecrosisConfig.AutomaticMenu then
		GameTooltip:AddLine(Necrosis.TooltipData[Type].Text2)
	else
		GameTooltip:AddLine(Necrosis.TooltipData[Type].Text)
	end
end
local function AddInfernalReagent()
	if BagHelper.InfernalStone_Count == 0 then
		GameTooltip:AddLine("|c00FF4444"..Necrosis.TooltipData.Main.InfernalStone..BagHelper.InfernalStone_Count.."|r")
	else
		GameTooltip:AddLine(Necrosis.TooltipData.Main.InfernalStone..BagHelper.InfernalStone_Count)
	end
end
local function AddDemoniacReagent()
	if BagHelper.DemonicFigure_Count == 0 then
		GameTooltip:AddLine("|c00FF4444"..Necrosis.TooltipData.Main.DemoniacStone..BagHelper.DemonicFigure_Count.."|r")
	else
		GameTooltip:AddLine(Necrosis.TooltipData.Main.DemoniacStone..BagHelper.DemonicFigure_Count)
	end
end

-- Function managing the help bubbles ||Fonction gérant les bulles d'aide
function Necrosis:BuildButtonTooltip(button)
	-- If the display of help bubbles is disabled, Bye bye! ||Si l'affichage des bulles d'aide est désactivé, Bye bye !
	if not NecrosisConfig.NecrosisToolTip then
		return
	end

	local f = button:GetName()
	local Type = ""
	local b = nil
	-- look up the button info
	for i, v in pairs (Necrosis.Warlock_Buttons) do
		if v.f == f then
			Type = Necrosis.Warlock_Buttons[i].tip
			b = v
			break
		else
		end
	end
	if b.tip == nil then
		return -- a button we are not interested in was given
	else
		Type = b.tip
	end


	if Necrosis.Debug.tool_tips then
		_G["DEFAULT_CHAT_FRAME"]:AddMessage("BuildButtonTooltip"
		.." b'"..tostring(f).."'"
		.." T'"..tostring(Type).."'"
		.." l'"..tostring(Necrosis.TooltipData[Type].Label).."'"
		)
	end
	anchor = b.anchor or "ANCHOR_RIGHT" -- put to right in case not specified...

	-- If the tooltip is associated with a menu button, we change the anchoring of the tooltip according to its meaning ||Si la bulle d'aide est associée à un bouton de menu, on change l'ancrage de la tooltip suivant son sens
	if b.menu then
		if (b.menu == "Pet" and NecrosisConfig.PetMenuPos.direction < 0)
			or
				(b.menu == "Buff" and NecrosisConfig.BuffMenuPos.direction < 0)
			or
				(b.menu == "Curse" and NecrosisConfig.CurseMenuPos.direction < 0)
			or
				(b.menu == "Timer" and NecrosisConfig.SpellTimerJust == "RIGHT")
			then
				anchor = "ANCHOR_LEFT"
		end
	else
		-- use the anchor already grabbed
	end

	-- local start,  duration  = Necrosis.Utils.GetSpellCooldown("domination", "spell")
	-- local start2, duration2  = Necrosis.Utils.GetSpellCooldown("ward", "spell")
	-- local start,  duration  = Necrosis.Spells:GetFelDominationCooldown()
	-- local start2, duration2 = Necrosis.Spells:GetShadowWardCooldown()

	-- Creating help bubbles .... ||Création des bulles d'aides....
	GameTooltip:SetOwner(button, anchor)
	GameTooltip:SetText(Necrosis.TooltipData[Type].Label)
	-- ..... for the main button ||..... pour le bouton principal
	if (Type == "Main") then
		GameTooltip:AddLine(Necrosis.TooltipData.Main.Soulshard..BagHelper.Soulshard_Count)
		GameTooltip:AddLine(Necrosis.TooltipData.Main.InfernalStone..BagHelper.InfernalStone_Count)
		GameTooltip:AddLine(Necrosis.TooltipData.Main.DemoniacStone..BagHelper.DemonicFigure_Count)
		local SoulOnHand = false
		local HealthOnHand = false
		local SpellOnHand = false
		local FireOnHand = false
		if BagHelper.Soulstone_IsAvailable then SoulOnHand = true end
		if BagHelper.Healthstone_IsAvailable then HealthOnHand = true end
		if BagHelper.Spellstone_IsAvailable then SpellOnHand = true end
		if BagHelper.Firestone_IsAvailable then FireOnHand = true end
		GameTooltip:AddLine(Necrosis.TooltipData.Main.Soulstone..Necrosis.TooltipData[Type].Stone[SoulOnHand])
		GameTooltip:AddLine(Necrosis.TooltipData.Main.Healthstone..Necrosis.TooltipData[Type].Stone[HealthOnHand])
		GameTooltip:AddLine(Necrosis.TooltipData.Main.Spellstone..Necrosis.TooltipData[Type].Stone[SpellOnHand])
		GameTooltip:AddLine(Necrosis.TooltipData.Main.Firestone..Necrosis.TooltipData[Type].Stone[FireOnHand])
		-- View the name of the daemon, or if it is slave, or "None" if no daemon is present ||Affichage du nom du démon, ou s'il est asservi, ou "Aucun" si aucun démon n'est présent
		if (Necrosis.CurrentEnv.DemonType) then
			GameTooltip:AddLine(Necrosis.TooltipData.Main.CurrentDemon..Necrosis.CurrentEnv.DemonType)
		elseif (Necrosis.CurrentEnv.DemonEnslaved) then
			GameTooltip:AddLine(Necrosis.TooltipData.Main.EnslavedDemon)
		else
			GameTooltip:AddLine(Necrosis.TooltipData.Main.NoCurrentDemon)
		end
	-- ..... for stone buttons ||..... pour les boutons de pierre
	elseif Type:find("stone") then
		-- Soul Stone ||Pierre d'âme
		if (Type == "Soulstone") then
			AddCastAndCost("soulstone")
			-- We display the name of the stone and the action that will produce the click on the button ||On affiche le nom de la pierre et l'action que produira le clic sur le bouton
			-- And also the cooldown ||Et aussi le Temps de recharge

			-- cool down or not
			local color = "|CFF808080"
			local str = ""
			local cool = ""
			if Local.Stone.Soul.Location[1] and Local.Stone.Soul.Location[2] then
				local startTime, duration, isEnabled = GetContainerItemCooldown(Local.Stone.Soul.Location[1], Local.Stone.Soul.Location[2])
				if startTime == 0 then
					-- not on cool down
				else
					str = Necrosis.Translation.Misc.Cooldown
					cool = " - "..Necrosis.Utils.TimeLeft(((startTime - GetTime()) + duration))
					cool = str..cool
				end
			end
			
			-- L click - use
			str = Necrosis.TooltipData[Type].Text[2]
			if cool == "" then
			else
				str = color..str.."|r" -- must wait for cool down
			end
			GameTooltip:AddLine(str)
			
			-- R click - create
			str = Necrosis.TooltipData[Type].Text[1]
			if BagHelper.Soulstone_IsAvailable then
				str = color..str.."|r" -- already have one
			else
			end
			GameTooltip:AddLine(str)
			
			GameTooltip:AddLine(Necrosis.TooltipData[Type].Ritual)
			
			-- show cool down
			GameTooltip:AddLine(cool)
		-- Healthstone | Stone of life ||Healthstone | Pierre de vie
		elseif (Type == "Healthstone") then
			-- Idem ||Idem
			if Local.Stone.Health.Mode == 1 then
				AddCastAndCost("healthstone")
			end
			GameTooltip:AddLine(Necrosis.TooltipData[Type].Text[Local.Stone.Health.Mode])
			if Local.Stone.Health.Mode == 2 then
				GameTooltip:AddLine(Necrosis.TooltipData[Type].Text2)
			end
			
			-- cool down or not
			if Necrosis.Debug.tool_tips then
				_G["DEFAULT_CHAT_FRAME"]:AddMessage("BuildButtonTooltip"
				.." b'"..tostring(f).."'"
				.." T'"..tostring(Type).."'"
				.." l'"..tostring(Necrosis.TooltipData[Type].Label).."'"
				)
			end
			if Local.Stone.Health.Location[1] and Local.Stone.Health.Location[2] then
				local startTime, duration, isEnabled = GetContainerItemCooldown(Local.Stone.Health.Location[1], Local.Stone.Health.Location[2])
				if startTime == 0 then
					-- not on cool down
				else
					local cool = ""
					local color = ""
					local str = Necrosis.Translation.Misc.Cooldown
					color = "|CFF808080"
					cool = " - "..Necrosis.Utils.TimeLeft(((startTime - GetTime()) + duration))
					GameTooltip:AddLine(color..str..cool.."|r")
				end
			end
			--[[
						if itemName:find(Necrosis.Translation.Misc.Cooldown) then
							GameTooltip:AddLine(itemName)
						end
			--]]
			if  BagHelper.Soulshard_Count > 0 then
				GameTooltip:AddLine(Necrosis.TooltipData[Type].Ritual)
			end
		-- Stone of spell ||Pierre de sort
		elseif (Type == "Spellstone") then
			-- Eadem ||Eadem
			if Local.Stone.Spell.Mode == 1 then
				AddCastAndCost("spellstone")
			end
			GameTooltip:AddLine(Necrosis.TooltipData[Type].Text[Local.Stone.Spell.Mode])
		-- Fire stone ||Pierre de feu
		elseif (Type == "Firestone") then
			-- Idem ||Idem
			if Local.Stone.Fire.Mode == 1 then
				AddCastAndCost("firestone")
			end
			GameTooltip:AddLine(Necrosis.TooltipData[Type].Text[Local.Stone.Fire.Mode])
		end
	elseif (Type == "DestroyShards") then
		GameTooltip:AddLine(Necrosis.TooltipData[Type].Text..tostring(NecrosisConfig.DestroyCount))
	-- ..... for the Timers button ||..... pour le bouton des Timers
	elseif (Type == "SpellTimer") then
		GameTooltip:AddLine(Necrosis.TooltipData[Type].Text)
		local cool = ""
		local color = ""
		local str = Necrosis.TooltipData[Type].Right..GetBindLocation()
		if Local.Stone.Hearth.Location[1] and Local.Stone.Hearth.Location[2] then
			local startTime, duration, isEnabled = GetContainerItemCooldown(Local.Stone.Hearth.Location[1], Local.Stone.Hearth.Location[2])
			if startTime == 0 then
				color = "|CFFFFFFFF"
			else
				color = "|CFF808080"
				cool = " - "..Necrosis.Utils.TimeLeft(((startTime - GetTime()) + duration))
			end
		end
		GameTooltip:AddLine(color..str..cool.."|r")
	-- ..... for the shadow trance button ||..... pour le bouton de la Transe de l'ombre
	elseif (Type == "ShadowTrance") then
		GameTooltip:SetText(Necrosis.TooltipData[Type].Label.."          |CFF808080"..Necrosis.GetSpellCastName("bolt").."|r")
	-- ..... for other buffs and demons, the mana cost ... ||..... pour les autres buffs et démons, le coût en mana...
	elseif (Type == "Enslave") then AddCastAndCost("enslave"); AddShard()
	elseif (Type == "Mount") then
		local left = nil
		local right = nil
		if (Necrosis.CurrentEnv.FelsteedAvailable) then
			left = "Left click: "..Necrosis.CurrentEnv.FelsteedName
			right = "Right click: "..Necrosis.CurrentEnv.FelsteedName
		end
		if (Necrosis.CurrentEnv.DreadsteedAvailable) then
			left = "Left click: "..Necrosis.CurrentEnv.DreadsteedName
		end
		if (left) then
			GameTooltip:AddLine(left);
		end
		if (right) then
			GameTooltip:AddLine(right);
		end
	elseif (Type == "Armor") then
		-- Check for Fel and Demon Armor
		local left = nil
		local right = nil
		local mana = nil
		if (Necrosis.CurrentEnv.DemonArmorAvailable) then
			mana = Necrosis.Spell[36].Mana
			left = "Left click: "..Necrosis.CurrentEnv.DemonArmorName.." "..mana.." "..L["MANA"]
			right = "Right click: "..Necrosis.CurrentEnv.DemonArmorName.." "..mana.." "..L["MANA"]
		end
		if (Necrosis.CurrentEnv.FelArmorAvailable) then
			mana = Necrosis.Spell[47].Mana
			left = "Left click: "..Necrosis.CurrentEnv.FelArmorName..", "..mana.." "..L["MANA"]
		end
		if (left) then
			GameTooltip:AddLine(left)
		end
		if (right) then
			GameTooltip:AddLine(right)
		end
		if (not left and not right) then
			AddCastAndCost("armor")
		end
	elseif (Type == "Invisible")	then AddCastAndCost("invisible")
	elseif (Type == "Aqua")			then AddCastAndCost("breath")
	elseif (Type == "Kilrogg")		then AddCastAndCost("eye")
	elseif (Type == "Banish") 		then AddCastAndCost("banish")
--		if Necrosis.Warlock_Spells[Necrosis.Warlock_Spell_Use["banish"]].SpellRank == 2 then
		if Necrosis.GetSpellRank("banish") == 2 then
			GameTooltip:AddLine(Necrosis.TooltipData[Type].Text) -- R click rank 1
		end
	elseif (Type == "Shatter") 		then
		AddCastAndCost("shatter")
		AddShard()
	elseif (Type == "Weakness")		then AddCastAndCost("weakness")
	elseif (Type == "Agony")		then AddCastAndCost("agony")
	elseif (Type == "Tongues")		then AddCastAndCost("tongues")
	elseif (Type == "Exhaust")		then AddCastAndCost("exhaustion")
	elseif (Type == "Elements")		then AddCastAndCost("elements")
	elseif (Type == "Doom")			then AddCastAndCost("doom")
	elseif (Type == "Corruption")	then AddCastAndCost("corruption")
	elseif (Type == "Reckless")		then AddCastAndCost("recklessness")
	elseif (Type == "TP")			then AddCastAndCost("summoning"); AddShard()
	elseif (Type == "SoulLink")		then AddCastAndCost("link")
	elseif (Type == "ShadowProtection") then AddCastAndCost("ward")
		local start2, duration2 = Necrosis.Spells:GetShadowWardCooldown()
		if start2 and duration2 then
			GameTooltip:AddLine("Cooldown : "..duration2)
		end
	elseif (Type == "Domination") then
		local start,  duration  = Necrosis.Spells:GetFelDominationCooldown()
		if start and duration then
			GameTooltip:AddLine("Cooldown : "..duration)
		end
	elseif (Type == "Imp")			then AddCastAndCost("imp"); AddDominion()--start, duration)
	elseif (Type == "Voidwalker")	then AddCastAndCost("voidwalker"); AddShard(); AddDominion()--start, duration)
	elseif (Type == "Succubus")		then AddCastAndCost("succubus"); AddShard(); AddDominion()--start, duration)
	elseif (Type == "Incubus")		then AddCastAndCost("incubus"); AddShard(); AddDominion()--start, duration)
	elseif (Type == "Felhunter")	then AddCastAndCost("felhunter"); AddShard(); AddDominion()--start, duration)
	elseif (Type == "Infernal")		then AddCastAndCost("inferno"); AddInfernalReagent()
	elseif (Type == "Doomguard")	then AddCastAndCost("ritual_doom"); AddDemoniacReagent()
	elseif (Type == "Sacrifice")	then AddCastAndCost("sacrifice")
	elseif (Type == "BuffMenu")		then AddMenuTip(Type)
	elseif (Type == "CurseMenu")	then AddMenuTip(Type)
	elseif (Type == "PetMenu")		then AddMenuTip(Type)
	end
	-- And hop, posting! || Et hop, affichage !
	GameTooltip:Show()
end


-- Update the sphere according to life || Update de la sphere en fonction de la vie
function Necrosis:UpdateHealth()
	local health = UnitHealth("player")
	if NecrosisConfig.Circle == "Health" then
		local healthMax = UnitHealthMax("player")
		if health == healthMax then
			if not (Local.LastSphereSkin == NecrosisConfig.NecrosisColor.."\\Shard32") then
				Local.LastSphereSkin = NecrosisConfig.NecrosisColor.."\\Shard32"
				NecrosisButton:SetNormalTexture(GraphicsHelper:GetTexture(Local.LastSphereSkin))
			end
		else
			local taux = math.floor(health / (healthMax / 16))
			if not (Local.LastSphereSkin == NecrosisConfig.NecrosisColor.."\\Shard"..taux) then
				Local.LastSphereSkin = NecrosisConfig.NecrosisColor.."\\Shard"..taux
				NecrosisButton:SetNormalTexture(GraphicsHelper:GetTexture(Local.LastSphereSkin))
			end
		end
	end
	-- If the inside of the stone shows life || Si l'intérieur de la pierre affiche la vie
	if NecrosisConfig.CountType == "Health" then
		NecrosisShardCount:SetText(health)
	end
end

-- Update buttons according to mana || Update des boutons en fonction de la mana
function Necrosis:UpdateMana()
	if Local.Dead then return end
  	local ptype = UnitPowerType("player")
	local mana = UnitPower("player",ptype)
	local manaMax = UnitPowerMax("player", ptype)

	-- If the perimeter of the stone shows the mana || Si le pourtour de la pierre affiche la mana
	if NecrosisConfig.Circle == "Mana" then
		if mana == manaMax then
			if not (Local.LastSphereSkin == NecrosisConfig.NecrosisColor.."\\Shard32") then
				Local.LastSphereSkin = NecrosisConfig.NecrosisColor.."\\Shard32"
				NecrosisButton:SetNormalTexture(GraphicsHelper:GetTexture(Local.LastSphereSkin))
			end
		else
			local taux = math.floor(mana / (manaMax / 16))
			if not (Local.LastSphereSkin == NecrosisConfig.NecrosisColor.."\\Shard"..taux) then
				Local.LastSphereSkin = NecrosisConfig.NecrosisColor.."\\Shard"..taux
				NecrosisButton:SetNormalTexture(GraphicsHelper:GetTexture(Local.LastSphereSkin))
			end
		end
	end

	-- If the inside of the stone shows mana || Si l'intérieur de la pierre affiche la mana
	if NecrosisConfig.CountType == "Mana" then
		NecrosisShardCount:SetText(mana)
	end

	-- If corrupt domination cooldown is gray || Si cooldown de domination corrompue on grise
	if _G["NecrosisPetMenu1"] and self.Spell[15].ID and not Local.BuffActif.Domination then
		local start, duration = GetSpellCooldown(self.Spell[15].ID, "spell")
		if start > 0 and duration > 0 then
			if not Local.Desatured["Domination"] then
				NecrosisPetMenu1:GetNormalTexture():SetDesaturated(1)
				Local.Desatured["Domination"] = true
			end
		else
			if Local.Desatured["Domination"] then
				NecrosisPetMenu1:GetNormalTexture():SetDesaturated(nil)
				Local.Desatured["Domination"] = false
			end
		end
	end

	-- If shadow guardian cooldown we gray || Si cooldown de gardien de l'ombre on grise
	if _G["NecrosisBuffMenu8"] and self.Spell[43].ID then
		local start, duration = GetSpellCooldown(self.Spell[43].ID, "spell")
		if self.Spell[43].Mana > mana and start > 0 and duration > 0 then
			if not Local.Desatured["Gardien"] then
				NecrosisBuffMenu8:GetNormalTexture():SetDesaturated(1)
				Local.Desatured["Gardien"] = true
			end
		else
			if Local.Desatured["Gardien"] then
				NecrosisBuffMenu8:GetNormalTexture():SetDesaturated(nil)
				Local.Desatured["Gardien"] = false
			end
		end
	end


	-- Demon button || Bouton des démons
	-----------------------------------------------
	local ManaPet = new("array",
		true, true, true, true, true, true, true
	)

	if mana then
	-- Coloring the button in gray if not enough mana || Coloration du bouton en grisé si pas assez de mana
		if self.Spell[3].ID then
			if self.Spell[3].Mana > mana then
				for i = 1, 7, 1 do
					ManaPet[i] = false
				end
			elseif self.Spell[4].ID then
				if self.Spell[4].Mana > mana then
					for i = 2, 7, 1 do
						ManaPet[i] = false
					end
				elseif self.Spell[8].ID then
					if self.Spell[8].Mana > mana then
							ManaPet[7] = false
							ManaPet[8] = false
					elseif self.Spell[30].ID then
						if self.Spell[30].Mana > mana then
							ManaPet[8] = false
						end
					end
				end
			end
		end
	end
	-- Coloring of the button in gray if no stone for the invocation || Coloration du bouton en grisé si pas de pierre pour l'invocation
	if BagHelper.Soulshard_Count == 0 then
		for i = 2, 5, 1 do
			ManaPet[i] = false
		end
	end
	if BagHelper.InfernalStone_Count == 0 then
		ManaPet[6] = false
	end
	if BagHelper.DemonicFigure_Count == 0 then
		ManaPet[7] = false
	end

	-- Texturing of pet buttons || Texturage des boutons de pet
	local PetNameHere = new("array",
		"Imp-0", "Voidwalker-0", "Succubus-0", "Incubus-0", "Felhunter-0", "Felguard-0", "Infernal-0", "Doomguard-0"
	)

	for i = 1, #PetNameHere, 1 do
		local PetManaButton = _G["NecrosisPetMenu"..(i + 1)]
		if PetManaButton
			and Necrosis.CurrentEnv.LastDemonType
			and Necrosis.CurrentEnv.LastDemonType == self.Translation.DemonName[i]
			and not (Necrosis.CurrentEnv.LastDemonType == Necrosis.CurrentEnv.DemonType)
			then
				PetManaButton:SetNormalTexture(GraphicsHelper:GetTexture(PetNameHere[i].."1"))
				Necrosis.CurrentEnv.LastDemonType = nil
		end
		if PetManaButton
			and Necrosis.CurrentEnv.DemonType
			and Necrosis.CurrentEnv.DemonType == self.Translation.DemonName[i]
			then
				PetManaButton:SetNormalTexture(GraphicsHelper:GetTexture(PetNameHere[i].."2"))
		elseif PetManaButton and ManaPet[i] then
			if Local.Desatured["NecrosisPetMenu"..(i + 1)] then
				PetManaButton:GetNormalTexture():SetDesaturated(nil)
				Local.Desatured["NecrosisPetMenu"..(i + 1)] = false
			end
		elseif PetManaButton then
			if not Local.Desatured["NecrosisPetMenu"..(i + 1)] then
				PetManaButton:GetNormalTexture():SetDesaturated(1)
				Local.Desatured["NecrosisPetMenu"..(i + 1)] = true
			end
		end
	end
	del(PetNameHere)
	del(ManaPet)


	-- Buffs button || Bouton des buffs
	-----------------------------------------------

	if mana then
	-- Coloring the button in gray if not enough mana || Coloration du bouton en grisé si pas assez de mana
		if self.Spell[35].ID then
			if self.Spell[35].Mana > mana or BagHelper.Soulshard_Count == 0 then
				if not Local.Desatured["Enslave"] then
					if _G["NecrosisPetMenu9"] then
						NecrosisPetMenu9:GetNormalTexture():SetDesaturated(1)
					end
					Local.Desatured["Enslave"] = true
				end
			else
				if Local.Desatured["Enslave"]then
					if _G["NecrosisPetMenu9"] then
						NecrosisPetMenu9:GetNormalTexture():SetDesaturated(nil)
					end
					Local.Desatured["Enslave"] = false
				end
			end
		end
		if _G["NecrosisBuffMenu1"] and self.Spell[31].ID then
			if self.Spell[31].Mana > mana then
				if  not Local.Desatured["Armor"] then
					NecrosisBuffMenu1:GetNormalTexture():SetDesaturated(1)
					Local.Desatured["Armor"] = true
				end
			else
				if Local.Desatured["Armor"] then
					NecrosisBuffMenu1:GetNormalTexture():SetDesaturated(nil)
					Local.Desatured["Armor"] = false
				end
			end
		elseif _G["NecrosisBuffMenu1"] and self.Spell[36].ID then
			if self.Spell[36].Mana > mana then
				if not Local.Desatured["Armor"] then
					NecrosisBuffMenu1:GetNormalTexture():SetDesaturated(1)
					Local.Desatured["Armor"] = true
				end
			else
				if Local.Desatured["Armor"] then
					NecrosisBuffMenu1:GetNormalTexture():SetDesaturated(nil)
					Local.Desatured["Armor"] = false
				end
			end
		elseif _G["NecrosisBuffMenu7"] and self.Spell[38].ID and not Local.BuffActif.SoulLink then
			if self.Spell[38].Mana > mana then
				if not Local.Desatured["SoulLink"] then
					NecrosisBuffMenu7:GetNormalTexture():SetDesaturated(1)
					Local.Desatured["SoulLink"] = true
				end
			else
				if Local.Desatured["SoulLink"] then
					NecrosisBuffMenu7:GetNormalTexture():SetDesaturated(nil)
					Local.Desatured["SoulLink"] = false
				end
			end
		end

		local BoutonNumber = new("array",
			2, 3, 4, 5, 6, 11
		)
		local SortNumber = new("array",
			47, 32, 33, 34, 37, 9
		)
		for i = 1, #SortNumber, 1 do
			local f = _G["NecrosisBuffMenu"..BoutonNumber[i]]
			if f and self.Spell[SortNumber[i]].ID then
				if self.Spell[SortNumber[i]].Mana > mana then
					if not Local.Desatured["NecrosisBuffMenu"..BoutonNumber[i]] then
						f:GetNormalTexture():SetDesaturated(1)
						Local.Desatured["NecrosisBuffMenu"..BoutonNumber[i]] = true
					end
				else
					if Local.Desatured["NecrosisBuffMenu"..BoutonNumber[i]] then
						f:GetNormalTexture():SetDesaturated(nil)
						Local.Desatured["NecrosisBuffMenu"..BoutonNumber[i]] = false
					end
				end
			end
		end
		del(BoutonNumber)
		del(SortNumber)

		if _G["NecrosisPetMenu11"] and self.Spell[44].ID then
			if not UnitExists("pet") then
				if not Local.Desatured["Sacrifice"] then
					NecrosisPetMenu11:GetNormalTexture():SetDesaturated(1)
					Local.Desatured["Sacrifice"] = true
				end
			else
				if Local.Desatured["Sacrifice"] then
					NecrosisPetMenu11:GetNormalTexture():SetDesaturated(nil)
					Local.Desatured["Sacrifice"] = false
				end
			end
		end

	end

	-- Curses button || Bouton des curses
	-----------------------------------------------

	if mana then
		local SpellMana = new("array",
													 23, -- Curse of weakness
													 22, -- Curse of agony
													 25, -- Curse of tongues
													 40, -- Curse of exhaustion
													 26, -- Curse of the elements
													 16, -- Curse of doom
													 14  -- Corruption
													)

		-- Coloring the button in gray if not enough mana || Coloration du bouton en grisé si pas assez de mana
		for i = 1, #SpellMana, 1 do
			local f = _G["NecrosisCurseMenu"..i+1]
			if f and self.Spell[SpellMana[i]].ID then
				if self.Spell[SpellMana[i]].Mana > mana then
					if not Local.Desatured["NecrosisCurseMenu"..i+1] then
						f:GetNormalTexture():SetDesaturated(1)
						Local.Desatured["NecrosisCurseMenu"..i+1] = true
					end
				else
					if Local.Desatured["NecrosisCurseMenu"..i+1] then
						f:GetNormalTexture():SetDesaturated(nil)
						Local.Desatured["NecrosisCurseMenu"..i+1] = false
					end
				end
			end
		end
		del(SpellMana)
	end

	-- if Local.Stone.Hearth.OnHand and Local.Stone.Hearth.Location[1] then
	-- 	local start, duration, enable = GetContainerItemCooldown(Local.Stone.Hearth.Location[1], Local.Stone.Hearth.Location[2])
	-- 	if duration > 20 and start > 0 then
	-- 		if not Local.Stone.Hearth.Cooldown then
	-- 			NecrosisSpellTimerButton:GetNormalTexture():SetDesaturated(1)
	-- 			Local.Stone.Hearth.Cooldown = true
	-- 		end
	-- 	else
	-- 		if Local.Stone.Hearth.Cooldown then
	-- 			NecrosisSpellTimerButton:GetNormalTexture():SetDesaturated(nil)
	-- 			Local.Stone.Hearth.Cooldown = false
	-- 		end
	-- 	end
	-- end
end


------------------------------------------------------------------------------------------------------
-- FUNCTIONS MANAGING STONES & SHARDS || FONCTIONS DES PIERRES ET DES FRAGMENTS
------------------------------------------------------------------------------------------------------

-- Explore bags for stones & shards || Fonction qui fait l'inventaire des éléments utilisés en démonologie : Pierres, Fragments, Composants d'invocation
function Necrosis:BagExplore(containerId)
	BagHelper:BagExplore(containerId)

	BagHelper:GetStoneCounts()

	-- Local.Soulshard.Count     = BagHelper.Soulshard_Count
	-- Local.Reagent.Infernal    = BagHelper.InfernalStone_Count
	-- Local.Reagent.Demoniac    = BagHelper.DemonicFigure_Count
	-- Local.Stone.Soul.OnHand   = BagHelper.Soulstone_IsAvailable
	-- Local.Stone.Health.OnHand = BagHelper.Healthstone_IsAvailable
	-- Local.Stone.Spell.OnHand  = BagHelper.Spellstone_IsAvailable
	-- Local.Stone.Fire.OnHand   = BagHelper.Firestone_IsAvailable

	local AncienCompte = BagHelper.Soulshard_Count

	-- Destroy extra shards (if enabled) || Si il y a un nombre maximum de fragments à conserver, on enlève les supplémentaires
	-- if NecrosisConfig.DestroyShard
	-- 	and NecrosisConfig.DestroyCount
	-- 	and NecrosisConfig.DestroyCount > 0
	-- 	then
	-- 		BagHelper:DestroyShards(math.floor(NecrosisConfig.DestroyCount))
	-- 		-- Local.Soulshard.Count = BagHelper.Soulshard_Count
	-- end

	-- Updtae the main (sphere) button display || Affichage du bouton principal de Necrosis
	if NecrosisConfig.Circle == "Soulshards" then
		if (BagHelper.Soulshard_Count <= 32) then
			if not (Local.LastSphereSkin == NecrosisConfig.NecrosisColor.."\\Shard"..BagHelper.Soulshard_Count) then
				Local.LastSphereSkin = NecrosisConfig.NecrosisColor.."\\Shard"..BagHelper.Soulshard_Count
				NecrosisButton:SetNormalTexture(GraphicsHelper:GetTexture(Local.LastSphereSkin))
			end
		elseif not (Local.LastSphereSkin == NecrosisConfig.NecrosisColor.."\\Shard32") then
			Local.LastSphereSkin = NecrosisConfig.NecrosisColor.."\\Shard32"
			NecrosisButton:SetNormalTexture(GraphicsHelper:GetTexture(Local.LastSphereSkin))
		end
	elseif NecrosisConfig.Circle == "RezTimer" and (Local.Stone.Soul.Mode == 1 or Local.Stone.Soul.Mode == 2) then

		if (BagHelper.Soulshard_Count <= 32) then
			if not (Local.LastSphereSkin == NecrosisConfig.NecrosisColor:gsub("Turquoise", "Bleu"):gsub("Rose", "Bleu"):gsub("Orange", "Bleu").."\\Shard"..BagHelper.Soulshard_Count) then
				Local.LastSphereSkin = NecrosisConfig.NecrosisColor:gsub("Turquoise", "Bleu"):gsub("Rose", "Bleu"):gsub("Orange", "Bleu").."\\Shard"..BagHelper.Soulshard_Count
				NecrosisButton:SetNormalTexture(GraphicsHelper:GetTexture(Local.LastSphereSkin))
			end
		elseif not (Local.LastSphereSkin == NecrosisConfig.NecrosisColor:gsub("Turquoise", "Bleu"):gsub("Rose", "Bleu"):gsub("Orange", "Bleu").."\\Shard32") then
			Local.LastSphereSkin = NecrosisConfig.NecrosisColor:gsub("Turquoise", "Bleu"):gsub("Rose", "Bleu"):gsub("Orange", "Bleu").."\\Shard32"
			NecrosisButton:SetNormalTexture(GraphicsHelper:GetTexture(Local.LastSphereSkin))
		end
	end

	if NecrosisConfig.ShowCount then
		if NecrosisConfig.CountType == "DemonStones" then
			NecrosisShardCount:SetText(BagHelper.InfernalStone_Count.." / "..BagHelper.DemonicFigure_Count)
		elseif NecrosisConfig.CountType == "Soulshards" then
			if BagHelper.Soulshard_Count < 10 then
				NecrosisShardCount:SetText("0"..BagHelper.Soulshard_Count)
			else
				NecrosisShardCount:SetText(BagHelper.Soulshard_Count)
			end
		end
	else
		NecrosisShardCount:SetText("")
	end

	-- Update icons and we're done || Et on met le tout à jour !
	UpdateIcons()

	-- If bags are full (or if we have reached the limit) then display a notification message || S'il y a plus de fragment que d'emplacements dans le sac défini, on affiche un message d'avertissement
	if NecrosisConfig.SoulshardSort then
		local CompteMax = NecrosisCompat.GetContainerNumSlots(NecrosisConfig.SoulshardContainer)
		for i,bag in ipairs(BagHelper:GetPlayerBags()) do
			if bag.isSoulBag and (not NecrosisConfig.SoulshardContainer == bag.slot) then
				CompteMax = CompteMax + bag.capacity
			end
		end
		if BagHelper.Soulshard_Count > AncienCompte and BagHelper.Soulshard_Count == CompteMax then
			-- if (NecrosisConfig.SoulshardDestroy) then
			-- 	self.Chat:_Msg(self.ChatMessage.Bag.FullPrefix..GetBagName(NecrosisConfig.SoulshardContainer)..self.ChatMessage.Bag.FullDestroySuffix)
			-- else
				self.Chat:_Msg(self.ChatMessage.Bag.FullPrefix..GetBagName(NecrosisConfig.SoulshardContainer)..self.ChatMessage.Bag.FullSuffix)
			-- end
		end
	end
end

-- Allows you to find / arrange shards in bags || Fonction qui permet de trouver / ranger les fragments dans les sacs
function Necrosis:SoulshardSwitch(Type)
	-- print (TYPE .. "SS type check".. Local.Soulshard.Move)
	if (Type == "CHECK") then Local.Soulshard.Move = 0 end
	for container = 0, 4, 1 do
		if Local.BagIsSoulPouch[container+1] then break end
		if not (container == NecrosisConfig.SoulshardContainer) then
			for slot = 1, NecrosisCompat.GetContainerNumSlots(container), 1 do
				local itemLink = GetContainerItemLink(container, slot)
				if (itemLink) then
					local _, itemID = strsplit(":", itemLink)
					itemID = tonumber(itemID)
					if (itemID == 6265) then
						if (Type == "CHECK") then
							Local.Soulshard.Move = Local.Soulshard.Move + 1
						elseif (Type == "MOVE") then
							self:FindSlot(container, slot)
							Local.Soulshard.Move = Local.Soulshard.Move - 1
						end
					end
				end
			end
		end
	end
end

-- Finds a new bag / slot when moving shards || Pendant le déplacement des fragments, il faut trouver un nouvel emplacement aux objets déplacés :)
function Necrosis:FindSlot(shardIndex, shardSlot)
	local full = true
	for slot=1, NecrosisCompat.GetContainerNumSlots(NecrosisConfig.SoulshardContainer), 1 do
		self:MoneyToggle()
 		NecrosisTooltip:SetBagItem(NecrosisConfig.SoulshardContainer, slot)
 		local itemInfo = tostring(NecrosisTooltipTextLeft1:GetText())
		if not itemInfo:find(self.Translation.Item.Soulshard) then
			NecrosisCompat.PickupContainerItem(shardIndex, shardSlot)
			NecrosisCompat.PickupContainerItem(NecrosisConfig.SoulshardContainer, slot)
			if (CursorHasItem()) then
				if shardIndex == 0 then
					PutItemInBackpack()
				else
					PutItemInBag(19 + shardIndex)
				end
			end
			full = false
			break
		end
	end
	-- -- Destory extra shards if the option is enabled || Destruction des fragments en sur-nombre si l'option est activée
	-- if (full and NecrosisConfig.SoulshardDestroy) then

	-- 	if (math.floor(NecrosisConfig.DestroyCount) < BagHelper.Soulshard_Count) then
	-- 		PickupContainerItem(shardIndex, shardSlot)
	-- 		if (CursorHasItem()) then
	-- 			DeleteCursorItem()
	-- 			BagHelper.Soulshard_Count = GetItemCount(6265)
	-- 		end
	-- 	end
	-- end
end

------------------------------------------------------------------------------------------------------
-- VARIOUS FUNCTIONS || FONCTIONS DES SORTS
------------------------------------------------------------------------------------------------------

-- Display or Hide buttons depending on spell availability || Affiche ou masque les boutons de sort à chaque nouveau sort appris
function Necrosis:ButtonSetup()
	local NBRScale = (100 + (NecrosisConfig.NecrosisButtonScale - 85)) / 100
	local dist = 35 * NBRScale
	dist = dist
	if NecrosisConfig.NecrosisButtonScale <= 100 then
		NBRScale = 1.1
		dist = 40 * NBRScale
	end

---[==[
	if Necrosis.Debug.buttons then
		_G["DEFAULT_CHAT_FRAME"]:AddMessage("ButtonSetup === Begin")
	end
	local fm = Necrosis.Warlock_Buttons.main.f
	local indexScale = -36
	for index=1, #Necrosis.Warlock_Lists.on_sphere, 1 do
		local v = Necrosis.Warlock_Lists.on_sphere[index]
		local warlockButton = Necrosis.Warlock_Buttons[v.f_ptr]
		local fr = warlockButton.f

		if Necrosis.Debug.buttons then
			_G["DEFAULT_CHAT_FRAME"]:AddMessage("ButtonSetup".." '"..tostring(fr))
		end
		local f = _G[fr]
		if (Necrosis.IsSpellKnown(v.high_of)            -- in spell book
			or v.menu                                   -- or on menu of spells
			or warlockButton.func                       -- Function to call when clicking the button
			or v.item)                                  -- or item to use
			and NecrosisConfig.StonePosition[index] > 0 -- and requested
		then
			if not f then
				-- f = Necrosis:CreateSphereButtons(Necrosis.Warlock_Buttons[v.f_ptr])
				if (warlockButton.menu) then
					f = SphereButtonHelper:CreateMenuButton(warlockButton)
				else
					f = SphereButtonHelper:CreateStoneButton(warlockButton)
				end
				Necrosis:StoneAttribute(Necrosis.CurrentEnv.SteedAvailable)
			end
			-- if (not EventHelper:IsCombatLocked()) then
				f:ClearAllPoints()
---[[
				if NecrosisConfig.NecrosisLockServ then
					f:SetPoint(
						"CENTER", fm, "CENTER",
						((dist) * cos(NecrosisConfig.NecrosisAngle - indexScale)),
						((dist) * sin(NecrosisConfig.NecrosisAngle - indexScale))
					)
					indexScale = indexScale + 36
				else
--]]
					f:SetPoint(
						NecrosisConfig.FramePosition[fr][1],
						NecrosisConfig.FramePosition[fr][2],
						NecrosisConfig.FramePosition[fr][3],
						NecrosisConfig.FramePosition[fr][4],
						NecrosisConfig.FramePosition[fr][5]
					)
				end
				f:SetScale(NBRScale)
				f:Show()
			-- end
		else
			if f then
				f:Hide()
			end
		end
	end
	if Necrosis.Debug.buttons then
		_G["DEFAULT_CHAT_FRAME"]:AddMessage("ButtonSetup === Done"
		)
	end
--]==]
end


------------------------------------------------------------------------------------------------------
-- MISCELLANEOUS FUNCTIONS || FONCTIONS DIVERSES
------------------------------------------------------------------------------------------------------

-- Trade healthstone (out of combat) || Fonction pour gérer l'échange de pierre (hors combat)
function Necrosis:TradeStone()
	-- If a friendly target is selected then trade the stone || Dans ce cas si un pj allié est sélectionné, on lui donne la pierre
	-- Else use it || Sinon, on l'utilise
	if Local.Trade.Request and BagHelper.Healthstone_IsAvailable and not Local.Trade.Complete then
		NecrosisCompat.PickupContainerItem(BagHelper.Healthstone_BagId, BagHelper.Healthstone_SlotId)
		ClickTradeButton(1)
		Local.Trade.Complete = true
	elseif UnitExists("target") and UnitIsPlayer("target")
		and not (UnitCanAttack("player", "target") or UnitName("target") == UnitName("player")) then
			NecrosisCompat.PickupContainerItem(BagHelper.Healthstone_BagId, BagHelper.Healthstone_SlotId)
			if CursorHasItem() then
				DropItemOnUnit("target")
				Local.Trade.Complete = true
			end
	end
end

function Necrosis:MoneyToggle()
	for index=1, 10 do
		local text = _G["NecrosisTooltipTextLeft"..index]
		if text then text:SetText(nil) end
		text = _G["NecrosisTooltipTextRight"..index]
		if text then text:SetText(nil) end
	end
	NecrosisTooltip:Hide()
	NecrosisTooltip:SetOwner(WorldFrame, "ANCHOR_NONE")
end

function Necrosis:GameTooltip_ClearMoney()
    -- Intentionally empty don't clear money while we use hidden tooltips
end


-- -- Rebuild the menus at mod startup or when the spellbook changes || A chaque changement du livre des sorts, au démarrage du mod, ainsi qu'au changement de sens du menu on reconstruit les menus des sorts
function Necrosis:CreateMenu()
	Local.Menu.Pet = setmetatable({}, metatable)
	Local.Menu.Curse = setmetatable({}, metatable)
	Local.Menu.Buff = setmetatable({}, metatable)
	SphereMenu:CreateMenu(Local)
end

-- Reset Necrosis to default position || Fonction pour ramener tout au centre de l'écran
function Necrosis:Recall()
	local ui = new("array",
		"NecrosisButton",
		-- "NecrosisSpellTimerButton",
		"NecrosisAntiFearButton",
		"NecrosisCreatureAlertButton",
		"NecrosisBacklashButton",
		"NecrosisShadowTranceButton"
	)
	local pos = new("array",
		{0, -100},
		{0, 100},
		{20, 0},
		{60, 0},
		{-60, 0},
		{-20, 0}
	)
	for i = 1, #ui, 1 do
		local f = _G[ui[i]]
		f:ClearAllPoints()
		f:SetPoint("CENTER", "UIParent", "CENTER", pos[i][1], pos[i][2])
		f:Show()
		self:OnDragStop(f)
	end
	del(ui)
	del(pos)
end

function Necrosis:SetOfxy(menu)
	if menu == "Buff" and _G["NecrosisBuffMenuButton"] then
		Local.Menu.Buff[1]:ClearAllPoints()
		Local.Menu.Buff[1]:SetPoint(
			"CENTER", "NecrosisBuffMenuButton", "CENTER",
			NecrosisConfig.BuffMenuPos.direction * NecrosisConfig.BuffMenuPos.x * 32 + NecrosisConfig.BuffMenuDecalage.x,
			NecrosisConfig.BuffMenuPos.y * 32 + NecrosisConfig.BuffMenuDecalage.y
		)
	elseif menu == "Pet" and _G["NecrosisPetMenuButton"] then
		Local.Menu.Pet[1]:ClearAllPoints()
		Local.Menu.Pet[1]:SetPoint(
			"CENTER", "NecrosisPetMenuButton", "CENTER",
			NecrosisConfig.PetMenuPos.direction * NecrosisConfig.PetMenuPos.x * 32 + NecrosisConfig.PetMenuDecalage.x,
			NecrosisConfig.PetMenuPos.y * 32 + NecrosisConfig.PetMenuDecalage.y
		)
	elseif menu == "Curse" and _G["NecrosisCurseMenuButton"] then
		Local.Menu.Curse[1]:ClearAllPoints()
		Local.Menu.Curse[1]:SetPoint(
			"CENTER", "NecrosisCurseMenuButton", "CENTER",
			NecrosisConfig.CurseMenuPos.direction * NecrosisConfig.CurseMenuPos.x * 32 + NecrosisConfig.CurseMenuDecalage.x,
			NecrosisConfig.CurseMenuPos.y * 32 + NecrosisConfig.CurseMenuDecalage.y
		)
	end
end

-- This function fixes a problem with the Blizzard API "GetCompanionInfo", which will return a different name for some mounts in the game.
-- Example: the bronze drake (spell 59569)
--      -> GetCompanionInfo will return this as "Bronze Drake Mount" (wrong)
--      -> GetSpellInfo will return this as "Bronze Drake" (correct)
function Necrosis:GetCompanionInfo(type, id)
	local creatureID, creatureName, creatureSpellID, icon, issummoned = GetCompanionInfo(type, id)

	if creatureSpellID then
		-- Get the correct (localised) name
		creatureName = GetSpellInfo(creatureSpellID)
	end

	return creatureID, creatureName, creatureSpellID, icon, issummoned
end
