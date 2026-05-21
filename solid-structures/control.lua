local State         = require("scripts.state")
local Tiles         = require("scripts.tiles")
local Invulnerability = require("scripts.invulnerability")
local Productivity  = require("scripts.productivity")

script.on_init(State.init)

-- On configuration change, reset caches, destroy all hidden beacons, and
-- re-apply state from tracked entities. Any always-invulnerable entities
-- already in ssTracked are re-made invulnerable; foundation buildings get
-- their tier re-evaluated with the (possibly updated) tile lists.
script.on_configuration_changed(function()
	for _, surface in pairs(game.surfaces) do
		for _, beacon in pairs(surface.find_entities_filtered { name = "ss-productivity-beacon" }) do
			beacon.destroy()
		end
	end
	storage.ssBonusBeacons = {}

	Tiles.resetCache()
	State.init()

	local toRemove = {}
	for uid, tracked in pairs(storage.ssTracked) do
		local entity = tracked.entity
		if not (entity and entity.valid) then
			toRemove[#toRemove + 1] = uid
		elseif Invulnerability.isAlwaysInvulnerable(entity) then
			Invulnerability.makeInvulnerable(entity)
		else
			local tier = Tiles.getEntityFoundationTier(entity)
			if tier then
				Invulnerability.makeInvulnerable(entity)
				Productivity.applyBonus(entity.surface, entity, tier)
			else
				Invulnerability.restoreDestructible(entity)
			end
		end
	end
	for _, uid in ipairs(toRemove) do State.clear(uid) end
end)

local function onEntityBuilt(event)
	local entity = event.destination_entity or event.entity
	if not (entity and entity.valid) then return end

	if Invulnerability.isAlwaysInvulnerable(entity) then
		Invulnerability.makeInvulnerable(entity)
	elseif entity.prototype.is_building then
		local tier = Tiles.getEntityFoundationTier(entity)
		if tier then
			Invulnerability.makeInvulnerable(entity)
			Productivity.applyBonus(entity.surface, entity, tier)
		end
	end
end

local function onEntityRemoved(event)
	local entity = event.entity
	if not entity then return end
	local uid = entity.unit_number
	if uid then
		Invulnerability.clearTracking(uid)
		Productivity.removeBonus(entity)
	end
end

-- Re-evaluates all buildings touching the given tile positions. Used for both
-- tile-placed and tile-mined events: getEntityFoundationTier always reads the
-- current tile state, so it naturally handles both cases.
local function reevaluateBuildings(surface, tiles)
	local seen = {}
	for _, tile in ipairs(tiles) do
		local area = {
			{ tile.position.x,     tile.position.y },
			{ tile.position.x + 1, tile.position.y + 1 }
		}
		for _, entity in pairs(surface.find_entities_filtered { area = area }) do
			local uid = entity.unit_number
			if uid and not seen[uid]
				and not Invulnerability.isAlwaysInvulnerable(entity)
				and entity.prototype and entity.prototype.is_building then
				seen[uid] = true
				local tier = Tiles.getEntityFoundationTier(entity)
				if tier then
					Invulnerability.makeInvulnerable(entity)
					Productivity.applyBonus(entity.surface, entity, tier)
				else
					Invulnerability.restoreDestructible(entity)
					Productivity.removeBonus(entity)
				end
			end
		end
	end
end

local function getSurface(event)
	if event.player_index then return game.players[event.player_index].surface end
	if event.robot        then return event.robot.surface end
	if event.surface_index then return game.surfaces[event.surface_index] end
end

for _, name in ipairs({
	"on_built_entity",
	"on_robot_built_entity",
	"on_space_platform_built_entity",
	"script_raised_built",
	"script_raised_revive",
	"on_entity_cloned",
}) do
	if defines.events[name] then
		script.on_event(defines.events[name], onEntityBuilt)
	end
end

for _, name in ipairs({
	"on_entity_died",
	"on_player_mined_entity",
	"on_robot_mined_entity",
	"on_space_platform_mined_entity",
	"script_raised_destroy",
}) do
	if defines.events[name] then
		script.on_event(defines.events[name], onEntityRemoved)
	end
end

for _, name in ipairs({
	"on_player_built_tile",
	"on_robot_built_tile",
	"on_space_platform_built_tile",
	"on_player_mined_tile",
	"on_robot_mined_tile",
	"on_space_platform_mined_tile",
}) do
	if defines.events[name] then
		script.on_event(defines.events[name], function(event)
			local surface = getSurface(event)
			if surface then reevaluateBuildings(surface, event.tiles) end
		end)
	end
end

script.on_event(defines.events.script_raised_set_tiles, function(event)
	local surface = game.surfaces[event.surface_index]
	if surface then reevaluateBuildings(surface, event.tiles) end
end)
