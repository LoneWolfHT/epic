
-- playername => pos
local punch_handler = {}

local update_formspec = function(meta, pos)
	local pos = meta:get_string("pos")
	local name = meta:get_string("name")
	local radius = meta:get_int("radius")

	meta:set_string("infotext", "Waypoint block: pos=" .. pos ..
		", radius=" .. radius)

	meta:set_string("formspec", "size[8,4;]" ..
		-- col 1
		"field[0.2,0.5;8,1;radius;Radius;" .. radius .. "]" ..

		-- col 1
		"field[0.2,1.5;8,1;name;Name;" .. name .. "]" ..

		-- col 2
		"button_exit[0.1,2.5;8,1;setpos;Set position]" ..

		-- col 2
		"button_exit[0.1,3.5;8,1;save;Save]" ..
		"")
end

minetest.register_node("epic:waypoint", {
	description = "Epic waypoint block",
	tiles = {
		"epic_node_bg.png",
		"epic_node_bg.png",
		"epic_node_bg.png",
		"epic_node_bg.png",
		"epic_node_bg.png",
		"epic_node_bg.png^epic_waypoint.png",
	},
	paramtype2 = "facedir",
	groups = {cracky=3,oddly_breakable_by_hand=3},
	on_rotate = screwdriver.rotate_simple,

	on_construct = function(pos)
    local meta = minetest.get_meta(pos)
		meta:set_string("name", "Waypoint")
		meta:set_string("pos", minetest.pos_to_string(pos))
		meta:set_int("radius", 3)
    update_formspec(meta, pos)
  end,

  on_receive_fields = function(pos, formname, fields, sender)
    local meta = minetest.get_meta(pos);

		if not sender or minetest.is_protected(pos, sender:get_player_name()) then
			-- not allowed
			return
		end

    if fields.save then
			local radius = tonumber(fields.radius) or 3
			if radius < 0 then
				radius = 1
			end

			meta:set_int("radius", radius)
			meta:set_string("name", fields.name or "")
			update_formspec(meta, pos)
    end

		if fields.setpos then
			minetest.chat_send_player(sender:get_player_name(), "[epic] Please punch the desired target position")
			punch_handler[sender:get_player_name()] = pos
		end

  end,

	epic = {
    on_enter = function(pos, meta, player, ctx)
			local target_pos = minetest.string_to_pos(meta:get_string("pos"))
			ctx.step_data.pos = target_pos
			ctx.step_data.radius = meta:get_int("radius")

			ctx.step_data.waypoint_hud_id = player:hud_add({
				hud_elem_type = "waypoint",
				name = meta:get_string("name"),
				text = "m",
				number = 0xFF0000,
				world_pos = target_pos
			})
    end,
    on_check = function(pos, meta, player, ctx)
			local pos = player:get_pos()
			if vector.distance(pos, ctx.step_data.pos) < ctx.step_data.radius then
				ctx.next()
			end
    end,
    on_exit = function(pos, meta, player, ctx)
			player:hud_remove(ctx.step_data.waypoint_hud_id)
    end
  }
})

minetest.register_on_punchnode(function(pos, node, puncher, pointed_thing)
	local playername = puncher:get_player_name()
	local cfg_pos = punch_handler[playername]
	if cfg_pos then
		local meta = minetest.get_meta(cfg_pos)
		local pos_str = minetest.pos_to_string(pos)
		meta:set_string("pos", pos_str)
		minetest.chat_send_player(playername, "[epic] target position successfully set to " .. pos_str)
		punch_handler[playername] = nil
	end
end)

minetest.register_on_leaveplayer(function(player)
	local playername = player:get_player_name()
	punch_handler[playername] = nil

end)