local core = LibStub("AceAddon-3.0"):GetAddon("AllTheLittleThings")
local mod = core:NewModule("Battlegrounds", "AceEvent-3.0", "AceHook-3.0")
local db

local defaults = {
	autoWG = false,
	eotsFlag = true,
}
local options = {
	autoWG = {
		name = "Auto Wintergrasp Join",
		desc = "Automatically joins Wintergrasp if in Dalaran or Ironforge. Also boots that faggot Unhidenenemy.",
		type = "toggle",
	},
	eotsFlag = {
		name = "Eye of the Storm Flag",
		desc = "Adds in points for a held flag based on bases owned.",
		type = "toggle",
	},
}

local gilneasTimes = { -- time in seconds to get a point
	[0] = 0,
	[1] = 8,
	[2] = 3,
	[3] = 1/3,
}
local wgStatus = 0
local flagStatus = 0

function mod:OnInitialize()
	self:RegisterOptions(options, defaults, function(d) db=d print(d) end)
	self:RegisterSlashCommand("ArathiPrint", "ab", "arathibasin")
end

function mod:OnEnable()
	self:RawHook("WorldStateAlwaysUpFrame_Update", true)
	self:RegisterEvent("BATTLEFIELD_MGR_ENTRY_INVITE")
	self:RegisterEvent("CHAT_MSG_BG_SYSTEM_ALLIANCE", "BattlegroundMessage")
	self:RegisterEvent("CHAT_MSG_BG_SYSTEM_HORDE", "BattlegroundMessage")
end

-- Arathi Basin ----------------------------------------------------------------
function mod:ArathiPrint(msg)
	if GetRealZoneText() == "Arathi Basin" then
		local _, _, aB, aP = string.find(select(4, GetWorldStateUIInfo(1)), "(%d).-(%d+)/")
		local _, _, hB, hP = string.find(select(4, GetWorldStateUIInfo(2)), "(%d).-(%d+)/")
		local ttw = math.min((1600-aP)*(5-aB)*.3, (1600-hP)*(5-hB)*.3)
		local need = math.ceil(5/((1600-hP)/(1600-aP)+1))
		-- local timeDiff = (1600-aP)*(5-need)*.3 - (1600-hP)*need*.3)
		-- local timeDiff = (hP-aP)/(2*need-6+(hP-aP)/math.abs(hP-aP))/3
		local timeDiff
		if hP > aP then
			timeDiff = (hP - aP) / (10/3 * (1/(5-need) - 1/need))
		elseif aP > hP then
			timeDiff = (hP - aP) / (10/3 * (1/(need-1) - 1/(6-need)))
		else
			timeDiff = 0
		end
		self:Print(string.format("Game end: %d:%02d, Bases needed: %d", floor(ttw/60), ttw%60, need)) --, floor(timeDiff/60), timeDiff%60, timeDiff))
	elseif GetRealZoneText() == "The Battle for Gilneas" then
		-- gilneasTimes - table with time per point
		local _, _, aB, aP = string.find(select(4, GetWorldStateUIInfo(1)), "(%d).-(%d+)/")
		local _, _, hB, hP = string.find(select(4, GetWorldStateUIInfo(2)), "(%d).-(%d+)/")
		local ttw = math.min((2000-aP)/10*gilneasTimes[aB], (2000-hP)/10*gilneasTimes[hB])
		local need = 0
		if (2000-aP)*8/3+hP > 2000 then
			need = 2
		else
			need = 1
		end
		-- local timeDiff = (2000-aP)*(5-need)*.3 - (2000-hP)*need*.3)
		-- local timeDiff = (hP-aP)/(2*need-6+(hP-aP)/math.abs(hP-aP))/3
		-- timeDiff means: "if we both keep going at the current rate, the point when we will need one less/more base is in x:xx"
		local timeDiff
		if hP > aP then
			timeDiff = (hP - aP) / (10/3 * (1/(5-need) - 1/need))
		elseif aP > hP then
			timeDiff = (hP - aP) / (10/3 * (1/(need-1) - 1/(6-need)))
		else
			timeDiff = 0
		end
		self:Print(string.format("Game end: %d:%02d, Bases needed: %d", floor(ttw/60), ttw%60, need))
	else
		self:Print("You must be in Arathi Basin or The Battle for Gilneas to use this command.")
	end
end

-- Wintergrasp -----------------------------------------------------------------
function mod:BATTLEFIELD_MGR_ENTRY_INVITE()
	if db.autoWG and (GetRealZoneText() == "Dalaran" or GetRealZoneText() == "Ironforge") then
		BattlefieldMgrEntryInviteResponse(1, 1)
		wgStatus = 1
		-- self:SetScript("OnKeyDown", self.OnKeyDown)
	end
end

-- Eye of the Storm ------------------------------------------------------------
function mod:BattlegroundMessage(event, msg)
	local faction = ((event=="CHAT_MSG_BG_SYSTEM_ALLIANCE" and 1) or 2)
	if string.find(msg, "captured.+flag") or string.find(msg, "dropped.+flag") then
		flagStatus = 0
	elseif string.find(msg, "taken.+flag") then
		flagStatus = faction
	end
end

function mod:WorldStateAlwaysUpFrame_Update(...)
	self.hooks["WorldStateAlwaysUpFrame_Update"](...)
	if db.eotsFlag and GetRealZoneText() == "Eye of the Storm" then
		local points = {[0]=0, 75, 85, 100, 500}
		if flagStatus > 0 then
			local i = flagStatus + 1
			if select(3, GetWorldStateUIInfo(i)) then -- extra if since I got a lua error while leaving a BG once
				local _, _, full, bases, score = string.find(select(3, GetWorldStateUIInfo(i)), "(Bases: (%d).-(%d+)/.+)")
				if not full then return end
				-- self:Print(string.find(select(3, GetWorldStateUIInfo(i)), "(Bases: (%d).-(%d+)/.+)"))
				-- self:Print(GetWorldStateUIInfo(i))
				local nScore = "|cff00ff00" .. (tonumber(score)+points[tonumber(bases)]) .. "|r"
				local frame = _G["AlwaysUpFrame"..flagStatus.."Text"]
				if frame then
					frame:SetText(string.gsub(full, score.."/", nScore.."/"))
				end
			end
		end
	end
end

-- function mod:OnKeyDown()
-- 	if wgStatus > 0 and GetRealZoneText() ~= "Wintergrasp" then
-- 		wgStatus = 0
-- 		BattlefieldMgrEntryInviteResponse(1, 1)
-- 	end
-- end
