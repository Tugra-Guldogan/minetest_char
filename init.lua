
local function deepclone(t)
	if type(t) ~= "table" then 
		return t 
	end
	
	--local meta = getmetatable(t)
	local target = {}
	
	for k, v in pairs(t) do
		if type(v) == "table" then
			target[k] = deepclone(v)
		else
			target[k] = v
		end
	end
	
	-- metatables for registered nodes don't let you set certain properties
	--setmetatable(target, meta)
	
	return target
end


local function splitname(name)
	local c = string.find(name, ":", 1)
	return string.sub(name, 1, c - 1), string.sub(name, c + 1, string.len(name))
end




function make_char_node(mod, name, shrink)
	local nn = mod .. "_" .. name

	if shrink == nil then
		shrink = .1
	end
	
	local def = minetest.registered_nodes[mod..":"..name]
	if not def then
		print("no node for "..nn)
		return
	end
	
	local nd = deepclone(def)
	
	for k,v in pairs(nd.tiles) do
		if type(v) == "string" then
			nd.tiles[k] = v.."^[colorize:black:140^char_char.png"
		else
			nd.tiles[k].name = v.name.."^[colorize:black:140^char_char.png"
		end
	end
	
	nd.description = "Burnt "..nd.description
	
	if nd.inventory_image then
		nd.inventory_image = nd.inventory_image.."^[colorize:black:140^char_char.png"
	end
	if nd.wield_image then
		nd.wield_image = nd.wield_image.."^[colorize:black:140^char_char.png"
	end
	
	nd.groups.falling_node = 1
	nd.groups.burnt = 1
	nd.groups.cracky = 1
	nd.groups.not_in_creative_inventory = 1
	nd.groups.flammable = nil
	nd.groups.tree = nil
	nd.groups.wood = nil
	
	

	
	if shrink > 0 and (nd.drawtype == "nodebox" or nd.drawtype == nil) then
		nd.paramtype = "light"
		nd.drawtype = "nodebox"
	
		if nd.node_box ~= nil then
			if nd.node_box.type == "fixed" then
				for k,v in pairs(nd.node_box.fixed) do
					nd.node_box.fixed[1] = nd.node_box.fixed[1] + shrink
					nd.node_box.fixed[3] = nd.node_box.fixed[3] + shrink
					
					nd.node_box.fixed[4] = nd.node_box.fixed[4] - shrink
					nd.node_box.fixed[6] = nd.node_box.fixed[6] - shrink
				end
			end
		else
			nd.node_box = {
				type = "fixed",
				fixed = {
					{-0.5 + shrink, -.5, -0.5 + shrink, 0.5 - shrink, 0.5, 0.5 - shrink},
				},
			}
		end
	end
	
-- 	print(dump(nd))
	minetest.register_node("char:burnt_"..nn, nd)
	
	minetest.override_item(mod..":"..name, {
		on_burn = function(pos)
			if math.random(3) == 1 then
				minetest.set_node(pos, {name="char:burnt_"..nn})
				minetest.check_for_falling(pos)
			else
				minetest.set_node(pos, {name="air"})
				minetest.check_for_falling({x=pos.x, y=pos.y+1, z=pos.z})
			end
		end,
	})
end


make_char_node("default", "tree")
make_char_node("default", "aspen_tree")
make_char_node("default", "jungletree")
make_char_node("default", "acacia_tree")
make_char_node("default", "pine_tree")

make_char_node("default", "wood", 0)
make_char_node("default", "acacia_wood", 0)
make_char_node("default", "junglewood", 0)
make_char_node("default", "aspen_wood", 0)
make_char_node("default", "pine_wood", 0)

make_char_node("default", "cactus", .2)

make_char_node("default", "sign_wall_wood", 0)
make_char_node("default", "fence_wood", 0)
make_char_node("default", "fence_acacia_wood", 0)
make_char_node("default", "fence_junglewood", 0)
make_char_node("default", "fence_pine_wood", 0)
make_char_node("default", "fence_aspen_wood", 0)

make_char_node("default", "bookshelf", 0)
make_char_node("default", "chest", 0)
make_char_node("default", "chest_locked", 0)

make_char_node("stairs", "stair_tree", 0)
make_char_node("stairs", "stair_pine_tree", 0)
make_char_node("stairs", "stair_aspen_tree", 0)
make_char_node("stairs", "stair_acacia_tree", 0)
make_char_node("stairs", "stair_jungletree", 0)
make_char_node("stairs", "slab_tree", 0)
make_char_node("stairs", "slab_pine_tree", 0)
make_char_node("stairs", "slab_aspen_tree", 0)
make_char_node("stairs", "slab_acacia_tree", 0)
make_char_node("stairs", "slab_jungletree", 0)

make_char_node("stairs", "stair_wood", 0)
make_char_node("stairs", "stair_pine_wood", 0)
make_char_node("stairs", "stair_aspen_wood", 0)
make_char_node("stairs", "stair_acacia_wood", 0)
make_char_node("stairs", "stair_junglewood", 0)
make_char_node("stairs", "slab_wood", 0)
make_char_node("stairs", "slab_pine_wood", 0)
make_char_node("stairs", "slab_aspen_wood", 0)
make_char_node("stairs", "slab_acacia_wood", 0)
make_char_node("stairs", "slab_junglewood", 0)






function make_charred_grass(mod, name)
	if minetest.registered_nodes[mod..":"..name] then
		local g = deepclone(minetest.registered_nodes[mod..":"..name].groups)
		g.charrable = 1 
		minetest.override_item(mod..":"..name, {
			on_char = function(pos)
				minetest.set_node(pos, {name="char:dirt_with_burnt_grass"})
				minetest.check_for_falling(pos)
			end,
			groups = g,
		})
	end

	
	local season_list = {"spring", "summer", "fall", "winter"}
	
	for _,s in ipairs(season_list) do
		local sn = "seasons:"..s.."_"..mod.."_"..name
		
		if minetest.registered_nodes[sn] then
			local g = deepclone(minetest.registered_nodes[sn].groups)
			g.charrable = 1 
			minetest.override_item(sn, {
				on_char = function(pos)
					minetest.set_node(pos, {name="char:dirt_with_burnt_grass"})
					minetest.check_for_falling(pos)
				end,
				groups = g
			})
		end
		
	end
	
end

--[[
for name,def in pairs(minetest.registered_nodes) do
	
	if def.groups and def.groups.spreading_dirt_type == 1 then
		local m,n = splitname(name)
		print(m.."__"..n)
		make_charred_grass(m, n)
	end
end
]]


minetest.register_node("char:dirt_with_burnt_grass", {
	description = "Dirt with Burnt Grass",
	tiles = {"char_burnt_grass.png", "default_dirt.png",
		{name = "default_dirt.png^char_burnt_grass_side.png",
			tileable_vertical = false}},
	groups = {crumbly = 3, soil = 1},
	drop = 'default:dirt',
	sounds = default.node_sound_dirt_defaults({
		footstep = {name = "default_grass_footstep", gain = 0.25},
	}),
})




make_charred_grass("default", "dirt_with_grass")
make_charred_grass("default", "dirt_with_grass_footsteps")
make_charred_grass("default", "dirt_with_dry_grass")
make_charred_grass("default", "dirt_with_snow")
make_charred_grass("default", "dirt_with_rainforest_litter")
make_charred_grass("default", "dirt_with_coniferous_litter")





minetest.register_abm({
	label = "Scorch charrable nodes",
	nodenames = {"group:charrable"},
	neighbors = {"fire:basic_flame"},
	interval = 4,
	chance = 6,
	catch_up = true,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local n = minetest.get_node(pos)
		if n and n.name then
			local def = minetest.registered_nodes[n.name]
			if def.on_char then
				def.on_char(pos)
			end
		end
	end,
})



local heat_noise, humidity_noise
minetest.after(0, function()
	local noise = minetest.get_mapgen_setting_noiseparams("mg_biome_np_heat")
	heat_noise = minetest.get_perlin(noise)
	
	noise = minetest.get_mapgen_setting_noiseparams("mg_biome_np_humidity")
	humidity_noise = minetest.get_perlin(noise)
end)

local good_biomes = {}
for _,def in pairs(minetest.registered_biomes) do
	if def.y_max >= 10 and def.y_min <= 10 then
		table.insert(good_biomes, def)
	end
end


local function find_biome(pos)
	local smallest = 99999999999
	local tmp = nil
	
	local he = heat_noise:get2d({x=pos.x, y=pos.z})
	local hu = humidity_noise:get2d({x=pos.x, y=pos.z})
	
	for _,def in pairs(good_biomes) do
			local a = he - def.heat_point
			local b = hu - def.humidity_point
			local c = math.sqrt(a*a + b*b)
			if c < smallest then
				smallest = c
				tmp = def
			end
	end
	
	return tmp.name
end

local grass_growth = {
	tundra = "default:dirt_with_snow",
	taiga = "default:dirt_with_snow",
	savanna = "default:dirt_with_dry_grass",
	grassland = "default:dirt_with_grass",
	snowy_grassland = "default:dirt_with_snow",
	deciduous_forest = "default:dirt_with_grass",
	coniferous_forest = "default:dirt_with_grass",
	desert = "default:dirt_with_dry_grass",
	cold_desert = "default:dirt_with_dry_grass",
	sandstone_desert = "default:dirt_with_dry_grass",
	rainforest = "default:dirt_with_rainforest_litter",
}


minetest.register_abm({
	label = "Grass regrowth",
	nodenames = {"char:dirt_with_burnt_grass"},
	neighbors = {"air"},
	interval = 42,
	chance = 680,
	catch_up = false,
	action = function(pos, node)
		-- Check for darkness: night, shadow or under a light-blocking node
		-- Returns if ignore above
		local above = {x = pos.x, y = pos.y + 1, z = pos.z}
		if (minetest.get_node_light(above) or 0) < 13 then
			return
		end

		-- Look for spreading dirt-type neighbours
		local p2 = minetest.find_node_near(pos, 1, "group:spreading_dirt_type")
		if p2 then
			local n3 = minetest.get_node(p2)
			minetest.set_node(pos, {name = n3.name})
			return
		end

		local biome = find_biome(pos)
		local nn = grass_growth[biome]
		if nn then
			minetest.set_node(pos, {name = nn})
		end
		
	end
})
