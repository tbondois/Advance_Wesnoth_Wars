--<<
-- Author: Ruvaak
-- Original Creation

--local _ = wesnoth.textdomain 'wesnoth-aww'

local _ = wesnoth.textdomain 'wesnoth-aww'

aww_status = {
	title = _"Advanced Wesnoth Wars",
	version = "1.14.13.0"
}

function aww_status.init()
	aww_status.feature_01 = wesnoth.get_variable("aww_01_enable_randomless_combats") or false
	aww_status.feature_02 = wesnoth.get_variable("aww_02_squad_mode") or 0
	aww_status.feature_03 = wesnoth.get_variable("aww_03_enable_promoted_leader") or false
	aww_status.feature_04 = wesnoth.get_variable("aww_04_passive_xp") or 0
	aww_status.feature_05 = wesnoth.get_variable("aww_05_healing_xp") or 0
	aww_status.feature_06 = wesnoth.get_variable("aww_06_enable_levelup_relative_healing") or false
	aww_status.feature_07 = wesnoth.get_variable("aww_07_enable_verbose") or false
	aww_status.feature_08 = wesnoth.get_variable("aww_08_randomless_damage_adjustment") or 0
	aww_status.feature_09 = wesnoth.get_variable("aww_09_enable_amla_bonus") or false
	aww_status.feature_10 = wesnoth.get_variable("aww_10_enable_gifted_leaders") or false
	aww_status.feature_11 = wesnoth.get_variable("aww_11_enable_ninja") or false
	aww_status.feature_12 = wesnoth.get_variable("aww_12_enable_berserk_fix") or false
	aww_status.feature_13 = wesnoth.get_variable("aww_13_enable_ambushed_fix") or false
	aww_status.feature_14 = wesnoth.get_variable("aww_14_enable_levelup_notif") or false
	wesnoth.set_variable("aww_version", aww_status.version)
end


function aww_status.migrate()
	-- migrate old versions name to keep options through versions of AWW on same campaign :
	if wesnoth.get_variable("aww_01_enable_randomless_combats") == nil and wesnoth.get_variable("aww_enable_randomless_combats") ~= nil then
		wesnoth.set_variable("aww_01_enable_randomless_combats", wesnoth.get_variable("aww_enable_randomless_combats"))
	end
	if wesnoth.get_variable("aww_02_squad_mode") == nil and wesnoth.get_variable("aww_enable_health_based_combats") ~= nil then
		local was_enabled_02 = wesnoth.get_variable("aww_enable_health_based_combats")
		if was_enabled_02 == true then
			wesnoth.set_variable("aww_02_squad_mode", 1)
		else
			wesnoth.set_variable("aww_02_squad_mode", 0)
		end
	end
	if wesnoth.get_variable("aww_03_enable_promoted_leader") == nil and wesnoth.get_variable("aww_enable_leader_promotions")~= nil then
		wesnoth.set_variable("aww_03_enable_promoted_leader", wesnoth.get_variable("aww_enable_leader_promotions"))
	end
	if wesnoth.get_variable("aww_04_passive_xp") == nil and wesnoth.get_variable("aww_passive_xp") ~= nil then
		wesnoth.set_variable("aww_04_passive_xp", wesnoth.get_variable("aww_passive_xp")*1)
	end
	if wesnoth.get_variable("aww_05_healing_xp") == nil and wesnoth.get_variable("aww_healing_xp") ~= nil  then
		wesnoth.set_variable("aww_05_healing_xp", wesnoth.get_variable("aww_healing_xp")*1)
	end
	if wesnoth.get_variable("aww_06_enable_levelup_relative_healing") == nil and wesnoth.get_variable("aww_enable_advance_healing_reduced") ~= nil then
		wesnoth.set_variable("aww_06_enable_levelup_relative_healing", wesnoth.get_variable("aww_enable_advance_healing_reduced"))
	end
	if wesnoth.get_variable("aww_07_enable_verbose") == nil and wesnoth.get_variable("aww_enable_debug") ~= nil  then
		wesnoth.set_variable("aww_07_enable_verbose", wesnoth.get_variable("aww_enable_debug"))
	end
	if wesnoth.get_variable("aww_08_randomless_damage_adjustment") == nil and wesnoth.get_variable("aww_randomless_terrain_adjustment") ~= nil then
		wesnoth.set_variable("aww_08_randomless_damage_adjustment", wesnoth.get_variable("aww_randomless_terrain_adjustment")*1)
	end
	if wesnoth.get_variable("aww_09_enable_amla_bonus") == nil and wesnoth.get_variable("aww_enable_amla_extra_bonus") ~= nil  then
		wesnoth.set_variable("aww_09_enable_amla_bonus", wesnoth.get_variable("aww_enable_amla_extra_bonus"))
	end
	if wesnoth.get_variable("aww_10_enable_gifted_leaders") == nil and wesnoth.get_variable("aww_enable_gifted_leaders") ~= nil  then
		wesnoth.set_variable("aww_10_enable_gifted_leaders", wesnoth.get_variable("aww_enable_gifted_leaders"))
	end
	if wesnoth.get_variable("aww_11_enable_ninja") == nil and wesnoth.get_variable("aww_enable_stealth_mode") ~= nil  then
		wesnoth.set_variable("aww_11_enable_ninja", wesnoth.get_variable("aww_enable_stealth_mode"))
	end
end


function aww_status.get_info()

	local msg = ""
	if aww_status.feature_01 then
		msg = _"1. No Random Combats" .. " | "
	end
	if aww_status.feature_01 and aww_status.feature_08 ~= 0 then
		msg = msg .. _"2. Increased Damage"
				.. string.format(" [%s%%]",aww_status.feature_08)
				.. " | "
	end
	if aww_status.feature_02 and aww_status.feature_02 ~= 0 then
		local label = ""
		if aww_status.feature_02 == 1 then
			label = _"Custom"
		elseif aww_status.feature_02 == 2 then
			label = _"Swarm"
		end
		msg = msg .. _"3. Squad Mode"
				.. string.format(" [%s:", aww_status.feature_02)
				..  label
				.. "] | "
	end
	if aww_status.feature_14 then
		msg = msg .. _"L-Up Notif" .. " | "
	end
	if aww_status.feature_06 then
		msg = msg .. _"4. L-Up Relative Heal" .. " | "
	end
	if aww_status.feature_09 then
		msg = msg .. _"5. L-Up AMLA Bonuses" .. " | "
	end
	if aww_status.feature_03 then
		msg = msg .. _"6. L-Up AMLA Promoted Leaders" .. " | "
	end
	if aww_status.feature_10 then
		msg = msg .. _"7. Gifted Heroes" .. " | "
	end
	if aww_status.feature_05 and aww_status.feature_04 ~= 0 then
		msg = msg .. _"8. Passive XP"
		 .. string.format(" [%s", aww_status.feature_04 )
		.. _"/turn]"
		 .. " | "
	end
	if aww_status.feature_05 and aww_status.feature_05 ~= 0
	then msg = msg .. _"9. Healing XP"
			.. _" [Max "
			.. string.format("%s", aww_status.feature_05)
			.. _"/turn]"
			.. " | "
	end
	if aww_status.feature_12 then
		msg = msg .. _"10. Berserk tweak" .. " | "
	end
	if aww_status.feature_13 then
		msg = msg .. _"11. Ambushed tweak" .. " | "
	end
	if aww_status.feature_11 then
		msg = msg .. _"12. NINJA WARS!" .. " | "
	end
	if aww_status.feature_07 then
		msg = msg .. _"Verbose"
	end

	if msg ~= "" then
		msg = _"Enabled :" .. " " .. msg
	else
		msg = _"All options are disabled."
	end
	return msg
end


function aww_status.message_info()
	wesnoth.message(aww_status.title .. " v".. aww_status.version, aww_status.get_info())
end


function aww_status.welcome()
	aww_status.migrate()
	aww_status.init()
	aww_status.message_info()
end


aww_status.welcome()

-->>
