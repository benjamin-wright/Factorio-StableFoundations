data:extend {
	{
		type = "string-setting",
		name = "ss-tier1-tiles",
		setting_type = "startup",
		default_value = "stone, gravel, wood",
		order = "a"
	},
	{
		type = "string-setting",
		name = "ss-tier2-tiles",
		setting_type = "startup",
		default_value = "concrete, tarmac, asphalt",
		order = "b"
	},
	{
		type = "string-setting",
		name = "ss-tier3-tiles",
		setting_type = "startup",
		default_value = "refined, reinforced, spaceship",
		order = "c"
	},
	{
		type = "int-setting",
		name = "ss-tier1-productivity",
		setting_type = "startup",
		default_value = 2,
		minimum_value = 0,
		maximum_value = 200,
		order = "d"
	},
	{
		type = "int-setting",
		name = "ss-tier2-productivity",
		setting_type = "startup",
		default_value = 4,
		minimum_value = 0,
		maximum_value = 200,
		order = "e"
	},
	{
		type = "int-setting",
		name = "ss-tier3-productivity",
		setting_type = "startup",
		default_value = 6,
		minimum_value = 0,
		maximum_value = 200,
		order = "f"
	},
}
