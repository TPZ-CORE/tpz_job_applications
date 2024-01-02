local TPZInv      = exports.tpz_inventory:getInventoryAPI()

-----------------------------------------------------------
--[[ Items Registration  ]]--
-----------------------------------------------------------

-- @param source     - returns the player source.
-- @param item       - returns the item name.
-- @param itemId     - returns the itemId (itemId exists only for non-stackable items) otherwise it will return as "0"
-- @param id         - returns the item id which is located in the tpz_items table.
-- @param label      - returns the item label name.
-- @param weight     - returns the item weight.
-- @param durability - returns the durability (exists only for non-stackable items).
-- @param metadata   - returns the metadata that you have created on the given item.

TPZInv.registerUsableItem(Config.DocumentItem, "tpz_job_applications", function(data)
	local _source = data.source

	local applicationId = data.metadata.applicationId

    TriggerClientEvent('tpz_job_applications:showApplicationDocument', _source, applicationId)

	TPZInv.closeInventory(_source)
end)
