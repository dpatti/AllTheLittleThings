local core = LibStub("AceAddon-3.0"):GetAddon("AllTheLittleThings")
local mod = core:NewModule("Battlegrounds", "AceEvent-3.0")

local defaults = {
}
local options = {
}

function mod:OnInitialize()
	core:RegisterOptions(options, defaults)
end

