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
-- Skins et voix Françaises : Eliah, Ner'zhul
--
-- Version Allemande par Geschan
-- Version Espagnole par DosS (Zul’jin)
-- Version Russe par Komsomolka
--
-- Version $LastChangedDate: 2009-12-10 17:09:53 +1100 (Thu, 10 Dec 2009) $
------------------------------------------------------------------------------------------------------

-- On définit G comme étant le tableau contenant toutes les frames existantes.
-- local _G = getfenv(0)


------------------------------------------------------------------------------------------------------
-- FUNCTIONS TO ADD TIMERS || FONCTIONS D'INSERTION
------------------------------------------------------------------------------------------------------

Necrosis.Timers = {
	Instances = {},
	SingleFrame = nil,
	SingleAnchor = nil,
	MobFrames = {},
	MobAnchor = nil,
	Font = CreateFont("NecrosisTimerFont"),
	TimeSinceLastUpdate = 0
}

local _t = Necrosis.Timers

local TICK_SECS = 0.05
local BAR_HEIGHT = 20
local BAR_WIDTH = 160
local BAR_PADDING = 1
local BAR_COLOR = {r = 1, g = 0.5, b = 0}
local TEXT_COLOR = {r = 1, g = 1, b = 1}
local SS_BAN_ANCHOR = {x = 0, y = 0}
local MOB_ANCHOR = {x = -60, y = 0}
local BACKGROUND_COLOR = {r = 0.2, g = 0.2, b = 0.2, a = 0.7}

function _t:GetFormattedTime(secs)
	local mins = math.modf(secs / 60)
	secs = math.fmod(secs, 60)
	if (mins > 0) then
		return string.format("%d:%02d", mins, secs)
	end
	return string.format("%d", secs)
end

function _t:SetFont(path, size, flags)
	flags = flags or ""
	local result = _t.Font:SetFont(path, size, flags)
end

local function FindMobTimerGroup(targetGuid)
	for i,mobFrame in pairs(_t.MobFrames) do
		if (mobFrame.Guid == targetGuid) then
			return mobFrame
		end
	end
	return nil
end

local function FindFreeMobTimerGroup()
	for i,mobFrame in pairs(_t.MobFrames) do
		-- A mobFrame is unused when it has no timers
		if (#mobFrame.Timers == 0 and mobFrame.Frame) then
			return mobFrame
		end
	end
	return nil
end

local function PositionMobTimerGroups()
	local activeCount = 0
	for i,mobFrame in pairs(_t.MobFrames) do
		-- Only reposition active frames
		if (#mobFrame.Timers > 0) then
			mobFrame.Frame:ClearAllPoints()
			if (_t.MobAnchor) then
				mobFrame.Frame:SetPoint(
					"LEFT",
					_t.MobAnchor,
					"LEFT",
					0 - (activeCount * (BAR_HEIGHT + BAR_WIDTH + BAR_PADDING)),
					0)
			else
				mobFrame.Frame:SetPoint(
					NecrosisConfig.FramePosition["NecrosisMobTimerAnchor"][1],
					NecrosisConfig.FramePosition["NecrosisMobTimerAnchor"][2],
					NecrosisConfig.FramePosition["NecrosisMobTimerAnchor"][3],
					NecrosisConfig.FramePosition["NecrosisMobTimerAnchor"][4] - (activeCount * (BAR_HEIGHT + BAR_WIDTH + BAR_PADDING)),
					NecrosisConfig.FramePosition["NecrosisMobTimerAnchor"][5]
				)
			end
			activeCount = activeCount + 1
		end
	end
end

local function PositionSingleTimerGroup()
	if (not _t.SingleFrame) then
		return
	end
	_t.SingleFrame.Frame:ClearAllPoints()
	if (_t.SingleAnchor) then
		-- Capture the single frame if it exists
		_t.SingleFrame.Frame:SetParent(_t.SingleAnchor)
		_t.SingleFrame.Frame:SetPoint(
			"LEFT",
			_t.SingleAnchor,
			"LEFT",
			0,
			0)
	else
		_t.SingleFrame.Frame:SetPoint(
			NecrosisConfig.FramePosition["NecrosisSingleTimerAnchor"][1],
			NecrosisConfig.FramePosition["NecrosisSingleTimerAnchor"][2],
			NecrosisConfig.FramePosition["NecrosisSingleTimerAnchor"][3],
			NecrosisConfig.FramePosition["NecrosisSingleTimerAnchor"][4],
			NecrosisConfig.FramePosition["NecrosisSingleTimerAnchor"][5]
		)
	end
end

local function MakeTimerGroupGui(parentFrame)
	local mf = CreateFrame("Frame", nil, parentFrame)
	-- local mf = CreateFrame("BUTTON", nil, parentFrame, "SecureActionButtonTemplate")
	mf:SetMovable(false)
	mf:ClearAllPoints()
	mf:SetSize(BAR_WIDTH, BAR_HEIGHT)

	local bg = mf:CreateTexture(nil, "BACKGROUND")
	bg:SetSize(BAR_WIDTH, BAR_HEIGHT)
	bg:SetColorTexture(BACKGROUND_COLOR.r, BACKGROUND_COLOR.g, BACKGROUND_COLOR.b, BACKGROUND_COLOR.a)
	bg:SetAllPoints()

	local title = mf:CreateFontString(nil, "OVERLAY", "NecrosisTimerFont")
	title:SetSize(BAR_WIDTH, BAR_HEIGHT)
	title:SetJustifyH("MIDDLE")
	title:SetJustifyV("MIDDLE")
	title:ClearAllPoints()
	title:SetPoint("CENTER", mf, "CENTER")
	title:SetTextColor(TEXT_COLOR.r, TEXT_COLOR.g, TEXT_COLOR.b)

	local icon = mf:CreateTexture(nil, "OVERLAY")
	icon:SetSize(BAR_HEIGHT, BAR_HEIGHT)
	icon:SetBlendMode("ADD")
	icon:ClearAllPoints()
	icon:SetPoint("LEFT", mf, "LEFT", BAR_PADDING, 0)

	return
		{
			Frame = mf,
			Background = bg,
			Title = title,
			RaidIcon = icon,
			Timers = {}
		}
end

local function SortTimerGroup(timerGroup)
	-- Sort timers by time when they are finished, lowest on top
	table.sort(timerGroup.Timers,
		function(a,b)
			return (a.EndTime > b.EndTime)
		end
	)
	for i,timerData in ipairs(timerGroup.Timers) do
		timerData.Frame:ClearAllPoints()
		timerData.Frame:SetPoint(
			"CENTER",
			timerGroup.Frame,
			"CENTER",
			0,
			i * (BAR_HEIGHT + BAR_PADDING))
	end
end

local function UpdateRaidIcon(data, iconNumber)
	if (iconNumber == data.RaidIconNumber) then
		return
	end
	if (iconNumber) then
		data.RaidIcon:SetTexture(GraphicsHelper:GetWoWTexture("TargetingFrame", "UI-RaidTargetingIcon_"..iconNumber))
		data.RaidIconNumber = iconNumber
	else
		data.RaidIcon:SetTexture(nil)
		data.RaidIconNumber = nil
	end
end

local function RemoveTimer(timerData)
	if (timerData.Finished or timerData.Finishing) then
		return
	end
	timerData.Finishing = true
	-- Hide the timer, stopping the countdown
	timerData.Frame:Hide()
	-- Remove the raid icon from the timer (might have been banish or ss)
	UpdateRaidIcon(timerData, nil)
	-- Remove the timer from the group
	local idx = table.indexOf(timerData.Group.Timers, timerData)
	table.remove(timerData.Group.Timers, idx)
	if (#timerData.Group.Timers > 0) then
		SortTimerGroup(timerData.Group)
	else
		-- Remove the raid icon from the timer group
		UpdateRaidIcon(timerData.Group, nil)
		timerData.Group.Frame:Hide()
		if (timerData.SpellType ~= "soulstone"
			and timerData.SpellType ~= "single"
			and timerData.SpellType ~= "self"
		) then
			PositionMobTimerGroups()
		end
	end
	-- Remove reference to the timer group as well
	timerData.Group = nil
	timerData.Finishing = false
	timerData.Finished = true
end

local function FindFreeTimer()
	for i,timerData in ipairs(_t.Instances) do
		if (timerData.Finished and timerData.Frame) then
			timerData.Finished = false
			return timerData
		end
	end
	return nil
end

local function MakeTimerGui(parentFrame)
	-- Frame will be positioned later
	local frame = CreateFrame("Frame", nil, parentFrame)
	frame:SetSize(BAR_WIDTH, BAR_HEIGHT)
	
	local lblCountdown = frame:CreateFontString(nil, "OVERLAY", "NecrosisTimerFont")
	lblCountdown:SetSize(2 * BAR_HEIGHT + BAR_PADDING, BAR_HEIGHT)
	lblCountdown:SetJustifyH("LEFT")
	lblCountdown:SetTextColor(TEXT_COLOR.r, TEXT_COLOR.g, TEXT_COLOR.b)
	lblCountdown:ClearAllPoints()
	-- lblCountdown:SetPoint("LEFT", frame, "LEFT", 1, 0)
	if (NecrosisConfig.SpellTimerPos == -1) then
		lblCountdown:SetPoint("LEFT", frame, "LEFT", 1, 0)
	else
		lblCountdown:SetPoint("LEFT", frame, "RIGHT", 5, 0)
	end

	local bar = CreateFrame("StatusBar", nil, frame)
	bar:SetSize(BAR_WIDTH - BAR_HEIGHT, BAR_HEIGHT)
	bar:SetStatusBarTexture(GraphicsHelper:GetWoWTexture("TargetingFrame", "UI-StatusBar"))
	bar:SetStatusBarColor(BAR_COLOR.r, BAR_COLOR.g, BAR_COLOR.b)
	bar:SetFrameLevel(bar:GetFrameLevel() - 1)
	bar:ClearAllPoints()
	bar:SetPoint("LEFT", frame, "LEFT")

	local lblSpellname = bar:CreateFontString(nil, "OVERLAY", "NecrosisTimerFont")
	lblSpellname:SetSize(BAR_WIDTH - BAR_HEIGHT, BAR_HEIGHT)
	lblSpellname:SetJustifyH("RIGHT")
	lblSpellname:SetJustifyV("MIDDLE")
	lblSpellname:ClearAllPoints()
	lblSpellname:SetPoint("LEFT", bar, "LEFT", -3, 0)
	lblSpellname:SetTextColor(TEXT_COLOR.r, TEXT_COLOR.g, TEXT_COLOR.b)

	local bg = bar:CreateTexture(nil, "BACKGROUND")
	bg:SetAllPoints()
	bg:SetColorTexture(BACKGROUND_COLOR.r, BACKGROUND_COLOR.g, BACKGROUND_COLOR.b, BACKGROUND_COLOR.a)

	local spellIcon = bar:CreateTexture(nil, "OVERLAY")
	spellIcon:SetSize(BAR_HEIGHT, BAR_HEIGHT)
	spellIcon:SetBlendMode("ADD")
	spellIcon:ClearAllPoints()
	spellIcon:SetPoint("RIGHT", frame, "RIGHT", BAR_PADDING, 0)

	local bgSpell = bar:CreateTexture(nil, "BACKGROUND")
	bgSpell:SetSize(BAR_HEIGHT, BAR_HEIGHT)
	bgSpell:ClearAllPoints()
	bgSpell:SetPoint("RIGHT", frame, "RIGHT", BAR_PADDING, 0)
	bgSpell:SetColorTexture(BACKGROUND_COLOR.r, BACKGROUND_COLOR.g, BACKGROUND_COLOR.b, BACKGROUND_COLOR.a)

	local raidIcon = bar:CreateTexture(nil, "OVERLAY")
	raidIcon:SetSize(BAR_HEIGHT, BAR_HEIGHT)
	raidIcon:SetBlendMode("ADD")
	raidIcon:ClearAllPoints()
	raidIcon:SetPoint("LEFT", frame, "RIGHT", BAR_PADDING, 0)

	return
		{
			Finished = false,
			Finishing = false,
			Frame = frame,
			lblCountdown = lblCountdown,
			lblSpellname = lblSpellname,
			ProgressBar = bar,
			SpellIcon = spellIcon,
			RaidIcon = raidIcon
		}
end

local function SetTimerParent(timerData, parentFrame)
	timerData.Frame:ClearAllPoints()
	timerData.Frame:SetAllPoints(parentFrame)
	timerData.Frame:SetParent(parentFrame)
end

local function LinkTimerGroup(timerData, timerGroup)
	-- print("Finding timer in timerGroup 1 "..tostring(timerData.Group))
	-- if (timerData.Group) then
	-- 	print("Finding timer in timerGroup 2")
	-- 	for i = #timerData.Group.Timers, 1, -1 do
	-- 		print("Finding timer in timerGroup 3 "..tostring(i))
	-- 		if timerData.Group.Timers[i] == timerData then
	-- 			print("Finding timer in timerGroup 4 "..tostring(i))
	-- 			table.remove(timerData.Group, i)
	-- 		end
	-- 	end
	-- end
	timerData.Group = timerGroup
	table.insert(timerGroup.Timers, timerData)
end

local function InsertTimer(timerGroup)
	-- Find a finished timer
	local timerData = FindFreeTimer()
	--print("Free timer: "..tostring(timerData))
	if (not timerData) then
		-- Create a new timer with gui elements
		timerData = MakeTimerGui(timerGroup.Frame)
		timerData.Frame:SetAttribute("TimerData", timerData)
		table.insert(_t.Instances, timerData)
	end
	-- Change references to the current timer group
	SetTimerParent(timerData, timerGroup.Frame)
	-- Link and reverse link timer to group
	LinkTimerGroup(timerData, timerGroup)
	return timerData
end

local function StartTimer(timerData)
	-- Timers are split into 4 types: single, soulstone, self and debuff
	-- Single are Banish, Enslave Demon etc.
	-- Single and soulstone are displayed in the same timer group, banishes etc. on top, soulstones at the bottom
	-- The rest is displayed in a timer group per mob since it's dots etc.

	-- Set starting values
	timerData.ProgressBar:SetMinMaxValues(0, timerData.SpellDuration)
	timerData.ProgressBar:SetValue(timerData.SpellDuration)
	timerData.lblCountdown:SetText(timerData.SpellDuration)
	timerData.Value = timerData.SpellDuration
	timerData.SpellIcon:SetTexture(GetSpellTexture(timerData.SpellId))

	-- Assign the spell name or target
	if (timerData.SpellType == "soulstone" or timerData.SpellType == "single") then
		-- If we target outselves, display the spell name instead
		if (timerData.CasterGuid == timerData.TargetGuid) then
			timerData.lblSpellname:SetText(timerData.SpellName)
		else
			timerData.lblSpellname:SetText(timerData.TargetName)
		end
	else
		timerData.lblSpellname:SetText(timerData.SpellName)
	end

	SortTimerGroup(timerData.Group)

	-- Show the gui elements, starting the timer
	timerData.Group.Frame:Show()
	timerData.Frame:Show()
	-- print("timerData.Frame.isShown() "..tostring(timerData.Frame.isShown()))
	-- print("timerData.Frame.isVisible() "..tostring(timerData.Frame.isVisible()))
	-- print("timerData.Frame "..tostring(timerData.Frame)..", parent "..tostring(timerData.Group.Frame)..", "..timerData.SpellName)
	-- print("timerData.SpellName "..tostring(timerData.SpellName))
	
	-- Update functionality inspired by AceTimer library
	timerData.TickEnd = GetTime() + TICK_SECS
	timerData.UpdateFunc =
		function()
			if (not (timerData.Finished or timerData.Finishing)) then
				timerData.Value = timerData.Value - TICK_SECS
				local fraction = timerData.Value / timerData.SpellDuration
				
				-- Update progress bar
				timerData.ProgressBar:SetValue(timerData.Value)
				
				-- Display minutes:seconds or seconds.tenths
				if (timerData.Value > 60) then
					timerData.lblCountdown:SetText(_t:GetFormattedTime(timerData.Value))
				else
					local idx = string.find(timerData.Value, ".", 1, true)
					if (idx) then
						local str = string.sub(timerData.Value, 1, idx + 1)
						timerData.lblCountdown:SetText(str)
					end
				end
	
				-- Clear timer or continue ticking
				if (fraction <= 0) then
					RemoveTimer(timerData)
				else
					local time = GetTime()
					local delay = TICK_SECS - (time - timerData.TickEnd)
					-- Ensure the delay doesn't go below the threshold
					if delay < 0.01 then delay = 0.01 end
					C_Timer.After(delay, timerData.UpdateFunc)
					timerData.TickEnd = time + delay
				end
			end
		end

	-- Start ticking
	C_Timer.After(TICK_SECS, timerData.UpdateFunc)
end

function _t:InsertSpellTimer(casterGuid, casterName, targetGuid, targetName, targetLevel, targetIcon, spellId, spellName, spellDuration, spellType)
	assert(casterGuid ~= nil, 	 "casterGuid is nil")
	assert(casterName ~= nil, 	 "casterName is nil")
	assert(targetGuid ~= nil, 	 "targetGuid is nil")
	assert(targetName ~= nil, 	 "targetName is nil")
	assert(targetLevel ~= nil, 	 "targetLevel is nil")
	if (targetIcon == 0) then targetIcon = nil end
	assert(spellId ~= nil, 		 "spellId is nil")
	assert(spellName ~= nil, 	 "spellName is nil")
	assert(spellDuration ~= nil, "spellDuration is nil")
	assert(spellType ~= nil, 	 "spellType is nil")

	local timerData

	if (spellType == "soulstone" or spellType == "single" or spellType == "self") then
		-- If we cast soulstone or banish etc., tell our fellow warlocks
		if (casterGuid == Necrosis.CurrentEnv.PlayerGuid) then
			if (spellType == "soulstone") then

				-- local bandwidthIn, bandwidthOut, latencyHomeMS, latencyWorldMS = GetNetStats()
				-- print("Net Stats: "
				-- 	.."bandwidthIn: "..bandwidthIn
				-- 	..", bandwidthOut: "..bandwidthOut
				-- 	..", latencyHome: "..latencyHomeMS
				-- 	..", latencyWorld: "..latencyWorldMS)
				local ti = targetIcon
				if (ti == nil) then ti = 0 end

				-- Broadcast to raid/party if applicable
				EventHelper:SendAddonMessage("InsertTimer~"
					..casterGuid.."|"
					..casterName.."|"
					..targetGuid.."|"
					..targetName.."|"
					..targetLevel.."|"
					..ti.."|"
					..spellId.."|"
					..spellName.."|"
					..spellDuration.."|"
					..spellType
				)
			end
		end
		if (not _t.SingleFrame) then
			-- Create and position the group for single timers
			_t.SingleFrame = MakeTimerGroupGui(UIParent)
			PositionSingleTimerGroup()
		end
		-- Add single timer
		_t.SingleFrame.Title:SetText("Single")
		timerData = InsertTimer(_t.SingleFrame)
	else
		-- Add mob timer
		local timerGroup = FindMobTimerGroup(targetGuid)
--print("targetGuid "..tostring(targetGuid)..", "..tostring(timerGroup))
		if (not timerGroup) then
			timerGroup = FindFreeMobTimerGroup()
			if (not timerGroup) then
				timerGroup = MakeTimerGroupGui(UIParent)
				table.insert(_t.MobFrames, timerGroup)
			end
			timerGroup.Guid = targetGuid
			timerGroup.Title:SetText(targetName)
		end
		timerData = InsertTimer(timerGroup)
		PositionMobTimerGroups()
	end

	-- Set payload
	timerData.CasterGuid = casterGuid
	timerData.CasterName = casterName
	timerData.SpellId = spellId
	timerData.SpellName = spellName
	timerData.SpellDuration = spellDuration
	timerData.SpellType = spellType
	timerData.TargetGuid = targetGuid
	timerData.TargetName = targetName
	timerData.TargetLevel = targetLevel
	timerData.EndTime = GetTime() + spellDuration

	StartTimer(timerData)

	return timerData
end

-- Update an existing timer, a (de)buff has been casted on a target while it was still active
function _t:UpdateTimer(casterGuid, targetGuid, spellId, spellDuration)
	for i,timerData in ipairs(_t.Instances) do
		if (not (timerData.Finished or timerData.Finishing)
			and timerData.CasterGuid == casterGuid
			and timerData.TargetGuid == targetGuid
			and timerData.SpellId == spellId)
		then
			timerData.Value = spellDuration
			timerData.EndTime = GetTime() + spellDuration
			if (timerData.Group) then
				SortTimerGroup(timerData.Group)
			end
			return true
		end
	end
	return false
end

local function RemoveSoulstone(timerData)
	-- If soulstone is cast, don't use it's timer but the item cooldown.
	-- -> Is that better?
	-- Display and communicate duration and target name.
	-- When target dies or removes ss, check for item cooldown.
	-- If ss is on cooldown (which it should if the target dies f.e.),
	-- then update the display and communicate the cooldown.

	-- Remove the target guid to avoid removing the timer by accident
	timerData.TargetGuid = "-"
	UpdateRaidIcon(timerData, 8)
	if (timerData.CasterGuid == Necrosis.CurrentEnv.PlayerGuid) then
		-- Our own soulstone target died
		local isCd, cdSecs = ItemHelper:GetSoulstoneCooldownSecs()
		if (isCd) then
			timerData.Value = cdSecs
			timerData.lblSpellname:SetText("On Cooldown")
			EventHelper:SendAddonMessage(
				"UpdateTimer~"
				..timerData.CasterGuid.."|"
				..timerData.TargetGuid.."|"
				..timerData.SpellId.."|"
				..cdSecs
			)
		else
			-- Soulstone is ready, remove the timer
			RemoveTimer(timerData)
			EventHelper:SendAddonMessage(
				"RemoveSpellTimerTargetName~"
				..timerData.CasterGuid.."|"
				..timerData.TargetGuid.."|"
				..timerData.SpellName
			)
		end
	else
		-- Soulstone target of a fellow warlock died
		print("Soulstone of another warlock died: "..timerData.CasterName)
		timerData.lblSpellname:SetText("C/D - "..timerData.CasterName)
	end
end

-- The target died, remove all timers for it
function _t:RemoveSpellTimerTarget(targetGuid)
	for i,timerData in ipairs(self.Instances) do
		if (timerData.TargetGuid == targetGuid) then
			if (timerData.SpellType == "soulstone") then
				RemoveSoulstone(timerData)
			else
				RemoveTimer(timerData)
			end
		end
	end
end

-- A spell was removed from target
function _t:RemoveSpellTimerTargetName(casterGuid, targetGuid, spellName)
	for i,timerData in ipairs(self.Instances) do
		if (timerData.TargetGuid == targetGuid and timerData.SpellName == spellName) then
			if (timerData.SpellType == "soulstone") then
				RemoveSoulstone(timerData)
			else
				RemoveTimer(timerData)
			end
		end
	end
end

function _t:RemoveAllTimers()
	for i,timerData in ipairs(_t.Instances) do
		RemoveTimer(timerData)
	end
end

local function MakeAnchor(anchorFrame, anchorName, anchorText)
	if (anchorFrame) then
		anchorFrame:Show()
	else
		anchorFrame = GraphicsHelper:CreateMovableDialog(anchorName, BAR_HEIGHT, BAR_WIDTH)
		local tex = anchorFrame:CreateTexture(nil, "BACKGROUND")
		tex:SetAllPoints()
		tex:SetColorTexture(1, 1, 1, 0.5)
		local fs = anchorFrame:CreateFontString(nil, "OVERLAY", "NecrosisTimerFont")
		fs:ClearAllPoints()
		fs:SetAllPoints()
		fs:SetTextColor(0.5, 1, 0)
		fs:SetText(anchorText)
		fs:Show()
	end
	if (not GraphicsHelper:LoadPosition(anchorFrame)) then
		anchorFrame:SetPoint("TOPLEFT", 100, -100)
	end
	return anchorFrame
end

function _t:ShowMobAnchor()
	self.MobAnchor = MakeAnchor(self.MobAnchor, "NecrosisMobTimerAnchor", "Mob Anchor")
	-- Capture existing timer groups
	for i,mobFrame in ipairs(self.MobFrames) do
		mobFrame.Frame:SetParent(self.MobAnchor)
	end
	PositionMobTimerGroups()
end

function _t:HideMobAnchor()
	for i,mobFrame in ipairs(self.MobFrames) do
		mobFrame.Frame:SetParent(UIParent)
	end
	self.MobAnchor:Hide()
	self.MobAnchor = nil
	PositionMobTimerGroups()
end

function _t:ShowSingleAnchor()
	self.SingleAnchor = MakeAnchor(self.SingleAnchor, "NecrosisSingleTimerAnchor", "Single Anchor")
	PositionSingleTimerGroup()
end

function _t:HideSingleAnchor()
	if (_t.SingleFrame) then
		_t.SingleFrame.Frame:SetParent(UIParent)
	end
	_t.SingleAnchor:Hide()
	_t.SingleAnchor = nil
	PositionSingleTimerGroup()
end

function _t:UpdateRaidIcon(unitGuid, iconNumber)
	for i,mobFrame in ipairs(_t.MobFrames) do
		if (mobFrame.Guid == unitGuid) then
			if (#mobFrame.Timers > 0) then
				UpdateRaidIcon(mobFrame, iconNumber)
			end
			break
		end
	end
	-- Check for banish on a target
	if (_t.SingleFrame) then
		for i,timerData in ipairs(_t.SingleFrame.Timers) do
			if (timerData.TargetGuid == unitGuid
				and (timerData.SpellType == "soulstone"
				or timerData.SpellType == "single"
				or timerData.SpellType == "self"))
			then
				if (not (timerData.Finished or timerData.Finishing)) then
					UpdateRaidIcon(timerData, iconNumber)
				end
				break
			end
		end
	end
end

local function RemoveCombatTimers()
	for i,timerData in ipairs(_t.Instances) do
		if (timerData.SpellType == "debuff") then
			RemoveTimer(timerData)
		end
	end
end

function _t:Initialize()
	-- Set the default font for timer bars if none is configured
	if (not NecrosisConfig.TimerFont) then
		NecrosisConfig.TimerFont = Necrosis.Config.Fonts[1]
	end
	-- Also set default font size
	if (not NecrosisConfig.TimerFontSize) then
		NecrosisConfig.TimerFontSize = 12
	end
	-- Set the configured font and anchors
	_t:SetFont(NecrosisConfig.TimerFont.Path, NecrosisConfig.TimerFontSize)
	if (not NecrosisConfig.FramePosition["NecrosisMobTimerAnchor"]) then
		NecrosisConfig.FramePosition["NecrosisMobTimerAnchor"] =
			Config.FramePosition["NecrosisMobTimerAnchor"]
	end
	-- Do nothing else if timers are disabled
	if (not NecrosisConfig.EnableTimerBars) then
		return
	end
	-- Add soulstone timer if it's on cooldown
	local iscd, secs = ItemHelper:GetSoulstoneCooldownSecs()
	if (iscd) then
		local spellId = Necrosis.Spell.SoulstoneRez.SpellIds[1] -- Major Soulstone Resurrection
		-- Add the timer
		local ssTimer =
			_t:InsertSpellTimer(
				Necrosis.CurrentEnv.PlayerGuid,
				Necrosis.CurrentEnv.PlayerName,
				"-", "Cooldown", "0", nil,
				spellId,
				GetSpellInfo(spellId),
				Necrosis.Spell.AuraDuration[spellId],
				Necrosis.Spell.AuraType[spellId]
			)
		-- Set the remaining duration
		ssTimer.Value = secs
	end

	-- Remove all dots and banishes when combat stops
	-- This is required f.e. for the core hound packs in MC which don't die but smolder
	EventHelper:RegisterOnCombatStopHandler(RemoveCombatTimers)
end

function _t:Disable()
	_t:RemoveAllTimers()
	EventHelper:UnregisterOnCombatStopHandler(RemoveCombatTimers)
end
