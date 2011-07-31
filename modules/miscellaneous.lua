local core = LibStub("AceAddon-3.0"):GetAddon("AllTheLittleThings")
local mod = core:NewModule("Miscellaneous", "AceEvent-3.0", "AceHook-3.0", "AceTimer-3.0")
local db

local defaults = {
	rollTally = true,
	nixAFK = true,
	achieveFilter = true,
	markMsgFilter = true,
	officerPhone = true,
}
local options = {
	rollTally = {
		name = "Roll Tally",
		desc = "Tallies rolls for 8s after a raid warning with 'roll' in the message. Can also activate with /atlt rt.",
		type = "toggle",
	},
	nixAFK = {
		name = "Remove AFK Responses",
		desc = "Removes AFK responses when whispering AFK players.",
		type = "toggle",
	},
	achieveFilter = {
		name = "Achievement Filter",
		desc = "Sets achievement filter to Incomplete automatically.",
		type = "toggle",
	},
	markMsgFilter = {
		name = "Mark Message Filter",
		desc = "Filters mark messages caused by the player.",
		type = 'toggle',
	},
	officerPhone = {
		name = "Officer Phone Records",
		desc = "Allows !phone <player>",
		type = 'toggle',
	},
	clickToPaste = {
		name = "Quick Paste to Officer Chat",
		desc = "Ctrl+Click on a chat line name to paste to Officer Chat",
		type = 'toggle',
	},
}

function mod:OnInitialize()
	self:RegisterOptions(options, defaults, function(d) db=d end)
	self:RegisterSlashCommand("RollTally", "rt", "rolltally")
	self:RegisterSlashCommand("FindPhones", "phone")
	self:RegisterSlashCommand("ActiveTally", "at", "activetally")

	-- allow max camera zoom
	ConsoleExec("cameradistancemaxfactor 5")
end


function mod:OnEnable()
	-- allow split with tradeskill
	SetModifiedClick("TRADESEARCHADD", nil)

	-- roll tally
	self:RegisterEvent("CHAT_MSG_RAID_WARNING")
	self:RegisterEvent("CHAT_MSG_SYSTEM")

	-- nix afk
	ChatFrame_AddMessageEventFilter("CHAT_MSG_AFK", function(...) return self:NixAFK(...) end)

	-- achieve filter
	self:RawHook("AchievementFrame_LoadUI", true)

	-- target icons
	self:SecureHook("TargetUnit")

	-- filter self targets
	ChatFrame_AddMessageEventFilter("CHAT_MSG_TARGETICONS", function(_,_,msg) if (msg:find("%["..UnitName("player").."%]")) then return true end end)

	-- officer phone
	self:RegisterEvent("CHAT_MSG_OFFICER");

	-- louder LFD sound
	self:RegisterEvent("LFG_PROPOSAL_SHOW");

	-- Fix guild crafters
	self:RegisterEvent("ADDON_LOADED", function(_, name)
		if name == "Blizzard_TradeSkillUI" then
			for i=1, TRADE_SKILL_GUILD_CRAFTERS_DISPLAYED do
				_G["TradeSkillGuildCrafter"..i.."Text"].SetTextColor = function() end 
			end
		end
	end)
end

-- Slash Commands --------------------------------------------------------------
function mod:RollTally()
	self:CHAT_MSG_RAID_WARNING(nil, "roll")
end

function mod:FindPhones()
	local found = false;
	for i=1,GetNumGuildMembers() do
		
		local player, num = self:CheckPhone(i);
		if (player and not num) then
			if (not found) then
				self:Print("Players without phone numbers:");
				found = true;
			end
			self:Print(player);
		end
	end
	if (not found) then
		self:Print("All players have a phone number.");
	end
end

function mod:ActiveTally(mode)
	local showTotal = mode=="t" or mode=="total"

	local function printInfo(msg)
		-- self:Print(msg)
		SendChatMessage(msg, "guild")
	end
	
	local mains = {}
	local alts = {} -- really a table of the mains as the key, alt totals as the value, but we'll merge later once we can confirm
	local capped = {} -- table of mains who hit cap
	for i=1,GetNumGuildMembers() do
		local name, rank, _, _, _, _, note = GetGuildRosterInfo(i)
		local xp, total = GetGuildRosterContribution(i)
		local tbl = mains
		
		if showTotal then 
			xp = total
		end
		
		if rank:find("Alt") then
			name, tbl = note, alts
		end
		
		if rank ~= "Non-raider" or name == "Ariik" then
			if not tbl[name] then
				tbl[name] = 0
			end
			tbl[name] = tbl[name] + xp
			
			if xp == 1575002 then
				-- don't think there is a weekly cap
				-- capped[name] = true
			end
		end
	end
	
	-- total and merge alts
	local total = 0
	for k,v in pairs(mains) do
		mains[k] = mains[k] + (alts[k] or 0)
		total = total + mains[k]
	end
	
	-- print using selection sort
	printInfo("Top contributors for the week; alts included:")
	while next(mains) ~= nil do
		local max, maxVal = "-", -1
		for k,v in pairs(mains) do
			if v > maxVal then
				max, maxVal = k, v
			end
		end
		printInfo(format("%s%s - %d (%.1f%%)", (capped[max] and "*" or ""), max, maxVal, maxVal/total*100))
		mains[max] = nil
	end
end

-- Roll Tally ------------------------------------------------------------------
local rollTally = {}
local rollTimer = false

function mod:CHAT_MSG_RAID_WARNING(_, message)
	if db.rollTally and string.find(message:lower(), "roll") then
		if rollTimer then
			-- Stop current roll
			self:CancelTimer(rollTimer)
			self:RollFinish()
		end
		rollTally = {}
		rollTimer = self:ScheduleTimer("RollFinish", 10)
	end
end

function mod:CHAT_MSG_SYSTEM(_, message, source)
	if db.rollTally and rollTimer then
		local name, roll, min, max = string.match(message, "(%S+) rolls (%d+) %((%d+)%-(%d+)%)")
		if name and roll and min and max then
			if min ~= "1" or max ~= "100" then
				self:Print(string.format("%s is rolling out of bounds (%d-%d).", name, min, max))
				return
			end
			if not rollTally then
				rollTally = {}
			end
			if rollTally[name] then
				self:Print(string.format("%s is rolling again (first: %d, this: %d).", name, rollTally[name], roll))
				return
			end
			rollTally[name] = roll
		end
	end
end

function mod:RollFinish()
	local winner
	local ties = {}
	for i,v in pairs(rollTally) do
		if (not winner) or (tonumber(rollTally[winner])<tonumber(v)) then
			winner = i
			ties = {}
		elseif rollTally[winner] == v then
			table.insert(ties, i)
		end
	end
	if not winner then
		self:Print("No rolls detected.")
	else
		if next(ties) then
			local roll = rollTally[winner]
			for i,v in ipairs(ties) do
				winner = v .. ", " .. winner
			end
			self:Print(string.format("%d-way tie between %s (rolled %d). Rerolling...", #ties+1, winner, roll))
			rollTally = {}
			self:ScheduleTimer("RollFinish", 4)
		else
			self:Print(string.format("%s won the roll with a %d.", winner, rollTally[winner]))
		end
	end
	rollTimer = false
end


function mod:NixAFK(_, _, ...)
	return (not not db.nixAFK), ...
end


-- Officer Phone ---------------------------------------------------------------
function mod:CHAT_MSG_OFFICER(_, msg)
	local _,_,numA,numB,numC  = msg:find("!phone %(?(%d+)%)?.(%d+).(%d+)");
	local _,_,name = msg:find("!phone (%w+)");
	
	if (not (numA and numB and numC) and not name) then
		return;
	end
	
	local setting = GetGuildRosterShowOffline();
	SetGuildRosterShowOffline(1);
	for i=1,GetNumGuildMembers() do
		local p, n = self:CheckPhone(i);
		if ((name and p and p:lower():find(name:lower())) or 
			(numA and n and format("%s-%s-%s", numA, numB, numC)==n)) then
			if (n) then
				SendChatMessage(format("%s: %s", p, n), "officer");
			else
				SendChatMessage(format("No %s for %s.", (numA and "name") or "number", p), "officer");
			end
		end
	end
	SetGuildRosterShowOffline(setting);
end

function mod:CheckPhone(index)
	local name, rank, _, _, _, _, _, onote = GetGuildRosterInfo(index);
	local a, b, c = onote:match("%(?(%d%d%d)%)?.(%d%d%d).(%d%d%d%d)");
	if (not rank:find("Alt") and not rank:find("Non")) then
		if (a) then
			return name, format("%s-%s-%s", a, b, c);
		end
		return name, nil;
	end
	return nil, nil;
end

-- Mark Star on Target ---------------------------------------------------------
function mod:TargetUnit(name)
	if name and GetNumPartyMembers() == 0 and GetNumRaidMembers() == 0 then
		self:RegisterEvent("UNIT_TARGET", function(_, unit)
			if unit == "player" then
				if UnitName("target") and UnitName("target"):lower():find(name:lower()) then
					SetRaidTarget("target", 1)
				end
				self:UnregisterEvent("UNIT_TARGET")
			end
		end)
	end
end

-- Achieve Load ----------------------------------------------------------------
function mod:AchievementFrame_LoadUI(...)
	local args = {self.hooks["AchievementFrame_LoadUI"](...)}
	AchievementFrame_SetFilter(3)
	self:Unhook("AchievementFrame_LoadUI")
	return unpack(args);
end


-- Fix to typing /w chi<cr> with auto complete ---------------------------------
-- change our OnEscapePressed to Reset
function ChatEdit_OnEscapePressed(editBox)
	ChatEdit_ResetChatTypeToSticky(editBox);
	if ( not editBox.isGM and (GetCVar("chatStyle") ~= "im" or editBox == MacroEditBox) ) then
		editBox:SetText("");
		editBox:Hide();
	else
		ChatEdit_DeactivateChat(editBox);
	end
end
-- change the editbox's OnEscape to a real OnEscape
for i=1,NUM_CHAT_WINDOWS do
	local f = _G["ChatFrame"..i.."EditBox"]
	if f then
		f:SetScript("OnEscapePressed", function(editBox)
			if ( not AutoCompleteEditBox_OnEscapePressed(editBox) ) then
				ChatEdit_OnEscapePressed(editBox)
			end
		end)
	end
end


-- LFD Louder Noise ------------------------------------------------------------
function mod:LFG_PROPOSAL_SHOW()
	PlaySound("ReadyCheck", "Master");
end


-- Officer Chat Link -----------------------------------------------------------
local SetItemRefHook = SetItemRef
function SetItemRef(id, text, button, chatFrame, ...)
	if IsControlKeyDown() then
		local name = id:match("player:(.-):")
		local prefix, message
		for i=1,select("#", chatFrame:GetRegions()) do
			local r = select(i, chatFrame:GetRegions())
			if r:GetObjectType() == "FontString" and r:GetText():find(id) then
				-- found the line, extract the message
				prefix, message = r:GetText():match("(.-%S:%s)(.+)")

				-- nasty hack to change player name in during whisper
				if id:find(":WHISPER:") and prefix:lower():find("%Wto%W") then
					name = UnitName("player")
				end
				break
			end
		end

		if name and message then
			SendChatMessage(("%s: %s"):format(name, message), "officer")
			return
		end
	end
	SetItemRefHook(id, text, button, chatFrame, ...)
end

