Advanced Wesnoth Wars
=======================

About
-----------

It's a mod  for "Battle for Wesnoth" open-source videogame.

* Author :  [Ruvaak](http://thomas.bondois.info)
* Version : see [lua/aww_status.lua:9](lua/aww_status.lua)
* Changelog : see [CHANGELOG.md](CHANGELOG.md)
* License : [GNU-GPL](LICENSE.md)
* Code Repository [on GitHub](https://github.com/tbondois/Advance_Wesnoth_Wars)
* Dedicated forum  [thread](https://forums.wesnoth.org/viewtopic.php?f=15&t=49454)


DISCLAIMER FOR MODDERS
----------------------

You can reuse the code of this mod in your own creations, without asking my authorization, only if you share it with the same Licence, freely.
But I will really appreciate to know my mod is re-used by someone, and that you credit my work somewhere in your code.


Thanks
-----------
Some of theses features are inspired from existing code, saving me lot of times.
A big thanks particularly to Eagle 11, Ravana, Bob_The_Mighty, for their creation.
And a big thanks for all Wesnoth WML wiki contributors !


Description
-----------

Last Wesnoth version tested : 1.14.7

A collection of the most-requested options to make the mechanics more realistic and tactic, for people curious to experiment a new gameplay.
It changes the combat approach, making it easier for good tacticians, harder for the others.
All theses features works for mainline Campaigns & Scenarios, Single or Multiplayer, for all sides (including AI)
It also includes some options to give interest to level-up units after max advancement.

Features (each one can be combined, enabled or disabled individually. Some of them are disabled by default) :

- No Random Combats : attacks never miss, terrain bonus is instead used as damage reducer.

- Increased Damage : To compensate the high terrains defenses. Only applies for 'No Random Combats'.

- Squad Mode (HP-related strikes) : Units lacking lot of HP do proportionally less attack strikes (or less damage for single-strike attacks). Swarm is a worse ratio (-1 strike if you miss just 1 HP), but native, so considered by AI. In both cases, minimum strikes will be 1, and will not apply for berserk.

- Level-Up : Relative Healing : When an unit advance a level, instead of a full healing and being cured, it keep the missing HP, but statuses are cured. The special case when post-advancement Max-HP is smaller than pre-advanced is also handled.

- Level-Up : Random Bonuses After Max Level Advancement : Units already AMLA (purple XP bar) gain an extra random ability or increased stat each time they level-up again.

- Level-Up : Promoted Leaders After Max Level Advancement : Post-level 3 standard units reaching their first AMLA level-up will be able to recruit the same units as the original leader, recall, and be prefixed 'Chief' with a bronze crown icon (keeping the Loyal icon in case). Excluded for special Heroes.

- *Updated* Epic Heroes : The Leaders and Heroes (gold & silver crowns) gain an increase of 20% of their attributes and a small regeneration ability, making them harder to kill. Excluded for Promoted Leaders.

- Learning from battlefield (Passive XP) : Extra XP for all units each turn (except for the ones not recalled).

- Learning from healing (Max XP/turn for Healing) : Each turn, Healers will earn 1 XP for each adjacent wounded (but not-poisoned) ally, but you can limit the max/turn.

- *Updated* Berserk tweak - Fury + Drain : Replace 'berserk' by a new 'Fury' weapon special, way more interesting. Come also with 'Bloodthirsty', an offensive drain. A warcry related to the fury level with also be displayed.

- *Updated* Ambushed tweak - Surprise Attacks : An ambush will trigger a quick combat in which the ambushed unit can't counter-attack. Awesome combined with NINJA WARS!

- *NEW* Ninja Wars (Stealthy units) : Most of units will melee back-stabs, poison arrows, distract from ZoC, be faster and invisible/ambushers in villages, forests, deep water, or everywhere at night. For funny PvP with fog-of-war focused on ambushes / hide&seek.

- *NEW* Level-Up After Max Level Advancement : Increase Level Number (The unit level will continue growing with the AMLA level-ups)

- Also includes a PvPvE scenario : '4p - Ruvaak Mirage Atoll' optimized to be combined with all features.

Feel free to contribute !
If you experiment a bug, please report it to me on the forum, then try to disable the feature (see next section).


How To Enable/Disable Mod Options During a Scenario/Campaign
-------------------------------

The mod works when features options are changed during a game.
When you disable an option, *MOST* of the changes made on units by the features are removed. But it's experimental.

1) During a game, type :
```
:debug
``` 
(except if you launched the game with --debug argument)
2) Then open Lua Console(default : `, but you can see it in Menu > Settings > Shortcut > display lua console)
3) Copy/paste/execute one of the following lines related to mod features. 
    - Change the number between parenthesis : 0 means disabled, 1 enabled.
    - When specified, you can replace it by another number. (like in feature 02, 04, 05, 08...)
    - Most of the changes will be operationnal immediately, or next turn, or next scenario. But units already modified will keep theirs changes.
The commands to edit each feature and remove/re-enable changes on units :
```lua
aww_status.update_feature_01(0) -- NoRandomCombats
aww_status.update_feature_02(0) -- Squad Mode 1 = custom, 2 = swarm
aww_status.update_feature_03(0) -- L-Up AMLA Promoted Leader
aww_status.update_feature_04(0) -- passive xp, 0 to 6
aww_status.update_feature_05(0) -- healing xp 0 to 6
aww_status.update_feature_06(0) -- L-Up  relative healing
aww_status.update_feature_07(0) -- verbose
aww_status.update_feature_08(0) -- NoRandomCombats Damages Adjustment, to -20 to 40
aww_status.update_feature_09(0) -- AMLA Random Bonuses
aww_status.update_feature_10(0) -- Epic Leaders
aww_status.update_feature_11(0) -- Ninja Wars
aww_status.update_feature_12(0) -- Berserk tweak
aww_status.update_feature_13(0) -- Ambush tweak
aww_status.update_feature_14(0) -- L-Up Notif
aww_status.update_feature_15(0) -- L-Up AMLA number
```
If you want to display all currently enabled features (and the associated number), copy/paste/execute this line the lua console :
```lua
aww_status.message_info_all()
```


How To Migrate a Savegame from a previous version of the mod
-------------------------------

It will do it automatically on next scenario. If you want to try to migrate the current scenario, copy/paste in lua console the following line :
```lua
wesnoth.fire_event('aww_event_reload_lua')
```
If you see some bugs on a feature,  (see previous section) disable it on re-enable it (replace XX by feature number):
```lua
aww_status.update_feature_XX(0)
aww_status.update_feature_XX(1)
```
See previous section to know how to open console or when the changes will applies.



Developer Mode
--------------

This is useful only for development/test purpose on the addon lua scripts. 

- Do not do that play a big campaign, as it can create issue with your savegame when you update the addon.

- Effect : the LUA scripts will be loaded externally (means you can edit them, and the effect will apply when you reload a savegame, no need to re-create a game or a scenario like for WML scripts).

- To enable it, just place a empty file named :
```
aww.dev
```
in the addon base directory (where the _main.cfg is).

- To disable it, just remove the file, and restart the game.

