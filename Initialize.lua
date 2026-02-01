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
-- Version $LastChangedDate: 2009-12-10 17:09:53 +1100 (Thu, 10 Dec 2009) $
------------------------------------------------------------------------------------------------------




-- Define _G as the table containing all existing frames.
local _G = getfenv(0)

------------------------------------------------------------------------------------------------------
-- FONCTION D'INITIALISATION
------------------------------------------------------------------------------------------------------

local function ApplyLocalization()
	-- Initilialisation des Textes (VO / VF / VA / VCT / VCS / VE)
	if NecrosisConfig.Version then
		if NecrosisConfig.Language == "frFR" then
			Localization.frFR()
		elseif (NecrosisConfig.Language == "deDE") then
			Localization.deDE()
		elseif (NecrosisConfig.Language == "zhTW") then
			Localization.zhTW()
		elseif (NecrosisConfig.Language == "zhCN") then
			Localization.zhCN()
		elseif (NecrosisConfig.Language == "esES") then
			Localization.esES()
		elseif (NecrosisConfig.Language == "ruRU") then
			Localization.ruRU()
		else
			-- Default to English
			Localization.enUS()
		end
	else
		local code = GetLocale()
		if code == "frFR" then
			Localization.frFR()
		elseif code == "deDE" then
			Localization.deDE()
		elseif code == "zhTW" then
			Localization.zhTW()
		elseif code == "zhCN" then
			Localization.zhCN()
		elseif code == "esES" then
			Localization.esES()
		elseif code == "ruRU" then
			Localization.ruRU()
		else
			-- Default to English
			Localization.enUS()
		end
	end
end

local function setupMenu()
	Necrosis:SpellSetup()
	Necrosis:CreateMenu()
	Necrosis:ButtonSetup()

	Necrosis:MainButtonAttribute()

	-- Set the size of the stone and buttons according to SavedVariables settings
	NecrosisButton:SetScale(NecrosisConfig.NecrosisButtonScale/100)
	NecrosisShadowTranceButton:SetScale(NecrosisConfig.ShadowTranceScale/100)
	NecrosisBacklashButton:SetScale(NecrosisConfig.ShadowTranceScale/100)
	NecrosisAntiFearButton:SetScale(NecrosisConfig.ShadowTranceScale/100)
	NecrosisCreatureAlertButton:SetScale(NecrosisConfig.ShadowTranceScale/100)

	-- Is the Shard locked on the interface?
	if NecrosisConfig.NoDragAll then
		SphereMenu:NoDrag()
		NecrosisButton:RegisterForDrag("")
	else
		SphereMenu:Drag()
		NecrosisButton:RegisterForDrag("LeftButton")
	end

	-- Inventory of stones and shards possessed by the Warlock
	Necrosis:BagExplore()

	-- Si la sphere doit indiquer la vie ou la mana, on y va
	Necrosis:UpdateHealth()
	Necrosis:UpdateMana()

	-- We verify that the shards are in the bag defined by the Warlock
	if NecrosisConfig.SoulshardSort then
		Necrosis:SoulshardSwitch("CHECK")
	end
end

function Necrosis:Initialize(Config)
	CheckGroupStatus()
	ApplyLocalization()

	-- Load (or create) the configuration for the player and display it on the console
	if not NecrosisConfig.Version or type(NecrosisConfig.Version) == "string" or Necrosis.Data.LastConfig > NecrosisConfig.Version then
		NecrosisConfig = {}
		NecrosisConfig = Config
		NecrosisConfig.Version = Necrosis.Data.LastConfig
		self.Chat:_Msg(self.ChatMessage.Interface.DefaultConfig, "USER")
	else
		self.Chat:_Msg(self.ChatMessage.Interface.UserConfig, "USER")
	end

	if (NecrosisConfig.StonePosition[9] == nil) then
		NecrosisConfig.StonePosition[9] = 1
	end
	self:CreateWarlockUI()

	local f = Necrosis.Warlock_Buttons.main.f
	if Necrosis.Debug.init_path then
		_G["DEFAULT_CHAT_FRAME"]:AddMessage("Necrosis- Initialize"
		.." f:'"..(tostring(f) or "nyl").."'"
		)
	end

	f = _G[f]
	-- Now ready to activate Necrosis
	f:SetScript("OnEvent", Necrosis.OnEvent)
	f:SetScript("OnEnter", 		function(self) Necrosis:BuildButtonTooltip(self) end)
	f:SetScript("OnLeave", 		function() GameTooltip:Hide() end)
	f:SetScript("OnMouseUp", 	function(self) Necrosis:OnDragStop(self) end)
	f:SetScript("OnDragStart", 	function(self) Necrosis:OnDragStart(self) end)
	f:SetScript("OnDragStop", 	function(self) Necrosis:OnDragStop(self) end)

	self:CreateWarlockPopup()
	-----------------------------------------------------------
	-- Execution of startup functions
	-----------------------------------------------------------
	-- Affichage d'un message sur la console
	self.Chat:_Msg(self.ChatMessage.Interface.Welcome, "USER")

	-- Creation of the list of available spells
	self:SpellLocalize()
	setupMenu()
	
	Necrosis.Timers:Initialize()

	local successfulRequest = C_ChatInfo.RegisterAddonMessagePrefix(Necrosis.CurrentEnv.ChatPrefix)

    -- Enregistrement de la commande console
	SlashCmdList["NecrosisCommand"] = Necrosis.SlashHandler
	SLASH_NecrosisCommand1 = "/necrosis"
end

------------------------------------------------------------------------------------------------------
-- FUNCTION RUNNING CONSOLE CONTROL / FONCTION GERANT LA COMMANDE CONSOLE /NECRO
------------------------------------------------------------------------------------------------------

function Necrosis.SlashHandler(arg1)
	if arg1:lower():find("recall") then
		Necrosis:Recall()
	elseif arg1:lower():find("reset") and not InCombatLockdown() then
		NecrosisConfig = {}
		ReloadUI()
	elseif arg1:lower():find("glasofruix") then
		NecrosisConfig.Smooth = not NecrosisConfig.Smooth
		Necrosis.Chat:_Msg("SpellTimer smoothing  : <lightBlue>Toggled")
	else
		Necrosis.Gui.MainWindow:Show()
	end
end

