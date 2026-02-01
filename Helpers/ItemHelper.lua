ItemHelper = {
    Soulshard_Item_Id = 6265,
    InfernalStone_Item_Id = 5565,
    DemonicFigure_Item_Id = 16583,
    
    Hearthstone_Item_Id = 6948,

    Firestone = {
        ItemIds = {
            1254,  -- Lesser
            13699, -- Normal
            13700, -- Greater
            13701, -- Major
            22128  -- Master
        }
    },

    Healthstone = {
        ItemIds = {
            5512,  -- Minor (0 talent points)
            19004, -- Minor (1 talent point)
            19005, -- Minor (2 talent points)
            5511,  -- Lesser (0 talent points)
            19006, -- Lesser (1 talent point)
            19007, -- Lesser (2 talent points)
            5509,  -- Normal (0 talent points)
            19008, -- Normal (1 talent point)
            19009, -- Normal (2 talent points)
            5510,  -- Greater (0 talent points)
            19010, -- Greater (1 talent point)
            19011, -- Greater (2 talent points)
            9421,  -- Major (0 talent points)
            19012, -- Major (1 talent point)
            19013, -- Major (2 talent points)
            22103, -- Master (0 talent points)
            22104, -- Master (1 talent point)
            22105  -- Master (2 talent points)
        }
    },

    Soulstone = {
        ItemIds = {
            5232,  -- Minor
            16892, -- Lesser
            16893, -- Normal
            16895, -- Greater
            16896, -- Major
            22116  -- Master
        }
    },

    Spellstone = {
        ItemIds = {
            5522,  -- Normal
            13602, -- Greater
            13603, -- Major
            22646  -- Master
        }
    }
}

local _ih = ItemHelper

local _ih_countdown = 0
local _ih_callback = nil

function _ih:RegisterStonesLoadedHandler(callback)
    _ih_callback = callback
end

function _ih:FireStonesLoadedHandler()
    _ih_callback()
end

local function MakeItemIdRanksAndNames(root)
    -- i is the rank of the item
    -- Create an entry in the form of [itemId] = { Rank = i, Name = blah }
    for i,id in ipairs(root.ItemIds) do
        -- Use callbacks to get item info because the client calls the server
        -- for each itemId and caches the result locally when received.
        local item = Item:CreateFromItemID(id)
        item:ContinueOnItemLoad(
            function()
                root[id] = {
                    Rank = i,
                    Name = item:GetItemName()
                }
                -- This is usually a bad idea in multithreaded apps, but works here for now
                _ih_countdown = _ih_countdown - 1
                if (_ih_countdown == 0) then
                    _ih:FireStonesLoadedHandler()
                end
            end
        )
    end
end

function _ih:Initialize()
    -- Set the counter for when to fire the stones loaded callback
    _ih_countdown
        = #self.Healthstone.ItemIds
        + #self.Firestone.ItemIds
        + #self.Spellstone.ItemIds
        + #self.Soulstone.ItemIds

    MakeItemIdRanksAndNames(self.Healthstone)
    MakeItemIdRanksAndNames(self.Firestone)
    MakeItemIdRanksAndNames(self.Spellstone)
    MakeItemIdRanksAndNames(self.Soulstone)
end

function _ih:IsFirestone(itemId)
    return tContains(self.Firestone.ItemIds, itemId)
end

function _ih:IsHealthstone(itemId)
    return tContains(self.Healthstone.ItemIds, itemId)
end

function _ih:IsHearthstone(itemId)
    return (self.Hearthstone_Item_Id == itemId)
end

function _ih:IsSoulstone(itemId)
    return tContains(self.Soulstone.ItemIds, itemId)
end

function _ih:IsSpellstone(itemId)
    return tContains(self.Spellstone.ItemIds, itemId)
end

-- Cooldowns
function _ih:IsSoulstoneOnCooldown()
	local secs = self:GetItemCooldownInSecs(self.Soulstone.ItemIds[1])
	return (secs > 0)
end

function _ih:GetSoulstoneCooldown()
	return self:GetItemCooldownTime(self.Soulstone.ItemIds[1])
end

function _ih:GetSoulstoneCooldownSecs()
	local secs = self:GetItemCooldownInSecs(self.Soulstone.ItemIds[1])
	return (secs > 0), secs
end

function _ih:GetHealthstoneCooldown()
	return self:GetItemCooldownTime(self.Healthstone.ItemIds[1])
end

function _ih:GetHearthstoneCooldown()
	return self:GetItemCooldownTime(self.Healthstone.ItemIds[1])
end

function _ih:GetItemCooldownTime(itemId)
	local secs = self:GetItemCooldownInSecs(itemId)
	return (secs > 0), Necrosis.Timers:GetFormattedTime(secs)
end

function _ih:GetItemCooldownInSecs(itemId)
	local startTime, duration, enable = NecrosisCompat.GetItemCooldown(itemId)
	if enable == 0 then
		return 0
	end
	if startTime == 0 then
		return 0
	end
	local remainingSecs = math.floor(duration - (GetTime() - startTime))
	return remainingSecs
end
