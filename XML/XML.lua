--[[
    Necrosis 
    Copyright (C) - copyright file included in this release
--]]

-- On définit G comme étant le tableau contenant toutes les frames existantes.
local _G = getfenv(0)

local function White(str)
	return "|c00FFFFFF"..str.."|r"
end


function Necrosis:CreateWarlockUI()
	------------------------------------------------------------------------------------------------------
	-- SPHERE NECROSIS
	------------------------------------------------------------------------------------------------------

	-- Create the main Necrosis button  || Création du bouton principal de Necrosis
	local frame = nil
	frame = _G["NecrosisButton"]
	if not frame then
		frame = CreateFrame("Button", "NecrosisButton", UIParent, "SecureActionButtonTemplate")
		frame:SetNormalTexture(GraphicsHelper:GetTexture("Shard"))
	end

	-- Define its attributes || Définition de ses attributs
	frame:SetFrameLevel(1)
	frame:SetMovable(true)
	frame:EnableMouse(true)
	frame:SetWidth(58)
	frame:SetHeight(58)
	frame:RegisterForDrag("LeftButton")
	frame:RegisterForClicks("AnyUp", "AnyDown")
	frame:Show()

	-- Place the button window at its saved location || Placement de la fenêtre à l'endroit sauvegardé ou à l'emplacement par défaut
	frame:ClearAllPoints()
	frame:SetPoint(
		NecrosisConfig.FramePosition["NecrosisButton"][1],
		NecrosisConfig.FramePosition["NecrosisButton"][2],
		NecrosisConfig.FramePosition["NecrosisButton"][3],
		NecrosisConfig.FramePosition["NecrosisButton"][4],
		NecrosisConfig.FramePosition["NecrosisButton"][5]
	)

	frame:SetScale(NecrosisConfig.NecrosisButtonScale / 100)
	
	-- Create the soulshard counter || Création du compteur de fragments d'âme
	local FontString = _G["NecrosisShardCount"]
	if not FontString then
		FontString = frame:CreateFontString("NecrosisShardCount", nil, "GameFontNormal")
	end

	-- Define its attributes || Définition de ses attributs
	FontString:SetText("00")
	FontString:SetPoint("CENTER")
	FontString:SetTextColor(1, 1, 1)
end


function Necrosis:CreateMenuItem(warlockButton, high_of)
	if Necrosis.Debug.buttons then
		_G["DEFAULT_CHAT_FRAME"]:AddMessage("CreateMenuItem"
		.." i'"..tostring(warlockButton.f).."'"
		.." ih'"..tostring(high_of).."'"
		.." s'"..tostring(Necrosis:GetSpellName(high_of)).."'"
		)
	end

	-- Create the button || Creaton du bouton
	local frame = _G[warlockButton.f]
	
	if not frame then
		frame = CreateFrame("Button", warlockButton.f, UIParent, "SecureActionButtonTemplate")
		-- Définition de ses attributs
		frame:SetMovable(true)
		frame:EnableMouse(true)
		frame:SetWidth(40)
		frame:SetHeight(40)
		frame:SetHighlightTexture(warlockButton.high) --("Interface\\AddOns\\Necrosis-Classic\\UI\\"...)
		frame:RegisterForClicks("AnyUp", "AnyDown")

		-- ======  hidden but effective
		-- Add valuable data to the frame for retrieval later
		frame.high_of = high_of
		frame.pet = warlockButton.pet
		
		-- Set the tooltip label to the localized name if not given one already
		Necrosis.TooltipData[warlockButton.tip].Label = White(Necrosis.GetSpellName(high_of))
	end

	frame:SetNormalTexture(warlockButton.norm)
	frame:Hide()

	-- Edit the scripts associated with the button || Edition des scripts associés au bouton 
	frame:SetScript("OnEnter", function(self) Necrosis:BuildButtonTooltip(self) end)
	frame:SetScript("OnLeave", function() GameTooltip:Hide() end)

	--============= Special settings per button
	--
	-- Special attributes for casting certain buffs || Attributs spéciaux pour les buffs castables sur les autres joueurs
	if (high_of == "breath" or high_of == "invisible") then
		frame:SetScript("PreClick", function(self)
			if (not UnitIsFriend("player","target")) then
				self:SetAttribute("unit", "player")
			end
		end)
		frame:SetScript("PostClick", function(self)
			--if not InCombatLockdown() then
				self:SetAttribute("unit", "target")
			--end
		end)
	end

	-- Special attribute for the Banish button || Attributes spéciaux pour notre ami le sort de Bannissement
	if (high_of == "banish") then
		frame:SetScale(NecrosisConfig.BanishScale/100)
	end

	return frame
end

------------------------------------------------------------------------------------------------------
-- SPECIAL POPUP BUTTONS || BOUTONS SPECIAUX POPUP
------------------------------------------------------------------------------------------------------

function Necrosis:CreateWarlockPopup()
	------------------------------------------------------------------------------------------------------
	-- Create the ShadowTrance button || Creation du bouton de ShadowTrance
	local frame = nil
	frame = _G["NecrosisShadowTranceButton"]
	if not frame then
		frame = CreateFrame("Button", "NecrosisShadowTranceButton", UIParent)
	end

	-- Define its attributes || Définition de ses attributs
	frame:SetMovable(true)
	frame:EnableMouse(true)
	frame:SetFrameStrata("HIGH")
	frame:SetWidth(40)
	frame:SetHeight(40)
	frame:SetNormalTexture(GraphicsHelper:GetTexture("ShadowTrance-Icon"))
	frame:RegisterForDrag("LeftButton")
	frame:RegisterForClicks("AnyUp", "AnyDown")
	frame:Hide()

	-- Edit scripts associated with the button || Edition des scripts associés au bouton
	frame:SetScript("OnEnter", function(self) Necrosis:BuildButtonTooltip(self) end)
	frame:SetScript("OnLeave", function() GameTooltip:Hide() end)
	-- OnMouseUp interferes with SecureActionButton
	-- frame:SetScript("OnMouseUp", function(self) Necrosis:OnDragStop(self) end)
	frame:SetScript("OnDragStart", function(self) Necrosis:OnDragStart(self) end)
	frame:SetScript("OnDragStop", function(self) Necrosis:OnDragStop(self) end)

	-- Place the button window at its saved location || Placement de la fenêtre à l'endroit sauvegardé ou à l'emplacement par défaut
	frame:ClearAllPoints()
	frame:SetPoint(
		NecrosisConfig.FramePosition["NecrosisShadowTranceButton"][1],
		NecrosisConfig.FramePosition["NecrosisShadowTranceButton"][2],
		NecrosisConfig.FramePosition["NecrosisShadowTranceButton"][3],
		NecrosisConfig.FramePosition["NecrosisShadowTranceButton"][4],
		NecrosisConfig.FramePosition["NecrosisShadowTranceButton"][5]
	)

------------------------------------------------------------------------------------------------------
	-- Create the Backlash button || Creation du bouton de BackLash
	local frame = _G["NecrosisBacklashButton"]
	if not frame then
		frame = CreateFrame("Button", "NecrosisBacklashButton", UIParent)
	end

	-- Definte its attributes || Définition de ses attributs
	frame:SetMovable(true)
	frame:EnableMouse(true)
	frame:SetFrameStrata("HIGH")
	frame:SetWidth(40)
	frame:SetHeight(40)
	frame:SetNormalTexture(GraphicsHelper:GetTexture("Backlash-Icon"))
	frame:RegisterForDrag("LeftButton")
	frame:Hide()

	-- Edit the scripts associated with the button || Edition des scripts associés au bouton
	frame:SetScript("OnEnter", function(self) Necrosis:BuildButtonTooltip(self) end)
	frame:SetScript("OnLeave", function() GameTooltip:Hide() end)
	-- OnMouseUp interferes with SecureActionButton
	-- frame:SetScript("OnMouseUp", function(self) Necrosis:OnDragStop(self) end)
	frame:SetScript("OnDragStart", function(self) Necrosis:OnDragStart(self) end)
	frame:SetScript("OnDragStop", function(self) Necrosis:OnDragStop(self) end)

	-- Place the button window at its saved location || Placement de la fenêtre à l'endroit sauvegardé ou à l'emplacement par défaut
	frame:ClearAllPoints()
	frame:SetPoint(
		NecrosisConfig.FramePosition["NecrosisBacklashButton"][1],
		NecrosisConfig.FramePosition["NecrosisBacklashButton"][2],
		NecrosisConfig.FramePosition["NecrosisBacklashButton"][3],
		NecrosisConfig.FramePosition["NecrosisBacklashButton"][4],
		NecrosisConfig.FramePosition["NecrosisBacklashButton"][5]
	)

------------------------------------------------------------------------------------------------------
	-- Create the Elemental alert button || Creation du bouton de détection des cibles banissables / asservissables
	frame = nil
	frame = _G["NecrosisCreatureAlertButton"]
	if not frame then
		frame = CreateFrame("Button", "NecrosisCreatureAlertButton", UIParent)
	end

	-- Define its attributes || Définition de ses attributs
	frame:SetMovable(true)
	frame:EnableMouse(true)
	frame:SetFrameStrata("HIGH")
	frame:SetWidth(40)
	frame:SetHeight(40)
	frame:SetNormalTexture(GraphicsHelper:GetTexture("ElemAlert"))
	frame:RegisterForDrag("LeftButton")
	frame:Hide()

	-- Edit the scripts associated with the button || Edition des scripts associés au bouton
	-- OnMouseUp interferes with SecureActionButton
	-- frame:SetScript("OnMouseUp", function(self) Necrosis:OnDragStop(self) end)
	frame:SetScript("OnDragStart", function(self) Necrosis:OnDragStart(self) end)
	frame:SetScript("OnDragStop", function(self) Necrosis:OnDragStop(self) end)

	-- Place the button window at its saved location || Placement de la fenêtre à l'endroit sauvegardé ou à l'emplacement par défaut
	if NecrosisConfig.FramePosition then
		if NecrosisConfig.FramePosition["NecrosisCreatureAlertButton"] then
			frame:ClearAllPoints()
			frame:SetPoint(
				NecrosisConfig.FramePosition["NecrosisCreatureAlertButton"][1],
				NecrosisConfig.FramePosition["NecrosisCreatureAlertButton"][2],
				NecrosisConfig.FramePosition["NecrosisCreatureAlertButton"][3],
				NecrosisConfig.FramePosition["NecrosisCreatureAlertButton"][4],
				NecrosisConfig.FramePosition["NecrosisCreatureAlertButton"][5]
			)
		end
	else
		frame:ClearAllPoints()
		frame:SetPoint("CENTER", UIParent, "CENTER", -50, 0)
	end

------------------------------------------------------------------------------------------------------
	-- Create the AntiFear button || Creation du bouton de détection des cibles protégées contre la peur
	local frame = _G["NecrosisAntiFearButton"]
	if not frame then
		frame = CreateFrame("Button", "NecrosisAntiFearButton", UIParent)
	end

	-- Define its attributes || Définition de ses attributs
	frame:SetMovable(true)
	frame:EnableMouse(true)
	frame:SetFrameStrata("HIGH")
	frame:SetWidth(40)
	frame:SetHeight(40)
	frame:SetNormalTexture(GraphicsHelper:GetTexture("AntiFear-01"))
	frame:RegisterForDrag("LeftButton")
	frame:Hide()

	-- Edit the scripts associated with the button || Edition des scripts associés au bouton
	-- OnMouseUp interferes with SecureActionButton
	-- frame:SetScript("OnMouseUp", function(self) Necrosis:OnDragStop(self) end)
	frame:SetScript("OnDragStart", function(self) Necrosis:OnDragStart(self) end)
	frame:SetScript("OnDragStop", function(self) Necrosis:OnDragStop(self) end)

	-- Place the button window at its saved location || Placement de la fenêtre à l'endroit sauvegardé ou à l'emplacement par défaut
	if NecrosisConfig.FramePosition then
		if NecrosisConfig.FramePosition["NecrosisAntiFearButton"] then
			frame:ClearAllPoints()
			frame:SetPoint(
				NecrosisConfig.FramePosition["NecrosisAntiFearButton"][1],
				NecrosisConfig.FramePosition["NecrosisAntiFearButton"][2],
				NecrosisConfig.FramePosition["NecrosisAntiFearButton"][3],
				NecrosisConfig.FramePosition["NecrosisAntiFearButton"][4],
				NecrosisConfig.FramePosition["NecrosisAntiFearButton"][5]
			)
		end
	else
		frame:ClearAllPoints()
		frame:SetPoint("CENTER", UIParent, "CENTER", 50, 0)
	end
end
