-- This mod makes all supported chests breakable even when there are items inside.

chests = {}

local function is_locked(name, locked)
	if locked ~= nil then
		return locked
	end
	if name:find("_locked_chest", 1, true) then
		return true
	end
	return false
end

local function chest_after_dig(pos, node, meta, digger)
	local drops = {}
	for _, stack in ipairs(meta.inventory.main) do
		local item = stack:to_string()
		if item ~= "" then
			table.insert(drops, item)
		end
	end
	minetest.handle_node_drops(pos, drops, digger)
end

local function chest_can_dig_normal(pos, player)
	return true
end

local function chest_can_dig_locked(pos, player)
	return default.can_interact_with_node(player, pos)
end

local function update_chest_def(name, def, locked)
	print("update_chest_def: ", name, locked)
	def.after_dig_node = chest_after_dig
	if locked then
		def.can_dig = chest_can_dig_locked
	else
		def.can_dig = chest_can_dig_normal
	end
end

local function update_chest(name, locked)
	print("update_chest: ", name, locked)
	local def = {}
	update_chest_def(name, def, locked)
	minetest.override_item(name, def)
end

update_chest("default:chest", false)
update_chest("default:chest_locked", true)

for name, def in pairs(minetest.registered_nodes) do
	if name:find("^technic:.+_chest") then
		update_chest(name, is_locked(name))
	end
end

local register_node = minetest.register_node
function minetest.register_node(name, def)
	if name:find("^:technic:.+_chest") then
		update_chest_def(name, def, is_locked(name))
	end
	register_node(name, def)
end
