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
-- Message handler (CONSOLE, CHAT, MESSAGE SYSTEM)
------------------------------------------------------------------------------------------------------

Necrosis.Chat = {
	LastSoulstoneMessageNumber = false,
	LastMountMessageNumber = false,
	LastRitualOfSoulsMessageNumber = false,
	LastRitualOfSummoningMessageNumber = false,
	LastDemonMessageNumber = false,
	LastDemonicSacrificeMessageNumber = false,
	TargetName = false,
	PetType = false,
	MsgTableAfter = false,
	MsgTableBefore = false
}

local _chat = Necrosis.Chat

------------------------------------------------------------------------------------------------------
-- Handles the posting of messages while casting a spell.
------------------------------------------------------------------------------------------------------
function _chat:BeforeSpellCast(spellData)
	if not NecrosisConfig.ChatMsg then
		-- Chat messages have been disabled
		return nil
	end

	-- messages to be posted while summoning a mount
	if (spellData.Name == Necrosis.Spell[1].Name or spellData.Name == Necrosis.Spell[2].Name) then
		if NecrosisConfig.SteedSummon then
			_chat:SummonMount()
		end
	-- messsages to be posted while casting 'Ritual of Souls' -Draven (April 3rd, 2008)
	elseif spellData.Name == Necrosis.Spell[50].Name then
		if NecrosisConfig.RoSSummon then
			_chat:CastRitualOfSouls()
		end
	-- messages to be posted while casting 'Soulstone' on a friendly target
	elseif tContains(Necrosis.Spell.SoulstoneRez.SpellIds, spellData.SpellId)
			and spellData.TargetName ~= nil
			and spellData.TargetName ~= Necrosis.CurrentEnv.PlayerName
	then
		_chat:CastSoulstone(spellData.TargetName)
	-- messages to be posted while casting 'Ritual of Summoning'
	elseif spellData.Name == Necrosis.Spell[37].Name then
		_chat:CastRitualOfSummoning(spellData.TargetName)
		AlphaBuffMenu = 1
		AlphaBuffVar = GetTime() + 3
	-- Messages for summoning Imp
	elseif spellData.Name == Necrosis.Spell[3].Name then
		if NecrosisConfig.DemonSummon then
			_chat:SummonDemon("Imp")
		end
	-- Messages for summoning Voidwalker
	elseif spellData.Name == Necrosis.Spell[4].Name then
		if NecrosisConfig.DemonSummon then
			_chat:SummonDemon("Voidwalker")
		end
	-- Messages for summoning Succubus
	elseif spellData.Name == Necrosis.Spell[5].Name then
		if NecrosisConfig.DemonSummon then
			_chat:SummonDemon("Succubus")
		end
	-- Messages for summoning Felhunter
	elseif spellData.Name == Necrosis.Spell[6].Name then
		if NecrosisConfig.DemonSummon then
			_chat:SummonDemon("Felhunter")
		end
	-- Messages for summoning Felguard
	elseif spellData.Name == Necrosis.Spell[7].Name then
		if NecrosisConfig.DemonSummon then
			_chat:SummonDemon("Felguard")
		end
	-- Messages for Demonic Sacrifice
	elseif spellData.Name == Necrosis.Spell[44].Name then
		if NecrosisConfig.DemonicSacrifice then
			_chat:CastDemonicSacrifice(Necrosis.CurrentEnv.DemonType)
		end
	end
end

------------------------------------------------------------------------------------------------------
-- Handles the posting of messages after a spell has been cast.
------------------------------------------------------------------------------------------------------
function _chat:AfterSpellCast()
	if (_chat.MsgTableAfter) then
		_chat:_PostMessages(_chat.MsgTableAfter)
		_chat.MsgTableAfter = nil
	end
end

function _chat:ClearMessages()
	_chat.MsgTableBefore = nil
	_chat.MsgTableAfter = nil
end


--
-- Start of refactored code
--

function _chat:CastSoulstone(targetName)
	-- Determine the message source table
	local msgTable = self:_GetShortOrFullMsgTable(
		Necrosis.Speech.ShortMessage.Soulstone,
		Necrosis.Speech.Rez
	)
	if not msgTable then
		print("No messages for Soulstone available...")
		return nil
	end
	-- Set available values
	self.TargetName = targetName
	self.PetType = nil
	-- Create and post random message
	-- Also set messages to be posted after the spell has been cast successfully
	self.LastSoulstoneMessageNumber = self:_PostRandomMessage(msgTable, self.LastSoulstoneMessageNumber)
end

function _chat:SummonMount()
	-- Determine the message source table
	local msgTable = self:_GetShortOrFullMsgTable(
		Necrosis.Speech.ShortMessage.Mount,
		Necrosis.Speech.Mount
	)
	if not msgTable then
		print("No messages for Mount available...")
		return nil
	end
	-- Set available values
	self.TargetName = nil
	self.PetType = nil
	-- Create and post random message
	-- Also set messages to be posted after the spell has been cast successfully
	self.LastMountMessageNumber = self:_PostRandomMessage(msgTable, self.LastMountMessageNumber)
end

function _chat:CastRitualOfSouls()
	-- Determine the message source table
	local msgTable = self:_GetShortOrFullMsgTable(
		Necrosis.Speech.ShortMessage.RitualOfSouls,
		Necrosis.Speech.RoS
	)
	if not msgTable then
		print("No messages for RitualOfSouls available...")
		return nil
	end
	-- Set available values
	self.TargetName = nil
	self.PetType = nil
	-- Create and post random message
	-- Also set messages to be posted after the spell has been cast successfully
	self.LastRitualOfSoulsMessageNumber = self:_PostRandomMessage(msgTable, self.LastRitualOfSoulsMessageNumber)
end

function _chat:CastRitualOfSummoning(targetName)
	-- Determine the message source table
	local msgTable = self:_GetShortOrFullMsgTable(
		Necrosis.Speech.ShortMessage.RitualOfSummoning,
		Necrosis.Speech.TP
	)
	if not msgTable then
		print("No messages for RitualOfSummoning available...")
		return nil
	end
	-- Set available values
	self.TargetName = targetName
	self.PetType = nil
	-- Create and post random message
	-- Also set messages to be posted after the spell has been cast successfully
	self.LastRitualOfSummoningMessageNumber = self:_PostRandomMessage(msgTable, self.LastRitualOfSummoningMessageNumber)
end

function _chat:SummonDemon(petType)
	-- Determine the message source table
	local msgTable = self:_GetShortOrFullMsgTable(
		Necrosis.Speech.ShortMessage.Demon,
		Necrosis.Speech.Demon[petType]
	)
	if not msgTable then
		print("No messages for Demon available...")
		return nil
	end
	-- Set available values
	self.TargetName = nil
	self.PetType = petType
	-- Create and post random message
	-- Also set messages to be posted after the spell has been cast successfully
	self.LastDemonMessageNumber = self:_PostRandomMessage(msgTable, self.LastDemonMessageNumber)
end

function _chat:CastDemonicSacrifice(petType)
	-- Determine the message source table
	local msgTable = self:_GetShortOrFullMsgTable(
		Necrosis.Speech.ShortMessage.DemonicSacrifice,
		Necrosis.Speech.DemonicSacrifice[petType]
	)
	if not msgTable then
		print("No messages for DemonicSacrifice available...")
		return nil
	end
	-- Set available values
	self.TargetName = nil
	self.PetType = petType
	-- Create and post random message
	-- Also set messages to be posted after the spell has been cast successfully
	self.LastDemonicSacrificeMessageNumber = self:_PostRandomMessage(msgTable, self.LastDemonicSacrificeMessageNumber)
end

function _chat:_GetShortOrFullMsgTable(shortMsgTable, fullMsgTable)
	if NecrosisConfig.SM then
		-- Check if any short messages are available
		if (not shortMsgTable) then
			print("No shortMessageTable entries available, aborting...")
			return nil
		end
		return shortMsgTable
	else
		-- Check if any normal messages are available
		if (not fullMsgTable) then
			print("No fullMsgTable entries available, aborting...")
			return nil
		end
		return fullMsgTable
	end
end

function _chat:_PostRandomMessage(msgTable, lastMsgNumber)
	-- Take a random message, if possible not the same as last time
	local lastMsgNumber, msgList = self:_GetRandomMessageNumber(lastMsgNumber, msgTable)
	self:_PrepareMessageTables(msgList)
	-- Post immediate messages before the spell is cast
	self:_PostMessages(self.MsgTableBefore)
	-- Other messages are posted after the spell finishes
	return lastMsgNumber
end

function _chat:_GetRandomMessageNumber(lastNumber, msgTable)
	local tmp = 0
	repeat 
		tmp = math.random(1, #msgTable)
	until (not (tmp == lastNumber) or #msgTable == 1)
	return tmp, msgTable[tmp]
end

function _chat:_PrepareMessageTables(msgList)
	self.MsgTableBefore = {}
	self.MsgTableAfter = {}
	for i in ipairs(msgList) do
		-- Check if the message should be posted before or after spellcast
		if string.find(msgList[i], "<after>") then
			-- Remove the <after> meta tag from the message before storing it
			table.insert(self.MsgTableAfter, self:_ParseChannelAndMessageData(string.gsub(msgList[i], "<after>", "", 1)))
		else
			table.insert(self.MsgTableBefore, self:_ParseChannelAndMessageData(msgList[i]))
		end
	end
end

function _chat:_ParseChannelAndMessageData(msg)
	local chatType
	if string.find(msg, "<emote>") then
		chatType = "EMOTE"
	elseif string.find(msg, "<yell>") then
		chatType = "YELL"
	elseif string.find(msg, "<say>") then
		chatType = "SAY"
	else
		chatType = "WORLD"
	end
	return {channel = chatType, msg = self:_ReplaceMessagePlaceholders(msg)}
end

------------------------------------------------------------------------------------------------------
-- Replace user-friendly string variables in the invocation messages
------------------------------------------------------------------------------------------------------
function _chat:_ReplaceMessagePlaceholders(msg)
	msg = msg:gsub("<player>", UnitName("player"))
	msg = msg:gsub("<emote>", "")
	msg = msg:gsub("<after>", "")
	msg = msg:gsub("<sacrifice>", "")
	msg = msg:gsub("<yell>", "")
	msg = msg:gsub("<say>", "")
	if self.TargetName then
		msg = msg:gsub("<target>", self.TargetName)
	end
	if self.PetType and NecrosisConfig.PetName[self.PetType] then
		msg = msg:gsub("<pet>", NecrosisConfig.PetName[self.PetType])
	end
	return msg
end

function _chat:_PostMessages(msgTable)
	for i,data in ipairs(msgTable) do
		self:_Msg(data.msg, data.channel)
	end
end

function _chat:_Msg(msg, channel)
	-- dispatch the message to the appropriate chat channel depending on the message type
	if (channel == "WORLD") then
		if (Necrosis.CurrentEnv.InRaid) then
			-- send to all raid members
			channel = "RAID"
		elseif (Necrosis.CurrentEnv.InParty) then
			-- send to party members
			channel = "PARTY"
		else
			-- not in a group so lets use the 'say' channel
			channel = "SAY"
		end
	end

	if (channel == "PARTY") then
		SendChatMessage(msg, _G.PARTY)
	elseif (channel == "RAID") then
		SendChatMessage(msg, _G.RAID)
	elseif (channel == "EMOTE") then
		SendChatMessage(msg, _G.EMOTE)
	-- SAY and YELL are protected functions and can't be called without hardware event anymore
	elseif (channel == "SAY") and IsInInstance() then
		SendChatMessage(msg, _G.SAY)
	elseif (channel == "YELL") and IsInInstance() then
		SendChatMessage(msg, _G.YELL)
	else
		-- Add some color to our message :D
		local msg = self:_ColorizeMessage(msg)
		local intro = "|CFFFF00FFNe|CFFFF50FFcr|CFFFF99FFos|CFFFFC4FFis|CFFFFFFFF: "
		if NecrosisConfig.ChatType then
			-- ...... on the first chat frame
			ChatFrame1:AddMessage(intro..msg, 1.0, 0.7, 1.0, 1.0, UIERRORS_HOLD_TIME)
		else
			-- ...... on the middle of the screen
			UIErrorsFrame:AddMessage(intro..msg, 1.0, 0.7, 1.0, 1.0, UIERRORS_HOLD_TIME)
		end
	end
end

-- Replace any color strings in the message with its associated value
function _chat:_ColorizeMessage(msg)
	if type(msg) == "string" then
		msg = msg:gsub("<white>", "|CFFFFFFFF")
		msg = msg:gsub("<lightBlue>", "|CFF99CCFF")
		msg = msg:gsub("<brightGreen>", "|CFF00FF00")
		msg = msg:gsub("<lightGreen2>", "|CFF66FF66")
		msg = msg:gsub("<lightGreen1>", "|CFF99FF66")
		msg = msg:gsub("<yellowGreen>", "|CFFCCFF66")
		msg = msg:gsub("<lightYellow>", "|CFFFFFF66")
		msg = msg:gsub("<darkYellow>", "|CFFFFCC00")
		msg = msg:gsub("<lightOrange>", "|CFFFFCC66")
		msg = msg:gsub("<dirtyOrange>", "|CFFFF9933")
		msg = msg:gsub("<darkOrange>", "|CFFFF6600")
		msg = msg:gsub("<redOrange>", "|CFFFF3300")
		msg = msg:gsub("<red>", "|CFFFF0000")
		msg = msg:gsub("<lightRed>", "|CFFFF5555")
		msg = msg:gsub("<lightPurple1>", "|CFFFFC4FF")
		msg = msg:gsub("<lightPurple2>", "|CFFFF99FF")
		msg = msg:gsub("<purple>", "|CFFFF50FF")
		msg = msg:gsub("<darkPurple1>", "|CFFFF00FF")
		msg = msg:gsub("<darkPurple2>", "|CFFB700B7")
		msg = msg:gsub("<close>", "|r")
	end
	return msg
end
