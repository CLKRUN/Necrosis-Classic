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

	-- Si le démoniste n'a pas de pierre dans son inventaire,
	-- Un clic gauche crée la pierre
	if nostone then
		local spellId = Necrosis.GetSpellId and Necrosis.GetSpellId("firestone") or nil
		local spellName = Necrosis.GetSpellCastName("firestone")
		f:SetAttribute("type1", "spell") -- 54
		f:SetAttribute("spell*", spellId or spellName) 
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

	-- Si le démoniste n'a pas de pierre dans son inventaire,
	-- Un clic gauche crée la pierre
	if nostone then
		local spellId = Necrosis.GetSpellId and Necrosis.GetSpellId("spellstone") or nil
		local spellName = Necrosis.GetSpellCastName("spellstone")
		f:SetAttribute("type1", "spell") -- 53
		f:SetAttribute("spell*", spellId or spellName) 
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

	-- Si le démoniste n'a pas de pierre dans son inventaire,
	-- Un clic gauche crée la pierre
	if nostone then
		local spellId = Necrosis.GetSpellId and Necrosis.GetSpellId("healthstone") or nil
		local spellName = Necrosis.GetSpellCastName("healthstone")
		f:SetAttribute("type1", "spell") -- 52
		f:SetAttribute("spell1", spellId or spellName) 
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
end


------------------------------------------------------------------------------------------------------
-- MENU BUTTONS || BOUTONS DES MENUS
------------------------------------------------------------------------------------------------------
-- Create a Menu (Open/Close) button || Creaton du bouton d'ouverture du menu
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
	frame:RegisterForClicks("AnyUp")
	frame:Show()

	-- Edit the scripts associated with the button || Edition des scripts associés au bouton
	frame:SetScript("OnEnter", function(self) Necrosis:BuildButtonTooltip(self) end)
	frame:SetScript("OnLeave", function() GameTooltip:Hide() end)
	frame:SetScript("OnMouseUp", function(self) Necrosis:OnDragStop(self) end)
	frame:SetScript("OnDragStart", function(self)
		if not NecrosisConfig.NecrosisLockServ then
			Necrosis:OnDragStart(self)
		end
	end)
	frame:SetScript("OnDragStop", function(self) Necrosis:OnDragStop(self) end)

	-- Place the button window at its saved location || Placement de la fenêtre à l'endroit sauvegardé ou à l'emplacement par défaut
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
-- BUTTONS for stones (health / spell / Fire), and the Mount || BOUTON DES PIERRES, DE LA MONTURE
------------------------------------------------------------------------------------------------------
-- Create the stone button || Création du bouton de la pierre
function _sbh:CreateStoneButton(warlockButton)
	local frame = CreateFrame("Button", warlockButton.f, UIParent, "SecureActionButtonTemplate")

	-- Define its attributes || Définition de ses attributs
	frame:SetMovable(true)
	frame:EnableMouse(true)
	frame:SetWidth(34)
	frame:SetHeight(34)
	frame:SetNormalTexture(warlockButton.norm) --("Interface\\AddOns\\Necrosis-Classic\\UI\\"..stone.."Button-01")
	frame:SetHighlightTexture(warlockButton.high) --("Interface\\AddOns\\Necrosis-Classic\\UI\\"..stone.."Button-0"..num)
	frame:RegisterForDrag("LeftButton")
	frame:RegisterForClicks("AnyUp")
	frame:Show()


	-- Edit the scripts associated with the buttons || Edition des scripts associés au bouton
	frame:SetScript("OnEnter", function(self) Necrosis:BuildButtonTooltip(self) end)
--	frame:SetScript("OnEnter", function(self) Necrosis:BuildTooltip(self, stone, "ANCHOR_LEFT") end)
	frame:SetScript("OnLeave", function() GameTooltip:Hide() end)
	frame:SetScript("OnMouseUp", function(self) Necrosis:OnDragStop(self) end)
	frame:SetScript("OnDragStart", function(self)
		if not NecrosisConfig.NecrosisLockServ then
			Necrosis:OnDragStart(self)
		end
	end)
	frame:SetScript("OnDragStop", function(self) Necrosis:OnDragStop(self) end)

	-- -- Attributes specific to the soulstone button || Attributs spécifiques à la pierre d'âme
	-- -- if there are no restrictions while in combat, then allow the stone to be cast || Ils permettent de caster la pierre sur soi si pas de cible et hors combat
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
	-- Create the soulshard counter || Création du compteur de fragments d'âme
	local FontString = _G[warlockButton.f.."Text"]
	if not FontString then
		FontString = frame:CreateFontString(warlockButton.f, nil, "GameFontNormal")
	end

	-- Hidden but very useful...
	frame.high_of = warlockButton
	frame.font_string = FontString

	-- Define its attributes || Définition de ses attributs
	FontString:SetText("") -- blank for now
	FontString:SetPoint("CENTER")

	-- Place the button window at its saved location || Placement de la fenêtre à l'endroit sauvegardé ou à l'emplacement par défaut
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
