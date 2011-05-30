local core = LibStub("AceAddon-3.0"):GetAddon("AllTheLittleThings")
local mod = core:NewModule("Battlegrounds", "AceEvent-3.0")
local db = core.db.profile[mod:GetName()]

local defaults = {
}
local options = {
}

function mod:OnInitialize()
	core:RegisterOptions(options, defaults)
	core:RegisterSlashCommand("method", "slsh1", "slash2")
end

