Advanced Wesnoth Wars
=======================

About
-----------------------

Mod  for "Battle for Wesnoth" open-source videogame

Author : Ruvaak

Version : See [lua/aww_status.lua:7](lua/aww_status.lua)

[Code Repository](https://github.com/tbondois/Advance_Wesnoth_Wars)

[Forum thread](https://forums.wesnoth.org/viewtopic.php?f=15&t=49454)

NOTE FOR MODDERS
-----------------------

You can reuse the code of this mod in your own creations, only if you share it with the same Licence, freely, and crediting this mod.


Description
-----------------------

Last Wesnoth version tested : 1.14.6

A collection of the most-requested options to make the mechanics more realistic and tactic, for people curious to experiment a new gameplay.
It changes the combat approach, making it easier for good tacticians, harder for the others.
All theses features works for vanilla Campaigns & Scenarios, Single or Multiplayer, for all sides (including AI)
It also includes some of options give interest to level-up units after level 3.

Features (each one can be combined, enabled or disabled individually. Some of them are disabled by default) :

1. No Random Combats : attacks never miss, terrain bonus is instead used as damage reducer.

2. Increased Damage : To compensate the high terrains defenses. Only applies for 'No Random Combats'.

3. Squad Mode (HP-related strikes) : Units lacking lot of HP do proportionally less attack strikes (or less damage for single-strike attacks). Swarm is a worse ratio (-1 strike if you miss just 1 HP), but native, so considered by AI. In both cases, minimum strikes will be 1, and will not apply for berserk.

4. Level-Up : Relative Healing : When an unit advance a level, instead of a full healing and being cured, it keep the missing HP, but statuses are cured. The special case when post-advancement Max-HP is smaller than pre-advanced is also handled.

5. *NEW* Level-Up : Random Bonuses After Max Level Advancement : Units already AMLA (purple XP bar) gain an extra random ability or increased stat each time they level-up again.

6. Level-Up : Promoted Leaders After Max Level Advancement : Post-level 3 standard units reaching their first AMLA level-up will be able to recruit the same units as the original leader, recall, and be prefixed 'Chief' with a bronze crown icon (keeping the Loyal icon in case). Excluded for special Heroes.

7. *NEW* Gifted Heroes : The Leaders and Heroes (gold & silver crowns) gain an increase of 20% of their attributes and a small regeneration ability, making them harder to kill. Excluded for Promoted Leaders.

8. Learning from battlefield (Passive XP) : Extra XP for all units each turn (except for the ones not recalled).

9. Learning from healing (Max XP/turn for Healing) : Each turn, Healers will earn 1 XP for each adjacent wounded (but not-poisoned) ally, but you can limit the max/turn.

10. *NEW*  10. Berserk tweak - Fury + Drain : When a berserk is attacked, the ability will not be triggered. But when a, unit attacks with a Berserk weapon, a calculated limit (using HP-ratio and a random factor) of 0-3 extra rounds will apply, he will get back half the damages he did, and after each fight a permanent +1 damage will apply with that berserk weapon (until +15 max).  A warcry related to the fury level with also be displayed.

11. *Beta* Ambushed tweak - Surprise Attacks : An ambush will trigger a quick combat in which the ambushed unit can't counter-attack. Awesome combined with NINJA WARS!

12. *NEW* Ninja Wars (Stealthy units) : Most of units will melee back-stabs, poison arrows, distract from ZoC, be faster and invisible/ambushers in villages, forests, deep water, or everywhere at night. For funny PvP with fog-of-war focused on ambushes / hide&seek.

- Also includes a PvPvE scenario : '4p - Ruvaak Mirage Atoll' optimized to be used with the mod.

Feel free to contribute !
