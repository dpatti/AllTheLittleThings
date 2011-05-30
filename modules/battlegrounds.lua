local core = LibStub("AceAddon-4.0"):GetAddon("AllTheLittleThings")
local mod = core:NewModule("Battlegrounds", "AceEvent-3.0")

local defaults = {
}
local options = {
}

local gilneasTimes = { -- time in seconds to get a point
	[0] = 0,
	[1] = 8,
	[2] = 3,
	[3] = 1/3,
}
core.wgStatus = 0
core.flagStatus = 0
core.eotsHook = false

function mod:OnInitialize()
	core:RegisterOptions(options, defaults)
end

