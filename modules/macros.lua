local core = LibStub("AceAddon-3.0"):GetAddon("AllTheLittleThings")
local mod = core:NewModule("Macros", "AceTimer-3.0", "AceEvent-3.0")
local db

local defaults = {
}
local options = {
}

function mod:OnInitialize()
	-- self:RegisterOptions(options, defaults, function(d) db=d end)
	self:RegisterSlashCommand("DisbandRaid", "dr", "disbandraid")
	self:RegisterSlashCommand("InviteGuild", "ig", "inviteguild")
	self:RegisterSlashCommand("PromoteAll", "pa", "promoteall")
	self:RegisterSlashCommand("DemoteAll", "da", "demoteall")
	self:RegisterSlashCommand("PrintLoot", "pl", "printloot")
	self:RegisterSlashCommand("ClearMarks", "cm", "clearmarks")
	self:RegisterSlashCommand("MasterLoot", "ml", "masterloot")
	self:RegisterSlashCommand("RandomLoot", "rl", "randomloot")
	self:RegisterSlashCommand("FlaskCheck", "fc", "flaskcheck")
	self:RegisterSlashCommand("Countdown", "cd", "countdown")
	self:RegisterSlashCommand("RosterCheck", "rc", "rostercheck")
	self:RegisterSlashCommand("AuctionHouseBuyout", "ahbo")
	self:RegisterEvent("AUCTION_ITEM_LIST_UPDATE")
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

function mod:FlaskCheck()
	local now = GetTime()
	for i=1,GetNumRaidMembers() do
		for j=1,32 do 
			local player = UnitName("raid"..i)
			name, _, _, _, _, _, expires = UnitAura("raid"..i, j)
			if name and name:find("Flask ") then 
				local time = expires - now
				if time<990 and time>0 then 
					SendChatMessage(format("%s %d:%02d", player, floor(time/60), time%60), "raid")
					-- SendChatMessage(format("Flask ending in %d:%02d", UnitName(r), floor(time/60), time%60), "whipser", nil, player)
				end
			end
		end
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

-- mass buyout
local bought = {}
function mod:AuctionHouseBuyout()
	local selected = GetSelectedAuctionItem("list")
	if selected>0 then 
		local name,_,count,_,_,_,_,_,price = GetAuctionItemInfo("list", selected)
		for j=1,50 do 
			local t_name,_,t_count,_,_,_,_,_,t_price = GetAuctionItemInfo("list", j)
			-- must be same item name and equal or less price per unit
			if (t_name == name) and (t_price>0) and (t_price/t_count <= price/count) then 
				if not bought[j] and selected ~= j then
					--self:Print("Buying",j,"at",t_price)
					PlaceAuctionBid("list", j, t_price)
					bought[j] = true
					return
				end
			end 
		end 

		-- no purchase made, buy selected
		PlaceAuctionBid("list", selected, price)
	end
end

function mod:AUCTION_ITEM_LIST_UPDATE()
	wipe(bought)
end

