--<<
-- SCRIPT TO CHANGE ATTACKS NUMBER AND DAMAGE BASED ON 2 OPTIONS COMBINATIONS
-- Author: Ruvaak
-- Initially based on No_Randomness_Mod, lot of changes to combine with my others features, and uses temp weapons specials instead of copy/replace stats
-- Features concerned : 01,02, 07, 08
-- LOAD THIS SCRIPT ONLY IF FEATURES 01 AND/OR 02 ARE ENABLED
-- TODO find how to update unit without _put, because it triggered unit placed in the middle of the attack
-- TODO manage bonuses of damage day/light and specific ennemyes ? apparently multiplier don't cover it

local helper = wesnoth.require "lua/helper.lua"

local _ = wesnoth.textdomain 'aww'

-- W = helper.set_wml_action_metatable {}

if aww_status == nil or aww_status.feature_01 == nil or aww_status.feature_02 == nil or aww_status.feature_08 == nil then
	wesnoth.message("AWW notice", "attempt running aww_status")
	wesnoth.dofile "./aww_status.lua"
	aww_status.run()
end

aww_duel = {
	-- uppercase = constants not designed to stay unchanged :
	SPECIAL_CHANCE_TO_HIT_ID         = "aww_tmp_special_chance_to_hit",
	SPECIAL_DAMAGE_ID                = "aww_tmp_special_damage",
	SPECIAL_STRIKES_ID               = "aww_tmp_special_strikes",
	SPECIAL_ESTIMATION_DUMMY_ID      = "aww_tmp_special_estimation_dummy",
	ARROW_CHAR                       = "&#x2192; ", -- html char representing an arrow

	-- used for verbose/debug messages :
	unit_side                        = 0,
}


wesnoth.wml_actions.event {
	name="attack" ,
	id="aww_wlua_trigger_duel_attack",
	first_time_only = false,
	{ "aww_attack_action", {
		{ "filter" , {
			id="$unit.id"
		}},
		{ "filter_second" , {
			id="$second_unit.id"
		}}
	}}
}
function wesnoth.wml_actions.aww_attack_action(cfg)
	local filter   = helper.get_child(cfg, "filter")
	local att_unit = wesnoth.get_units(filter)[1]
	filter         = helper.get_child(cfg, "filter_second")
	local def_unit = wesnoth.get_units(filter)[1]

	aww_duel.modify_unit_specials_multipliers(att_unit, def_unit)
	aww_duel.modify_unit_specials_multipliers(def_unit, att_unit)
end


wesnoth.wml_actions.event {
	name="attack_end",
	id="aww_wlua_trigger_duel_attack_end",
	first_time_only = false,
	{ "aww_restore_properties", {
		id="$unit.id"
	}},
	{ "aww_restore_properties", {
		id="$second_unit.id"
	}}
}
function wesnoth.wml_actions.aww_restore_properties(cfg)
	local u = wesnoth.get_units(cfg)[1]
	if u then
		aww_duel.remove_tmp_specials(u)
	end
end


wesnoth.wml_actions.event {
	name="select,recruit,post advance",
	--name="select,moveto,recruit,post advance",
	-- never uses "unit_placed" because put_init will do an infinite loop.
	id="aww_wlua_trigger_squad_custom_estimation_refresh",
	first_time_only = false,
	{ "aww_estimate_weapons_special", {
		id="$unit.id"
	}}
}
wesnoth.wml_actions.event {
	-- can also be used in attack, but no real point except for debug.
	name="attack_end",
	id="aww_wlua_trigger_squad_custom_estimation_refresh_attack_end",
	first_time_only = false,
	{ "aww_estimate_weapons_special", {
		id="$unit.id"
	}},
	{ "aww_estimate_weapons_special", {
		id="$second_unit.id"
	}}
}
function wesnoth.wml_actions.aww_estimate_weapons_special(cfg)
	local unit = wesnoth.get_units(cfg)[1]
	aww_duel.estimate_weapons_special_display(unit)
end


function aww_duel.is_enabled()
	if aww_status.feature_01 == true or aww_status.feature_02 > 0 then
		return true
	end
	return false
end


function aww_duel.modify_unit_specials_multipliers(att_unit, def_unit)
	if not aww_duel.is_enabled() then
		return
	end

	-- if defender (u2) is on a terrain at 40%, att_terrain_hit_chance should be around 60 :
	local att_terrain_hit_chance = wesnoth.unit_defense(def_unit, wesnoth.get_terrain(def_unit.x, def_unit.y)) *1

	local att_hp_ratio = aww_duel.calculate_hp_ratio(att_unit.hitpoints, att_unit.max_hitpoints)

	aww_duel.unit_side = att_unit.side

	-- unit_data contains the att_unit properties in array instead of object:
	local unit_data = att_unit.__cfg

	aww_duel.debug_message_side(string.format("--- S%s %s (%d/%s) attacks S%s %s ---", aww_duel.unit_side, att_unit.name, att_unit.hitpoints, att_unit.max_hitpoints, def_unit.side, def_unit.name))

	--aww_duel.debug_message_table(attacker_data)

	for a =1,#unit_data do
		if unit_data[a][1] == "attack" then

			local weapon_hit_chance = att_terrain_hit_chance

			local has_specials=false

			local weapon_base_damage = unit_data[a][2].damage
			local weapon_strikes = unit_data[a][2].number
			local ignore_strike_edit = false

			--aww_duel.debug_message(string.format("-- a=%s", a))
			--aww_duel.debug_message_table(attacker_data[a])

			local specials_index = 0
			--local last_special_index = 1

			for wa =1,#unit_data[a][2] do
				if unit_data[a][2][wa][1] == "specials" then

					specials_index = wa
					has_specials=true

					--aww_duel.debug_message(string.format("---- wa=%s", wa))
					--aww_duel.debug_message_table(attacker_data[w][2][wa])

					for s =1,#unit_data[a][2][wa][2] do
						--last_special_index = s
						--aww_duel.debug_message(string.format("-------- s=%s", s))
						--aww_duel.debug_message_table(attacker_data[w][2][ss][2][s])

						-- managing "swarm" special : will ignore the health-based hit number decreases :
						if unit_data[a][2][wa][2][s][1] == "swarm"
								or unit_data[a][2][wa][2][s][1] == "berserk"
								or unit_data[a][2][wa][2][s][2].id == "aww_special_fury"
						then
							ignore_strike_edit = true
						end

						if unit_data[a][2][wa][2][s][1] == "chance_to_hit" and (not unit_data[a][2][wa][2][s][2].id or unit_data[a][2][wa][2][s][2].id ~= aww_duel.SPECIAL_CHANCE_TO_HIT_ID) then
							weapon_hit_chance = aww_duel.get_special_modifier_value(weapon_hit_chance, unit_data[a][2][wa][2][s][2], (unit_data.id == att_unit.id), (unit_data.id == def_unit.id))
						end

						-- Do NOT enable theses 2 block here, as damage / attacks special are taken in account after this function :

						-- if unit_data[a][2][wa][2][s][1] == "damage" and (not unit_data[a][2][wa][2][s][2].id or unit_data[a][2][wa][2][s][2].id ~= aww_duel.SPECIAL_DAMAGE_ID) then
						-- 	weapon_base_damage = aww_duel.get_special_modifier_value(weapon_base_damage, unit_data[a][2][wa][2][s][2], (unit_data.id == att_unit.id), (unit_data.id == def_unit.id))
						-- end

						 --if unit_data[a][2][wa][2][s][1] == "attacks" and (not unit_data[a][2][wa][2][s][2].id or unit_data[a][2][wa][2][s][2].id ~= aww_duel.SPECIAL_STRIKES_ID) then
						 --	weapon_strikes = aww_duel.get_special_modifier_value(weapon_strikes, unit_data[a][2][wa][2][s][2], (unit_data.id == att_unit.id), (unit_data.id == def_unit.id))
						 --end

					end -- foreach s (special)
					-- aww_duel.debug_message_side("- Specials attacks : YES") -- normal case for all attacks
				end -- if specials
			end -- foreach wa (weapon attribute)



			if aww_status.feature_01 then

				aww_duel.debug_message_side("special hit chance weapon & att_terrain_hit_chance ".. string.format("%s & %s", weapon_hit_chance, att_terrain_hit_chance))
				if weapon_hit_chance < att_terrain_hit_chance then
					weapon_hit_chance = att_terrain_hit_chance
					aww_duel.debug_message_side("special hit chance weapon ignored")
				end

				if not has_specials then
					aww_duel.debug_message_side("- Specials attacks : LINE CREATION")
					table.insert(unit_data[a][2], { "specials", { aww_duel.special_chance_to_hit_100() }})
				else
					table.insert(unit_data[a][2][specials_index][2], aww_duel.special_chance_to_hit_100())
				end
			end

			local damage_ratio   = aww_duel.get_new_damage_ratio(weapon_base_damage, weapon_hit_chance, weapon_strikes, att_hp_ratio)
			local strikes_ratio  = aww_duel.get_new_strikes_ratio(weapon_strikes, att_hp_ratio, ignore_strike_edit)

			if damage_ratio ~= 1 then
				table.insert(unit_data[a][2][specials_index][2], aww_duel.special_damage_multiplier(damage_ratio))
			end

			if strikes_ratio ~= 1 then
				table.insert(unit_data[a][2][specials_index][2], aww_duel.special_strikes_multiplier(strikes_ratio))
			end

			--- end new

		end --if (attribute)a=attack
	end --foreach a (unit attribute)
	wesnoth.put_unit(unit_data)  -- trigger unit placed, take care ! TODO find better way
end -- local function


function aww_duel.remove_tmp_specials(unit)
	if not aww_duel.is_enabled() then
		return
	end
	local unit_data = unit.__cfg
	local to_update = false

	for a =1,#unit_data do
		if unit_data[a][1] == "attack" then

			--aww_duel.debug_message(string.format("a  = %s", a))

			for wa =1,#unit_data[a][2] do
				if unit_data[a][2][wa][1] == "specials" then

					--aww_duel.debug_message(string.format("wa  = %s", wa))

					local s = 1 -- array index  indexes starts at 1 in lua
					local count_specials = #unit_data[a][2][wa][2]
					while (s <= count_specials) do

						--aww_duel.debug_message(string.format("s  = %s", s))

						if unit_data[a][2][wa][2][s] and unit_data[a][2][wa][2][s][2] and unit_data[a][2][wa][2][s][2].id then

							--aww_duel.debug_message(string.format("s.1  = %s", unit_data[a][2][wa][2][s][1]))
							--aww_duel.debug_message(string.format("s.2.id  = %s", unit_data[a][2][wa][2][s][2].id))

							local special_id = unit_data[a][2][wa][2][s][2].id

							--aww_duel.debug_message(string.format("special id = %s", special_id))

							if special_id == aww_duel.SPECIAL_CHANCE_TO_HIT_ID
							 or special_id == aww_duel.SPECIAL_DAMAGE_ID
							 or special_id == aww_duel.SPECIAL_STRIKES_ID
							then
								to_update = true
								--aww_duel.debug_message(string.format("deleted special %s, a=%s, wa=%s, s=%s", special_id, a, wa, s))
								--aww_duel.debug_message_table(unit_data[a][2][wa])
								table.remove(unit_data[a][2][wa][2], s)
								s = -1 -- s-1, because of the re-shift, next item is at the current index
								count_specials = count_specials - 1
							end
						end
						s = s + 1
					end -- foreach s (special)
				end -- if specials
			end -- foreach wa (weapon attribute)
		end --if(attribute) a=attack
	end --foreach a (unit attribute)

	if to_update then
		wesnoth.put_unit(unit_data)  -- trigger unit placed, take care ! TODO find better way
		--aww_duel.debug_message_side(string.format("restored attacks for unit [%s] %s", unit.id, unit.name))
	else
		aww_duel.debug_message_side(string.format("NOTHING to restore for unit [%s] %s", unit.id, unit.name))
		--aww_duel.debug_message_table(unit_data)
	end
end


function aww_duel.special_chance_to_hit_100()
	--local descr = aww_duel.description_no_random_combats()
	return {
		"chance_to_hit" , {
			id=aww_duel.SPECIAL_CHANCE_TO_HIT_ID,
			name = aww_duel.ARROW_CHAR .. _"no random misses",
			value=300,
			cumulative = true,
			--description = descr,
		}
	}
end


function aww_duel.special_damage_multiplier(multiplier)
	--local descr = aww_duel.description_no_random_combats() .. aww_duel.description_squad_mode_custom()
	return {
		"damage" , {
			id = aww_duel.SPECIAL_DAMAGE_ID,
			name = aww_duel.ARROW_CHAR .. _"damage" .. string.format(" x%s", multiplier),
			multiply = multiplier *1,
			cumulative = true,
			--description = descr,
		}
	}
end


function aww_duel.special_strikes_multiplier(multiplier)
	--local descr = aww_duel.description_squad_mode_custom()
	return {
		"attacks" , {
			id = aww_duel.SPECIAL_STRIKES_ID,
			name = aww_duel.ARROW_CHAR .. _"strikes".. string.format(" x%s", multiplier),
			multiply = multiplier *1,
			cumulative = true,
			--description = descr,
		}
	}
end


function aww_duel.special_estimation_dummy(base_damage, base_strikes, hit_chance, hp_ratio, ignore_strike_edit)

	--aww_duel.debug_message_side(string.format("special_estimation_dummy: base_damage=%s, base_strikes=%s, hit_chance=%s, hp_ratio=%s, ignore_strike_edit=%s", base_damage, base_strikes, hit_chance, hp_ratio, ignore_strike_edit))
	hit_chance = math.max(0, hit_chance)

	local damage_ratio  = aww_duel.get_new_damage_ratio(base_damage, hit_chance, base_strikes, hp_ratio)
	local strikes_ratio = aww_duel.get_new_strikes_ratio(base_strikes, hp_ratio, ignore_strike_edit)
	local estim_damage  = base_damage * damage_ratio
	local estim_strikes = base_strikes * strikes_ratio

	local display_damage  =  math.floor(estim_damage)
	local display_strikes =  math.floor(estim_strikes)

	local min_damage = aww_duel.round(.2 * estim_damage) -- .2 to simulate 20% terrain bonus (the minimum in core game)
	if aww_status.feature_01 then
		if hit_chance < 100 then
			min_damage = display_damage
			local max_damage_ratio = aww_duel.get_new_damage_ratio(base_damage, 100, base_strikes, hp_ratio)
			display_damage = math.floor(base_damage * max_damage_ratio)
		end
		display_damage = string.format("(%s-%s)", min_damage, display_damage)
	end

	local descr = _"estimated with" .. string.format(" %s x %s (defense %s%%)", estim_damage, estim_strikes, hit_chance)
	if aww_status.feature_01 and aww_status.feature_08  ~= 0 then
		descr =  descr .. "\n - " .. _"Increased Damage" .. _" (option) : ".. aww_status.feature_08 .. "%"
	end
	if aww_status.feature_02 > 0 then
		descr =  descr .. "\n - " .. _"HP ratio" .. string.format(" %s%%", hp_ratio)
	end

	descr = descr .. "\n" .. aww_duel.description_no_random_combats() .. aww_duel.description_squad_mode_custom()
	if hit_chance >= 100 then
		-- todo see if core game use a round or a math.floor
		descr = descr .. "\n" .. _"- Damages based on defense terrain bonus where enemy is :"
		descr = descr .. "\n" .. aww_duel.info_quick_estim(base_damage, base_strikes, 100, hp_ratio, ignore_strike_edit)
		descr = descr .. "\n" .. aww_duel.info_quick_estim(base_damage, base_strikes, 80, hp_ratio, ignore_strike_edit)
		descr = descr .. "\n" .. aww_duel.info_quick_estim(base_damage, base_strikes, 70, hp_ratio, ignore_strike_edit)
		descr = descr .. "\n" .. aww_duel.info_quick_estim(base_damage, base_strikes, 60, hp_ratio, ignore_strike_edit)
		descr = descr .. "\n" .. aww_duel.info_quick_estim(base_damage, base_strikes, 50, hp_ratio, ignore_strike_edit)
		descr = descr .. "\n" .. aww_duel.info_quick_estim(base_damage, base_strikes, 40, hp_ratio, ignore_strike_edit)
		descr = descr .. "\n" .. aww_duel.info_quick_estim(base_damage, base_strikes, 30, hp_ratio, ignore_strike_edit)
		descr = descr .. "\n" .. aww_duel.info_quick_estim(base_damage, base_strikes, 20, hp_ratio, ignore_strike_edit)
	else
		descr = descr .. "\n" .. _"- Max terrain defense against this attack :" .. string.format("%s%%", 100 - hit_chance)
	end

	return {
		"dummy" , {
			id=aww_duel.SPECIAL_ESTIMATION_DUMMY_ID,
			name = "<span color='#7FFFD4'>"
				.. aww_duel.ARROW_CHAR
				.. string.format("%sx%s ", display_damage, display_strikes)
				.. "</span>",
			cumulative = true,
			description= descr,
		}
	}
end

function aww_duel.info_quick_estim(base_damage, base_strikes, hit_chance, hp_ratio, ignore_strike_edit)

	--aww_duel.debug_message_side(string.format("info_quick_estim: base_damage=%s, base_strikes=%s, hit_chance=%s, hp_ratio=%s, ignore_strike_edit=%s", base_damage, base_strikes, hit_chance, hp_ratio, ignore_strike_edit))
	hit_chance = math.max(0, hit_chance)

	local damage_ratio  = aww_duel.get_new_damage_ratio(base_damage, hit_chance, base_strikes, hp_ratio)
	local strikes_ratio = aww_duel.get_new_strikes_ratio(base_strikes, hp_ratio, ignore_strike_edit)

	local estim_damage  = base_damage * damage_ratio
	local estim_strikes = base_strikes * strikes_ratio

	local display_damage  =  math.floor(estim_damage)
	local display_strikes =  math.floor(estim_strikes)

	local defense = 100 - hit_chance;
	return string.format("%s%% : %sx%s", defense, display_damage, display_strikes)
end

function aww_duel.description_no_random_combats()
	local descr = ""
	if aww_status.feature_01 then
		descr = "- "
			.. _"No Random Combats"
			.. " : "
			.. _"Attacks will never randomly miss, misses probabilities is instead used as damage reduction."
			.. "\n"
	end
	return descr
end

-- see also abilties.ma.cfg:AWW_WEAPON_SPECIAL_SQUAD_SWARM for mirror description
function aww_duel.description_squad_mode_custom()
	local descr = ""
	if aww_status.feature_02 == 1 then
		descr = "- "
			.. _"Squad Mode"
			.. " : "
			.. _"Custom"
			.. " - "
			.. _"The number of strikes of this attack decreases when the unit is wounded. The number of strikes is proportional to the percentage of its of maximum HP the unit has. For example a unit with 3/4 of its maximum HP will get 3/4 of the number of strikes."
			.. " "
			.. _"Minimum strikes will be 1."
     		.. _"For attack having only 1 base strike, HP ratio will be used to reduce damage."
			.. _"Excluded for berserk & fury attack. To simulate that the lesser they are, the more furious they go."
	end
	return descr
end


-- returns calculated ratio (100% will return 1), but weapon_hit_chance will be 100 for 100%
function aww_duel.calculate_randomless_damage_ratio(weapon_hit_chance)

	local adj = aww_status.feature_08 or 0
	-- max hit chance at 100%, in case another mode interfere :
	local result = (math.min(100, weapon_hit_chance) + adj) / 100

	 aww_duel.debug_message_side(string.format("(No-Random) Damage ratio = %s  |  (hit ratio) %s%% + %s%%", result, weapon_hit_chance, aww_status.feature_08))
	-- will return between 10% and 140% (from extra adj) :
	return math.max(.2, math.min(1.4, result))
end


-- Health Ratio : hp/max_hp. Used for Health based Strikes (or Damage if 1 Strike)
function aww_duel.calculate_hp_ratio(hp, max_hp)
	if (max_hp <= 1) then
		-- avoid divide by 0 or multiplication :
		return 1
	end

	local result = hp / max_hp

	-- result between 0.X (to do a minimum of damage) and 1 (in case of over-HP), no rounding :
	result = math.min(1, math.max(.2, result))

	-- aww_duel.debug_message_side(string.format("Health-based) Calculated health ratio = %s | %d / %d", result, hp, max_hp))

	return result
end

-- Number of strike the unit can do with current health, compare to her maximum :

function aww_duel.round_healthy_strikes(weapon_strikes, att_hp_ratio)

	if weapon_strikes <= 1 then
		return 1
	end

	if att_hp_ratio >= 1 then
		return weapon_strikes
	end

	local result = weapon_strikes * att_hp_ratio

	-- min 1, rounded at .5 :
	result = math.max(1, aww_duel.round(result))

	aww_duel.debug_message_side(string.format("(Health-based) Rounded Strikes Number = %s  |  (base strikes) %s x (health ratio) %s", result, weapon_strikes, att_hp_ratio))

	return result
end


function aww_duel.get_new_damage_ratio(weapon_damage, weapon_hit_chance, weapon_strikes, hp_ratio)

	local damage_ratio = 1
	if aww_status.feature_01 then
		damage_ratio = aww_duel.calculate_randomless_damage_ratio(weapon_hit_chance)
	end
	--aww_duel.debug_message_side(string.format("base damage multiplier = %s", damage_ratio))

	if aww_status.feature_02 >= 1 and weapon_strikes == 1 and hp_ratio < 1 then
		if aww_status.feature_01 then
			-- both feature combined can make the units hitting single strikes making too low damage when hurt, so we lift up by 30% (max 1) :
			local hp_ratio_boosted = math.min(1, .3 + hp_ratio)
			damage_ratio =  damage_ratio * hp_ratio_boosted
			aww_duel.debug_message_side(string.format("hp_ratio_boosted to %s because NoRandom + SquadMode, hp_ratio was %s", hp_ratio_boosted, hp_ratio))
		else
			damage_ratio = damage_ratio * hp_ratio
		end
	end

	--aww_duel.debug_message_side(string.format("squad damage multiplier = %s", damage_ratio))

	-- to make base min damage 1 :
	local min_ratio = 1 / math.max(1, weapon_damage)
	-- we add 0.01 to avoid the rounding down by the game, and max ratio 1.4 (damage adj) :
	local result = math.min(1.4, .01 + math.max(min_ratio, damage_ratio))
	aww_duel.debug_message_side(string.format("new damage ratio : %s | calc ratio %s , min %s, weapon_damage %s, hit chance %s, strikes %s, hp_ratio %s", result, damage_ratio, min_ratio, weapon_damage, weapon_hit_chance, weapon_strikes, hp_ratio))
	return result
end


function aww_duel.get_new_strikes_ratio(weapon_strikes, hp_ratio, ignore_strike_edit)

	local estim_strikes_number = weapon_strikes
	if aww_status.feature_02 == 1 and not ignore_strike_edit then
		estim_strikes_number = aww_duel.round_healthy_strikes(weapon_strikes, hp_ratio)
	end

	local strikes_ratio = estim_strikes_number / math.max(1, weapon_strikes)

	-- to make base min 1 :
	local min_ratio = 1 / math.max(1, weapon_strikes)

	-- we add 0.01 to avoid the rounding down by the game, and max ratio 1 :
	local result = math.min(1, .01 + math.max(min_ratio, strikes_ratio))
	aww_duel.debug_message_side(string.format("new strikes ratio : %s | (strikes %s x hp %s = %s), min %s, before min %s, ignored strikes =%s", result, weapon_strikes, hp_ratio, estim_strikes_number, min_ratio, strikes_ratio, ignore_strike_edit))
	return result
end


-- to manage specials number-based likes [chance_to_hit] (marskman, magical), [damage] (backstab, charge), [attacks] etc :
function aww_duel.get_special_modifier_value(base_value, special_data, offense_test, defense_test)
	local new_value = base_value
	if special_data.active_on ~= "offense" or offense_test then
		if special_data.active_on ~= "defense" or defense_test then
			if special_data.value then
				if special_data.cumulative ~= true or 0 < special_data.value then
					new_value = special_data.value
				end
			end
			if special_data.add then
				new_value = new_value + special_data.add
			end
			if special_data.sub then
				new_value = new_value - special_data.sub
			end
			if special_data.multiply then
				new_value = new_value * special_data.multiply
			end
			if special_data.divide then
				new_value = new_value - special_data.divide
			end

		end
	end
	return new_value
end


function aww_duel.estimate_weapons_special_display(unit)

	local unit_to_update = false -- indicates if at least a weapon data has changed, so we save the unit
	local base_hit_chance = 100

	aww_duel.unit_side = unit.side

	local hp = unit.hitpoints
	local max_hp = unit.max_hitpoints
	local hp_ratio = aww_duel.calculate_hp_ratio(hp, max_hp)

	local unit_data = unit.__cfg

	--aww_duel.debug_message_table(unit_data)

	for a =1,#unit_data do
		if unit_data[a][1] == "attack" then

			local current_weapon_stat = ""
			local weapon_base_damage = unit_data[a][2].damage
			local weapon_strikes = unit_data[a][2].number
			local special_hit_chance = base_hit_chance
			local special_damage = weapon_base_damage
			local special_strikes = weapon_strikes
			local has_specials=false
			local ignore_strike_edit = false

			local specials_index = 0

			local special_index_estim = nil

			for wa =1,#unit_data[a][2] do
				if unit_data[a][2][wa][1] == "specials" then

					specials_index = wa
					has_specials=true

					for s =1,#unit_data[a][2][wa][2] do

						-- managing "swarm" special : will ignore the health-based hit number decreases :
						if unit_data[a][2][wa][2][s][1] == "swarm"
								or unit_data[a][2][wa][2][s][1] == "berserk"
								or unit_data[a][2][wa][2][s][2].id == "aww_special_fury"
						then
							ignore_strike_edit = true
						end

						if unit_data[a][2][wa][2][s][1] == "chance_to_hit" and (not unit_data[a][2][wa][2][s][2].id or unit_data[a][2][wa][2][s][2].id ~= aww_duel.SPECIAL_CHANCE_TO_HIT_ID) then
							special_hit_chance = aww_duel.get_special_modifier_value(special_hit_chance, unit_data[a][2][wa][2][s][2], true, false)
							-- will be a variable between 20 and 80%. It's the opposite of the defense % on terrains
						end

						-- estimation of damage / attacks  (do not take everything in account)

						if unit_data[a][2][wa][2][s][1] == "damage" and (not unit_data[a][2][wa][2][s][2].id or unit_data[a][2][wa][2][s][2].id ~= aww_duel.SPECIAL_DAMAGE_ID) then
							special_damage = aww_duel.get_special_modifier_value(special_damage, unit_data[a][2][wa][2][s][2],  true, false)
						end

						if unit_data[a][2][wa][2][s][1] == "attacks" and (not unit_data[a][2][wa][2][s][2].id or unit_data[a][2][wa][2][s][2].id ~= aww_duel.SPECIAL_STRIKES_ID) then
							special_strikes = aww_duel.get_special_modifier_value(special_strikes, unit_data[a][2][wa][2][s][2], true, false)
						end

						--aww_duel.debug_message("---- search --")
						--aww_duel.debug_message(unit_data[a][2][wa][2][s][2].id)
						--aww_duel.debug_message(unit_data[a][2][wa][2][s][2].name)
						--aww_duel.debug_message("---- end search --")
						--aww_duel.debug_message(s)
						--aww_duel.debug_message_table(unit_data[a][2][wa][2][s][2])

						if (unit_data[a][2][wa][2][s][2].id == aww_duel.SPECIAL_ESTIMATION_DUMMY_ID) then
							current_weapon_stat = unit_data[a][2][wa][2][s][2].name
							special_index_estim = s
							--aww_duel.debug_message("found it !")
							--aww_duel.debug_message(current_weapon_stat)
							--aww_duel.debug_message(s)
						end

					end -- foreach s (special)
				end -- if specials
			end -- foreach wa (weapon attribute)

			if aww_status.feature_01 or aww_status.feature_02 == 1 or (aww_status.feature_02 == 2 and special_strikes == 1) then

				--aww_duel.debug_message_side("special hit chance ".. string.format("%s", special_hit_chance))
				if special_hit_chance < 60 then
					special_hit_chance = base_hit_chance
					--aww_duel.debug_message_side("special hit chance ignored")
				end

				local new_special_estim_data = aww_duel.special_estimation_dummy(special_damage, special_strikes, special_hit_chance, hp_ratio, ignore_strike_edit)

				if current_weapon_stat ~= new_special_estim_data[2].name then
					unit_to_update = true
					--aww_duel.debug_message("to update !")
					--aww_duel.debug_message(current_weapon_stat)
					--aww_duel.debug_message(new_special[2].name)
					if special_index_estim ~= nil then
						-- update special :
						unit_data[a][2][specials_index][2][special_index_estim] = new_special_estim_data
						--aww_duel.debug_message("special_index_squad_mode =")
						--aww_duel.debug_message(special_index_squad_mode)
					else
						-- insert special :
						table.insert(unit_data[a][2][specials_index][2], new_special_estim_data)
					end
				end
			end

		end --if (attribute)a=attack
	end --foreach a (unit attribute)

	if unit_to_update == true then
		wesnoth.put_unit(unit_data)  -- trigger unit placed, take care ! TODO find better way
		aww_duel.debug_message_side("weapons estimations updated for unit : ".. unit.id)
	end
end


function aww_duel.round(value)
	return math.floor(.5 + value)
end


-- display chat message if debug option enabled
-- Launch only if attacker unit.side = event.$side_number - or side not defined
function aww_duel.debug_message_side(msg)

	local player_side = wesnoth.get_variable("side_number") or 0

	if player_side > 0 and (player_side == aww_duel.unit_side) then
		return aww_duel.debug_message(msg)
	end
	return false
end


function aww_duel.debug_message(msg)

	if aww_status.feature_07 then
		wesnoth.message("AWW DUEL debug", msg)
	end
	return false
end


-- debug function : log/print array
function aww_duel.debug_message_table(o)
	aww_duel.debug_message(aww_duel.dump_table(o, 9))
	--aww_duel.debug_message(wesnoth.wesnoth.debug(o))
	-- try wml.tostring() or wesnoth.debug(wml_table)
end


-- debug function : stringify array
function aww_duel.dump_table(o, depth)
	if depth < 0 then
		return "..."
	end
	if type(o) == 'table' then
		local s = '{ '
		for k,v in pairs(o) do
			if type(k) ~= 'number' then k = '"'..k..'"' end
			if k == nil then
				s = s .. '[nil] = ' .. aww_duel.dump_table(v, depth-1) .. ','
			else
				local r = aww_duel.dump_table(v, depth-1)
				if r == nil then
					s = s .. '['..k..'] = nil,'
				else
					s = s .. '['..k..'] = ' .. aww_duel.dump_table(v, depth-1) .. ','
				end
			end
		end
		return s .. '} '
	else
		return tostring(o)
	end
end


aww_duel.debug_message("aww_duel.lua loaded.")
-->>
