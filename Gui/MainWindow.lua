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


Necrosis.Gui.MainWindow = {
	CurrentPanelId = 1,
	Frame = false,
	bgIcon = false,
	bgTopLeft = false,
	bgTopRight = false,
	bgBottomLeft = false,
	bgBottomRight = false,
	fsTitle = false,
	fsCredits = false,
	fsTabTitle = false,
	btnClose = false,
	TabTable = {
		[1] = { view = Necrosis.Gui.MessagesView, 	texture = "Ability_Creature_Cursed_03"	},
		[2] = { view = Necrosis.Gui.SphereView,		texture = "INV_Misc_Gem_Amethyst_02"	},
		[3] = { view = Necrosis.Gui.ButtonsView,	texture = "Trade_Engineering"			},
		[4] = { view = Necrosis.Gui.MenusView,		texture = "INV_Wand_1H_Stratholme_D_02"	},
		[5] = { view = Necrosis.Gui.TimersView, 	texture = "Spell_Nature_TimeStop"		},
		[6] = { view = Necrosis.Gui.MiscView,		texture = "Ability_Creature_Disease_05"	}
	}
}

local _mw = Necrosis.Gui.MainWindow

function _mw.UpdateTexts()
	_mw.fsTabTitle:SetText(Necrosis.Config.Panel[_mw.CurrentPanelId])
end

-- Opening the options menu framework
function _mw:Show()
	-- If the window doesn't exist, create it
	if not self.Frame then
		-- Help messages are displayed
		if Necrosis.ChatMessage.Help[1] then
			for i = 1, #Necrosis.ChatMessage.Help, 1 do
				Necrosis.Chat:_Msg(Necrosis.ChatMessage.Help[i], "USER")
			end
		end

		self.Frame = GraphicsHelper:CreateMovableDialog("NecrosisGeneralFrame", 402, 428)
		if (not GraphicsHelper:LoadPosition(self.Frame)) then
			self.Frame:SetPoint("TOPLEFT", 100, -100)
		end

		self.bgIcon = GraphicsHelper:CreateTexture(
			self.Frame, "BACKGROUND",
			62, 62,
			GraphicsHelper:GetWoWTexture("Spellbook", "Spellbook-Icon"),
			"TOPLEFT",
			10, -8
		)

		-- Frame textures
		self.bgTopLeft = GraphicsHelper:CreateTexture(
			self.Frame, "BORDER",
			280, 280,
			GraphicsHelper:GetWoWTexture("PaperDollInfoFrame", "UI-Character-General-TopLeft"),
			"TOPLEFT",
			0, 0
		)

		self.bgTopRight = GraphicsHelper:CreateTexture(
			self.Frame, "BORDER",
			280, 148,
			GraphicsHelper:GetWoWTexture("PaperDollInfoFrame", "UI-Character-General-TopRight"),
			"TOPRIGHT",
			0, 0
		)

		self.bgBottomLeft = GraphicsHelper:CreateTexture(
			self.Frame, "BORDER",
			280, 280,
			GraphicsHelper:GetWoWTexture("PaperDollInfoFrame", "UI-Character-General-BottomLeft"),
			"BOTTOMLEFT",
			0, -105
		)

		self.bgBottomRight = GraphicsHelper:CreateTexture(
			self.Frame, "BORDER",
			280, 148,
			GraphicsHelper:GetWoWTexture("PaperDollInfoFrame", "UI-Character-General-BottomRight"),
			"BOTTOMRIGHT",
			0, -105
		)

		-- Text of the title
		self.fsTitle = GraphicsHelper:CreateFontString(
			self.Frame,
			Necrosis.Data.Label,
			"TOP",
			0, -21
		)
		self.fsTitle:SetTextColor(1, 0.8, 0)

		-- Credits
		self.fsCredits = GraphicsHelper:CreateFontString(
			self.Frame,
			"Developed by Lom Enfroy part of Necrosis LdC",
			"TOP",
			0, -44
		)
		self.fsCredits:SetTextColor(1, 0.8, 0)

		-- Section title at the top of the page
		self.fsTabTitle = GraphicsHelper:CreateFontString(
			self.Frame,
			nil,
			"TOP",
			0, -62
		)

		-- Window closing button
		self.btnClose = CreateFrame("Button", nil, self.Frame, "UIPanelCloseButton")
		self.btnClose:SetWidth(34)
		self.btnClose:SetHeight(34)
		self.btnClose:ClearAllPoints()
		self.btnClose:SetPoint("CENTER", "NecrosisGeneralFrame", "TOPRIGHT", -53, -27)

		-- Create Tabs on the right side
		for i,item in ipairs(self.TabTable) do
			local tab = CreateFrame("CheckButton", nil, self.Frame)
			tab:SetWidth(32)
			tab:SetHeight(32)
			tab:Show()
			tab:ClearAllPoints()
			tab:SetPoint("TOPRIGHT", -8, -30 - (i * 50))

			tab:SetScript("OnEnter",
				function(self)
					GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
					GameTooltip:SetText(Necrosis.Config.Panel[i])
				end
			)
			tab:SetScript("OnLeave", function() GameTooltip:Hide() end)
			tab:SetScript("OnClick", function() self:SetPanel(i) end)

			local txTab = GraphicsHelper:CreateTexture(
				tab, "BACKGROUND",
				64, 64,
				GraphicsHelper:GetWoWTexture("SpellBook", "SpellBook-SkillLineTab"),
				"TOPLEFT",
				-3, 11
			)

			tab:SetNormalTexture(GraphicsHelper:GetWoWTexture("Icons", item.texture))
			tab:SetHighlightTexture(GraphicsHelper:GetWoWTexture("Buttons", "ButtonHilight-Square"))
			tab:GetHighlightTexture():SetBlendMode("ADD")
			tab:SetCheckedTexture(GraphicsHelper:GetWoWTexture("Buttons", "CheckButtonHilight"))
			tab:GetCheckedTexture():SetBlendMode("ADD")

			-- Save the tab in the TabTable
			item.tab = tab
		end

		self:SetPanel(1)

		-- Register handler to update texts when language changes
		EventHelper:RegisterLanguageChangedHandler(_mw.UpdateTexts)
		-- Make it closable by hitting escape
		tinsert(UISpecialFrames, self.Frame:GetName())
	end

	self.Frame:Show()
end


------------------------------------------------------------------------------------------------------
-- FONCTIONS LIÉES AU PANNEAU DE CONFIGURATION
------------------------------------------------------------------------------------------------------

-- Function to display different pages of the control panel || Fonction permettant l'affichage des différentes pages du panneau de configuration
function _mw:SetPanel(panelIndex)
	_mw.CurrentPanelId = panelIndex
	for index=1, #self.TabTable, 1 do
		local item = self.TabTable[index]
		if index == panelIndex then
			item.tab:SetChecked(1)
			item.view:Show()
			self.fsTabTitle:SetText(Necrosis.Config.Panel[index])
		else
			item.tab:SetChecked(nil)
			item.view:Hide()
		end
	end
end
