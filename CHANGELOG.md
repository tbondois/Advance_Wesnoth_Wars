# Changelog

For more clarity about compatibility, first 2 version numbers will follow base game version.

So 1.14.X.Y means game was checked compatible with Wesnoth 1.14. X is incremented for new features ; Y is increment for fixes/optimisations.

## [1.14.14.1] - 2019-04-13

### Changed
- re-balanced Feature #12 (Berserk tweak) : no more initial offensive drains, base attacks damage don't increase on kills, but after 5 kills the fury attack gains also Bloodthirsty (offensive drains)
- Feature #11, ninja : movement increase is used in [object] like the others changes,  don't include a 'stealthy' trait anymore.

## [1.14.14.0] - 2019-04-13

### Added
- Feature #15 : Level-Up After Max Level Advancement : Increase Level Number (default ON)
- Explanations in README.md and code adaption (aww_status.lua, aww_duel.lua) to enabled/disable feature during a game/campaign
- aww_status.run.lua (to separate aww_status declaration from execution)
- aww_status.lua : some functions to manage disable/enable features
- events _enable _restart, _reset on most features impacting units, to revert / re-enable changes (experimental)

### Changed
- Feature #13 : Ambush Tweak no longer in beta, added hides cooldown of 1 turn after surprise/normal attack
- Options numbers are now the same as feature numbers.
- Squad Mode Custom : strikes special effect is now a cumulative multiplier, instead of a not-cumulative
- Squad Mode : Swarm : attacks having 1 base strike will do reduced HP-related damages, like in Custom Mode.
- NoRandomCombats & Squad Mode : added + 0.01 to multiplier to prevent a round down and get a round(.5)
- Feature "Gifted heroes" renamed "Epic heroes"
- balancing Epic heroes : don't include anymore "leadership" ability (already give custom regen 4/slowed + distract)
- Some adjustments on gifted trait stats, and renamed it "epic"
- Max attack damage points earned with "Fury" changed from 15 to 10
- Somes changes in scenario + map 4p_Ruvaak_Mirage_Atoll (now v1.4)
- gettext : textdomains wesnoth-aww and wesnoth-aww-rma merged in one "aww" (and scenario translation reworks)
- macro files *.ma.cfg renamed *.mac.cfg
- uses of [objects] in some features, for effects/abilities
- Features #09 AMLA Random Bonuses : less probabiities to have moves +1

### Fixed
- LUA error sometimes in the end of scenario when NoRandom-Combats/Squad Mode Custom is enabled and no side is defined : (Saw Voyage of a drake > skip tutorial)
- Healing XP : apply to ability-type "heals" instead of only ability id "healing". Optimized not-poisoned filter.

### Deleted
- useless about.cfg

## [1.14.13.0] - 2019-04-04

### Added
- Ability 'distract' for "Gifted Leader". It's a Skirmisher leadership from data/campaigns/The_Rise_Of_Wesnoth/utils/trow-abilities.cfg
- Ability 'leadership' for "Gifted Leader"

### Changed
- Completely changed the "berserk tweak"
- Update french translations
- Ability 'distract' instead of 'skirmisher' for "NINJA WARS!" & "ALMA Random Bonus"
- ability name for camouflage changed from "ambush" to "aww_ability_camouflage"

### Fixed
- Issue reported by Hammerfriz: Squad Mode Custom was not working sometimes (special set to cumulative=false)


## [1.14.12.6] - 2019-03-31

### Changed
- "10. Berserk tweak : Fury" becomes : "10. Berserk tweak : Fury & Drains & Drains"
- "7. Epic heroes" : + leadership ability

## [1.14.12.5] - 2019-03-31

### Added
- Estimations of damages on each weapons (No Random Combats or Squad Mode except if Squad Mode : Swarm chosen)
    - on events : select,sighted,advance,recruit, attack end (for both units)
    - Note : "select" do not apply on enemy unit.
- translation strings in LUA script
- 100% french translated ! Cocorico !

### Changed
- some variables names in aww_duel.lua : notion of constants uppercases
- some french trads

### Fixed
- clear aww_bonus_rand variable after each use (optimisation) (09_amla_bonus)
- lua errors on hit_chance calculation with marksmanshit units (No Random Combats)

## [1.14.12.4] - 2019-03-30

### Fixed
- fix on "Promoted Leaders" : take in account Heroes (to exclude them) not having hero ellipse but overlays icon.

## [1.14.12.3] - 2019-03-29

### Changed
- "Promoted Leaders" : Warning about using it in Campaigns. units who can recruits disapears in The_Rise_Of_Wesnoth : 15_A_New_Land

### Fixed
- retrocompatiblity if a player update from mod in the middle of a campaign
- bug reported by Trossknecht : The_Rise_Of_Wesnoth heroes are not declared properly as Heroes, so I put them in exception list for feature "Promoted Leaders"

## [1.14.12.2] - 2019-03-24

### Changed
- French translations improvements
- Scenario 4p_Ruvaak_Mirage_Atoll : changed default starting gold, from 100 to 200.

### Fixed
- Better retrocompatibilty for features "passive XP" and "healing XP"

## [1.14.12.1] - 2019-03-24

### Added
- Translations support
- French translations

### Changed
- Minors changes on descriptions
- Minors changes on scenario 4p_Ruvaak_Mirage_Atoll.cfg, passing it to v1.3
- macro items.ma.cfg OBJ_TEMPEST_TRIDENT become AWW_OBJ_TEMPEST_TRIDENT with parameters for damages & strikes

## [1.14.12.0] - 2019-03-24

### Added
- Squad (swarm) alternative mode for (Health-based Hits number)
- macros files filters.ma.cfg, setters.ma.cfg
- Feature 12 : Berserk Fix - limit to 0-3 extra attacks
- Feature 13 : Ambushed fix - surprise Attacks (beta)
- Feature 14 : Level-Up Notification on unit
- floating text (and 2 macros for it) on some events
- .editorconfig
- a "Dev Mode" allowing to use dynamic lua file. Create a empty aww.dev file in parent add-ons/ directory to enable it.

### Changed
- By default, LUA files will be included in savegame package (MP / retrocompat optimisation)
- (Health) based Hits) become Squad Mode with a choice between No, Advanced, and Squad (swarm). Advanced is the first made and the one by default (Health-based Hits number)
- Complete rework of LUA script for no-random combats & Squad Mode
- Preview of the damage during/after attack with features 1-2 as Weapon Specials
- (Health) based Hits) Will not apply for berserk, neither "swarm" in 'Custom' algoritm.
- change aww_combats.lua to exlucude swarm mode instead of calculated strikes. (Health-based Hits)
- Promoted leader use the extra_recruit_list defined on main leader, (cf Orchish Incursion cs1) and refresh it on new scenario
- Some macros for detecting hero/loyal-icon in macro (Promoted Leader)
- more filter/filter_condition for lauching events than test inside the event (optimisations)
- Renamed most files in macros/ and mods/. Pure Macros files are suffixed .ma.cfg now.
- Renamed almost all event.id(s) and mods options names
- Renamed some option variables (the most recent)
- Renamed macros.*.cfg => macros/*.ma.cfg
- Ninja mode : now backstab only apply on blade/pierce melee weapons not having charge/berserk
- Ninja mode : now poison only apply on pierce-ranged weapons not having charge/berserk
- Some edit on scenario 4p_Ruvaak_Mirage_Atoll

## [1.14.11.3] - 2019-03-17

### Changed
- Refactoring/optimizations of all WML code
- 'Epic heroes' now also apply to Heroes (silver crowns) and all leaders (except Promoted ones). Option name is now "Epic heroes".
- Renamed leader-crown-promoted.png to aww-leader-crown-alt.png (Promoted Heroes) like in core name, with just a prefix.
- Events in preload and now in start, to synchronize MP and making the map loading less long.

## [1.14.11.2] - 2019-03-17

### Added
- macros/constants.cfg
- images/misc/leader-crown-promoted.png - a copy of core images/misc/leader-crown-alt.png. This image is never used anymore in Wesnoth, so I guess it can be be remove at any version, that's why the copy.

### Changed
- Unit texts when unstored re-enabled (for Gifted!, Ninja! and LEVEL UP! healing reduced), but will apply only if same side.
- Bronze crown instead of silver one for Promoted Leader. Will still display the "loyal" marker. (Promoted Leaders)
- adjustements of random bonuses in amla_extra_bonus (less mouvements chances, no -1 damage for +1 strike)
- improvement movement +1 every advancement  (instead of a initial 20%) for 'stealth' trait (Ninja Wars)
- renamed gifted_leaders.cfg to leader_gifted.cfg (to follow naming convention) Gifted Leaders)
- 'gifted' hh regeneration changed from 5 to 4, to fit more wesnoth standards. (Gifted Leaders)
- trait "chief" renamed to "recruiter" (Promoted Leaders)
- Disabled level-up symbols in unit names (Random Bonuses AMLA)
- Management of missing lua file (retro-compat old saves games using new addon version)

### Fixed
- Healers could get XP from wounded ennemy (Healing XP)
- Bad variable tested in pre advance (Promoted Leaders)

## [1.14.11.1] - 2019-03-17

### Added
- Feature #10 (option 7) : Gifted Starting Leaders
- Feature #11 (option 10) : Ninja Wars! (Stealthy units)
- "chief" trait  (Promoted Leaders)

### Changed
- 'Promoted Leaders' now only only apply AFTER level 3 AND first AMLA level-up
- 'Healing XP' works now a different way : you define the max xp/turn each healer can get (and wil get 1 by heal), instead of defininf the XP for each heal
- Flipped order of option 5 & 6
- More readable options titles and descriptions, prefixed with "Level-Up :" the accurate options


### Fixed
- aww_combats.lua : Option "Health-based Hit Numbers" will never apply for "swarm" special attack.

## [1.14.10.2] - 2019-03-17

### Changed
- Increased damage option minimum range, from 0 to -20%
- Disabled text floating around unit for level-up, I need to test if it can appears to others players in PvP even with fog.

### Fixed
- fixed bug when randomless damage is enabled without option 'Health-base Hits number'

## [1.14.10.1] - 2019-03-17

### Changed
- Bonuses for the new options

## [1.14.10.0] - 2019-03-16

### Added
- New Optional Feature : "Level-Up Bonuses After Max Level Advancement". in mods/amla_extra_bonus.cfg
- Reintroduced on maps/scenario 4p_Ruvaak_Mirage_Atoll after lot of changes. A perfect mod introduction.

### Changed
- Healers XP : max 1 XP by turn
- Renamed "Advance Wesnoth Wars mods" to "Advanced Wesnoth Wars" (added the "d") on _server.pbl : title for Extension Manager.
- Renamed "Advance Wesnoth Wars" to "Advanced Wesnoth Wars" (added the "d") on _main.cfg : modification.name
- Change max value for the 2 XP options from 2 to 3
- Changed default value for 'No Random Combats : Increased Damage' from 10 to 0, to maintain a better "average damage balance" with original combat system.
- re-enabled maps and scenarios, as it is a good introduction to the mod.

### Fixed
- bad debug function called in case of backup error (this should never happens anyway)

## [1.14.9.4] - 2019-03-14

### Changed
- "Random Combats : Terrains Defense Reduction" option renamed "Increased Damage". Variables names not changed.
- applied this bonus to all attacks, even for fixed hits % not depending on terrain (like Magic)
- aww_get_healthy_strikes now returns a rounded result on 0.5, not rounded up
- big refactoring, more human-readable code in lua/aww_combats.lua.
    - Separated functions aww_calculate_* and aww_get_* (who returns rounded result)
    - all functions put in wesnoth. domain for reusability in external scripts

## [1.14.9.3] - 2019-03-16

### Changed
- Relative Healing on Level-Up : statuses are cured, not maintained.

## [1.14.9.2] - 2019-03-16

### Changed
- More readable loading message.
- Default Terrain Defense Reduction: from 20 to 10.
- Color of unit text on healing Xp and Level-Up to RGB 0,150,225 (lighter blue)

### Added
- lua/aww_info.lua
- about.cfg

### Renamed
- mods/resume.cfg => mods/info.cfg


## [1.14.9.1] - 2019-03-10

### Changed
- disabled map & scenario loading (not the point of this mod)

### Fixed
- fix issue in resume.cfg
- fix cpp issue in 4p_Ruvaak_Mirage_Atoll.map

## [1.14.9.0] - 2019-03-10

### Added
- Optional feature "Terrains Bonus Reduction" for  'No Random Combats'
- moved [options] in a separated file ./mods/options.cfg

### Changed
- Options label/descriptions
- Sliders max values decreased to avoid it completely breaks game balance

## [1.14.8.2] - 2019-03-09

### Fixed
- Healing XP : no XP points gained for poisoned units (healer don't always cures, and can be exploited to gain lot of XP)
- aww_combats.lua : LUA error happening occasionally on array index, add index test before searching further in array

## [1.14.8.1] - 2019-03-09

### Changed
- function debug_message() renamed aww_debug_message() to avoid conflicts with addons
- In aww_combat.lu:aww_debug_message(), no do launch combat message for players not owning the attacking unit
- More readdable debug message
- Add description of this option 7 in various locations

### Added
- Optional Feature & Option : Debug messages (Attacks calculations). Disabled by default
- PvPvE scenario + map : 4p_Ruvaak_Mirage_Atoll
- Recap about options valus at map startup.
- Splitted _main.cfg in one file by features in mods/

### Changed
- Refactoring of LUA scripts, the 3 scripts for combats are merged in one, with conditions
- Files split in lot of different files
- Recap message in LUA about mod options values at game (re)loading.
- LUA : wesnoth.message("Advance Wesnoth Wars", x) proper message prefixes.
- Introducing an option to enable debug messages (damage calculations etc)

### Deleted
- previous lua scripts for combats, now they are all merged in one.

## [1.14.7.3] - 2019-03-09

### Changed
- "Differential Healing on Level-Up" option label become "Relative Healing on Level-Up""
- Changed calculation of "Differential Healing on Level-Up" to be based on reporting lack of HP (like in 1.14.1) OR  keeping current HP if new advancement have less max_hitpoints than the previous one.
- Options descriptions are in tooltips now, not the name, so window size is not enlarged.

## [1.14.7.2] - 2019-03-09

### Changed
- Changed calculation of "Differential Healing on Level-Up" to be based on a ratio previous hp / max_hp, to not kill units advancing with less HP.
- Options descriptions are in the proper tooltip now, not the name.

### Fixed
- No opportunity to do a division by 0 in aww_healthy_combats.lua and aww_randomless_healthy_combats.lua (in case of bad function parameters)

## [1.14.7.1] - 2019-03-09

### Changed
- "No Full Heal on Advancement" become "Differential Healing on Level-Up"
- Changed calculation of this feature and HP given, and description of it

## [1.14.7] - 2019-03-09

### Added
- Optional Feature : "No Full Heal on Advancement". Enabled by default.

### Changed
- Caption text for xp earned by healers, just indicate in blue XP earned for each

## [1.14.6] - 2019-03-09

### Changed
- Rounding Up (instead of rounding on .5) strikes number for Health-based Damages
- Promote Leader : prefix changed from "Sir" to "Chief"
- Promote Leader : found a way to filter heroes bases on their ellipse

### Deleted
- images/misc/ellipse-leader-nozoc*.png copied/pasted by mistake.

## [1.14.5] - 2019-03-09

### Changed
- "Promote Leader" don't force their upkeep free.

## [1.14.4] - 2019-03-09

### Changed
- "Health-based" option impact on number of strikes, not damage of theses strikes (except with weapon having a single big strike)
- "Health-based Combats" option description changed

## [1.14.3] - 2019-03-05

### Changed
- Promote Leader option exclude most Heroes (silver crown) from promotion, of base game & "To Lands Unknown" Campaigns.
- Description for Promote Leader option

## [1.14.2] - 2019-03-09

### Fixed
- Promoted Leader are re-prefixed "Sir" (bug introduced in version 1.14.1)

## [1.14.1] - 2019-03-09

### Changed
- Default value for "Learning from battlefield" changed from 1 to 0. Can still be change in options.
### Fixed
- No messages about damage calculation

## [1.14.0] - 2019-03-09

### Added
- script `lua/aww_healthy_combats.lua`
- Conditions to run health-based combats keeping the RNG random misses
- this CHANGELOG.md file
- debug message when combats modifications script is loaded, identifying which one is
- debug message explaining damage calculation on each attack

### Changed
- "Health Damage" option can be enabled independently of "Randomless Damage"
- Addon and options descriptions

## [1.0.1] - 2019-03-04

### Added
- script `lua/aww_randomless_healthy_combats`
- option "(If first option enabled) Enable Health-based Combats"

### Changed
- Dissociated "Health based Damages" and "Randomless Damages" option and script . But "Health Damage" will work only if first "Randomless Combats" is also enabled
- Addon and options descriptions

## [1.0.0] - 2019-03-03

### Changed
- Management of "Health based" Damages" added in "Randomless Damages" script for now. Only one option to enable both.
- Addon and options descriptions

### Fixed
- Various fixes

## [0.1.0] - 2019-03-02

### Added
- First release on Battle for Wesnoth Add-ons Manager.
