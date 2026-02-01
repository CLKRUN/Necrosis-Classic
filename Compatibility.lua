--[[
    Necrosis Compatibility Layer for TBC Anniversary (Interface 20505)
    
    This file provides runtime compatibility shims for API changes between
    Classic/TBC and modern WoW clients. It detects which APIs are available
    and creates wrappers to maintain addon functionality.
    
    Load this file EARLY in the TOC to ensure shims are available before
    other addon code runs.
--]]

local _G = getfenv(0)
local compat = {}

------------------------------------------------------------------------------------------------------
-- ADDON API COMPATIBILITY
-- C_AddOns namespace was introduced in later expansions
------------------------------------------------------------------------------------------------------

if C_AddOns then
    -- Modern API available (Retail/newer clients)
    compat.GetAddOnMetadata = function(name, field)
        return C_AddOns.GetAddOnMetadata(name, field)
    end
    
    compat.IsAddOnLoaded = function(name)
        return C_AddOns.IsAddOnLoaded(name)
    end
    
    compat.LoadAddOn = function(name)
        return C_AddOns.LoadAddOn(name)
    end
else
    -- Classic/TBC API (use global functions)
    compat.GetAddOnMetadata = GetAddOnMetadata
    compat.IsAddOnLoaded = IsAddOnLoaded
    compat.LoadAddOn = LoadAddOn
end

------------------------------------------------------------------------------------------------------
-- CONTAINER/BAG API COMPATIBILITY
-- C_Container namespace was introduced in later expansions
------------------------------------------------------------------------------------------------------

if C_Container then
    -- Modern API available
    compat.GetContainerNumSlots = function(bagID)
        return C_Container.GetContainerNumSlots(bagID)
    end
    
    compat.GetBagName = function(bagID)
        if C_Container.GetBagName then
            return C_Container.GetBagName(bagID)
        else
            -- Fallback: get bag item link and extract name
            local inventoryID = ContainerIDToInventoryID(bagID)
            if inventoryID then
                local itemLink = GetInventoryItemLink("player", inventoryID)
                if itemLink then
                    return GetItemInfo(itemLink)
                end
            end
            return nil
        end
    end
    
    compat.GetContainerItemInfo = function(bagID, slot)
        local info = C_Container.GetContainerItemInfo(bagID, slot)
        if info then
            -- Convert new structure to old return values
            return info.iconFileID, info.stackCount, info.isLocked, info.quality,
                   info.isReadable, info.hasLoot, info.hyperlink, info.isFiltered,
                   info.hasNoValue, info.itemID
        end
        return nil
    end
    
    compat.GetContainerItemLink = function(bagID, slot)
        return C_Container.GetContainerItemLink(bagID, slot)
    end
    
    compat.GetContainerItemID = function(bagID, slot)
        if C_Container.GetContainerItemID then
            return C_Container.GetContainerItemID(bagID, slot)
        else
            local itemInfo = C_Container.GetContainerItemInfo(bagID, slot)
            return itemInfo and itemInfo.itemID
        end
    end
    
    compat.GetContainerItemCooldown = function(bagID, slot)
        return C_Container.GetContainerItemCooldown(bagID, slot)
    end
    
    compat.PickupContainerItem = function(bagID, slot)
        return C_Container.PickupContainerItem(bagID, slot)
    end
    
    compat.UseContainerItem = function(bagID, slot, onSelf)
        return C_Container.UseContainerItem(bagID, slot, onSelf)
    end
else
    -- Classic/TBC API (use global functions)
    compat.GetContainerNumSlots = GetContainerNumSlots
    compat.GetContainerItemInfo = GetContainerItemInfo
    compat.GetContainerItemLink = GetContainerItemLink
    compat.GetContainerItemID = GetContainerItemID
    compat.GetContainerItemCooldown = GetContainerItemCooldown
    compat.PickupContainerItem = PickupContainerItem
    compat.UseContainerItem = UseContainerItem
    
    -- GetBagName doesn't exist in TBC Anniversary - need to construct it
    compat.GetBagName = function(bagID)
        local inventoryID = ContainerIDToInventoryID(bagID)
        if inventoryID then
            local itemLink = GetInventoryItemLink("player", inventoryID)
            if itemLink then
                return GetItemInfo(itemLink)
            end
        end
        return nil
    end
end

------------------------------------------------------------------------------------------------------
-- SPELL API COMPATIBILITY
------------------------------------------------------------------------------------------------------

-- IsSpellKnown is available in TBC, no shim needed
compat.IsSpellKnown = IsSpellKnown or function(spellID)
    -- Fallback: check spellbook
    local i = 1
    while true do
        local spellName, spellSubName = GetSpellName(i, BOOKTYPE_SPELL)
        if not spellName then
            break
        end
        local spellId = select(7, GetSpellInfo(spellName))
        if spellId == spellID then
            return true
        end
        i = i + 1
    end
    return false
end

------------------------------------------------------------------------------------------------------
-- ITEM API COMPATIBILITY
------------------------------------------------------------------------------------------------------

-- GetItemInfo should work in TBC, but add safety check
if not GetItemInfo then
    compat.GetItemInfo = function(itemID)
        return nil
    end
else
    compat.GetItemInfo = GetItemInfo
end

-- GetItemCooldown compatibility
if C_Item and C_Item.GetItemCooldown then
    compat.GetItemCooldown = function(itemID)
        return C_Item.GetItemCooldown(itemID)
    end
elseif GetItemCooldown then
    compat.GetItemCooldown = GetItemCooldown
else
    -- Fallback for very old clients
    compat.GetItemCooldown = function(itemID)
        return 0, 0, 1
    end
end

------------------------------------------------------------------------------------------------------
-- UNIT API COMPATIBILITY
------------------------------------------------------------------------------------------------------

-- UnitGUID should be available in TBC
compat.UnitGUID = UnitGUID or function(unit)
    -- Fallback for very old clients (shouldn't be needed for TBC)
    return nil
end

------------------------------------------------------------------------------------------------------
-- REGISTER COMPATIBILITY LAYER GLOBALLY
------------------------------------------------------------------------------------------------------

-- Make compat table available globally for addon use
_G.NecrosisCompat = compat

-- Optionally override global functions if needed (use with caution)
-- This approach lets existing code work without changes
-- but only do this if the APIs don't already exist

if not GetAddOnMetadata and compat.GetAddOnMetadata then
    _G.GetAddOnMetadata = compat.GetAddOnMetadata
end

if not IsAddOnLoaded and compat.IsAddOnLoaded then
    _G.IsAddOnLoaded = compat.IsAddOnLoaded
end

if not LoadAddOn and compat.LoadAddOn then
    _G.LoadAddOn = compat.LoadAddOn
end

-- Note: We DON'T override container functions globally since they exist in TBC
-- The addon code should use the compat wrappers or these functions already work

------------------------------------------------------------------------------------------------------
-- TOOLTIP BACKDROP COMPATIBILITY (for future-proofing)
------------------------------------------------------------------------------------------------------

-- In later clients, CreateFrame requires "BackdropTemplate" for frames that use SetBackdrop
-- TBC Anniversary should still support the old method, but add detection for safety

compat.CreateFrameWithBackdrop = function(frameType, name, parent, template)
    local frame
    
    -- Try with BackdropTemplate first (for newer clients)
    if template then
        local success
        success, frame = pcall(CreateFrame, frameType, name, parent, template .. ",BackdropTemplate")
        if success and frame then
            return frame
        end
    end
    
    -- Fall back to standard creation (works in TBC)
    frame = CreateFrame(frameType, name, parent, template)
    return frame
end

------------------------------------------------------------------------------------------------------
-- DEBUG/UTILITY
------------------------------------------------------------------------------------------------------

compat.DebugPrint = function(msg)
    if DEFAULT_CHAT_FRAME then
        DEFAULT_CHAT_FRAME:AddMessage("|cFF9482C9Necrosis Compat:|r " .. tostring(msg))
    end
end

-- Print compatibility layer status on load
if DEFAULT_CHAT_FRAME then
    local apis = {}
    if C_AddOns then table.insert(apis, "C_AddOns") end
    if C_Container then table.insert(apis, "C_Container") end
    
    if #apis > 0 then
        compat.DebugPrint("Loaded with modern APIs: " .. table.concat(apis, ", "))
    else
        compat.DebugPrint("Loaded with Classic/TBC APIs")
    end
end

return compat
