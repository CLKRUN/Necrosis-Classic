BagHelper = {
	Soulshard_Count = 0,
	InfernalStone_Count = 0,
	DemonicFigure_Count = 0,
	
	Soulstone_IsAvailable = false,
	Soulstone_Rank = 0,
	Soulstone_Name = nil,

	Healthstone_IsAvailable = false,
	Healthstone_Rank = 0,
	Healthstone_ItemId = 0,
	Healthstone_Name = nil,
	Healthstone_BagId = nil,
	Healthstone_SlotId = nil,

	Firestone_IsAvailable = false,
	Firestone_Rank = 0,
	Firestone_Name = nil,

	Spellstone_IsAvailable = false,
	Spellstone_Rank = 0,
	Spellstone_Name = nil,

	Hearthstone_IsAvailable = false,
}

local _bh = BagHelper

function _bh:GetPlayerBags()
    local bagsArray = {}
    for i = 0, NUM_BAG_SLOTS, 1 do
		local bagName = NecrosisCompat.GetBagName(i)
		if (bagName) then
			local bagSlots = NecrosisCompat.GetContainerNumSlots(i)
			local itemType, itemSubType, _, _, _, _, classID, subclassID = select(6, GetItemInfo(bagName))
			table.insert(
				bagsArray,
				{
					id = i,
					name = bagName,
					type = itemSubType,
					capacity = bagSlots,
					isBag = (subclassID == 0), -- This is a normal bag, not profession specific
					isSoulBag = (subclassID == 1)
				}
			)
		end
	end
	return bagsArray
end

function _bh:GetStoneCounts()
	self.Soulshard_Count = GetItemCount(ItemHelper.Soulshard_Item_Id)
	self.InfernalStone_Count = GetItemCount(ItemHelper.InfernalStone_Item_Id)
	self.DemonicFigure_Count = GetItemCount(ItemHelper.DemonicFigure_Item_Id)
end

-- Explore bags for stones & shards || Fonction qui fait l'inventaire des éléments utilisés en démonologie : Pierres, Fragments, Composants d'invocation
function _bh:BagExplore(bagId)
	-- Only check inventory bags or -2 (same bag)
	if (bagId
		and (bagId < 0 or bagId > NUM_BAG_SLOTS)
	    and not (bagId == -2))
	then
		return
	end

	self.Soulstone_IsAvailable = false
	self.Soulstone_Rank = 0
	self.Soulstone_Name = nil
	self.Healthstone_IsAvailable = false
	self.Healthstone_Rank = 0
	self.Healthstone_ItemId = 0
	self.Healthstone_Name = nil
	self.Firestone_IsAvailable = false
	self.Firestone_Rank = 0
	self.Firestone_Name = nil
	self.Spellstone_IsAvailable = false
	self.Spellstone_Rank = 0
	self.Spellstone_Name = nil
	self.Hearthstone_IsAvailable = false

	-- Search all bags || Parcours des sacs
	local bagsArray = self:GetPlayerBags()
	for i,bag in ipairs(bagsArray) do
		if (bag.isBag) then
			self:_FindStones(bag)
		end
	end
end

function _bh:_FindStones(bag)
	-- Exit if its a known soul bag (which can only store shards) || Parcours des emplacements des sacs
	if (not bag.isSoulBag) then
		-- Iterate over the bag slots
		for slot = 1,bag.capacity,1 do
			local itemId = NecrosisCompat.GetContainerItemID(bag.id, slot)
			-- If there is an item located in that bag slot || Dans le cas d'un emplacement non vide
			if (itemId) then
				-- Check if its a soulstone and of higher rank than the current one
				if (ItemHelper:IsSoulstone(itemId)
					and self.Soulstone_Rank < ItemHelper.Soulstone[itemId].Rank)
				then
					self.Soulstone_IsAvailable = true
					self.Soulstone_Rank = ItemHelper.Soulstone[itemId].Rank
					self.Soulstone_Name = ItemHelper.Soulstone[itemId].Name
					-- Update its button attributes on the sphere || On attache des actions au bouton de la pierre
					SphereButtonHelper:SoulstoneUpdateAttribute()

				-- Check if its a healthstone and of higher rank than the current one
				elseif (ItemHelper:IsHealthstone(itemId)
					and self.Healthstone_Rank <= ItemHelper.Healthstone[itemId].Rank
					and self.Healthstone_ItemId < itemId) -- Check if there is a 0, 1 or 2x improved healthstone
				then
					self.Healthstone_IsAvailable = true
					self.Healthstone_Rank = ItemHelper.Healthstone[itemId].Rank
					self.Healthstone_ItemId = itemId
					self.Healthstone_BagId = bag.id
					self.Healthstone_SlotId = slot
					self.Healthstone_Name = ItemHelper.Healthstone[itemId].Name
					-- Update its button attributes on the sphere || On attache des actions au bouton de la pierre
					SphereButtonHelper:HealthstoneUpdateAttribute()

				-- Check if its a spellstone and of higher rank than the current one
				elseif (ItemHelper:IsSpellstone(itemId)
					and self.Spellstone_Rank < ItemHelper.Spellstone[itemId].Rank)
				then
					self.Spellstone_IsAvailable = true
					self.Spellstone_Rank = ItemHelper.Spellstone[itemId].Rank
					self.Spellstone_Name = ItemHelper.Spellstone[itemId].Name
					-- Update its button attributes on the sphere || On attache des actions au bouton de la pierre
					SphereButtonHelper:SpellstoneUpdateAttribute()

				-- Check if its a firestone and of higher rank than the current one
				elseif (ItemHelper:IsFirestone(itemId)
					and self.Firestone_Rank < ItemHelper.Firestone[itemId].Rank)
				then
					self.Firestone_IsAvailable = true
					self.Firestone_Rank = ItemHelper.Firestone[itemId].Rank
					self.Firestone_Name = ItemHelper.Firestone[itemId].Name
					-- Update its button attributes on the sphere || On attache des actions au bouton de la pierre
					SphereButtonHelper:FirestoneUpdateAttribute()

				-- Check if its a hearthstone || et enfin la pierre de foyer
				elseif (ItemHelper:IsHearthstone(itemId)) then
					self.Hearthstone_IsAvailable = true
				end
			end
		end
	end
end

function _bh:DestroyShards(maxToKeep)
	self.Soulshard_Count = GetItemCount(ItemHelper.Soulshard_Item_Id)
	for i,bag in ipairs(self:GetPlayerBags()) do
		-- Skip soul bags
		if (not bag.isSoulBag) then
			-- Iterate over the bag slots
			for slot = 1,bag.capacity,1 do
				if (maxToKeep >= self.Soulshard_Count) then
					break
				end
				if (self:TryDestroyShard(bag.id, slot)) then
					self.Soulshard_Count = self.Soulshard_Count - 1
				end
			end
		end
	end
end

function _bh:TryDestroyShard(bagId, slot)
	local itemId = NecrosisCompat.GetContainerItemID(bagId, slot)
	if (itemId == ItemHelper.Soulshard_Item_Id) then
		PickupContainerItem(bagId, slot)
		if (CursorHasItem()) then
			DeleteCursorItem()
			return true
		end
	end
	return false
end
