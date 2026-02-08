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
-- CREATION OF THE OPTIONS FRAME
------------------------------------------------------------------------------------------------------

Necrosis.Gui.TimersView = {
	Frame = false,
	-- cbEnableTimers = false,
	cbTimersGrowUpwards = false,
	cbTimersOnLeftSide = false
}

local _tv = Necrosis.Gui.TimersView

function _tv:cbLockTimers_Click()
	if (self:GetChecked()) then
		Necrosis.Timers:HideMobAnchor()
		Necrosis.Timers:HideSingleAnchor()
	else
		Necrosis.Timers:ShowMobAnchor()
		Necrosis.Timers:ShowSingleAnchor()
	end
end

-- function _tv:cbEnableTimers_Click()
-- 	NecrosisConfig.ShowSpellTimers = self:GetChecked()
-- 	-- if NecrosisConfig.ShowSpellTimers then
-- 	-- 	NecrosisSpellTimerButton:Show()
-- 	-- else
-- 	-- 	NecrosisSpellTimerButton:Hide()
-- 	-- end
-- end

function _tv:cbEnableTimerBars_Click()
	NecrosisConfig.EnableTimerBars = self:GetChecked()
	if (NecrosisConfig.EnableTimerBars) then
		Necrosis.Timers:Initialize()
	else
		Necrosis.Timers:Disable()
	end
end

function _tv:cbTimersOnLeftSide_Click()
	Necrosis:SymetrieTimer(self:GetChecked())
end

function _tv:cbTimersGrowUpwards_Click()
	if (self:GetChecked()) then
		NecrosisConfig.SensListe = -1
	else
		NecrosisConfig.SensListe = 1
	end
end

function _tv.ddTimerFont_Init(dd)
	for i,font in ipairs(Necrosis.Config.Fonts) do
		UIDropDownMenu_AddButton({
			text = font.Name,
			value = font,
			checked = false,
			func = _tv.ddTimerFont_Click,
			arg1 = dd
		})
		if (font.Name == NecrosisConfig.TimerFont.Name) then
			UIDropDownMenu_SetSelectedValue(dd, font)
			UIDropDownMenu_SetText(dd, font.Name)
		end
	end
end

function _tv.ddTimerFont_Click(item, dd)
	UIDropDownMenu_SetSelectedValue(dd, item.value)
	NecrosisConfig.TimerFont = item.value
	Necrosis.Timers:SetFont(item.value.Path, NecrosisConfig.TimerFontSize)
end

function _tv.ddTimerFontSize_Init(dd)
	for i = 6,30,1 do
		UIDropDownMenu_AddButton({
			text = i,
			value = i,
			checked = false,
			func = _tv.ddTimerFontSize_Click,
			arg1 = dd
		})
		if (i == NecrosisConfig.TimerFontSize) then
			UIDropDownMenu_SetSelectedValue(dd, i)
			UIDropDownMenu_SetText(dd, i)
		end
	end
end

function _tv.ddTimerFontSize_Click(item, dd)
	UIDropDownMenu_SetSelectedValue(dd, item.value)
	NecrosisConfig.TimerFontSize = item.value
	Necrosis.Timers:SetFont(NecrosisConfig.TimerFont.Path, item.value)
end

function _tv.DisableTimers()
	_tv.cbTimersGrowUpwards:Disable()
	_tv.cbTimersOnLeftSide:Disable()
	if _G["NecrosisListSpells"] then NecrosisListSpells:SetText("") end
	local index = 1
	while _G["NecrosisTimerFrame"..index] do
		_G["NecrosisTimerFrame"..index]:Hide()
		index = index + 1
	end
end

function _tv.EnableTextualTimers()
	_tv.cbTimersGrowUpwards:Disable()
	_tv.cbTimersOnLeftSide:Enable()
	local index = 1
	while _G["NecrosisTimerFrame"..index] do
		_G["NecrosisTimerFrame"..index]:Hide()
		index = index + 1
	end
end

function _tv.EnableGraphicalTimers()
	_tv.cbTimersGrowUpwards:Enable()
	_tv.cbTimersOnLeftSide:Enable()
	if _G["NecrosisListSpells"] then NecrosisListSpells:SetText("") end
end

function _tv.UpdateTexts()
	-- _tv.cbEnableTimers:SetText(Necrosis.Config.Timers["Afficher le bouton des timers"])
	_tv.cbTimersGrowUpwards:SetText(Necrosis.Config.Timers["Afficher les timers de bas en haut"])
	_tv.cbTimersOnLeftSide:SetText(Necrosis.Config.Timers["Afficher les timers sur la gauche du bouton"])
end


function _tv:Show()
	if not self.Frame then
		-- Création de la fenêtre
		self.Frame = GraphicsHelper:CreateDialog(NecrosisGeneralFrame)

		self.cbLockTimers = GraphicsHelper:CreateCheckButton(
			self.Frame,
			"Lock timers",
			0, -18,
			self.cbLockTimers_Click
		)
		self.cbLockTimers:SetChecked(true)

		-- -- Affiche ou masque le bouton des timers
		-- self.cbEnableTimers = GraphicsHelper:CreateCheckButton(
		-- 	self.Frame,
		-- 	Necrosis.Config.Timers["Afficher le bouton des timers"],
		-- 	0, -40,
		-- 	self.cbEnableTimers_Click
		-- )
		-- self.cbEnableTimers:SetChecked(NecrosisConfig.ShowSpellTimers)

		-- Affiche ou masque le bouton des timers
		self.cbEnableTimerBars = GraphicsHelper:CreateCheckButton(
			self.Frame,
			"Enable timer bars",
			0, -66,
			self.cbEnableTimerBars_Click
		)
		self.cbEnableTimerBars:SetChecked(NecrosisConfig.EnableTimerBars)

		-- Affiche les timers sur la gauche du bouton
		self.cbTimersOnLeftSide = GraphicsHelper:CreateCheckButton(
			self.Frame,
			Necrosis.Config.Timers["Afficher les timers sur la gauche du bouton"],
			0, -88,
			self.cbTimersOnLeftSide_Click
		)
		self.cbTimersOnLeftSide:SetChecked(NecrosisConfig.SpellTimerPos == -1)

		-- Affiche les timers de bas en haut
		self.cbTimersGrowUpwards = GraphicsHelper:CreateCheckButton(
			self.Frame,
			Necrosis.Config.Timers["Afficher les timers de bas en haut"],
			0, -110,
			self.cbTimersGrowUpwards_Click
		)
		self.cbTimersGrowUpwards:SetChecked(NecrosisConfig.SensListe == -1)

		-- Handler to update texts when language changes
		EventHelper:RegisterLanguageChangedHandler(self.UpdateTexts)

		-- Timer font
		self.ddTimerFont, self.lblTimerFont = GraphicsHelper:CreateDropDown(
			self.Frame,
			"Font",
			0, -132,
			self.ddTimerFont_Init
		)
	
		-- Timer font size
		self.ddTimerFontSize, self.lblTimerFontSize = GraphicsHelper:CreateDropDown(
			self.Frame,
			"Font Size",
			0, -154,
			self.ddTimerFontSize_Init
		)
	
		self.btnTestTimer = GraphicsHelper:CreateButton(
			self.Frame,
			"Test Soulstone",
			-200, -230,
			function(self)
				local spellId = 20765
			-- Use player as target if no target exists
			local targetGuid = UnitGUID("target") or Necrosis.CurrentEnv.PlayerGuid
			local targetName = UnitName("target") or Necrosis.CurrentEnv.PlayerName
			Necrosis.Timers:InsertSpellTimer(
				Necrosis.CurrentEnv.PlayerGuid,
				Necrosis.CurrentEnv.PlayerName,
				targetGuid, targetName, 0, 0,
					spellId,
					GetSpellInfo(spellId),
					Necrosis.Spell.AuraDuration[spellId],
					Necrosis.Spell.AuraType[spellId]
				)
			end
		)
		self.btnTestTimer:SetWidth(100)
		
		self.btnTestTimerBanish = GraphicsHelper:CreateButton(
			self.Frame,
			"Test Banish",
			-200, -258,
			function(self)
				local spellId = 18647
				Necrosis.Timers:InsertSpellTimer(
					Necrosis.CurrentEnv.PlayerGuid,
					Necrosis.CurrentEnv.PlayerName,
					UnitGUID("target"), UnitName("target"), 0, 0,
					spellId,
					GetSpellInfo(spellId),
					Necrosis.Spell.AuraDuration[spellId],
					Necrosis.Spell.AuraType[spellId]
				)
			end
		)
		self.btnTestTimerBanish:SetWidth(100)

		self.btnTestCorruptionBanish = GraphicsHelper:CreateButton(
			self.Frame,
			"Test Corruption",
			-200, -286,
			function(self)
				local spellId = 11672
				Necrosis.Timers:InsertSpellTimer(
					Necrosis.CurrentEnv.PlayerGuid,
					Necrosis.CurrentEnv.PlayerName,
					UnitGUID("target"), UnitName("target"), 0, nil,
					spellId,
					GetSpellInfo(spellId),
					Necrosis.Spell.AuraDuration[spellId],
					Necrosis.Spell.AuraType[spellId]
				)
			end
		)
		self.btnTestCorruptionBanish:SetWidth(100)

		self.btnClearTimer = GraphicsHelper:CreateButton(
			self.Frame,
			"Clear timer",
			-90, -230,
			function(self)
				Necrosis.Timers:RemoveAllTimers()
			end
		)
		self.btnClearTimer:SetWidth(100)

		self.btnKillSoulstoneTimer = GraphicsHelper:CreateButton(
			self.Frame,
			"Kill Target",
			-90, -258,
			function(self)
				Necrosis.Timers:RemoveSpellTimerTarget(UnitGUID("target"))
			end
		)
		self.btnKillSoulstoneTimer:SetWidth(100)
		
		self.btnTestTimerSSRemote = GraphicsHelper:CreateButton(
			self.Frame,
			"Test SS Remote",
			-90, -286,
			function(self)
				local spellId = 20765
				local spellName = GetSpellInfo(spellId)
				EventHelper:SendAddonMessage("InsertTimer~"
					..tostring(12345).."|"
					..tostring("Testman").."|"
					..tostring(UnitGUID("target")).."|"
					..tostring(UnitName("target")).."|"
					..tostring(0).."|"
					..tostring(nil).."|"
					..tostring(spellId).."|"
					..tostring(spellName).."|"
					..tostring(Necrosis.Spell.AuraDuration[spellId]).."|"
					..tostring(Necrosis.Spell.AuraType[spellId])
				)
				-- Necrosis.Timers:InsertSpellTimer(
				-- 	"12345",
				-- 	"Testman",
				-- 	-- Necrosis.CurrentEnv.PlayerGuid,
				-- 	-- Necrosis.CurrentEnv.PlayerName,
				-- 	UnitGUID("target"), UnitName("target"), 0, 0,
				-- 	spellId,
				-- 	GetSpellInfo(spellId),
				-- 	Necrosis.Spell.AuraDuration[spellId],
				-- 	Necrosis.Spell.AuraType[spellId]
				-- )
			end
		)
		self.btnTestTimerSSRemote:SetWidth(100)
	end

	self.Frame:Show()
end

function _tv:Hide()
	if self.Frame then
		HideUIPanel(self.Frame)
	end
end
