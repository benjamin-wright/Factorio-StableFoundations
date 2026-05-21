local Shared = {}

local function parseTileList(str)
	local tiles = {}
	for tile in tostring(str):gmatch("([^,]+)") do
		local t = tile:match("^%s*(.-)%s*$")
		if t ~= "" then tiles[#tiles + 1] = t end
	end
	return tiles
end

Shared.TIERS = {
	[1] = parseTileList(settings.startup["ss-tier1-tiles"].value),
	[2] = parseTileList(settings.startup["ss-tier2-tiles"].value),
	[3] = parseTileList(settings.startup["ss-tier3-tiles"].value),
}

Shared.PRODUCTIVITY = {
	[1] = settings.startup["ss-tier1-productivity"].value / 100,
	[2] = settings.startup["ss-tier2-productivity"].value / 100,
	[3] = settings.startup["ss-tier3-productivity"].value / 100,
}

return Shared
