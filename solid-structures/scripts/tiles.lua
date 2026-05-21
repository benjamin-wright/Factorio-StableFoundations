local Shared = require("shared")
local Tiles = {}

local cache = {}

function Tiles.resetCache()
	cache = {}
end

-- Plain substring match, highest tier wins on conflict.
function Tiles.getTier(tileName)
	if not tileName then return nil end
	local cached = cache[tileName]
	if cached ~= nil then return cached or nil end

	for tier = 3, 1, -1 do
		for _, pattern in ipairs(Shared.TIERS[tier]) do
			if tileName:find(pattern, 1, true) then
				cache[tileName] = tier
				return tier
			end
		end
	end

	cache[tileName] = false
	return nil
end

-- Returns the foundation tier if all tiles under the entity's footprint are the
-- same foundation tile type, or nil if the footprint is partially or fully uncovered.
function Tiles.getEntityFoundationTier(entity)
	if not (entity and entity.valid) then return nil end
	local surface = entity.surface
	local box = entity.bounding_box
	local left   = math.floor(box.left_top.x + 0.1)
	local top    = math.floor(box.left_top.y + 0.1)
	local right  = math.ceil(box.right_bottom.x - 0.1)
	local bottom = math.ceil(box.right_bottom.y - 0.1)
	local w, h   = right - left, bottom - top

	if w <= 0 or h <= 0 then
		local tile = surface.get_tile(entity.position)
		return tile and Tiles.getTier(tile.prototype.name) or nil
	end

	local cornerTile = surface.get_tile(left, top)
	if not cornerTile then return nil end
	local tier = Tiles.getTier(cornerTile.prototype.name)
	if not tier then return nil end
	if w == 1 and h == 1 then return tier end

	local count = surface.count_tiles_filtered {
		area = { { left, top }, { right, bottom } },
		name = cornerTile.name
	}
	return count == w * h and tier or nil
end

return Tiles
