local core = LibStub("AceAddon-3.0"):GetAddon("AllTheLittleThings")
local mod = core:NewModule("Raid", "AceEvent-3.0", "AceTimer-3.0")
local db

local defaults = {
	autoML = true,
}
local options = {
	autoML = {
		name = "Auto ML",
		desc = "Sets loot type to ML when a raid has more than 20 players in it.",
		type = "toggle",
	},
}

function mod:OnInitialize()
	self:RegisterOptions(options, defaults, function(d) db=d end)
end

function mod:OnEnable()
	self:RegisterEvent("RAID_ROSTER_UPDATE")
end

local zoneBlacklist = {
	["Wintergrasp"] = true,
	["Tol Barad"] = true,
	["Alterac Valley"] = true,
	["Isle of Conquest"] = true,
}
function mod:RAID_ROSTER_UPDATE()
	if db.autoML and IsRaidLeader() and GetNumRaidMembers()>20 and GetLootMethod() ~= "master" and not zoneBlacklist[GetRealZoneText()] then
		SetLootMethod("master", "player")
		self:ScheduleTimer(function() SetLootThreshold(3) end, 2)
	end
end
