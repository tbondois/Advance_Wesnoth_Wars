--<<
-- Author: Ruvaak
-- Original Creation
-- used in mods/00_common.cfg
-- include aww_status.lua before.
if aww_status ~= nil then
	aww_status.run()
else
	wesnoth.message("AWW error", "aww_status should be already loaded !")
end
-->>
