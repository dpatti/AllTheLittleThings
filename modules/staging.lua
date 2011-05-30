local core = LibStub("AceAddon-3.0"):GetAddon("AllTheLittleThings")
local mod = core:NewModule("Staging", "AceEvent-3.0")
local db

local defaults = {
}
local options = {
}

function mod:OnInitialize()
	db = core.db.profile[self:GetName()] or {}
	self:RegisterOptions(options, defaults)
end

