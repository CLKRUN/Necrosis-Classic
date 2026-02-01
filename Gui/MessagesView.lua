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
-- CREATING THE OPTIONS FRAME
------------------------------------------------------------------------------------------------------

Necrosis.Gui.MessagesView = {
	Frame = false,
	
	ddLanguage = false,
	cbShowTooltip = false,
	cbChatType = false,
	cbSpeech = false,
	cbShortMessages = false,
	cbDemonMessages = false,
	cbMountMessages = false,
	cbRoSMessages = false,
	cbDemonicSacrifice = false,
	cbSound = false,
	cbAntiFearAlert = false,
	cbBanishAlert = false,
	cbTranceAlert = false
}

-- Use a local variable for easier referencing
local _mv = Necrosis.Gui.MessagesView

-- Handler to initialize language dropdown
function _mv.LanguageDropDownInit(dd)
    UIDropDownMenu_Initialize(dd, _mv._LanguageDropDownInit)
end

-- Add items to the dropdown
function _mv._LanguageDropDownInit(dd, level, menulist)
    if not Localization.Languages then
        print("Necrosis: Error - Localization.Languages is nil")
        return
    end
    
    for i, v in pairs(Localization.Languages) do
        UIDropDownMenu_AddButton({
            text = v.lang,
            value = v.code,
            checked = false,
            func = _mv._LanuageDropDownItemClick,
            -- arg1 and arg2 can be used to pass any extra argument to the button
            arg1 = dd,
            arg2 = v.init
        })

        if v.code == NecrosisConfig.Language then
            UIDropDownMenu_SetSelectedValue(dd, v.code)
        end
    end
end

-- Handler when language in dropdown is clicked
-- dd is arg1, initFunc is arg2
function _mv._LanuageDropDownItemClick(item, dd, initFunc)
    UIDropDownMenu_SetSelectedValue(dd, item.value)
    initFunc()
    EventHelper:OnLanguageChangedEvent(item.value)
end

function _mv:cbShowTooltip_Click()
	NecrosisConfig.NecrosisToolTip = self:GetChecked()
end

function _mv:cbChatType_Click()
	NecrosisConfig.ChatType = not self:GetChecked()
	Necrosis.Chat:_Msg(Necrosis.Config.Messages.Position)
end

function _mv:cbSpeech_Click()
	NecrosisConfig.ChatMsg = self:GetChecked()
	if NecrosisConfig.ChatMsg then
		_mv:EnableMessages()
	else
		_mv:DisableMessages()
	end
end

function _mv:cbShortMessages_Click()
	NecrosisConfig.SM = self:GetChecked()
end

function _mv:cbDemonMessages_Click()
	NecrosisConfig.DemonSummon = self:GetChecked()
end

function _mv:cbMountMessages_Click()
	NecrosisConfig.SteedSummon = self:GetChecked()
end

function _mv:cbRoSMessages_Click()
	NecrosisConfig.RoSSummon = self:GetChecked()
end

function _mv:cbDemonicSacrifice_Click()
	NecrosisConfig.DemonicSacrifice = self:GetChecked()
end

function _mv:cbSound_Click()
	NecrosisConfig.Sound = self:GetChecked()
end

function _mv:cbBanishAlert_Click()
	NecrosisConfig.BanishAlert = self:GetChecked()
end

function _mv:cbAntiFearAlert_Click()
	NecrosisConfig.AntiFearAlert = self:GetChecked()
end

function _mv:cbTranceAlert_Click()
	NecrosisConfig.ShadowTranceAlert = self:GetChecked()
end

function _mv:DisableMessages()
	self.cbShortMessages:Disable()
	self.cbDemonMessages:Disable()
	self.cbMountMessages:Disable()
	self.cbRoSMessages:Disable()
	self.cbDemonicSacrifice:Disable()
end

function _mv:EnableMessages()
	self.cbShortMessages:Enable()
	self.cbDemonMessages:Enable()
	self.cbMountMessages:Enable()
	self.cbRoSMessages:Enable()
	self.cbDemonicSacrifice:Enable()
end

-- Handler to update texts when language changes
function _mv.UpdateTexts()
    _mv.cbShowTooltip:SetText(Necrosis.Config.Messages["Afficher les bulles d'aide"])
    _mv.cbChatType:SetText(Necrosis.Config.Messages["Afficher les messages dans la zone systeme"])
    _mv.cbSpeech:SetText(Necrosis.Config.Messages["Activer les messages aleatoires de TP et de Rez"])
    _mv.cbShortMessages:SetText(Necrosis.Config.Messages["Utiliser des messages courts"])
    _mv.cbDemonMessages:SetText(Necrosis.Config.Messages["Activer egalement les messages pour les Demons"])
    _mv.cbMountMessages:SetText(Necrosis.Config.Messages["Activer egalement les messages pour les Montures"])
    _mv.cbRoSMessages:SetText(Necrosis.Config.Messages["Activer egalement les messages pour le Rituel des ames"])
    _mv.cbDemonicSacrifice:SetText(Necrosis.Config.Messages["DemonicSacrifice"])
    _mv.cbSound:SetText(Necrosis.Config.Messages["Activer les sons"])
    _mv.cbAntiFearAlert:SetText(Necrosis.Config.Messages["Alerter quand la cible est insensible a la peur"])
    _mv.cbBanishAlert:SetText(Necrosis.Config.Messages["Alerter quand la cible peut etre banie ou asservie"])
    _mv.cbTranceAlert:SetText(Necrosis.Config.Messages["M'alerter quand j'entre en Transe"])
end

function _mv:Show()
	-- Check if the frame has been initialized before
	if not self.Frame then
		-- Create the window
		self.Frame = GraphicsHelper:CreateDialog(NecrosisGeneralFrame)

		-- Language selection
		self.ddLanguage, self.lblLanguage =
			GraphicsHelper:CreateDropDown(
				self.Frame,
				"Langue / Language / Sprache",
				0, 0,
				self.LanguageDropDownInit
			)

		-- Turn on help bubbles
		self.cbShowTooltip =
			GraphicsHelper:CreateCheckButton(
				self.Frame,
				Necrosis.Config.Messages["Afficher les bulles d'aide"],
				0, -28,
				self.cbShowTooltip_Click
			)
		self.cbShowTooltip:SetChecked(NecrosisConfig.NecrosisToolTip)

		-- Move messages to the system area
		self.cbChatType =
			GraphicsHelper:CreateCheckButton(
				self.Frame,
				Necrosis.Config.Messages["Afficher les messages dans la zone systeme"],
				0, -50,
				self.cbChatType_Click
			)
		self.cbChatType:SetChecked(not NecrosisConfig.ChatType)

		-- Activate TP and Rez messages
		self.cbSpeech =
			GraphicsHelper:CreateCheckButton(
				self.Frame,
				Necrosis.Config.Messages["Activer les messages aleatoires de TP et de Rez"],
				0, -72,
				self.cbSpeech_Click
			)
		self.cbSpeech:SetChecked(NecrosisConfig.ChatMsg)

		-- Activate short messages
		self.cbShortMessages =
			GraphicsHelper:CreateCheckButton(
				self.Frame,
				Necrosis.Config.Messages["Utiliser des messages courts"],
				20, -94,
				self.cbShortMessages_Click
			)
		self.cbShortMessages:SetChecked(NecrosisConfig.SM)

		-- Activate demon messages
		self.cbDemonMessages =
			GraphicsHelper:CreateCheckButton(
				self.Frame,
				Necrosis.Config.Messages["Activer egalement les messages pour les Demons"],
				20, -116,
				self.cbDemonMessages_Click
			)
		self.cbDemonMessages:SetChecked(NecrosisConfig.DemonSummon)

		-- Activate mount messages
		self.cbMountMessages =
			GraphicsHelper:CreateCheckButton(
				self.Frame,
				Necrosis.Config.Messages["Activer egalement les messages pour les Montures"],
				20, -138,
				self.cbMountMessages_Click
			)
		self.cbMountMessages:SetChecked(NecrosisConfig.SteedSummon)

		-- Activate Ritual of Souls speech button -Draven (April 3rd, 2008)
		self.cbRoSMessages =
			GraphicsHelper:CreateCheckButton(
				self.Frame,
				Necrosis.Config.Messages["Activer egalement les messages pour le Rituel des ames"],
				20, -160,
				self.cbRoSMessages_Click
			)
		self.cbRoSMessages:SetChecked(NecrosisConfig.RoSSummon)

		-- Demonic Sacrifice messages
		self.cbDemonicSacrifice =
			GraphicsHelper:CreateCheckButton(
				self.Frame,
				Necrosis.Config.Messages["DemonicSacrifice"],
				20, -182,
				self.cbDemonicSacrifice_Click
			)
		self.cbDemonicSacrifice:SetChecked(NecrosisConfig.DemonicSacrifice)

		-- Sound alerts
		self.cbSound =
			GraphicsHelper:CreateCheckButton(
				self.Frame,
				Necrosis.Config.Messages["Activer les sons"],
				0, -204,
				self.cbSound_Click
			)
		self.cbSound:SetChecked(NecrosisConfig.Sound)

		-- Antifear alerts
		self.cbAntiFearAlert =
			GraphicsHelper:CreateCheckButton(
				self.Frame,
				Necrosis.Config.Messages["Alerter quand la cible est insensible a la peur"],
				0, -226,
				self.cbAntiFearAlert_Click
			)
		self.cbAntiFearAlert:SetChecked(NecrosisConfig.AntiFearAlert)

		-- Elemental / Demon Alerts
		self.cbBanishAlert =
			GraphicsHelper:CreateCheckButton(
				self.Frame,
				Necrosis.Config.Messages["Alerter quand la cible peut etre banie ou asservie"],
				0, -248,
				self.cbBanishAlert_Click
			)
		self.cbBanishAlert:SetChecked(NecrosisConfig.BanishAlert)

		-- Trance alerts
		self.cbTranceAlert =
			GraphicsHelper:CreateCheckButton(
				self.Frame,
				Necrosis.Config.Messages["M'alerter quand j'entre en Transe"],
				0, -270,
				self.cbTranceAlert_Click
			)
		self.cbTranceAlert:SetChecked(NecrosisConfig.ShadowTranceAlert)

		-- Handler to update texts when language changes
		EventHelper:RegisterLanguageChangedHandler(self.UpdateTexts)

		-- Apply initial configuration
		if not NecrosisConfig.ChatMsg then
			self:DisableMessages()
		else
			self:EnableMessages()
		end
	end

	self.Frame:Show()
end

function _mv:Hide()
	if self.Frame then
		HideUIPanel(self.Frame)
	end
end