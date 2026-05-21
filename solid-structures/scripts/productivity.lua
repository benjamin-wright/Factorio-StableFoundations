local Shared = require("shared")
local Productivity = {}

local function canReceiveBonus(entity)
	if not entity.valid or entity.type == "beacon" then return false end
	local effects = entity.prototype.allowed_effects
	if not effects then return false end
	for _, e in ipairs(effects) do
		if e == "productivity" then return true end
	end
	return false
end

function Productivity.applyBonus(surface, entity, tier)
	if not canReceiveBonus(entity) then
		Productivity.removeBonus(entity)
		return
	end

	local value = Shared.PRODUCTIVITY[tier]
	if not value or value <= 0 then
		Productivity.removeBonus(entity)
		return
	end

	local uid = entity.unit_number
	storage.ssBonusBeacons = storage.ssBonusBeacons or {}
	local beacon = storage.ssBonusBeacons[uid]

	if beacon and not beacon.valid then
		beacon = nil
		storage.ssBonusBeacons[uid] = nil
	end

	if not beacon then
		beacon = surface.create_entity {
			name = "ss-productivity-beacon",
			position = entity.position,
			force = entity.force
		}
		if not beacon then return end
		beacon.destructible = false
		beacon.minable = false
		beacon.operable = false
		storage.ssBonusBeacons[uid] = beacon
	end

	local inv = beacon.get_module_inventory()
	for i = 1, #inv do
		if inv[i].valid_for_read then inv[i].clear() end
	end

	local moduleName = "ss-productivity-module-" .. tier
	if prototypes.item[moduleName] then
		inv.insert({ name = moduleName, count = 1 })
	end
end

function Productivity.removeBonus(entity)
	local uid = entity and entity.unit_number
	if not (uid and storage.ssBonusBeacons) then return end
	local beacon = storage.ssBonusBeacons[uid]
	if beacon and beacon.valid then beacon.destroy() end
	storage.ssBonusBeacons[uid] = nil
end

return Productivity
