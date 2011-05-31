local core = LibStub("AceAddon-3.0"):GetAddon("AllTheLittleThings")
local mod = core:NewModule("Staging", "AceEvent-3.0")
local db

local defaults = {
}
local options = {
}

function mod:OnInitialize()
	self:RegisterOptions(options, defaults, function(d) db=d end)
end

