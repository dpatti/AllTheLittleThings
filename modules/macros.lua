local core = LibStub("AceAddon-3.0"):GetAddon("AllTheLittleThings")
local mod = core:NewModule("Macros", "AceTimer-3.0", "AceConsole-3.0")
local db = core.db.profile[mod:GetName()]

local defaults = {
}
local options = {
}

function mod:OnInitialize()
	core:RegisterOptions(options, defaults)
	core:RegisterSlashCommand("DisbandRaid", "dr", "disbandraid")
	core:RegisterSlashCommand("InviteGuild", "ig", "inviteguild")
	core:RegisterSlashCommand("PromoteAll", "pa", "promoteall")
	core:RegisterSlashCommand("DemoteAll", "da", "demoteall")
	core:RegisterSlashCommand("PrintLoot", "pl", "printloot")
	core:RegisterSlashCommand("ClearMarks", "cm", "clearmarks")
	core:RegisterSlashCommand("MasterLoot", "ml", "masterloot")
	core:RegisterSlashCommand("RandomLoot", "rl", "randomloot")
	core:RegisterSlashCommand("Countdown", "cd", "countdown")
	core:RegisterSlashCommand("RosterCheck", "rc", "rostercheck")
end

function mod:DisbandRaid()
	for i=1, GetNumRaidMembers() do
		if not UnitIsUnit("raid"..i,"player") then 
			UninviteUnit("raid"..i) 
		end
	end
end


function mod:InviteGuild()
	for i=1, select(2, GetNumGuildMembers()) do 
		if not UnitInRaid(GetGuildRosterInfo(i)) then
			InviteUnit(GetGuildRosterInfo(i)) 
		end
	end
end

function mod:PromoteAll()
	for i=0, GetNumRaidMembers() do
		PromoteToAssistant("raid"..i)
	end
end

function mod:DemoteAll()
	for i=0, GetNumRaidMembers() do
		DemoteAssistant("raid"..i)
	end
end

function mod:PrintLoot()
	self:RaidDump("Send tells for loot:", "raid_warning")
	for i=1,GetNumLootItems() do 
		SendChatMessage(GetLootSlotLink(i) .. " (" .. ({"A", "B", "C", "D", "E", "F", "G", "H"})[i] .. ")", "raid_warning")
	end
end

function mod:ClearMarks()
	for i=8,0,-1 do
		SetRaidTarget("player", i)
	end
	self:ScheduleTimer(function() SetRaidTarget("player", 0) end, 0.5)
end

local mlOrder = {"Chira", "Brinkley", "Yukiri"}
function mod:MasterLoot()
	for k,v in ipairs(mlOrder) do
		for i=1, 40 do
			if GetMasterLootCandidate(i) == v then
				for j=1, GetNumLootItems() do 
					GiveMasterLoot(j, i)
				end 
				return
			end 
		end
	end
end

function mod:RandomLoot()
	local members = {}
	for i=1,40 do
		if GetMasterLootCandidate(i) then
			table.insert(members, i);
		end
	end

	for j=1, GetNumLootItems() do 
		GiveMasterLoot(j, members[random(#members)])
	end 
end

local countDown = {"Pulling in 5", "4", "3", "2", "1", "Go"} -- used in /atlt cd
function mod:Countdown()
	for i=5,0,-1 do
		self:ScheduleTimer(function()
			local msg = countDown[6-i];
			--[[if (msg == "Go") then
			local transitive = TRANSITIVES[math.random(#TRANSITIVES)];
			msg = format("%s babies", transitive)
			end]]
			SendChatMessage(msg, "RAID_WARNING");
		end, 5-i);
	end
end

-- TODO: make a global alt_ranks and main_ranks thing in case we change it
local altRanks = {
	[2] = true,
	[4] = true,
}
function mod:RosterCheck()
	local mains = {}
	local alts = {}
	for i=1,GetNumGuildMembers() do
		local name, _, rank, _, _, _, onote = GetGuildRosterInfo(i)
		if altRanks[rank] then
			alts[name] = onote
		else
			mains[name] = true
		end
	end
	local toPrint = {}
	for name,main in pairs(alts) do
		if mains[main] then
			alts[name] = nil
		else
			table.insert(toPrint, name)
			table.sort(toPrint, function(a,b) return alts[a]<alts[b] end)				
		end
	end
	for _,name in ipairs(toPrint) do
		self:Print("Mismatched Alt:", name, "belongs to", alts[name], format("|cffffa0a0|Hgremove:%s|h[Guild Remove]|h", name))
	end
end

-- mismatched alts itemlink
local SetItemRefHook = SetItemRef
function SetItemRef(id, ...)
	local target = id:match("gremove:(.+)")
	if target then
		GuildUninvite(target)
	else
		return SetItemRefHook(id, ...)
	end
end
