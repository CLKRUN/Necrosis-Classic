--[[
    Necrosis 
    Copyright (C) - copyright file included in this release
--]]

-- On définit G comme étant le tableau contenant toutes les frames existantes.
local _G = getfenv(0)
-- local L = LibStub("AceLocale-3.0"):GetLocale(NECROSIS_ID, true)

------------------------------------------------------------------------------------------------------
-- DEFINITION OF INITIAL MENU ATTRIBUTES || DEFINITION INITIALE DES ATTRIBUTS DES MENUS
------------------------------------------------------------------------------------------------------

-- On crée les menus sécurisés pour les différents sorts Buff / Démon / Malédictions
function Necrosis:MenuAttribute(menuButton)
	if not menuButton:GetAttribute("state") then 
		menuButton:SetAttribute("state", "Ferme")
	end
	
	if not menuButton:GetAttribute("lastClick") then 
		menuButton:SetAttribute("lastClick", "LeftButton")
	end
	
	if not menuButton:GetAttribute("close") then 
		menuButton:SetAttribute("close", 0)
	end
	
	-- run at OnLoad of button
	-- if (menuButton:IsProtected()) then
		menuButton:Execute([[ 
			ButtonList = table.new(self:GetChildren())
			if (self:GetAttribute("state") == "Bloque") then
				for i, button in ipairs(ButtonList) do
					button:Show()
				end
			else
				for i, button in ipairs(ButtonList) do
					button:Hide()
				end
			end
		]])
	-- end

	menuButton:SetAttribute("_onclick", [[
		self:SetAttribute("lastClick", button)
		local state = self:GetAttribute("state")
		if state == "Ferme" then
			if button == "RightButton" then
				self:SetAttribute("state", "ClicDroit")
			else
				self:SetAttribute("state", "Ouvert")
			end
		elseif state == "Ouvert" then
			if button == "RightButton" then
				self:SetAttribute("state", "ClicDroit")
			else
				self:SetAttribute("state", "Ferme")
			end
		elseif state == "Combat" then
			for i, button in ipairs(ButtonList) do
				if button:IsShown() then
					--button:Hide()
				else
					--button:Show()
				end
			end
		elseif state == "ClicDroit" and button == "LeftButton" then
			self:SetAttribute("state", "Ferme")
		end
	]])

	menuButton:SetAttribute("_onattributechanged", [[
		if name == "state" then
			if value == "Ferme" then
				for i, button in ipairs(ButtonList) do
					button:Hide()
				end
			elseif value == "Ouvert" then
				for i, button in ipairs(ButtonList) do
					button:Show()
				end
				
				self:SetAttribute("close", self:GetAttribute("close") + 1)
				-- control:SetTimer(6, self:GetAttribute("close"))
			elseif value == "Combat" or value == "Bloque" then
				for i, button in ipairs(ButtonList) do
					button:Show()
				end
			elseif value == "Refresh" then
				self:SetAttribute("state", "Ouvert")
			elseif value == "ClicDroit" then
				for i, button in ipairs(ButtonList) do
					button:Show()
				end
			end
		end
	]])
	
	menuButton:SetAttribute("_ontimer", [[
		if self:GetAttribute("close") <= message and not self:GetAttribute("mousehere") then
			self:SetAttribute("state", "Ferme")
		end
	]])
end

local l_click = 1
local r_click = 2
------------------------------------------------------------------------------------------------------
-- DEFINITION INITIALE DES ATTRIBUTS DES SORTS
------------------------------------------------------------------------------------------------------

-- On associe les malédictions au clic sur le bouton concerné
function Necrosis:SetBuffSpellAttribute(button)
	local f = button
	if f then
		local spellName = Necrosis.GetSpellCastName(f.high_of)
		
		if Necrosis.Debug.buttons then
			_G["DEFAULT_CHAT_FRAME"]:AddMessage("SetBuffSpellAttribute"
			.." f'"..tostring(button).."'"
			.." h'"..tostring(f.high_of).."'"
			.." name'"..tostring(spellName or "nil").."'"
			)
		end
		if (f.high_of == "banish") then
			-- Do NOT like hard coding but leave for now...
			-- local Rank1 = self.Warlock_Spells[710].InSpellBook and self.Warlock_Spells[710].CastName
			if (Necrosis.GetSpellRank(f.high_of) == 2) then -- has rank 2
				-- local Rank2 = self.Warlock_Spells[18647].InSpellBook and self.Warlock_Spells[18647].CastName
				-- so lets use the "harmbutton" special attribute!
				-- assign Banish(rank 2) to LEFT click 
				f:SetAttribute("type"..l_click, "macro")
				f:SetAttribute("macrotext"..l_click, "/stopcasting\n/focus\n/cast "..spellName.."(rank 2)")
				
				-- assign Banish(rank 1) to RIGHT click 
				f:SetAttribute("type"..r_click, "macro")
				f:SetAttribute("macrotext"..r_click, "/stopcasting\n/focus\n/cast "..spellName.."(rank 1)")

				-- allow focused target to be rebanished with CTRL+LEFT or RIGHT click
				f:SetAttribute("ctrl-type"..l_click, "spell")
				f:SetAttribute("ctrl-unit"..l_click, "focus")
				f:SetAttribute("ctrl-spell"..l_click, spellName.."(rank 2)")
				f:SetAttribute("ctrl-type"..r_click, "spell")
				f:SetAttribute("ctrl-unit"..r_click, "focus")
				f:SetAttribute("ctrl-spell"..r_click, spellName.."(rank 1)")
			else -- only have rank 1
				-- left & right click will perform the same macro
				f:SetAttribute("type*", "macro")
				f:SetAttribute("macrotext*", "/stopcasting\n/cast "..spellName) 

				-- Si le démoniste control + click le bouton de banish || if the warlock uses ctrl-click then
				-- On rebanish la dernière cible bannie || rebanish the previously banished target
				f:SetAttribute("ctrl-type*", "spell")
				f:SetAttribute("ctrl-spell*", spellName)
			end
		elseif (f.high_of == "armor") then
			-- Check if we got Fel Armor, which has different effects
			f:SetAttribute("type1", "spell")
			f:SetAttribute("spell1", spellName)
			f:SetAttribute("type2", "spell")
			f:SetAttribute("spell2", spellName)
			if (Necrosis.CurrentEnv.DemonArmorAvailable) then
				f:SetAttribute("spell1", Necrosis.CurrentEnv.DemonArmorName)
				f:SetAttribute("spell2", Necrosis.CurrentEnv.DemonArmorName)
			end
			if (Necrosis.CurrentEnv.FelArmorAvailable) then
				f:SetAttribute("spell1", Necrosis.CurrentEnv.FelArmorName)
			end
		else
			f:SetAttribute("type", "spell")
			f:SetAttribute("spell", spellName)
		end
	end
end

-- On associe les buffs au clic sur le bouton concerné
function Necrosis:BuffSpellAttribute(buttonList)
	for i = 1, #buttonList, 1 do
		Necrosis:SetBuffSpellAttribute(buttonList[i])
	end
end

-- On associe les démons au clic sur le bouton concerné
function Necrosis:SetPetSpellAttribute(button)
	local f = button
	if f then
		local spellName = Necrosis.GetSpellCastName(f.high_of)
		
		if Necrosis.Debug.buttons then
			_G["DEFAULT_CHAT_FRAME"]:AddMessage("SetPetSpellAttribute"
			.." f'"..tostring(button).."'"
			.." h'"..tostring(f.high_of).."'"
			.." p'"..tostring(f.pet).."'"
			.." name'"..tostring(spellName or "nil").."'"
			)
		end

		if f.pet then
			f:SetAttribute("type1", "spell")
			f:SetAttribute("spell", spellName) 
			if Necrosis.IsSpellKnown("domination") then
				local dominationName = Necrosis.GetSpellCastName("domination")
				f:SetAttribute("type2", "macro")
				local str = 
					"/stopcasting"
					.."\n/cast "..dominationName
					.."\n/cast "..spellName
				f:SetAttribute("macrotext",str)
			end
		else
			f:SetAttribute("type", "spell")
			f:SetAttribute("spell", spellName) 
		end
	end
end

function Necrosis:PetSpellAttribute(buttonList)
	for i = 1, #buttonList, 1 do
		Necrosis:SetPetSpellAttribute(buttonList[i])
	end
end

-- On associe les malédictions au clic sur le bouton concerné
function Necrosis:SetCurseSpellAttribute(button)
	local f = button
	if f then
		local spellName = Necrosis.GetSpellCastName(f.high_of)
		
		f:SetAttribute("harmbutton", "debuff")
		f:SetAttribute("type-debuff", "spell")
		f:SetAttribute("unit", "target")
		f:SetAttribute("spell-debuff", spellName)

		if Necrosis.Debug.buttons then
			_G["DEFAULT_CHAT_FRAME"]:AddMessage("SetCurseSpellAttribute"
			.." f'"..tostring(f:GetName()).."'"
			.." h'"..tostring(f.high_of).."'"
			.." name'"..tostring(spellName or "nil").."'"
			)
		end
	end
end

function Necrosis:CurseSpellAttribute(buttonList)
	for i = 1, #buttonList, 1 do
		Necrosis:SetCurseSpellAttribute(buttonList[i])
	end
end

-- Associating the frames to buttons, and creating stones on right-click.
-- Association de la monture au bouton, et de la création des pierres sur un clic droit
function Necrosis:StoneAttribute(Steed)
	if Necrosis.Debug.buttons then
		_G["DEFAULT_CHAT_FRAME"]:AddMessage("StoneAttribute"
		.." a'"..(tostring(Steed) or "nyl")..'"'
		)
	end

	-- Do the 'stones'
	if Necrosis.IsSpellKnown("firestone") then
		local f = _G[Necrosis.Warlock_Buttons.fire_stone.f]
		if f then
			local spellName = Necrosis.GetSpellCastName("firestone")
			f:SetAttribute("type2", "spell")
			f:SetAttribute("spell2", spellName)
		end
	end
	if Necrosis.IsSpellKnown("spellstone") then
		local f = _G[Necrosis.Warlock_Buttons.spell_stone.f]
		if f then
			local spellName = Necrosis.GetSpellCastName("spellstone")
			f:SetAttribute("type2", "spell")
			f:SetAttribute("spell2", spellName)
		end
	end
	if Necrosis.IsSpellKnown("healthstone") then
		local f = _G[Necrosis.Warlock_Buttons.health_stone.f]
		if f then
			local spellName = Necrosis.GetSpellCastName("healthstone")
			f:SetAttribute("type2", "spell")
			f:SetAttribute("spell2", spellName)
			
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
	end

	-- Destroy Shards button is a new type, with function attached
	local destroy_shards_button = _G[Necrosis.Warlock_Buttons.destroy_shards.f]
	if (destroy_shards_button) then
		destroy_shards_button:SetScript(
			"OnClick",
			Necrosis.Warlock_Buttons.destroy_shards.func
		)
	end
	
	SphereButtonHelper:SoulstoneUpdateAttribute()

	-- mounts || Pour la monture
	local f = Necrosis.Warlock_Buttons.mounts.f
	f = _G[f]
	if Steed and f then
		f:SetAttribute("type1", "spell")
		f:SetAttribute("type2", "spell")
		
		if (NecrosisConfig.LeftMount) then
			local leftMountName = GetSpellInfo(NecrosisConfig.LeftMount)
			f:SetAttribute("spell1", leftMountName)
		else
			if (Necrosis.CurrentEnv.FelsteedAvailable) then
				f:SetAttribute("spell1", Necrosis.CurrentEnv.FelsteedName)
				f:SetAttribute("spell2", Necrosis.CurrentEnv.FelsteedName)
			end			
			if (Necrosis.CurrentEnv.DreadsteedAvailable) then
				f:SetAttribute("spell1", Necrosis.CurrentEnv.DreadsteedName)
			end
		end
		
		if (NecrosisConfig.RightMount) then
			local rightMountName = GetSpellInfo(NecrosisConfig.RightMount)
			f:SetAttribute("spell2", rightMountName)
		end
	end

	-- local f = Necrosis.Warlock_Buttons.timer.f
	-- f = _G[f]
	-- if f then
	-- 	-- hearthstone || Pour la pierre de foyer
	-- 	f:SetAttribute("unit1", "target")
	-- 	f:SetAttribute("type1", "macro")
	-- 	f:SetAttribute("macrotext", "/focus")
	-- 	f:SetAttribute("type2", "item")
	-- 	f:SetAttribute("item", self.Translation.Item.Hearthstone)
	-- end
---[[
	local f = Necrosis.Warlock_Buttons.hearth_stone.f
	f = _G[f]
	if f then
		f:SetAttribute("unit1", "target")
		f:SetAttribute("type1", "macro")
		f:SetAttribute("macrotext", "/focus")
		f:SetAttribute("type2", "item")
		f:SetAttribute("item", self.Translation.Item.Hearthstone)
	end
--]]
end

-- Connection Association to the central button if the spell is available || Association de la Connexion au bouton central si le sort est disponible
function Necrosis:MainButtonAttribute()
	local f = Necrosis.Warlock_Buttons.main.f
	f = _G[f]
	if not f then return end

	-- Le clic droit ouvre le Menu des options
	f:SetAttribute("type2", "Open")
	f.Open = function()
		if (not EventHelper:IsCombatLocked()) then
			Necrosis.Gui.MainWindow:Show()
		end
	end

	local main_cast_name = Necrosis.Spell[NecrosisConfig.MainSpell].NameOrg
	
	if Necrosis.Debug.buttons then
		_G["DEFAULT_CHAT_FRAME"]:AddMessage("MainButtonAttribute"
		.." idx'"..tostring(NecrosisConfig.MainSpell or "nyl").."'"
		.." name'"..tostring(main_cast_name or "nyl").."'"
		)
	end
	
	if main_cast_name and main_cast_name ~= "" then
		f:SetAttribute("type1", "spell")
		f:SetAttribute("spell", main_cast_name)
	end
end


------------------------------------------------------------------------------------------------------
-- DEFINITION DES ATTRIBUTS DES SORTS EN FONCTION DU COMBAT / REGEN
------------------------------------------------------------------------------------------------------

function Necrosis:NoCombatAttribute(SoulstoneMode, FirestoneMode, SpellstoneMode, Pet, Buff, Curse)

	local f = Necrosis.Warlock_Buttons.pets.f
	f = _G[f]

	-- Si on veut que le menu s'engage automatiquement en combat
	-- Et se désengage à la fin
	if NecrosisConfig.AutomaticMenu and not NecrosisConfig.BlockedMenu then
		if f then
			if f:GetAttribute("lastClick") == "RightButton" then
				f:SetAttribute("state", "ClicDroit")
			else
				f:SetAttribute("state", "Ferme")
			end
			if NecrosisConfig.ClosingMenu then
				for i = 1, #Pet, 1 do
					f:WrapScript(Pet[i], "OnClick", [[
						if self:GetParent():GetAttribute("state") == "Ouvert" then
							self:GetParent():SetAttribute("state", "Ferme")
						end
					]])
				end
			end
		end
		local f = _G[Necrosis.Warlock_Buttons.buffs.f]
		if f then
			if f:GetAttribute("lastClick") == "RightButton" then
				f:SetAttribute("state", "ClicDroit")
			else
				f:SetAttribute("state", "Ferme")
			end
			if NecrosisConfig.ClosingMenu then
				for i = 1, #Buff, 1 do
					f:WrapScript(Buff[i], "OnClick", [[
						if self:GetParent():GetAttribute("state") == "Ouvert" then
							self:GetParent():SetAttribute("state", "Ferme")
						end
					]])
				end
			end
		end
		local f = _G[Necrosis.Warlock_Buttons.curses.f]
		if f then
			if f:GetAttribute("lastClick") == "RightButton" then
				f:SetAttribute("state", "ClicDroit")
			else
				f:SetAttribute("state", "Ferme")
			end
			if NecrosisConfig.ClosingMenu then
				for i = 1, #Curse, 1 do
					f:WrapScript(Curse[i], "OnClick", [[
						if self:GetParent():GetAttribute("state") == "Ouvert" then
							self:GetParent():SetAttribute("state", "Ferme")
						end
					]])
				end
			end
		end
	end

	if Necrosis.Debug.buttons then
		_G["DEFAULT_CHAT_FRAME"]:AddMessage("NoCombatAttribute"
		.." sps'"..(tostring(BagHelper.Spellstone_Name) or "nyl")..'"'
		.." fs'"..(tostring(BagHelper.Firestone_Name) or "nyl")..'"'
		.." hs'"..(tostring(BagHelper.Healthstone_Name) or "nyl")..'"'
		.." ss'"..(tostring(BagHelper.Soulstone_Name) or "nyl")..'"'
		)
	end

	-- Si on connait l'emplacement de la pierre de sort,
	-- Alors cliquer sur le bouton de pierre de sort l'équipe.
	local f = _G[Necrosis.Warlock_Buttons.spell_stone.f]
	if BagHelper.Spellstone_Name and f then
		f:SetAttribute("type1", "macro")
		f:SetAttribute("macrotext*","/cast "..BagHelper.Spellstone_Name.."\n/use 16")
	end
	-- Si on connait l'emplacement de la pierre de feu,
	-- Alors cliquer sur le bouton de pierre de feu l'équipe.
	local f = _G[Necrosis.Warlock_Buttons.fire_stone.f]
	if BagHelper.Firestone_Name and f then
		f:SetAttribute("type1", "macro")
		f:SetAttribute("macrotext*", "/cast "..BagHelper.Firestone_Name.."\n/use 16")
	end
end

function Necrosis:InCombatAttribute(Pet, Buff, Curse)
	-- Si on veut que le menu s'engage automatiquement en combat
	if NecrosisConfig.AutomaticMenu and not NecrosisConfig.BlockedMenu then
		local f = Necrosis.Warlock_Buttons.pets.f
		f = _G[f]
		if f and NecrosisConfig.StonePosition[7] then
			f:SetAttribute("state", "Combat")
			if NecrosisConfig.ClosingMenu then
				for i = 1, #Pet, 1 do
					f:UnwrapScript(Pet[i], "OnClick")
				end
			end
		end
		local f = Necrosis.Warlock_Buttons.buffs.f
		f = _G[f]
		if f and NecrosisConfig.StonePosition[5] then
			f:SetAttribute("state", "Combat")
			if NecrosisConfig.ClosingMenu then
				for i = 1, #Buff, 1 do
					f:UnwrapScript(Buff[i], "OnClick")
				end
			end
		end
		local f = Necrosis.Warlock_Buttons.curses.f
		f = _G[f]
		if f and NecrosisConfig.StonePosition[8] then
			f:SetAttribute("state", "Combat")
			if NecrosisConfig.ClosingMenu then
				for i = 1, #Curse, 1 do
					f:UnwrapScript(Curse[i], "OnClick")
				end
			end
		end
	end

	if Necrosis.Debug.buttons then
		_G["DEFAULT_CHAT_FRAME"]:AddMessage("InCombatAttribute"
		.." sps'"..(tostring(BagHelper.Spellstone_Name) or "nyl")..'"'
		.." fs'"..(tostring(BagHelper.Firestone_Name) or "nyl")..'"'
		.." hs'"..(tostring(BagHelper.Healthstone_Name) or "nyl")..'"'
		.." ss'"..(tostring(BagHelper.Soulstone_Name) or "nyl")..'"'
		)
	end

	-- Si on connait le nom de la pierre de sort,
	-- Alors le clic gauche utiliser la pierre
	local f = Necrosis.Warlock_Buttons.spell_stone.f
	f = _G[f]
	if BagHelper.Spellstone_Name and f then
		f:SetAttribute("type1", "macro")
		f:SetAttribute("macrotext*", "/cast "..BagHelper.Spellstone_Name.."\n/use 16")
	end

	-- Si on connait le nom de la pierre de feu,
	-- Alors le clic sur le bouton équipera la pierre
	local f = Necrosis.Warlock_Buttons.fire_stone.f
	f = _G[f]
	if BagHelper.Firestone_Name and f then
		f:SetAttribute("type1", "macro")
		f:SetAttribute("macrotext*", "/cast "..BagHelper.Firestone_Name.."\n/use 16")
	end

	-- Si on connait le nom de la pierre de soin,
	-- Alors le clic gauche sur le bouton utilisera la pierre
	local f = Necrosis.Warlock_Buttons.health_stone.f
	f = _G[f]
	if BagHelper.Healthstone_Name and f then
		local useHealthstoneMacro = ""
		for i,id in ipairs(ItemHelper.Healthstone.ItemIds) do
			useHealthstoneMacro = "/use item:"..tostring(id).."\n"..useHealthstoneMacro
		end

		f:SetAttribute("type1", "macro")
		f:SetAttribute("macrotext1", "/stopcasting\n"..useHealthstoneMacro)
	end
--[[
	-- If we know the name of the soul stone,
	-- Then the left click on the button will use the stone
	-- Si on connait le nom de la pierre d'âme,
	-- Alors le clic gauche sur le bouton utilisera la pierre
	local f = Necrosis.Warlock_Buttons.soul_stone.f
	f = _G[f]
	if NecrosisConfig.ItemSwitchCombat[4] and f then
		f:SetAttribute("type1", "item")
		f:SetAttribute("unit", "target")
		f:SetAttribute("item1", NecrosisConfig.ItemSwitchCombat[4])
	end
--]]
end


--[[ https://wowwiki.fandom.com/wiki/SecureActionButtonTemplate
"type"					Any clicks.
"*type1"				Any left click.
"type1"					Unmodified left click.
"shift-type2"			Shift+right click. (But not Alt+Shift+right click)
"shift-type*"			Shift+any button click.
"alt-ctrl-shift-type*"	Alt+Control+Shift+any button click.
"ctrl-alt-shift-type*"	Invalid, as modifiers are in the wrong order.
===
For example, suppose we wanted to create a button that would alter behavior based on whether you can attack your target. 
Setting the following attributes has the desired effect:
"unit"				"target"				Make all actions target the player's target.
"*harmbutton1"		"nuke1"					Remap any left clicks to "nuke1" clicks when target is hostile.
"*harmbutton2"		"nuke2"					Remap any right clicks to "nuke2" clicks when target is hostile.
"helpbutton1"		"heal1"					Remap unmodified left clicks to "heal1" clicks when target is friendly.
"type"				"spell"					Make all clicks cast a spell.
"spell-nuke1"		"Mind Flay"				Cast Mind Flay on "hostile" left click.
"spell-nuke2"		"Shadow Word: Death"	Cast Shadow Word: Death on "hostile" right click.
"alt-spell-nuke2"	"Mind Blast"			Cast Mind Blast on "hostile" alt-right click.
"spell-heal1"		"Flash Heal"			Cast Flash Heal on "friendly" left click.

:::SecureActionButtonTemplate "type" attributes:::
Type			Used attributes		Behavior
"actionbar"		"action"			Switches the current action bar depending on the value of the "action" attribute:
									A number: switches to a the bar specified by the number.
									"increment" or "decrement": move one bar up/down.
									"a, b", where a, and b are numeric, switches between bars a and b.
"action"		"unit", "action"
				["actionpage"]		Performs an action specified by the "action" attribute (a number).
									If the button:GetID() > 0, paging behavior is supported; 
									see the ActionButton_CalculateAction FrameXML function.
"pet"			"unit", "action"	Calls CastPetAction(action, unit);
"spell"			"unit", "spell"		Calls CastSpellByName(spell, unit);
"item"			"unit"
				"item" OR
				["bag", "slot"]		Equips or uses the specified item, as resolved by SecureCmdItemParse.
									"item" attribute value may be a macro conditioned string, item name, or "bag slot" string (i.e. "1 3").
									If "item" is nil, the "bag" and "slot" attributes are used; those are deprecated -- use a "bag slot" item string.
"macro"			"macro" OR
				"macrotext"			If "macro" attribute is specified, calls RunMacro(macro, button); otherwise, RunMacroText(macrotext, button);
"cancelaura"	"unit"
				"index" OR
				"spell"[, "rank"]	Calls either CancelUnitBuff(unit, index) or CancelUnitBuff(unit, spell, rank). The first version
									Note: the value of the "index" attribute must resolve to nil/false for the "spell", "rank" attributes to be considered.

"stop"	 							Calls SpellStopTargeting().
"target"		"unit"				Changes target, targets a unit for a spell, or trades unit an item on the cursor.
									If "unit" attribute value is "none", your target is cleared.
"focus"			"unit"				Calls FocusUnit(unit).
"assist"		"unit"				Calls AssistUnit(unit).
"mainassist"	"action", "unit"	Performs a main assist status on the unit based on the value of the "action" attribute:
									nil or "set": the unit is assigned main assist status. (SetPartyAssignment)
									"clear": the unit is stripped main assist status. (ClearPartyAssignment)
									"toggle": the main assist status of the unit is inverted.
"maintank"		"action", "unit"	As "mainassist", but for main tank status.
"click"			"clickbutton"		Calls clickbutton:Click(button)
"attribute"		["attribute-frame",]
				"attribute-name"
				"attribute-value"	Calls frame:SetAttribute(attributeName, attributeValue). 
									If "attribute-frame" is not specified, the button itself is assumed.
									Any other value	"_type"	Action depends on the value of the modified ("_" .. type) attribute, or rawget(button, type), in that order.
									If the value is a function, it is called with (self, unit, button, actionType) arguments
									If the value is a string, a restricted snippet stored in the attribute specified by the value on the button is executed as if it was OnClick.
--]]

