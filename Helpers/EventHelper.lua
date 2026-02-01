-- Class for central event management
EventHelper = {
    -- Events utilised by Necrosis
    ApiEvents = {
        "BAG_UPDATE",
        "CHAT_MSG_ADDON",
        "COMBAT_LOG_EVENT_UNFILTERED",
        "GROUP_ROSTER_UPDATE",
        "PLAYER_ALIVE",
        "PLAYER_DEAD",
        "PLAYER_REGEN_DISABLED",
        "PLAYER_REGEN_ENABLED",
        "PLAYER_TARGET_CHANGED",
        "PLAYER_UNGHOST",
        -- "UNIT_AURA",
        "UNIT_HEALTH",
        "UNIT_MANA",
        "UNIT_PET",
        "UNIT_SPELLCAST_FAILED",
        "UNIT_SPELLCAST_INTERRUPTED",
        "UNIT_SPELLCAST_SENT",
        "UNIT_SPELLCAST_START",
        "UNIT_SPELLCAST_SUCCEEDED",
        "SKILL_LINES_CHANGED",
        "SPELLS_CHANGED",
        "TRADE_ACCEPT_UPDATE",
        "TRADE_CLOSED",
        "TRADE_REQUEST",
        "TRADE_REQUEST_CANCEL",
        "TRADE_SHOW",
        -- "RAID_TARGET_UPDATE",
        -- "UNIT_FLAGS",
        -- GROUP_ROSTER_CHANGED
    }
}

-- Array with references to text change functions
local _onLanguageChangedHandlers = {}

local _eh = EventHelper

-- Localization event and handler
function _eh:RegisterLanguageChangedHandler(handler)
    table.insert(_onLanguageChangedHandlers, handler)
end

-- Notify language change
function _eh:OnLanguageChangedEvent(code)
    NecrosisConfig.Language = code
    Necrosis:SpellLocalize("tooltip")
    for i,handler in ipairs(_onLanguageChangedHandlers) do
        handler()
    end    
end

-- Events: PLAYER_ENTERING_WORLD and PLAYER_LEAVING_WORLD || Events : PLAYER_ENTERING_WORLD et PLAYER_LEAVING_WORLD
-- Function applied to each loading screen || Fonction appliquée à chaque écran de chargement
-- When you leave an area, you stop watching the surroundings || Quand on sort d'une zone, on arrête de surveiller les envents
-- When we enter an area, we resume surveillance || Quand on rentre dans une zone, on reprend la surveillance
-- This makes it possible to avoid a loading time that is too long for the mod || Cela permet d'éviter un temps de chargement trop long du mod
function _eh:AttachApiEvents()
    for i,e in ipairs(_eh.ApiEvents) do
        NecrosisButton:RegisterEvent(e)
    end
end

function _eh:ReleaseApiEvents()
    for i,e in ipairs(_eh.ApiEvents) do
        NecrosisButton:UnregisterEvent(e)
    end
end

function _eh:SendAddonMessage(message)
    local channel = "say"
    if (Necrosis.CurrentEnv.InRaid) then
        channel = "RAID"
    elseif (Necrosis.CurrentEnv.InParty) then
        channel = "PARTY"
    end
    local success = C_ChatInfo.SendAddonMessage(Necrosis.CurrentEnv.ChatPrefix, message, channel)
    -- print("_eh:SendAddonMessage: "..tostring(success))
end

-- Process messages from other warlocks in the raid or party
function _eh:ProcessAddonMessage(text)
    print("ProcessAddonMessage: "..tostring(text))
    local split_cmd = split(text, "~")
    -- print("command: "..tostring(split_cmd[1])..", "..tostring(split_cmd[2]))

    if (split_cmd[1] == "InsertTimer") then
        local split_timer = split(split_cmd[2], "|")
        Necrosis.Timers:InsertSpellTimer(
            split_timer[1], -- casterGuid
            split_timer[2], -- casterName
            split_timer[3], -- targetGuid
            split_timer[4], -- targetName
            split_timer[5], -- targetLevel
            split_timer[6], -- targetIcon
            split_timer[7], -- spellId
            split_timer[8], -- spellName
            split_timer[9], -- spellDuration
            split_timer[10] -- spellType
        )

    elseif (split_cmd[1] == "RemoveSpellTimerTargetName") then
        local split_timer = split(split_cmd[2], "|")
        -- print("Msg RemoveSpellTimerTargetName: "
        --     ..split_timer[1]..", "
        --     ..split_timer[2]..", "
        --     ..split_timer[3])
        Necrosis.Timers:RemoveSpellTimerTargetName(
            split_timer[1], -- casterGuid
            split_timer[2], -- targetGuid
            split_timer[3]  -- spellName
        )

    elseif (split_cmd[1] == "UpdateTimer") then
        local split_timer = split(split_cmd[2], "|")
        -- print("Msg UpdateTimer: "
        --     ..split_timer[1]..", "
        --     ..split_timer[2]..", "
        --     ..split_timer[3]..", "
        --     ..split_timer[4])
        Necrosis.Timers:UpdateTimer(
            split_timer[1], -- casterGuid
            split_timer[2], -- targetGuid
            split_timer[3], -- spellId
            split_timer[4]  -- spellDuration
        )
    end
end

-- Combat start event
local _onCombatStartHandlers = {}

function _eh:RegisterOnCombatStartHandler(handler)
    table.insert(_onCombatStartHandlers, handler)
end

function _eh:OnCombatStart()
    -- print("Combat starts...")
    for i,handler in ipairs(_onCombatStartHandlers) do
        handler()
    end
end

-- Combat finished event
local _onCombatStopHandlers = {}

function _eh:RegisterOnCombatStopHandler(handler)
    table.insert(_onCombatStopHandlers, handler)
end

function _eh:UnregisterOnCombatStopHandler(handler)
    local idx = table.indexOf(_onCombatStopHandlers, handler)
    if (idx and idx > 0) then
        table.remove(_onCombatStopHandlers, idx)
    end
end

function _eh:OnCombatStop()
    -- print("Combat stops...")
    for i,handler in ipairs(_onCombatStopHandlers) do
        handler()
    end
end

function _eh:IsCombatLocked()
    return InCombatLockdown()
end