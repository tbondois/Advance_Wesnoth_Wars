--<<
-- Author: Ruvaak
-- Original Creation

local _ = wesnoth.textdomain 'aww'

aww_status = {
	title = _"Advanced Wesnoth Wars",
	version = "1.14.14.1",
	FEATURE_IDS = {
		[1]  = "aww_01_enable_randomless_combats",
		[2]  = "aww_02_squad_mode",
		[3]  = "aww_03_enable_promoted_leader",
		[4]  = "aww_04_passive_xp",
		[5]  = "aww_05_healing_xp",
		[6]  = "aww_06_enable_levelup_relative_healing",
		[7]  = "aww_07_enable_verbose",
		[8]  = "aww_08_randomless_damage_adjustment",
		[9]  = "aww_09_enable_amla_bonus",
		[10] = "aww_10_enable_gifted_leaders",
		[11] = "aww_11_enable_ninja",
		[12] = "aww_12_enable_berserk_fix",
		[13] = "aww_13_enable_ambushed_fix",
		[14] = "aww_14_enable_levelup_notif",
		[15] = "aww_15_enable_levelup_amla_inc",
	},
}


function aww_status.run()
	aww_status.versioning()
	aww_status.init()
	aww_status.message_info()
end


function aww_status.init()
	aww_status.feature_01 = aww_status.get_feature_value(1, false)
	aww_status.feature_02 = aww_status.get_feature_value(2, 0)
	aww_status.feature_03 = aww_status.get_feature_value(3, false)
	aww_status.feature_04 = aww_status.get_feature_value(5, 0)
	aww_status.feature_05 = aww_status.get_feature_value(5, 0)
	aww_status.feature_06 = aww_status.get_feature_value(6, false)
	aww_status.feature_07 = aww_status.get_feature_value(7, false)
	aww_status.feature_08 = aww_status.get_feature_value(8, 0)
	aww_status.feature_09 = aww_status.get_feature_value(9, false)
	aww_status.feature_10 = aww_status.get_feature_value(10, false)
	aww_status.feature_11 = aww_status.get_feature_value(11, false)
	aww_status.feature_12 = aww_status.get_feature_value(12, false)
	aww_status.feature_13 = aww_status.get_feature_value(13, false)
	aww_status.feature_14 = aww_status.get_feature_value(14, false)
	aww_status.feature_15 = aww_status.get_feature_value(15, false)
end


function aww_status.versioning()
	local prev_version = wesnoth.get_variable("aww_version")
	if prev_version == nil or prev_version ~= aww_status.version then
		aww_status.migrate(prev_version)
	end
	wesnoth.set_variable("aww_version", aww_status.version)
end


-- migrate old versions name to keep options through versions of AWW on same campaign :
function aww_status.migrate(from_version)
	if aww_status.get_feature_value(1, nil) == nil and wesnoth.get_variable("aww_enable_randomless_combats") ~= nil then
		aww_status.update_feature_01(wesnoth.get_variable("aww_enable_randomless_combats"))
	end
	if aww_status.get_feature_value(2, nil) == nil and wesnoth.get_variable("aww_enable_health_based_combats") ~= nil then
		local was_enabled_02 = wesnoth.get_variable("aww_enable_health_based_combats")
		if was_enabled_02 == true then
			aww_status.update_feature_02(1)
		else
			aww_status.update_feature_02(0)
		end
	end
	if aww_status.get_feature_value(3, nil) == nil and wesnoth.get_variable("aww_enable_leader_promotions")~= nil then
		aww_status.update_feature_03(wesnoth.get_variable("aww_enable_leader_promotions"))
	end
	if aww_status.get_feature_value(4, nil) == nil and wesnoth.get_variable("aww_passive_xp") ~= nil then
		aww_status.update_feature_04(wesnoth.get_variable("aww_passive_xp")*1)
	end
	if aww_status.get_feature_value(5, nil) == nil and wesnoth.get_variable("aww_healing_xp") ~= nil  then
		aww_status.update_feature_05(wesnoth.get_variable("aww_healing_xp")*1)
	end
	if aww_status.get_feature_value(6, nil) == nil and wesnoth.get_variable("aww_enable_advance_healing_reduced") ~= nil then
		aww_status.update_feature_06(wesnoth.get_variable("aww_enable_advance_healing_reduced"))
	end
	if aww_status.get_feature_value(7, nil) == nil and wesnoth.get_variable("aww_enable_debug") ~= nil  then
		aww_status.update_feature_07(wesnoth.get_variable("aww_enable_debug"))
	end
	if aww_status.get_feature_value(8, nil) == nil and wesnoth.get_variable("aww_randomless_terrain_adjustment") ~= nil then
		aww_status.update_feature_08(wesnoth.get_variable("aww_randomless_terrain_adjustment")*1)
	end
	if aww_status.get_feature_value(9, nil) == nil and wesnoth.get_variable("aww_enable_amla_extra_bonus") ~= nil  then
		aww_status.update_feature_09(wesnoth.get_variable("aww_enable_amla_extra_bonus"))
	end
	if aww_status.get_feature_value(10, nil)== nil and wesnoth.get_variable("aww_enable_gifted_leaders") ~= nil  then
		aww_status.update_feature_10(wesnoth.get_variable("aww_enable_gifted_leaders"))
	end
	if aww_status.get_feature_value(11, nil) == nil and wesnoth.get_variable("aww_enable_stealth_mode") ~= nil  then
		aww_status.update_feature_11(wesnoth.get_variable("aww_enable_stealth_mode"))
	end

	if from_version ~= nil then
		wesnoth.message("AWW notice", "migrating from version ".. wesnoth.get_variable("aww_version") .. " to ".. aww_status.version)
		wesnoth.set_variable("aww_migrated_version", from_version)
	end
end


function aww_status.get_info(filter_id)
	-- filter_id is an optionnal parameter. if not present/nil, will display all enabled features in the same order as in options menu
	local msg = ""
	if (filter_id == nil or filter_id == 1) and aww_status.feature_01 then
		msg = "01. ".._"No Random Combats" .. " | "
	end
	if aww_status.feature_01 and (filter_id == nil or filter_id == 1) and aww_status.feature_08 ~= 0 then
		msg = msg .. "08. ".._"Increased Damage"
				.. string.format(" [%s%%]",aww_status.feature_08)
				.. " | "
	end
	if (filter_id == nil or filter_id == 2) and aww_status.feature_02 and aww_status.feature_02 ~= 0 then
		local label = ""
		if aww_status.feature_02 == 1 then
			label = _"Custom"
		elseif aww_status.feature_02 == 2 then
			label = _"Swarm"
		end
		msg = msg .. "02. ".._"Squad Mode"
				.. string.format(" [%s:", aww_status.feature_02)
				..  label
				.. "] | "
	end
	if (filter_id == nil or filter_id == 14) and aww_status.feature_14 then
		msg = msg .. "14. ".. _"L-Up ".._"Notif" .. " | "
	end
	if (filter_id == nil or filter_id == 6) and aww_status.feature_06 then
		msg = msg .. "06. ".. _"L-Up ".. _"Relative Heal" .. " | "
	end
	if (filter_id == nil or filter_id == 15) and aww_status.feature_15 then
		msg = msg .. "15. L-Up ".._"AMLA".." ".. _"Increase Level Number" .. " | "
	end
	if (filter_id == nil or filter_id == 9) and aww_status.feature_09 then
		msg = msg .. "09. ".. _"L-Up ".._"AMLA".." ".._"Bonuses" .. " | "
	end
	if (filter_id == nil or filter_id == 3) and aww_status.feature_03 then
		msg = msg .. "03. ".. _"L-Up ".._"AMLA".." ".._"Promoted Leaders" .. " | "
	end
	if (filter_id == nil or filter_id == 10) and aww_status.feature_10 then
		msg = msg .. "10. ".. _"Epic Heroes" .. " | "
	end
	if (filter_id == nil or filter_id == 4) and aww_status.feature_04 and aww_status.feature_04 ~= 0 then
		msg = msg .. "04. ".. _"Passive XP"
		 .. string.format(" [%s", aww_status.feature_04 )
		.. _"/turn]"
		 .. " | "
	end
	if (filter_id == nil or filter_id == 5) and aww_status.feature_05 and aww_status.feature_05 ~= 0
	then msg = msg .. "05. ".._"Healing XP"
			.. _" [Max "
			.. string.format("%s", aww_status.feature_05)
			.. _"/turn]"
			.. " | "
	end
	if (filter_id == nil or filter_id == 12) and aww_status.feature_12 then
		msg = msg .. "12. ".._"Berserk tweak" .. " | "
	end
	if (filter_id == nil or filter_id == 13) and aww_status.feature_13 then
		msg = msg .. "13. ".._"Ambush tweak" .. " | "
	end
	if (filter_id == nil or filter_id == 11) and aww_status.feature_11 then
		msg = msg .. "11. ".._"NINJA WARS!" .. " | "
	end
	if (filter_id == nil or filter_id == 7) and aww_status.feature_07 then
		msg = msg .. "07. ".._"Verbose"
	end

	if msg ~= "" then
		msg = _"Enabled :" .. " " .. msg
	elseif filter_id then
		msg = aww_status.get_feature_info(filter_id)
	else
		msg = _"All mod options are disabled."
	end
	return msg
end


function aww_status.get_feature_info(id)
	local msg = string.format(" #%s. %s = [%s]", id, aww_status.feature_code(id), aww_status.get_feature_value(id, '?'))
    msg = string.gsub(msg, "true", "ON")
    msg = string.gsub(msg, "false", "off")
    msg = string.gsub(msg, "aww_", "")
    msg = string.gsub(msg, "_", " ")
	return _"Feature" .. msg
end


function aww_status.message_info(id)
	wesnoth.message(aww_status.title .. " v".. aww_status.version, aww_status.get_info(id))
end


function aww_status.message_info_all()
	local msg = ""
	for id = 1, #aww_status.FEATURE_IDS do
		msg = msg .. aww_status.get_feature_info(id) .. " | "
	end
	wesnoth.message(aww_status.title .. " v".. aww_status.version, msg)
end


function aww_status.feature_code(id)
	if aww_status.FEATURE_IDS[id] ~= nil then
		return aww_status.FEATURE_IDS[id]
	end
	return "undefined"
end

function aww_status.get_feature_value(id, nil_value)
	local value = wesnoth.get_variable(aww_status.feature_code(id))
	if value == nil then
		 return nil_value
	end
	return value
end

function aww_status.set_feature_value(id, value)
	wesnoth.set_variable(aww_status.feature_code(id), value)
end

function aww_status.update_feature_01(value)
	local id = 1
	value = aww_status.to_bool(value)
	aww_status.feature_01 = value
	local old_value = aww_status.get_feature_value(id, nil)
	if value ~= old_value then
		aww_status.feature_01_was = old_value
		aww_status.set_feature_value(id, value)
		aww_status.message_info(id)
		wesnoth.fire_event("aww_event_01_02_reset")
		if value then
			wesnoth.fire_event('aww_event_reload_duel')
		end
	end
	return value
end


function aww_status.update_feature_02(value)
	local id = 2
	value = value *1
	aww_status.feature_02 = value
	local old_value = aww_status.get_feature_value(id, nil)
	if value ~= old_value then
		aww_status.feature_02_was = old_value
		aww_status.set_feature_value(id, value)
		aww_status.message_info(id)
		wesnoth.fire_event("aww_event_01_02_reset")
		if old_value == 0 then
			wesnoth.fire_event('aww_event_reload_duel')
		end
		if old_value == 2 then
			wesnoth.fire_event("aww_event_02_swarm_disable")
		end
		if value == 2 then
			wesnoth.fire_event("aww_event_02_swarm_enable")
		end
	end
	return value
end


function aww_status.update_feature_03(value)
	local id = 3
	value = aww_status.to_bool(value)
	aww_status.feature_03 = value
	local old_value = aww_status.get_feature_value(id, nil)
	if value ~= old_value then
		aww_status.feature_03_was = old_value
		aww_status.set_feature_value(id, value)
		aww_status.message_info(id)
		if value then
			wesnoth.fire_event("aww_event_03_enable")
		else
			wesnoth.fire_event("aww_event_03_disable")
		end
		if value == false then
		end
	end
	return value
end

function aww_status.update_feature_04(value)
	local id = 5
	value = value *1
	aww_status.feature_04 = value
	local old_value = aww_status.get_feature_value(id, nil)
	if value ~= old_value then
		aww_status.feature_04_was = old_value
		aww_status.set_feature_value(id, value)
		aww_status.message_info(id)
	end
	return value
end

function aww_status.update_feature_05(value)
	local id = 5
	value = value *1
	aww_status.feature_05 = value
	local old_value = aww_status.get_feature_value(id, nil)
	if value ~= old_value  then
		aww_status.feature_05_was = old_value
		aww_status.set_feature_value(id, value)
		aww_status.message_info(id)
	end
	return value
end

function aww_status.update_feature_06(value)
	local id = 6
	value = aww_status.to_bool(value)
	aww_status.feature_06 = value
	local old_value = aww_status.get_feature_value(id, nil)
	if value ~= old_value then
		aww_status.feature_06_was = old_value
		aww_status.set_feature_value(id, value)
		aww_status.message_info(id)
	end
	return value
end

function aww_status.update_feature_07(value)
	local id = 7
	value = aww_status.to_bool(value)
	aww_status.feature_07 = value
	local old_value = aww_status.get_feature_value(id, nil)
	if value ~= old_value then
		aww_status.feature_07_was = old_value
		aww_status.set_feature_value(id, value)
		aww_status.message_info(id)
		if (aww_status.feature_01 or aww_status.feature_02 > 0) then
			wesnoth.fire_event('aww_event_reload_duel')
		end
	end
	return value
end

function aww_status.update_feature_08(value)
	local id = 8
	value = value *1
	aww_status.feature_08 = value
	local old_value = aww_status.get_feature_value(id, nil)
	if value ~= old_value then
		aww_status.feature_08_was = old_value
		aww_status.set_feature_value(id, value)
		aww_status.message_info(id)
		if (aww_status.feature_01) then
			wesnoth.fire_event('aww_event_reload_duel')
			wesnoth.fire_event("aww_event_01_02_reset")
		end
	end
	return value
end

function aww_status.update_feature_09(value)
	local id = 9
	value = aww_status.to_bool(value)
	aww_status.feature_09 = value
	local old_value = aww_status.get_feature_value(id, nil)
	if value ~= old_value then
		aww_status.feature_09_was = old_value
		aww_status.set_feature_value(id, value)
		aww_status.message_info(id)
		if value == false then
			wesnoth.fire_event("aww_event_09_disable")
		end
	end
	return value
end

function aww_status.update_feature_10(value)
	local id = 10
	value = aww_status.to_bool(value)
	aww_status.feature_10 = value
	local old_value = aww_status.get_feature_value(id, nil)
	if value ~= old_value then
		aww_status.feature_10_was = old_value
		aww_status.set_feature_value(id, value)
		aww_status.message_info(id)
		if value then
			wesnoth.fire_event("aww_event_10_enable")
		else
			wesnoth.fire_event("aww_event_10_disable")
		end
	end
	return value
end

function aww_status.update_feature_11(value)
	local id = 11
	value = aww_status.to_bool(value)
	aww_status.feature_11 = value
	local old_value = aww_status.get_feature_value(id, nil)
	if value ~= old_value then
		aww_status.feature_11_was = old_value
		aww_status.set_feature_value(id, value)
		aww_status.message_info(id)
		if value then
			wesnoth.fire_event("aww_event_11_enable")
		else
			wesnoth.fire_event("aww_event_11_disable")
		end
	end
	return value
end


function aww_status.update_feature_12(value)
	local id = 12
	value = aww_status.to_bool(value)
	aww_status.feature_12 = value
	local old_value = aww_status.get_feature_value(id, nil)
	if value ~= old_value then
		aww_status.feature_12_was = old_value
		aww_status.set_feature_value(id, value)
		aww_status.message_info(id)
		if value then
			wesnoth.fire_event("aww_event_12_enable")
		else
			wesnoth.fire_event("aww_event_12_disable")
		end
	end
	return value
end


function aww_status.update_feature_13(value)
	local id = 13
	value = aww_status.to_bool(value)
	value = aww_status.to_bool(value)
	aww_status.feature_13 = value
	local old_value = aww_status.get_feature_value(id, nil)
	if value ~= old_value then
		aww_status.feature_13_was = old_value
		aww_status.set_feature_value(id, value)
		aww_status.message_info(id)
		wesnoth.fire_event("aww_event_13_reset")
	end
	return value
end

function aww_status.update_feature_14(value)
	local id = 14
	value = aww_status.to_bool(value)
	aww_status.feature_14 = value
	local old_value = aww_status.get_feature_value(id, nil)
	if value ~= old_value then
		aww_status.feature_14_was = old_value
		aww_status.set_feature_value(id, value)
		aww_status.message_info(id)
	end
	return value
end

function aww_status.update_feature_15(value)
	local id = 15
	value = aww_status.to_bool(value)
	aww_status.feature_15 = value
	local old_value = aww_status.get_feature_value(id, nil)
	if value ~= old_value then
		aww_status.feature_13_was = old_value
		aww_status.set_feature_value(id, value)
		aww_status.message_info(id)
	end
	return value
end


function aww_status.to_bool(v)
	if (type(v) =="boolean") then
		return v
	end
    return v and (
		(type(v) =="number" and (v > 0))
		or (type(v)=="string" and v ~= "false" and v ~= "no" and v ~= "0" and v ~= "")
	)
end


-- DEPRECATED alias for run(), for retrocompatibility in dev mode :
function aww_status.welcome()
	aww_status.run()
end

-- aww_status.run() -- load aww_status.up.lua instead
-->>
