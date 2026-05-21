local Shared = require("shared")

local tile_beacon = {
	type = "beacon",
	name = "ss-productivity-beacon",
	icon = "__base__/graphics/icons/beacon.png",
	icon_size = 64,
	hidden = true,
	selectable_in_game = false,
	allow_copy_paste = false,
	protected_from_tile_building = false,
	minable = nil,
	energy_usage = "1W",
	supply_area_distance = 0,
	distribution_effectivity = 1,
	distribution_effectivity_bonus_per_quality_level = 0,
	graphics_set = nil,
	selection_box = { { 0, 0 }, { 0, 0 } },
	collision_box = { { 0, 0 }, { 0, 0 } },
	profile = { 1 },
	beacon_counter = "same_type",
	collision_mask = { layers = {} },
	energy_source = { type = "void" },
	module_slots = 1,
	render_layer = "floor-chain-render-layer",
	allowed_effects = { "productivity" },
	flags = {
		"placeable-off-grid",
		"not-on-map",
		"not-blueprintable",
		"not-deconstructable",
		"hide-alt-info",
		"no-copy-paste",
		"no-automated-item-insertion",
		"no-automated-item-removal",
		"not-repairable",
		"not-flammable",
		"not-selectable-in-game",
		"not-in-made-in",
		"not-in-kill-statistics",
		"not-upgradable",
		"not-rotatable"
	}
}

data:extend { tile_beacon }

for tier = 1, 3 do
	local value = Shared.PRODUCTIVITY[tier]
	if value and value > 0 then
		data:extend {
			{
				type = "module",
				name = "ss-productivity-module-" .. tier,
				icon = "__base__/graphics/icons/productivity-module.png",
				icon_size = 64,
				hidden = true,
				flags = { "hide-from-bonus-gui" },
				subgroup = "module",
				category = "productivity",
				tier = 0,
				order = "z" .. tier,
				stack_size = 1,
				effect = { productivity = value },
				limitation = {},
				limitation_message_key = "ss-module-beacon-only",
			}
		}
	end
end
