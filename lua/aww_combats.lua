--<<
-- DEPRECATED ; replace by aww_duel.lua. Keeped for retrocompat with old gamesaves !
-- SCRIPT TO CHANGE ATTACKS NUMBER AND DAMAGE BASED ON 2 OPTIONS COMBINATIONS
-- Author: Ruvaak
-- Initially based on No_Randomness_Mod, lot of changes to combine with my others features
-- Features concerned : 1, 2, 7, 8
-- LOAD THIS SCRIPT ONLY IF AT LEAST ONE OF THEM IS ENABLED

local helper = wesnoth.require "lua/helper.lua"

-- Turning WML option variables into global LUA typed variables. "yes"/"no" becomes bool true/false

local aww_g_randomless_enabled = wesnoth.get_variable("aww_01_enable_randomless_combats")
local aww_g_healthy_strikes_choice = wesnoth.get_variable("aww_02_squad_mode")

-- reduction of defense, number 0 and 50. Will represent the increased damages in %.
-- To make combats quicker, and units gaining less xp on each weak hit, increase value
-- The "standard terrain is usually" is 40% (means 60% of probabilities to hit, so x0.6 damage in randomless calculation)
-- And the worst terrain is 20% of defense.
-- A value of 15 for this variable will increase probability to hit of 15% (because reducing the defender terrain bonus of 15%)

local aww_g_randomless_terrain_adjustment = wesnoth.get_variable("aww_08_randomless_damage_adjustment")

-- compat games created < 1.14.9.0, variable was not existing :
if not aww_g_randomless_terrain_adjustment then
	aww_g_randomless_terrain_adjustment = 0
else
	-- numeric convert :
	aww_g_randomless_terrain_adjustment = aww_g_randomless_terrain_adjustment *1
end

-- trying to see which side is attacking to filter debug messages
local aww_g_att_side = 0
local aww_g_def_side = 0

wesnoth.wml_actions.event{
	name="attack" ,
	id="aww_attack_event",
	first_time_only=false,
	{ "aww_attack_action", {
		{ "filter" , {
			id="$unit.id"
		}},
		{ "filter_second" , {
			id="$second_unit.id"
		}}
	}}
}


wesnoth.wml_actions.event{
	name="attack end",
	id="aww_post_attack_event",
	first_time_only=false,
	{ "aww_restore_properties", {
		id="$unit.id"
	}},
	{ "aww_restore_properties", {
		id="$second_unit.id"
	}}
}


function wesnoth.aww_deepcopy(orig)

	local orig_type = type(orig)
	local copy
	if orig_type == 'table' then
	copy = {}
	for orig_key, orig_value in next, orig, nil do
		copy[wesnoth.aww_deepcopy(orig_key)] = wesnoth.aww_deepcopy(orig_value)
	end
		setmetatable(copy, wesnoth.aww_deepcopy(getmetatable(orig)))
	else -- number, string, boolean, etc
		copy = orig
	end
	return copy
end


function wesnoth.wml_actions.aww_attack_action(cfg)

	local filter = helper.get_child(cfg, "filter")
	local u1     = wesnoth.get_units(filter)[1]
	filter       = helper.get_child(cfg, "filter_second")
	local u2     = wesnoth.get_units(filter)[1]

	local function aww_modify_unit_attack(attacker,defender)
		-- TODO test manage damage specials. Charge (dmg x2) OK, magic (+ increased hit prob) OK,

		-- if defender (u2) is on a terrain at 40%, hit_prob should be around 60
		local att_hit_prob = wesnoth.unit_defense(defender, wesnoth.get_terrain(defender.x, defender.y))
		-- numeric convert :
		att_hit_prob = att_hit_prob *1

		att_health_ratio = wesnoth.aww_calculate_health_ratio(attacker.hitpoints, attacker.max_hitpoints)

		aww_g_att_side = attacker.side
		aww_g_def_side = defender.side

		local attacker_data = attacker.__cfg
		local variables_pos
		local backup_pos

		wesnoth.aww_debug_message_side(string.format("--- S%s %s (%d/%s) attacks S%s %s ---", aww_g_att_side, attacker.name, attacker.hitpoints, attacker.max_hitpoints, aww_g_def_side, defender.name))

		for i = 1,#attacker_data do
			if attacker_data[i][1] == "variables" then
				variables_pos = i
				backup_pos = #attacker_data[i][2] + 1
				attacker_data[i][2][backup_pos] = { "aww_backup" , {}}
			end
		end

		--wesnoth.aww_debug_message_table(attacker_data)

		for a =1,#attacker_data do
			if attacker_data[a][1] == "attack" then
				table.insert(attacker_data[variables_pos][2][backup_pos][2], wesnoth.aww_deepcopy(attacker_data[a]) )
				local has_specials=false

				weapon_base_damage = attacker_data[a][2].damage
				weapon_strikes = attacker_data[a][2].number
				local ignore_strike_edit = false

				--wesnoth.aww_debug_message(string.format("-- a=%s", a))
				--wesnoth.aww_debug_message_table(attacker_data[a])

				for wa =1,#attacker_data[a][2] do

					if attacker_data[a][2][wa][1] == "specials" then
						has_specials=true
						local special_att_hit_prob =  att_hit_prob * 1

						--wesnoth.aww_debug_message(string.format("---- wa=%s", wa))
						--wesnoth.aww_debug_message_table(attacker_data[w][2][wa])

						for s =1,#attacker_data[a][2][wa][2] do

							--wesnoth.aww_debug_message(string.format("-------- s=%s", s))
							--wesnoth.aww_debug_message_table(attacker_data[w][2][ss][2][s])

							-- managing "swarm" special : will ignore the health-based hit number decreases :
							if attacker_data[a][2][wa][2][s][1] == "swarm"
								or attacker_data[a][2][wa][2][s][1] == "berserk"
								or attacker_data[a][2][wa][2][s][2].id == "aww_special_fury"
							then
								--wesnoth.aww_debug_message_side("Swarm/berserk special weapon detected  v")
								ignore_strike_edit = true
							end

							-- managing special hit rating from weapon, not depending of terrain, like Magical :

							if attacker_data[a][2][wa][2][s][1] == "chance_to_hit" then
								if attacker_data[a][2][wa][2][s][2].active_on ~= "offense" or attacker_data.id == u1.id then
									if attacker_data[a][2][wa][2][s][2].active_on ~= "defense" or attacker_data.id == u2.id then
										if attacker_data[a][2][wa][2][s][2].value then
											if attacker_data[a][2][wa][2][s][2].cumulative ~= true or special_att_hit_prob < attacker_data[a][2][wa][2][s][2].value then
												special_att_hit_prob = attacker_data[a][2][wa][2][s][2].value
											end
										end
										if attacker_data[a][2][wa][2][s][2].add then
											special_att_hit_prob = special_att_hit_prob + attacker_data[a][2][wa][2][s][2].add
										end
										if attacker_data[a][2][wa][2][s][2].sub then
											special_att_hit_prob = special_att_hit_prob - attacker_data[a][2][wa][2][s][2].sub
										end
										if attacker_data[a][2][wa][2][s][2].multiply then
											special_att_hit_prob = special_att_hit_prob * attacker_data[a][2][wa][2][s][2].multiply
										end
										if attacker_data[a][2][wa][2][s][2].divide then
											special_att_hit_prob = special_att_hit_prob - attacker_data[a][2][wa][2][s][2].divide
										end

										-- wesnoth.aww_debug_message_side(string.format("special different hit prob=%s", special_att_hit_prob))
										-- wesnoth.wml_actions.message{ speaker="narrator", message=special_att_hit_prob }
									end
								end
								attacker_data[a][2][wa][2][s][2].value=nil
								attacker_data[a][2][wa][2][s][2].add=nil
								attacker_data[a][2][wa][2][s][2].sub=nil
								attacker_data[a][2][wa][2][s][2].divide=nil
								attacker_data[a][2][wa][2][s][2].multiply=nil
								attacker_data[a][2][wa][2][s][2].cumulative=nil

							end
						end -- foreach s (special)

						-- wesnoth.aww_debug_message_side("- Specials attacks : YES") -- normal case for all attacks

						if aww_g_randomless_enabled then
							table.insert(attacker_data[a][2][wa][2], { "chance_to_hit" , { id="aww_effect", value=100 } } )
						end

						if aww_g_randomless_enabled or aww_g_healthy_strikes_choice == 1 then
							attacker_data[a][2].damage = wesnoth.aww_round_damage(weapon_base_damage, weapon_strikes, special_att_hit_prob, att_health_ratio)
						end

					end -- if special
				end -- foreach wa (weapon attribute)

				if has_specials == false then

						-- wesnoth.aww_debug_message_side("- Specials attacks : NO")

						if aww_g_randomless_enabled then
							table.insert(attacker_data[a][2], { "specials", { { "chance_to_hit" , { id="aww_effect", value=100 } } }})
						end

						if aww_g_randomless_enabled or aww_g_healthy_strikes_choice == 1 then
							attacker_data[a][2].damage = wesnoth.aww_round_damage(weapon_base_damage, weapon_strikes, att_hit_prob, att_health_ratio)
						end
				end -- if not special


				if aww_g_healthy_strikes_choice == 1 and att_health_ratio < 1 and not ignore_strike_edit then
					--wesnoth.aww_debug_message("NOT SWARM")
					-- swarm do kinda the same process, changing strikes directly on data, so we can't do that on swarm :
					attacker_data[a][2].number = wesnoth.aww_round_healthy_strikes(weapon_strikes, att_health_ratio)
				end

			end --if a=attack
		end --foreach a (unit attribute)
		wesnoth.put_unit(attacker_data) -- trigger unit placed, take care !
	end -- local function
	aww_modify_unit_attack(u1, u2)
	aww_modify_unit_attack(u2, u1)
end


function wesnoth.wml_actions.aww_restore_properties(cfg)
	local u = wesnoth.get_units(cfg)[1]
	if u then
		local unit = u.__cfg

		for i = 1,#unit do
			if unit[i] and unit[i][1] == "variables" then
				for j = 1,#unit[i][2] do
					if not unit[i][2][j] then
						wesnoth.aww_debug_message(string.format("missing backup J for unit i=%s, j=%s", i, j))
					end
					if unit[i][2][j] and unit[i][2][j][1] == "aww_backup" then
						local attack_num = 1
						for k = 1,#unit do
							if not unit[k] then
								wesnoth.aww_debug_message(string.format("missing backup K for unit i=%s, j=%s, k=%s", i, j, k))
							end
							if unit[k] and unit[k][1] == "attack" then
								unit[k] = wesnoth.aww_deepcopy(unit[i][2][j][2][attack_num])
								attack_num = attack_num + 1
							end
						end
						table.remove(unit[i][2], j)
					end
				end
			end
		end
		wesnoth.put_unit(unit)
	end
end


function wesnoth.aww_round_damage(weapon_base_damage, weapon_strikes, att_hit_prob, att_health_ratio)

	result = weapon_base_damage

	if aww_g_randomless_enabled then

		if aww_g_healthy_strikes_choice == 1 then
			result = wesnoth.aww_round_randomless_healthy_damage(weapon_base_damage, weapon_strikes, att_hit_prob, att_health_ratio)
		else
			result = wesnoth.aww_round_randomless_damage(weapon_base_damage, att_hit_prob)
		end
	elseif aww_g_healthy_strikes_choice == 1 then
		result = wesnoth.aww_round_healthy_damage(weapon_base_damage, weapon_strikes, att_health_ratio)
	end

	return result
end


function wesnoth.aww_calculate_randomless_damage(weapon_base_damage, att_hit_prob)

	local randomless_damage_ratio = wesnoth.aww_calculate_randomless_damage_ratio(att_hit_prob)

	local result = weapon_base_damage * randomless_damage_ratio

	return result
end


function wesnoth.aww_round_randomless_damage(weapon_base_damage, att_hit_prob)

	local result = wesnoth.aww_calculate_randomless_damage(weapon_base_damage, att_hit_prob)

	result = math.max(1, aww_duel.round(result ))

	wesnoth.aww_debug_message_side(string.format("(No-Random) Rounded Hit Damage = %s  |  (base) %d x (hit ratio) %d%%+%d%%", result, weapon_base_damage, att_hit_prob, aww_g_randomless_terrain_adjustment))

	return result
end


-- returns calculated ratio (100% will return 1), but att_hit_prob will be 100 for 100%

function wesnoth.aww_calculate_randomless_damage_ratio(att_hit_prob)

	local result = (att_hit_prob + aww_g_randomless_terrain_adjustment) / 100

	-- min 0, max 200%, no rounding :
	result = math.max(0, math.min(2, result))

	-- wesnoth.aww_debug_message_side(string.format("(No-Random) Damage ratio = %s  |  (hit ratio) %s%%+%s%%", result, att_hit_prob, aww_g_randomless_terrain_adjustment))

	return result
end


-- randomless + health-based damages
-- Kinda combination between calculate_randomless_damage() & calculate_healthy_damage()

function wesnoth.aww_calculate_randomless_healthy_damage(weapon_base_damage, weapon_strikes, att_hit_prob, att_health_ratio)

	local result = wesnoth.aww_calculate_randomless_damage(weapon_base_damage, att_hit_prob)
	if (weapon_strikes <= 1) then
		-- if only one strike, we reduce damage from the single attack
		result = result * att_health_ratio
	end
	return result
end


function wesnoth.aww_round_randomless_healthy_damage(weapon_base_damage, weapon_strikes, att_hit_prob, att_health_ratio)

	local result = wesnoth.aww_calculate_randomless_healthy_damage(weapon_base_damage, weapon_strikes, att_hit_prob, att_health_ratio)

	-- min 1, rounding on .5 :
	result = math.max(1, aww_duel.round(result))

	wesnoth.aww_debug_message_side(string.format("(No-Random + Health-based) Rounded Hit Damage for weapon %dx%d = %s  |  (base) %d x (hit ratio) %d%%+%d%% x (health ratio) %s", weapon_base_damage, weapon_strikes, result, weapon_base_damage, att_hit_prob,aww_g_randomless_terrain_adjustment,  att_health_ratio))

	return result
end


-- health based damage (if strikes > 1) :

function wesnoth.aww_calculate_healthy_damage(weapon_base_damage, weapon_strikes, att_health_ratio)

	local result = weapon_base_damage
	if (weapon_strikes <= 1) then
		-- if only one strike, we reduce damage from the single attack
		result = weapon_base_damage * att_health_ratio
	end
	return result
end


function wesnoth.aww_round_healthy_damage(weapon_base_damage, weapon_strikes, att_health_ratio)

	local result = wesnoth.aww_calculate_healthy_damage(weapon_base_damage, weapon_strikes, att_health_ratio)

	-- rounding at .5 and minimum 1 :
	result = math.max(1, aww_duel.round(result))

	wesnoth.aww_debug_message_side(string.format("(Health-based) Rounded Hit Damage for weapon %dx%d = %s  |  (base) %d | (health ratio) %s", weapon_base_damage, weapon_strikes, result, weapon_base_damage, att_health_ratio))

	return result
end


-- Health Ratio : hp/max_hp. Used for Health based Strikes (or Damage if 1 Strike)

function wesnoth.aww_calculate_health_ratio(hp, max_hp)
	if (max_hp <= 1) then
		-- avoid divide by 0 or multiplication :
		return 1
	end

	local result = hp / max_hp

	-- result between 0.2 (to do a minimum of damage) and 1 (in case of over-HP), no rounding :
	result = math.min(1, math.max(0.2, result))

	-- wesnoth.aww_debug_message_side(string.format("Health-based) Calculated health ratio = %s | %d / %d", result, hp, max_hp))

	return result
end


-- Number of strike the unit can do with current health, compare to her maximum :

function wesnoth.aww_round_healthy_strikes(weapon_strikes, att_health_ratio)

	if weapon_strikes <= 1 then
		return 1
	end

	local result = weapon_strikes * att_health_ratio

	-- min 1, rounded at .5 :
	result = math.max(1, aww_duel.round(result))

	wesnoth.aww_debug_message_side(string.format("(Health-based) Rounded Hits Number = %s  |  (base strikes) %s x (health ratio) %s", result, weapon_strikes, att_health_ratio))

	return result
end


-- display chat message if debug option enabled
-- Launch only if attacker unit.side = event.$side_number - or side not defined

function wesnoth.aww_debug_message_side(msg)

	local player_side = wesnoth.get_variable("side_number")

	if player_side > 0 and (player_side == aww_g_att_side) then
		return wesnoth.aww_debug_message(msg)
	end
	return false
end


function wesnoth.aww_debug_message(msg)

	local verbose_enabled = wesnoth.get_variable("aww_07_enable_verbose")

	if verbose_enabled then
		wesnoth.message("Advanced WW debug", msg)
	end
	return false
end


-- debug function : log/print array

function wesnoth.aww_debug_message_table(o)
	wesnoth.aww_debug_message(wesnoth.aww_dump_table(o, 7))
	--wesnoth.aww_debug_message(wesnoth.wesnoth.debug(o))
	-- try wml.tostring() or wesnoth.debug(wml_table)
end


-- debug function : stringify array

function wesnoth.aww_dump_table(o, depth)
	if depth < 0 then
		return "..."
	end
	if type(o) == 'table' then
		local s = '{ '
		for k,v in pairs(o) do
			if type(k) ~= 'number' then k = '"'..k..'"' end
			if k == nil then
				s = s .. '[nil] = ' .. wesnoth.aww_dump_table(v, depth-1) .. ','
			else
				local r = wesnoth.aww_dump_table(v, depth-1)
				if r == nil then
					s = s .. '['..k..'] = nil,'
				else
					s = s .. '['..k..'] = ' .. wesnoth.aww_dump_table(v, depth-1) .. ','
				end
			end
		end
		return s .. '} '
	else
		return tostring(o)
	end
end


wesnoth.aww_debug_message("Combats script loaded. This file is DEPRECATED")
-->>
