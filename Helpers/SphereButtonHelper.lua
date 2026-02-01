SphereButtonHelper = {
    States = {
        Bloque = "Bloque",
        Ferme = "Ferme",
        Ouvert = "Ouvert",
        ClicDroit = "ClicDroit",
        Combat = "Combat",
        Refresh = "Refresh"
    }
}

local _sbh = SphereButtonHelper

function _sbh:SoulstoneUpdateAttribute(nostone)
	if Necrosis.Debug.buttons then
		_G["DEFAULT_CHAT_FRAME"]:AddMessage("SoulstoneUpdateAttribute"
		.." a'"..(tostring(nostone) or "nyl")..'"'
		.." s'"..(tostring(BagHelper.Soulstone_Name))..'"'
		.." f'"..(tostring(Necrosis.Warlock_Buttons.soul_stone.f))..'"'
		.." '"..(str)..'"'
		)
	end

	local f = _G[Necrosis.Warlock_Buttons.soul_stone.f]
	if not f then
		return
	end
	if Necrosis.IsSpellKnown("soulstone") then
		local str = ""
		-- R click to create; will cause an error if one is in bags
--		f:SetAttribute("type2", "macro")
--		str = "/cast Create "..L["SOUL_STONE"] -- 
		f:SetAttribute("type2", "spell") -- 51
		str = Necrosis.GetSpellCastName("soulstone")
		f:SetAttribute("spell2", str)
		-- Use all possible Soulstones. Modifying the button use during combat is forbidden.
		f:SetAttribute("type1", "macro")
		f:SetAttribute("type3", "macro")
		local useSoulstoneMacro = ""
		for i,id in ipairs(ItemHelper.Soulstone.ItemIds) do
			useSoulstoneMacro = "/use item:"..tostring(id).."\n"..useSoulstoneMacro
		end
		f:SetAttribute("macrotext", useSoulstoneMacro)
		
		-- if the 'Ritual of Summoning' spell is known, then associate it to the soulstone icon as shift-click.
		if Necrosis.IsSpellKnown("summoning") then
			f:SetAttribute("shift-type*", "spell")
			f:SetAttribute("shift-spell*", 
			Necrosis.GetSpellCastName("summoning")) 
		end
	end
end

function _sbh:FirestoneUpdateAttribute(nostone)
	local f = _G[Necrosis.Warlock_Buttons.fire_stone.f]
	if not f then
		return
	end

	if Necrosis.Debug.buttons then
		_G["DEFAULT_CHAT_FRAME"]:AddMessage("FirestoneUpdateAttribute"
		.." a'"..(tostring(nostone) or "nyl")..'"'
		.." s'"..(BagHelper.Firestone_Name or "nyl")..'"'
		)
	end

	-- If the warlock doesn't have a stone in their inventory,
	-- Left click creates the stone
	if nostone then
		local spellName = Necrosis.GetSpellCastName("firestone")
		f:SetAttribute("type1", "spell")
		f:SetAttribute("spell1", spellName) 
	else
		f:SetAttribute("type1", "item")
		f:SetAttribute("item1", BagHelper.Firestone_Name)
	end
end

function _sbh:SpellstoneUpdateAttribute(nostone)
	local f = _G[Necrosis.Warlock_Buttons.spell_stone.f]
	if not f then
		return
	end

	if Necrosis.Debug.buttons then
		_G["DEFAULT_CHAT_FRAME"]:AddMessage("SpellstoneUpdateAttribute"
		.." a'"..(tostring(nostone) or "nyl")..'"'
		.." s'"..(BagHelper.Spellstone_Name or "nyl")..'"'
		)
	end

	-- If the warlock doesn't have a stone in their inventory,
	-- Left click creates the stone
	if nostone then
		local spellName = Necrosis.GetSpellCastName("spellstone")
		f:SetAttribute("type1", "spell")
		f:SetAttribute("spell1", spellName) 
	else
		f:SetAttribute("type1", "item")
		f:SetAttribute("item1", BagHelper.Spellstone_Name)
	end
end

function _sbh:HealthstoneUpdateAttribute(nostone)
	local f = _G[Necrosis.Warlock_Buttons.health_stone.f]
	if not f then
		return
	end

	if Necrosis.Debug.buttons then
		_G["DEFAULT_CHAT_FRAME"]:AddMessage("HealthstoneUpdateAttribute"
		.." a'"..(tostring(nostone) or "nyl")..'"'
		.." s'"..(BagHelper.Healthstone_Name or "nyl")..'"'
		)
	end

	-- If the warlock doesn't have a stone in their inventory,
	-- Left click creates the stone
	if nostone then
		local spellName = Necrosis.GetSpellCastName("healthstone")
		f:SetAttribute("type1", "spell")
		f:SetAttribute("spell1", spellName) 
	else
		-- Use all available healthstones
		local useHealthstoneMacro = ""
		for i,id in ipairs(ItemHelper.Healthstone.ItemIds) do
			useHealthstoneMacro = "/use item:"..tostring(id).."\n"..useHealthstoneMacro
		end
		f:SetAttribute("type1", "macro")
		f:SetAttribute("macrotext1", "/stopcasting\n"..useHealthstoneMacro)

		f:SetAttribute("type3", "Trade")
		f:SetAttribute("ctrl-type1", "Trade")
		f.Trade = function () Necrosis:TradeStone() end
	end
	
	-- Shift+click for Ritual of Summoning and/or Ritual of Souls
	local ritualMacro = ""
	if Necrosis.IsSpellKnown("summoning") then
		local summoningSpell = Necrosis.GetSpellCastName("summoning")
		ritualMacro = "/cast "..summoningSpell.."\n"
	end
	if Necrosis.IsSpellKnown("ritual_souls") then
		local soulsSpell = Necrosis.GetSpellCastName("ritual_souls")
		ritualMacro = ritualMacro.."/cast "..soulsSpell
	end
	if ritualMacro ~= "" then
		f:SetAttribute("shift-type1", "macro")
		f:SetAttribute("shift-macrotext1", ritualMacro)
	end
end


------------------------------------------------------------------------------------------------------
-- MENU BUTTONS
------------------------------------------------------------------------------------------------------
-- Create a Menu (Open/Close) button
function _sbh:CreateMenuButton(warlockButton)
	local frame = CreateFrame("Button", warlockButton.f, UIParent, "SecureHandlerAttributeTemplate,SecureHandlerClickTemplate,SecureHandlerEnterLeaveTemplate")

	if Necrosis.Debug.buttons then
		_G["DEFAULT_CHAT_FRAME"]:AddMessage("CreateMenuButton"
		.." i'"..tostring(warlockButton).."'"
		.." b'"..tostring(warlockButton.f).."'"
		--.." tn'"..tostring(b.norm).."'"
		--.." th'"..tostring(b.high).."'"
		)
	end

	-- Define its attributes || Définition de ses attributs
	frame:SetMovable(true)
	frame:EnableMouse(true)
	frame:SetWidth(34)
	frame:SetHeight(34)
	frame:SetNormalTexture(warlockButton.norm) 
	frame:SetHighlightTexture(warlockButton.high) 
	frame:RegisterForDrag("LeftButton")
	frame:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	frame:Show()

	-- Edit the scripts associated with the button
	frame:SetScript("OnEnter", function(self) Necrosis:BuildButtonTooltip(self) end)
	frame:SetScript("OnLeave", function() GameTooltip:Hide() end)
	-- OnMouseUp removed - it interferes with SecureActionButton spell casting
	frame:SetScript("OnDragStart", function(self)
		if not NecrosisConfig.NecrosisLockServ then
			Necrosis:OnDragStart(self)
		end
	end)
	frame:SetScript("OnDragStop", function(self) Necrosis:OnDragStop(self) end)

	-- Place the button window at its saved location
	if not NecrosisConfig.NecrosisLockServ then
		frame:ClearAllPoints()
		frame:SetPoint(
			NecrosisConfig.FramePosition[frame:GetName()][1],
			NecrosisConfig.FramePosition[frame:GetName()][2],
			NecrosisConfig.FramePosition[frame:GetName()][3],
			NecrosisConfig.FramePosition[frame:GetName()][4],
			NecrosisConfig.FramePosition[frame:GetName()][5]
		)
	end

	return frame
end


------------------------------------------------------------------------------------------------------
-- BUTTONS for stones (health / spell / Fire), and the Mount
------------------------------------------------------------------------------------------------------
-- Create the stone button
function _sbh:CreateStoneButton(warlockButton)
	local frame = CreateFrame("Button", warlockButton.f, UIParent, "SecureActionButtonTemplate")

	-- Define its attributes
	frame:SetMovable(true)
	frame:EnableMouse(true)
	frame:SetWidth(34)
	frame:SetHeight(34)
	frame:SetNormalTexture(warlockButton.norm) --("Interface\\AddOns\\Necrosis-Classic\\UI\\"..stone.."Button-01")
	frame:SetHighlightTexture(warlockButton.high) --("Interface\\AddOns\\Necrosis-Classic\\UI\\"..stone.."Button-0"..num)
	frame:RegisterForDrag("LeftButton")
	frame:RegisterForClicks("AnyUp", "AnyDown")
	frame:Show()


	-- Edit the scripts associated with the buttons
	frame:SetScript("OnEnter", function(self) Necrosis:BuildButtonTooltip(self) end)
--	frame:SetScript("OnEnter", function(self) Necrosis:BuildTooltip(self, stone, "ANCHOR_LEFT") end)
	frame:SetScript("OnLeave", function() GameTooltip:Hide() end)
	-- OnMouseUp removed - it interferes with SecureActionButton spell casting
	frame:SetScript("OnDragStart", function(self)
		if not NecrosisConfig.NecrosisLockServ then
			Necrosis:OnDragStart(self)
		end
	end)
	frame:SetScript("OnDragStop", function(self) Necrosis:OnDragStop(self) end)

	-- -- Attributes specific to the soulstone button
	-- -- if there are no restrictions while in combat, then allow the stone to be cast
	-- if warlockButton == Necrosis.Warlock_Buttons.soul_stone.f then
	-- 	frame:SetScript("PreClick", function(self)
	-- 		if (not UnitIsFriend("player","target")) then
	-- 			self:SetAttribute("unit", "player")
	-- 		end
	-- 	end)
	-- 	frame:SetScript("PostClick", function(self)
	-- 		self:SetAttribute("unit", "target")
	-- 	end)
	-- end

	-- Create a place for text
	-- Create the soulshard counter
	local FontString = _G[warlockButton.f.."Text"]
	if not FontString then
		FontString = frame:CreateFontString(warlockButton.f, nil, "GameFontNormal")
	end

	-- Hidden but very useful...
	frame.high_of = warlockButton
	frame.font_string = FontString

	-- Define its attributes
	FontString:SetText("") -- blank for now
	FontString:SetPoint("CENTER")

	-- Place the button window at its saved location
	if not NecrosisConfig.NecrosisLockServ then
		frame:ClearAllPoints()
		frame:SetPoint(
			NecrosisConfig.FramePosition[frame:GetName()][1],
			NecrosisConfig.FramePosition[frame:GetName()][2],
			NecrosisConfig.FramePosition[frame:GetName()][3],
			NecrosisConfig.FramePosition[frame:GetName()][4],
			NecrosisConfig.FramePosition[frame:GetName()][5]
		)
	end

	return frame
end
