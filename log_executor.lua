
epic.register_hook({
  on_execute_epic = function(player, main_pos, exit_pos, abort_pos, state)
    minetest.log("action", "[epic] on_execute_epic player=" ..
      player:get_player_name() ..
      " main_pos=" .. minetest.pos_to_string(main_pos) ..
			" exit_pos=" .. minetest.pos_to_string(exit_pos or {x=0,y=0,z=0}) ..
			" abort_pos=" .. minetest.pos_to_string(abort_pos or {x=0,y=0,z=0}) ..
      " state=" .. dump(state))
  end,

  on_before_node_enter = function(pos, player)
    minetest.log("action", "[epic] on_before_node_enter player=" ..
      player:get_player_name() ..
      " pos=" .. minetest.pos_to_string(pos) ..
      " node=" .. minetest.get_node(pos).name)
  end,

  on_before_node_exit = function(pos, player)
    minetest.log("action", "[epic] on_before_node_exit player=" ..
      player:get_player_name() ..
      " pos=" .. minetest.pos_to_string(pos) ..
      " node=" .. minetest.get_node(pos).name)
  end,

  on_epic_exit = function(playername, state)
    minetest.log("action", "[epic] on_epic_exit player=" ..
      playername ..
      " state=" .. dump(state))
  end,

  on_epic_abort = function(playername, state, reason)
    minetest.log("action", "[epic] on_epic_abort player=" ..
      playername ..
      " state=" .. dump(state) ..
      " reason=" .. reason)
  end
})
