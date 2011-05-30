AllTheLittleThings = LibStub("AceAddon-3.0"):NewAddon("ATLT", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0", "AceHook-3.0")
local core = AllTheLittleThings

-- local DedicatedInsanity = {46017,47069,47079,47082,47093,47072,47073,47090,47071,47094,47081,47092,47070,47080,47104,47138,47114,47121,47142,47108,47106,47107,47140,47126,47139,47116,47148,47193,47233,47150,47234,47195,47184,47204,47151,47186,47235,47183,47194,47187,47225,47203,47054,47182,46958,46976,46985,46996,46994,46979,46963,46962,46997,47052,47057,46999,46961,46960,47083,46990,47152,47056,47000,46988,46974,47055,46992,47051,46972,47141,47042,47043,47041,47115,46959,47053,49500,49494,49465,49493,49490,49496,49497,49499,49495,49501,49498,49466,49467,49474,49475,49476,49478,49479,49480,49468,49469,49470,49471,49472,49473,49477,49481,49482,49483,49484,49491,49489,49492,49464,49488,47078,47085,47086,47098,47076,47074,47087,47099,47077,47096,47084,47097,47095,47075,47088,47001,47156,46995,46980,46969,47113,47521,47206,47526,47519,47239,46964,47130,47524,47525,47517,47506,47515,46968,47147,46986,47003,47154,47240,47061,47067,47132,47002,47207,46967,47111,46965,47209,47109,47191,46991,47153,47068,47004,46989,46975,47190,47112,47145,47066,47155,46993,47129,47205,47236,47062,47189,46973,47143,47208,46971,46977,47063,47192,47238,47545,47547,47549,47552,47553,47237,47060,47110,47133,47144,47059,47131,47188,47224,47157,46966,47146,47064,
-- 42210,42229,42234,42244,42250,42257,42262,42267,42272,42277,42282,42287,42292,42319,42324,42329,42334,42348,42354,42366,42386,42392,42483,42487,42492,42498,42504,42515,42521,44423,44424,48402,48404,48406,48408,48410,48412,48414,48420,48422,48424,48426,48428,48432,48435,48438,48440,48442,48444,48507,48509,48511,48513,48515,48517,48519,48521,48523,49185,49189,49191,
-- 40790,40791,40792,40810,40811,40812,40829,40830,40831,40850,40851,40852,40870,40871,40872,40883,40884,40890,40910,40928,40934,40940,40964,40978,40979,40984,40994,40995,41002,41008,41014,41020,41028,41034,41039,41045,41052,41056,41061,41066,41071,41076,41082,41088,41138,41144,41152,41158,41200,41206,41212,41218,41226,41231,41236,41276,41282,41288,41294,41299,41305,41311,41317,41322,41328,41618,41622,41626,41631,41636,41641,41651,41656,41662,41668,41673,41679,41684,41716,41768,41774,41833,41837,41841,41855,41860,41865,41870,41875,41882,41886,41894,41899,41904,41910,41916,41922,41928,41935,41941,41947,41954,41960,41966,41972,41994,41999,42006,42012,42018,42041,42042,42043,42044,42045,42046,42047,42076,42077,42078,42079,42080,42081,42082,42118,42119,42527,42533,42539,42561,42566,42572,42580,42585,42591,42599,42604,42609,42616,42622,42854,46374,49086,49179,49181,49183,49187,
-- 48646,48645,48644,48643,48642,48616,48615,48614,48613,48612,48584,48583,48582,48581,48580,48547,48546,48545,48544,48543,48490,48489,48488,48487,48486,48455,48453,48451,48447,48433,48385,48384,48383,48382,48381,48355,48354,48353,48352,48351,48325,48324,48323,48322,48321,48294,48293,48292,48291,48290,48264,48263,48262,48261,48260,48232,48231,48230,48229,48228,48207,48206,48205,48204,48203,48172,48171,48170,48169,48168,48142,48141,48140,48139,48138,48086,48085,48084,48083,48082,48037,48035,48033,48031,48029,47792,47791,47790,47789,47788,47762,47761,47760,47759,47758,
-- }
local options = {
	name = "All The Little Things",
	type = 'group',
	args = {
		alwaysDump = {
			order = 1,
			name = "Always Dump",
			desc = "Always dump to raid chat regardless of promotion",
			type = 'toggle',
			get = function(info) return core.db.profile.alwaysDump end,
			set = function(info, v) core.db.profile.alwaysDump = v end,
		},
		interrupt = {
			order = 4,
			name = "Interrupt printing",
			desc = "Toggles printing what you interrupted in party chat",
			type = "toggle",
			get = function(info) return core.db.profile.interrupt end,
			set = function(info, v) core.db.profile.interrupt = v end,
		},
		autoML = {
			order = 20,
			name = "Auto ML",
			desc = "Sets loot type to ML when a raid has more than 20 players in it.",
			type = "toggle",
			get = function(info) return core.db.profile.autoML end,
			set = function(info, v) core.db.profile.autoML = v core:OnEnable() end,
		},
		easyInvites = {
			order = 25,
			name = "Easy Raid Invites",
			desc = "Colors names and allows you to alt+click to invite.",
			type = "toggle",
			get = function(info) return core.db.profile.easyInvites end,
			set = function(info, v) core.db.profile.easyInvites = v core:OnEnable() end,
		},
		rollTally = {
			order = 30,
			name = "Roll Tally",
			desc = "Tallies rolls for 8s after a raid warning with 'roll' in the message. Can also activate with /atlt rt.",
			type = "toggle",
			get = function(info) return core.db.profile.rollTally end,
			set = function(info, v) core.db.profile.rollTally = v core:OnEnable() end,
		},
		nixAFK = {
			order = 30,
			name = "Remove AFK Responses",
			desc = "Removes AFK responses when whispering AFK players.",
			type = "toggle",
			get = function(info) return core.db.profile.nixAFK end,
			set = function(info, v) core.db.profile.nixAFK = v core:OnEnable() end,
		},
		autoWG = {
			order = 35,
			name = "Auto Wintergrasp Join",
			desc = "Automatically joins Wintergrasp if in Dalaran or Ironforge. Also boots that faggot Unhidenenemy.",
			type = "toggle",
			get = function(info) return core.db.profile.autoWG end,
			set = function(info, v) core.db.profile.autoWG = v core:OnEnable() end,
		},
		eotsFlag = {
			order = 40,
			name = "Eye of the Storm Flag",
			desc = "Adds in points for a held flag based on bases owned.",
			type = "toggle",
			get = function(info) return core.db.profile.eotsFlag end,
			set = function(info, v) core.db.profile.eotsFlag = v core:OnEnable() end,
		},
		achieveFilter = {
			order = 45,
			name = "Achievement Filter",
			desc = "Sets achievement filter to Incomplete automatically.",
			type = "toggle",
			get = function(info) return core.db.profile.achieveFilter end,
			set = function(info, v) core.db.profile.achieveFilter = v core:OnEnable() end,
		},
		officerPhone = {
			order = 60,
			name = "Officer Phone Records",
			desc = "Allows !phone <player>",
			type = 'toggle',
			get = function(info) return core.db.profile.officerPhone end,
			set = function(info, v) core.db.profile.officerPhone = v core:OnEnable() end,
		},
		markMsgFilter = {
			order = 70,
			name = "Mark Message Filter",
			desc = "Filters mark messages caused by the player.",
			type = 'toggle',
			get = function(info) return core.db.profile.markMsgFilter end,
			set = function(info, v) core.db.profile.markMsgFilter = v core:OnEnable() end,
		},
		spellWatch = {
			order = 80,
			name = "Print important spells",
			desc = "Prints MD, ToTT, and taunts to ncafail.",
			type = 'toggle',
			get = function(info) return core.db.profile.spellWatch end,
			set = function(info, v) core.db.profile.spellWatch = v end,
		},
		macroSwap = {
			order = 90,
			name = "Flame Caps for Lich King",
			desc = "Swaps the macro to use Flame Caps for HLK",
			type = 'toggle',
			get = function(info) return core.db.profile.macroSwap end,
			set = function(info, v) core.db.profile.macroSwap = v end,
		},
	},
}
local defaults = {
	profile = {
		addonDebug = {
			x = 100,
			y = 100,
		},
		alwaysDump = true,
		isGay = false,
		interrupt = false,
		autoML = false,
		easyInvites = false,
		nixAFK = true,
		autoWG = false,
		eotsFlag = true,
		consolidateThresh = 0,
		officerPhone = true,
		markMsgFilter = true,
		spellWatch = true,
		macroSwap = true,
		halloween = 1,
		guildXPMarks = { },
	}
}
local spellWatch = {
	["Taunt"] = true,
	["Growl"] = true,
	["Hand of Reckoning"] = true,
	["Death Grip"] = true,
	["Dark Command"] = true,
}
local aoeSpellWatch = {
	["Misdirection"] = true,
	["Tricks of the Trade"] = true,
	["Righteous Defense"] = true,
	["Challenging Shout"] = true,
	["Challenging Roar"] = true,
};
local gilneasTimes = { -- time in seconds to get a point
	[0] = 0,
	[1] = 8,
	[2] = 3,
	[3] = 1/3,
}
local potList = {
	["a"] = 58146, -- Golemblood
	["b"] = 58145, -- Tol'vir
	["c"] = 58090, -- Earthen
	["d"] = 58091, -- Volcanic
	["e"] = 57194, -- Concentration
	["f"] = 57192, -- Mythical
}
local armorGlyphs = {
	[30482] = 56382,	 -- Molten Armor
	[6117]	= 56383,	 -- Mage Armor
}

core.guildList = {}
core.rollTally = {}
core.rollTimer = false
core.guildHook = false
core.guildView = nil
core.interruptCast = false
core.consolidateHook = false
core.mlOrder = {"Chira", "Devotchka", "Yawning", "Brinkley", "Toney", "Dcon"}
core.wgStatus = 0
core.flagStatus = 0
core.eotsHook = false
core.achieveHook = false
core.hallowBuff = nil
core.countDown = {"Pulling in 5", "4", "3", "2", "1", "Go"} -- used in /atlt cd
core.mailQueue = {} -- used in /atlt pots
core.rosterRaidersOnly = false
-- core.rosterAlteredCache = {} -- mapping of ids when checked
core.rosterRaidersCache = {} -- mains who are raiders
core.rosterRaidersCount = 0
core.rosterRaidersOnline = 0
-- core.inRosterUpdate = false -- whether to return mapped values

function core:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("AllTheLittleThingsDB", defaults, "Default")
	--[[self.db.RegisterCallback(self, "OnProfileChanged", "OnProfileChanged")
	self.db.RegisterCallback(self, "OnProfileCopied", "OnProfileChanged")
	self.db.RegisterCallback(self, "OnProfileReset", "OnProfileChanged")]]
	
	self:RegisterChatCommand("atlt", "SlashProcess")
	
	-- options.args.profile = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
	LibStub("AceConfig-3.0"):RegisterOptionsTable("ATLT", options)
	self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("ATLT", "All The Little Things")
	
	-- Init finished
	-- self.guildList = self:GetGuildList()
	ConsoleExec("cameradistancemaxfactor 5")
	
	-- try to reproduce that bug
	-- self:Nostromo()
end

function core:OnEnable()
	SetModifiedClick("TRADESEARCHADD", nil)
	
	if self.db.profile.autoML or self.db.profile.easyInvites or self.db.profile.autoWG then
		self:RegisterEvent("RAID_ROSTER_UPDATE")
		self:RAID_ROSTER_UPDATE()
	end
	-- if self.db.profile.easyInvites then
	self:RegisterEvent("ADDON_LOADED", function(_, name)
		if name == "Blizzard_GuildUI" then
			self:SecureHook("GuildRoster_Update")
			self:SecureHook(GuildRosterContainer, "update", "GuildRoster_Update")
			local buttons = GuildRosterContainer.buttons
			for i=1, #buttons do
				buttons[i].stripe.texture = buttons[i].stripe:GetTexture()
				self:RawHookScript(buttons[i], "OnClick", "GuildRosterButton_OnClick")
			end
			-- self:RawHook("GuildRosterButton_OnClick", true)
			self:SecureHook("GuildRoster_SetView")
			self:UnregisterEvent("ADDON_LOADED")
			
			-- modify
			self:ModifyRosterPane()
			-- need to write my own hook since AceHook doesn't allow more than one?
			-- self:Hook("GuildRoster_Update", "RosterUpdatePreHook", true)
			-- local GuildRoster_UpdateHook = GuildRoster_Update
			-- local function GuildRoster_UpdateReplace()
				-- self:RosterUpdatePreHook()
				-- return GuildRoster_UpdateHook()
				-- self:GuildRoster_UpdateNew()
				-- self:GuildRoster_Update() -- for the other bit
			-- end
			-- GuildRoster_Update = GuildRoster_UpdateReplace
			-- GuildRosterContainer.update = GuildRoster_UpdateReplace
		end
	end)
	-- end
	if self.db.profile.rollTally then
		self:RegisterEvent("CHAT_MSG_RAID_WARNING")
		self:RegisterEvent("CHAT_MSG_SYSTEM")
	end
	if self.db.profile.nixAFK then
		ChatFrame_AddMessageEventFilter("CHAT_MSG_AFK", function(...) return self:NixAFK(...); end);
	end
	if self.db.profile.markMsgFilter then
		ChatFrame_AddMessageEventFilter("CHAT_MSG_TARGETICONS", function(_,_,msg) if (msg:find("%["..UnitName("player").."%]")) then return true; end end);
	end
	if self.db.profile.autoWG then
		self:RegisterEvent("BATTLEFIELD_MGR_ENTRY_INVITE")
	end
	if self.db.profile.eotsFlag and not self.eotsHook then
		self:RawHook("WorldStateAlwaysUpFrame_Update", true)
		self.eotsHook = true
		self:RegisterEvent("CHAT_MSG_BG_SYSTEM_ALLIANCE", "BattlegroundMessage")
		self:RegisterEvent("CHAT_MSG_BG_SYSTEM_HORDE", "BattlegroundMessage")
	end
	if self.db.profile.achieveFilter and not self.achieveHook then
		self:RawHook("AchievementFrame_LoadUI", true)
		self.achieveHook = true
	end
	-- if (self.db.profile.consolidateThresh>0) and (not self.consolidateHook) then
		-- self:RawHook("UnitAura", true)
		-- self.consolidateHook = true
	-- end
	if (self.db.profile.officerPhone) then
		self:RegisterEvent("CHAT_MSG_OFFICER");
	end
	self:RegisterEvent("MAIL_SHOW", "MailQueueCheck");
	self:RegisterEvent("MAIL_SUCCESS", "MailQueueCheck");
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "ZoneChange");
	self:RegisterEvent("ZONE_CHANGED", "ZoneChange");
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA", "ZoneChange");
	self:RegisterEvent("PLAYER_DIFFICULTY_CHANGED", "ZoneChange");
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	self:RegisterEvent("CHAT_MSG_LOOT")
	self:RegisterEvent("UNIT_AURA")
	self:RegisterEvent('GUILDBANKFRAME_OPENED')
	
	self:SecureHook("TargetUnit")
	
	if RaidBuffStatus then
		self:SecureHook(RaidBuffStatus, "SetupFrames", "SetupRBS")
	end	

	if Prat then
		self:SetupPrat()
	end

	-- self:ScheduleTimer("SetupAddonDebug", 3)
end

function core:OnDisable()
	self:UnregisterAllEvents()
	self:UnhookAll()
	self.guildHook = false
	self.achieveHook = false
	self.eotsHook = false
	self.consolidateHook = false
end

function core:SlashProcess(msg)
	if msg == "debug" then
		self:BugInit()
	elseif msg == "disbandraid" or msg == "dr" then
		for i=1, GetNumRaidMembers() do
			if not UnitIsUnit("raid"..i,"player") then 
				UninviteUnit("raid"..i) 
			end
		end
	elseif msg == "inviteguild" or msg == "ig" then
		for i=1, select(2, GetNumGuildMembers()) do 
			if not UnitInRaid(GetGuildRosterInfo(i)) then
				InviteUnit(GetGuildRosterInfo(i)) 
			end
		end
	elseif msg == "promoteall" or msg == "pa" then
		for i=0, GetNumRaidMembers() do
			PromoteToAssistant("raid"..i)
		end
	elseif msg == "printloot" or msg == "pl" then
		self:RaidDump("Send tells for loot:", "raid_warning")
		for i=1,GetNumLootItems() do 
			self:RaidDump(GetLootSlotLink(i) .. " (" .. ({"A", "B", "C", "D", "E", "F", "G", "H"})[i] .. ")", "raid_warning")
		end
	elseif msg == "clearmarks" or msg == "cm" then
		for i=8,0,-1 do
			SetRaidTarget("player", i)
		end
		self:ScheduleTimer(function() SetRaidTarget("player", 0) end, 0.5)
	elseif msg == "rolltally" or msg == "rt" then
		self:CHAT_MSG_RAID_WARNING(nil, "roll")
	elseif msg == "phone" then
		-- prints missing phone numbers
		self:FindMissingPhones();
	elseif msg == "masterloot" or msg == "ml" then
		self:MasterLoot()
	elseif msg == "randomloot" or msg == "rl" then
		local members = {}
		for i=1,40 do
			if GetMasterLootCandidate(i) then
				table.insert(members, i);
			end
		end
		
		for j=1, GetNumLootItems() do 
			GiveMasterLoot(j, members[random(#members)])
		end 
	elseif msg == "arathibasin" or msg == "ab" then
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
	elseif msg == "ilevel" or msg == "il" then
		self:RaidDump("Tallying iLevel Sums...")
		r = {}
		for i=1,GetNumRaidMembers() do 
			s=0
			InspectUnit("raid"..i) 
			for j=1,16 do 
				l=GetInventoryItemLink("raid"..i,j) 
				if l~=nil and j~=4 then 
					_,_,_,v=GetItemInfo(l) s=s+v 
				end 
			end
			r[i] = {UnitName("raid"..i), s}
		end
		table.sort(r, function(a, b) return a[2] > b[2] end)
		for i,v in pairs(r) do
			if v[2] > 0 then
				self:RaidDump(v[1]..": "..v[2])
			else
				self:RaidDump(v[1]..": (out of range)")
			end
		end
		self:RaidDump("---")
	elseif msg == "combatlog" or msg == "cl" then
		CombatLogClearEntries()
	elseif msg == "count" or msg == "ct" then
		self:Countdown()
	elseif msg:match("^pots ") then
		-- get all guild members
		for i=1,GetNumGuildMembers() do
			local name, rank = GetGuildRosterInfo(i)
			name = name:lower()
			if rank == "Member" or rank == "Officer" or rank == "Guild Master" then
				if self.mailQueue[name] == nil then
					self.mailQueue[name] = {}
				end
			end
		end
		-- parse
		msg:gsub("([^%d%s]+)(%d+)(%w)", function(name, ct, type)
			local typeRef = potList[type]
			name = name:lower()
			ct = tonumber(ct)
			if typeRef and ct then
				for i,_ in pairs(self.mailQueue) do
					if i:match("^"..name) then
						self.mailQueue[i][typeRef] = ct
						print(format("Queued %dx |Hitem:%d|h[%s]|h for %s", ct, typeRef, GetItemInfo("item:"..typeRef), i))
					end
				end
			end
		end)
		-- cleanup array
		for name,data in pairs(self.mailQueue) do
			local ct = 0
			for i,v in pairs(data) do
				ct = ct + v
			end
			if ct == 0 then
				self.mailQueue[name] = nil
			end
		end
	elseif msg == "markxp" then
		-- write all current
		local db = self.db.profile.guildXPMarks
		local num = #db+1
		
		db[num] = { 
			time = time(),
			marks = { },
		}
		local markSet = db[num].marks
		
		-- build all xp list
		for i=1,GetNumGuildMembers() do
			local name, rank, _, _, _, _, note = GetGuildRosterInfo(i)
			local xp, total = GetGuildRosterContribution(i)
			
			if rank:find("Alt") then
				name = note
			end
			
			if not markSet[name] then
				markSet[name] = 0
			end
			markSet[name] = markSet[name] + total
		end		
		
		self:Print(format("Created new mark set #%d; suggested UI reload", num))
	elseif msg:find("diff ") then
		local setNum = tonumber(msg:match("diff (%d+)"))
		local set = setNum and self.db.profile.guildXPMarks[setNum]
		
		if not set then
			self:Print(format("Could not find split %d", setNum))
			return
		end
		
		local markSet = { }
		for i=1,GetNumGuildMembers() do
			local name, rank, _, _, _, _, note = GetGuildRosterInfo(i)
			local xp, total = GetGuildRosterContribution(i)
			
			if rank:find("Alt") then
				name = note
			end
			
			if not markSet[name] then
				markSet[name] = 0
			end
			markSet[name] = markSet[name] + total
		end
		
		local diff = { }
		local total = 0
		for player, xp in pairs(set.marks) do
			if markSet[player] > xp then
				local d = markSet[player] - xp
				diff[player] = d
				total = total + d
			end
		end
		
		local function printInfo(msg)
			-- self:Print(msg)
			SendChatMessage(msg, "guild")
		end
		
		printInfo(format("Guild XP Difference Since %s:", date("%c", set.time)))
		while next(diff) ~= nil do
			local max, maxVal = "-", -1
			for k,v in pairs(diff) do
				if v > maxVal then
					max, maxVal = k, v
				end
			end
			printInfo(format("%s - %.1fk (%.1f%%)", max, maxVal/1000, maxVal/total*100))
			diff[max] = nil
		end
	elseif msg == "activitytally" or msg == "at" then
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
			
			if self.toggleTotal then 
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
					capped[name] = true
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
		printInfo("* Denotes capped on at least one character")
	elseif msg == "rostercheck" or msg == "rc" then
		-- TODO: make a global alt_ranks and main_ranks thing in case we change it
		local altRanks = {
			[2] = true,
			[4] = true,
		}
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
	elseif msg == "hott" then 
		self:RaidDump("Checking for Herald Gear...")
		for i=1,GetNumRaidMembers() do 
			s=0
			InspectUnit("raid"..i) 
			for j=1,18 do 
				l=GetInventoryItemLink("raid"..i,j) 
				if l~=nil then 
					_,_,_,v=GetItemInfo(l)
					if v>232 then
						self:RaidDump(UnitName("raid"..i) .. ": " .. l .. "!!")
					elseif v>226 and (j~=16 and j~=18) then
						self:RaidDump(UnitName("raid"..i) .. ": " .. l .. "!!")
					end
				end 
			end
		end
		self:RaidDump("Check complete.")
	elseif msg == "ttdi" then
		local toCheck = {}
		local uncheckedPlayers = {}
		self:RaidDump("Checking for Dedicated Insanity Gear...")
		for i=1,GetNumRaidMembers() do 
			local name = UnitName("raid"..i)
			InspectUnit("raid"..i) 
			uncheckedPlayers[name] = 0
			for j=1,18 do 
				l=GetInventoryItemLink("raid"..i,j) 
				if l~=nil then 
					uncheckedPlayers[name] = uncheckedPlayers[name]+1
					_, _, id = strfind(l, "item:(%d+)")
					if id then
						toCheck[id] = l
					end
				end
			end
		end
		for i,v in ipairs(DedicatedInsanity) do
			if toCheck[tostring(v)] then
				SendChatMessage(string.format("%s is not allowed", toCheck[tostring(v)]), "raid")
			end
		end
		for i,v in pairs(uncheckedPlayers) do
			if v < 5 then
				SendChatMessage(string.format("%s was not checked.", i), "raid")
			end
		end
		self:RaidDump("Check complete.")
		
	else
		self:Print("Valid commands:")
		self:Print("/atlt disbandraid - Disbands a raid")
		self:Print("/atlt inviteguild - Invites everyone in your guild to a raid")
		self:Print("/atlt promoteall - Promotes everyone in the raid")
		self:Print("/atlt printloot - Prints the loot in raid warning")
		self:Print("/atlt clearmarks - Clears all raid marks")
		self:Print("/atlt rolltally - Begins recording rolls for 10 seconds")
		self:Print("/atlt arathibasin - Prints info on the current AB game")
		self:Print("/atlt printloot - Prints the loot in /rw with accompanying letter")
		self:Print("/atlt ilevel - Prints the sum of everyone's ilevel gear in raid chat")
		self:Print("/atlt combatlog - Fixes a broken combat log")
		self:Print("/atlt hott - Raid wide Herald of the Titans check")
		self:Print("/atlt ttdi - Raid wide Tribute to Dedicated Insanity check")
	end
end

function core:RAID_ROSTER_UPDATE()
	if (_G["GuildRoster_Update"]) then
		self:GuildRoster_Update()
	end
	if self.db.profile.autoML and IsRaidLeader() and GetNumRaidMembers()>20 and GetLootMethod() ~= "master" and GetRealZoneText() ~= "Wintergrasp" then
		SetLootMethod("master", "player")
		self:ScheduleTimer(function() SetLootThreshold(3) end, 2)
	end
	if nil and self.db.profile.easyInvites and GuildFrame:IsShown() then
		GuildStatus_Update()
	end
	if self.db.profile.autoWG then
		if UnitName("Unhidenenemy") and GetRealZoneText() == "Wintergrasp" and IsRaidOfficer() then
			UninviteUnit("Unhidenenemy")
		end
	end
end

function core:CHAT_MSG_RAID_WARNING(_, message)
	if self.db.profile.rollTally and string.find(message:lower(), "roll") then
		if self.rollTimer then
			-- Stop current roll
			self:CancelTimer(self.rollTimer)
			self:RollFinish()
		end
		self.rollTally = {}
		self.rollTimer = self:ScheduleTimer("RollFinish", 10)
	end
end

function core:UNIT_AURA(_, unit)
	-- if we haven't set the initial value yet, set and quit
	if (self.hallowBuff == nil) then
		self.hallowBuff = not not UnitDebuff("player", "Tricked or Treated")
		-- self:Print("Set to", self.hallowBuff);
		return;
	end
	
	local function hasBuff()
		return not not UnitDebuff("player", "Tricked or Treated")
	end
	
	if (unit == "player") then
		if (self.hallowBuff and not hasBuff()) then
			self:Print("Halloween debuff lost!");
			self.hallowBuff = false;
		elseif (not self.hallowBuff and hasBuff()) then
			self.db.profile.halloween = self.db.profile.halloween + 1;
			-- pick transitive
			local transitive = TRANSITIVES[math.random(#TRANSITIVES)];
			self:Print(format("I will %s %d babies this year", transitive, self.db.profile.halloween))
			self.hallowBuff = true;
		end
	end
end

-- g_allLoots = {}
function core:CHAT_MSG_LOOT(_, message, source)
	-- if (message:find("Saampson") and message:find("Shadowfrost Shard")) then
		-- SendChatMessage(format("Saampson Shard Count: %d", math.random(15, 50)), "raid");
	-- end
	
	-- source = message:match("(.+) receives loot")
	-- if not g_allLoots[source] then
		-- g_allLoots[source] = 0
	-- end
	-- g_allLoots[source] = g_allLoots[source] + 1
	if message:find("You create") and message:find("Deathblood Venom") and GuildBankFrame and GuildBankFrame:IsVisible() and GetItemCount("Deathblood Venom") >= 4 then
		for bag=0,NUM_BAG_SLOTS do
			for slot=1,GetContainerNumSlots(bag) do
				if GetContainerItemID(bag, slot) == 58142 then
					SetCurrentGuildBankTab(5)
					UseContainerItem(bag, slot)
				end
			end
		end
	end
end

function core:CHAT_MSG_SYSTEM(_, message, source)
	if self.db.profile.rollTally and self.rollTimer then
		local name, roll, min, max = string.match(message, "(%S+) rolls (%d+) %((%d+)%-(%d+)%)")
		if name and roll and min and max then
			if min ~= "1" or max ~= "100" then
				self:Print(string.format("%s is rolling out of bounds (%d-%d).", name, min, max))
				return
			end
			if not self.rollTally then
				self.rollTally = {}
			end
			if self.rollTally[name] then
				self:Print(string.format("%s is rolling again (first: %d, this: %d).", name, self.rollTally[name], roll))
				return
			end
			self.rollTally[name] = roll
		end
	end
end

function core:BATTLEFIELD_MGR_ENTRY_INVITE()
	if self.db.profile.autoWG and (GetRealZoneText() == "Dalaran" or GetRealZoneText() == "Ironforge") then
		BattlefieldMgrEntryInviteResponse(1, 1)
		wgStatus = 1
		-- self:SetScript("OnKeyDown", self.OnKeyDown)
	end
end

-- g_allDebuffs = {}
function core:COMBAT_LOG_EVENT_UNFILTERED(_, timestamp, event, _, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, spellid, spellName, spellSchool, extraSpellid, extraSpellName, ...)
--[[	
	if self.db.profile.interrupt and GetNumPartyMembers()>0 then
		if event == "SPELL_INTERRUPT" and srcName == UnitName("player") then
			SendChatMessage("Interrupted " .. dstName .. "'s " .. extraSpellName, "party")
			self.interruptCasted = false
		end
		if (event == "SPELL_MISSED" or event == "SPELL_HIT") and srcName == UnitName("player") and spellName == "Counterspell" then
			SendChatMessage("Counterspell missed", "party")
			self.interruptCasted = false
		end
		if event == "SPELL_CAST_SUCCESS" and srcName == UnitName("player") and spellName == "Counterspell" then
			self.interruptCasted = true
			self:ScheduleTimer(function() if core.interruptCasted == true then 
									SendChatMessage("Counterspell failed", "party")
									self.interruptCasted = false
								end end, 0.3)
		end					
	end
]]	
	-- if (spellName == "Animal Blood" and event == "SPELL_AURA_REMOVED") then
		-- if not g_allDebuffs[dstName] then
			-- g_allDebuffs[dstName] = 0
		-- end
		
		-- g_allDebuffs[dstName] = g_allDebuffs[dstName] + 1
	-- end

	if (self.db.profile.spellWatch and (UnitInRaid(srcName) or UnitInParty(srcName)) and (not UnitInBattleground("player")) and (GetRealZoneText() ~= "Wintergrasp")) then
		-- temp gaffer watch!
		--if (UnitInRaid("Gaffer") or UnitInRaid("Gtt")) then
		--	return;
		--end
		
		local act = false;
		if ( (event == "SPELL_AURA_APPLIED" and spellWatch[spellName]) or 
			 (event == "SPELL_CAST_SUCCESS" and aoeSpellWatch[spellName]) ) then
			act = "casted";
		elseif (event == "SPELL_MISSED" and spellWatch[spellName]) then
			act = "missed";
		end
		if (act ~= false) then
			local target = (dstName and " on %s") or "";
			SendChatMessage(format("%s %s %s"..target, srcName, act, spellName, dstName), "channel", nil, GetChannelName("ncafail"));
		end
	end
	
	if (event == "SPELL_AURA_REMOVED" and dstGUID == UnitGUID("player") and spellName == "Cauterize") then
		self:ScheduleTimer(function()
			if not UnitIsDead("player") then
				for i=1,GetNumGuildMembers() do
					local name, _, _, _, _, _, _, _, online = GetGuildRosterInfo(i)
					if name == "Chira" and online then
						SendChatMessage(">>> Cauterize just saved me! <<<", "whisper", nil, name)
					end
				end
			end
		end, 1)
	end
	
	if (event == "SPELL_AURA_APPLIED" and dstGUID == UnitGUID("player")) then
		if armorGlyphs[spellid] then
			-- print(spellid, armorGlyphs[spellid])
			-- check if we have a different glyph
			for i=1, NUM_GLYPH_SLOTS do
				local glyphSpell = select(4, GetGlyphSocketInfo(i))
				-- print(glyphSpell)
				if glyphSpell == armorGlyphs[spellid] then
					return
				end
			end
			print(format("Warning: %s is not glyphed", spellName))
		end
	end

end

function core:FlaskCheck()
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

function core:Countdown()
	for i=5,0,-1 do
		self:ScheduleTimer(function()
			local msg = self.countDown[6-i];
			--[[if (msg == "Go") then
				local transitive = TRANSITIVES[math.random(#TRANSITIVES)];
				msg = format("%s babies", transitive)
			end]]
			SendChatMessage(msg, "RAID_WARNING");
		end, 5-i);
	end
end

function core:MasterLoot()
	for k,v in ipairs(self.mlOrder) do
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

local macro = "MI+FC";
function core:ZoneChange()
	if (self.db.profile.macroSwap and UnitName("player")=="Chira" and GetMacroIndexByName(macro)>0) then
		if (GetSubZoneText() == "The Frozen Throne" and self:GetMode()>3) then
			EditMacro(GetMacroIndexByName(macro), nil, nil, GetMacroBody(macro):gsub("Flame Caq", "Flame Cap"));
		else
			EditMacro(GetMacroIndexByName(macro), nil, nil, GetMacroBody(macro):gsub("Flame Cap", "Flame Caq"));
		end
	end
end

function core:GetMode()
	local _, _, diff, _, _, dynHeroic, dynFlag = GetInstanceInfo(); 
	return diff; -- (dynFlag and (2-(diff%2)+2*dynHeroic)) or diff; 
end

function core:OnKeyDown()
	if self.wgStatus > 0 and GetRealZoneText() ~= "Wintergrasp" then
		self.wgStatus = 0
		BattlefieldMgrEntryInviteResponse(1, 1)
	end
end

function core:CheckSmash()
	local sum, str
	local thresh = self.db.profile.smash
	for name, vals in pairs(self.smashList) do
		sum = 0
		str = " ("
		for _,v in ipairs(vals) do
			sum = sum + v
			str = str .. v .. ", "
		end
		if sum > thresh then
			self:RaidDump(name .. " got smashed for " .. sum .. str:sub(1, -3) ..  ")")
		end
		self.smashList[name] = {}
	end
	self.smashTimer = nil
end


function core:RaidDump(msg, sink)
	if self.db.profile.alwaysDump or IsRaidOfficer() then
		sink = sink or "raid"
		SendChatMessage(msg, sink)
	end
end

function core:RollFinish()
	local winner
	local ties = {}
	for i,v in pairs(self.rollTally) do
		if (not winner) or (tonumber(self.rollTally[winner])<tonumber(v)) then
			winner = i
			ties = {}
		elseif self.rollTally[winner] == v then
			table.insert(ties, i)
		end
	end
	if not winner then
		self:Print("No rolls detected.")
	else
		if next(ties) then
			local roll = self.rollTally[winner]
			for i,v in ipairs(ties) do
				winner = v .. ", " .. winner
			end
			self:Print(string.format("%d-way tie between %s (rolled %d). Rerolling...", #ties+1, winner, roll))
			self.rollTally = {}
			self:ScheduleTimer("RollFinish", 4)
		else
			self:Print(string.format("%s won the roll with a %d.", winner, self.rollTally[winner]))
		end
	end
	self.rollTimer = false
end

function core:NixAFK(_, _, ...)
	return (not not self.db.profile.nixAFK), ...;
end


function core:GuildRoster_Update()
	self:RosterUpdatePostHook()
	
	local view = self.guildView or GuildRosterViewDropdown.selectedValue
	local buttons = GuildRosterContainer.buttons
	local offset = HybridScrollFrame_GetOffset(GuildRosterContainer);
	for i=1, #buttons do
		local stripe = buttons[i].stripe
		if stripe.texture then
			stripe:SetTexture(stripe.texture)
		end
		
		if (UnitInRaid("player") and self.db.profile.easyInvites) then
			if buttons[i].guildIndex then
				name = GetGuildRosterInfo(buttons[i].guildIndex)
				if name and UnitInRaid(name) and (view == "playerStatus" or view == "guildStatus") then
					buttons[i].stripe:SetTexture(1, 0.5, 0, 0.3)
				end
			end
		end
	end
end

function core:GuildRoster_SetView(view)
	self.guildView = view
end

function core:GuildRosterButton_OnClick(this, button, ...)
	if self.db.profile.easyInvites and IsAltKeyDown() then
		local guildIndex = this.guildIndex
		local name, _, _, _, _, _, _, _, online = GetGuildRosterInfo(guildIndex)
		if online then
			InviteUnit(name)
		end
	else
		self.hooks[this].OnClick(this, button, ...)
	end
end

function core:WorldStateAlwaysUpFrame_Update(...)
	self.hooks["WorldStateAlwaysUpFrame_Update"](...)
	if GetRealZoneText() == "Eye of the Storm" then
		local points = {[0]=0, 75, 85, 100, 500}
		if self.flagStatus > 0 then
			local i = self.flagStatus + 1
			if select(3, GetWorldStateUIInfo(i)) then -- extra if since I got a lua error while leaving a BG once
				local _, _, full, bases, score = string.find(select(3, GetWorldStateUIInfo(i)), "(Bases: (%d).-(%d+)/.+)")
				if not full then return end
				-- self:Print(string.find(select(3, GetWorldStateUIInfo(i)), "(Bases: (%d).-(%d+)/.+)"))
				-- self:Print(GetWorldStateUIInfo(i))
				local nScore = "|cff00ff00" .. (tonumber(score)+points[tonumber(bases)]) .. "|r"
				local frame = _G["AlwaysUpFrame"..self.flagStatus.."Text"]
				if frame then
					frame:SetText(string.gsub(full, score.."/", nScore.."/"))
				end
			end
		end
	end
end

function core:BattlegroundMessage(event, msg)
	local faction = ((event=="CHAT_MSG_BG_SYSTEM_ALLIANCE" and 1) or 2)
	if string.find(msg, "captured.+flag") or string.find(msg, "dropped.+flag") then
		self.flagStatus = 0
	elseif string.find(msg, "taken.+flag") then
		self.flagStatus = faction
	end
end

function core:AchievementFrame_LoadUI(...)
	local args = {self.hooks["AchievementFrame_LoadUI"](...)}
	AchievementFrame_SetFilter(3)
	self:Unhook("AchievementFrame_LoadUI")
	return unpack(args);
end

function core:UnitAura(...)
	name, rank, icon, count, dispelType, duration, expires, caster, isStealable, shouldConsolidate, spellID = self.hooks["UnitAura"](...)
	if expires and (self.db.profile.consolidateThresh > 0) then
		if ((expires-GetTime())/60 > self.db.profile.consolidateThresh) or (name:find("Aura") or name:find("Totem")) or (shouldConsolidate == 1) then
			shouldConsolidate = 1
		else
			shouldConsolidate = nil
		end
	end
	
	return name, rank, icon, count, dispelType, duration, expires, caster, isStealable, shouldConsolidate, spellID
end

function core:CHAT_MSG_OFFICER(_, msg)
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

function core:CheckPhone(index)
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

function core:FindMissingPhones()
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

function core:TargetUnit(name)
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

--[[ Things to do here still:
	- remove debug
	- consumables.php: group names together in slash args
	- consumables.php: split slash by pots?
	- if we don't have mats for this player, move to end of queue
	- use a flag of sorts to keep track of who was moved and who was not; reset flags on... mailbox close? this way we don't keep going through the queue over and over at the end
	- change data structure to numerical array (so we can move to the end)
	- change subject line to include amount
	- the lowercase first letter bugs me
	- do check when parsing slash command to make sure there are no ambiguous targets (Eternal/Eternity)
	- compress slash command more: 
		limit to first 4 letters (chir40d, chir->chira)? 3 may be possible but has higher collisions
		allow for chaining (chira40d2e6f - 40d, 2e, 6f)?
		include length of name after characters *in hex* (chi540d - "chira" has length of 5)
	- re-consolidate stacks at the end of the queue
	- add a command to display how much left of each is needed vs how much you have
]]
local mailQueueTimer
function core:MailQueueCheck(caller, passData)
	local name,data = next(self.mailQueue)
	if not data then
		return -- no need to process queue
	end

	local delay = 0.5
	if caller == "MAIL_SUCCESS" then
		-- MAIL_SUCCESS fires on open too, so going to make sure we're looking at a Send Mail screen
		if MailFrame.selectedTab ~= 2 then
			return
		end
	end
	if mailQueueTimer then
		self:CancelTimer(mailQueueTimer, true)
	end
	-- slight pause to allow for items to disappear
	mailQueueTimer = self:ScheduleTimer(function()
		do
			self:Print(caller)
			-- return
		end
		
		-- find all slots for splitting onto
		local emptySlots = {}
		for bag=0,NUM_BAG_SLOTS do
			local free = GetContainerFreeSlots(bag)
			for _,slot in ipairs(free) do
				table.insert(emptySlots, bag*100+slot)
			end
		end
		
		-- need to keep track of what to push to Send Mail window when the item lock clears
		local pushQueue = {}
		local checkItemLock = function(_, bagID, slotID)
			local globalID = bagID*100+slotID
			self:Print("ITEM_LOCK_CHANGED fired", globalID)
			if pushQueue[globalID] then
				local _, _, locked = GetContainerItemInfo(bagID, slotID)
				if not locked then
					PickupContainerItem(bagID, slotID)
					ClickSendMailItemButton()
					pushQueue[globalID] = nil
					
					-- if our queue is empty
					if not next(pushQueue) then
						self:UnregisterEvent("ITEM_LOCK_CHANGED")
						self:Print("Unregistering ITEM_LOCK_CHANGED")
					end
				end
			end
		end
		local initializeQueue = function()
			self:RegisterEvent("ITEM_LOCK_CHANGED", checkItemLock)
			self:Print("Registering ITEM_LOCK_CHANGED")
		end
		
		-- swap tabs if we need to
		if MailFrame.selectedTab ~= 2 then
			MailFrameTab_OnClick(MailFrame, 2)
		end
		ClearSendMail()
		
		-- set name
		SendMailNameEditBox:SetText(name)
		
		-- fill out shit
		for item,ct in pairs(data) do
			print("--------- NEXT ITEM:", item)
			if ct > 0 then
				local inv = GetItemCount(item)
				print("Checking item count:", inv, ct, inv<ct)
				if inv < ct then
					-- we don't have enough. abort.
					core:Print(format("We don't have enough |Hitem:%d|h[%s]|h for %s. Needed %d; have %d.", item, GetItemInfo("item:"..item), name, ct, inv))
					ClearSendMail()
					return
				end
				
				-- find container slot with item
				for bag=0,NUM_BAG_SLOTS do
					-- check if we're done
					if ct > 0 then
						for slot=1,GetContainerNumSlots(bag) do
							-- make sure the item we want is this slot
							if GetContainerItemID(bag, slot) == item then
								local _, slotCt, locked = GetContainerItemInfo(bag, slot)
								print("LOOP", GetItemInfo("item:"..item), slotCt, "/", ct, locked)
								if locked then
									-- the item is locked for whatever reason. abort?
									self:Message("|Hitem:%d|h[%s]|h in bag %d, slot %d is locked.", item, GetItemInfo("item:"..item), bag, slot)
									return
								else
									-- if item too many; find empty spot to dump extras
									if slotCt > ct then
										-- check to make sure we can split
										if #emptySlots == 0 then
											print("Not enough bag space to split. Aborting.")
											ClearSendMail()
											core:CancelAllTimers()
											return
										end
										-- pop empty slot off the list
										local extraSpace = table.remove(emptySlots)
										local extraBag, extraSlot = floor(extraSpace/100), extraSpace % 100
										-- split and place
										print("splitting", bag, slot, slotCt-ct)
										SplitContainerItem(bag, slot, slotCt-ct)
										print("extras at", extraBag, extraSlot)
										PickupContainerItem(extraBag, extraSlot) -- place
										
										-- check when lock is clear
										if not next(pushQueue) then
											initializeQueue()
										end
										pushQueue[bag*100+slot] = true -- register source as push target
										ct = 0
										break
									else
										-- item should have enough
										print("adding to mail", bag, slot, ct, slotCt, ct-slotCt)
										PickupContainerItem(bag, slot)
										ClickSendMailItemButton()
										ct = ct - slotCt
										print("and after", ct)
										if ct == 0 then
											break
										end
									end
								end
							end
						end
					end
				end
			end
		end

		-- click send
		self.mailQueue[name] = nil
		-- self:ScheduleTimer(function()
			-- self.mailQueue[name] = nil
			-- ClearSendMail()
			-- self:MailQueueCheck()
		-- end, 5)
		
		mailQueueTimer = nil
	end, delay)
end

local didSetup = false
function core:SetupRBS()
	if didSetup or not RaidBuffStatus or not RaidBuffStatus.frame then 
		return
	end
	didSetup = true
	
	-- register new buttons
	self:NewRBSButton("Flask", function()
		self:FlaskCheck()
	end, 45, "TOPLEFT", "BOTTOMLEFT", 7, 5)
	self:NewRBSButton("Count", function()
		self:Countdown()
	end, 45, "TOP", "BOTTOM", 0, 5)
	self:NewRBSButton("Loot", function()
		self:MasterLoot()
	end, 45, "TOPRIGHT", "BOTTOMRIGHT", -7, 5)
	
	-- reposition old ones
	RaidBuffStatus.readybutton:SetWidth(45)
	RaidBuffStatus.readybutton:SetText("Ready")
	
	-- hook old show/hide
	local rbShow = RaidBuffStatus.readybutton.Show
	RaidBuffStatus.readybutton.Show = function(...)
		RaidBuffStatus.FlaskButton:Show()
		RaidBuffStatus.CountButton:Show()
		RaidBuffStatus.LootButton:Show()
		return rbShow(...)
	end
	local rbHide = RaidBuffStatus.readybutton.Hide
	RaidBuffStatus.readybutton.Hide = function(...)
		RaidBuffStatus.FlaskButton:Hide()
		RaidBuffStatus.CountButton:Hide()
		RaidBuffStatus.LootButton:Hide()
		return rbHide(...)
	end
	
	--[[ fix height
	local heightFix = 25
	RaidBuffStatus.frame:SetHeight(RaidBuffStatus.frame:GetHeight() + heightFix)
	
	-- fix future height
	RaidBuffStatus.frame:SetScript("OnSizeChanged", function(self, width, height)
		-- since this will cause OnSizeChanged to fire again immediately, we use a flag to determine which call it was
		if self.heightFlag then
			self.heightFlag = nil
		else
			self.heightFlag = true
			self:SetHeight(height + heightFix)
		end
	end)]]
end

function core:NewRBSButton(label, func, width, anchorFrom, anchorTo, anchorX, anchorY)
	local button = CreateFrame("Button", "", RaidBuffStatus.frame, "OptionsButtonTemplate")
	button:SetText(label)
	button:SetWidth(width)
	button:SetPoint(anchorFrom, RaidBuffStatus.frame, anchorTo, anchorX, anchorY)
	button:SetScript("OnClick", func)
	button:Show()
	RaidBuffStatus[label.."Button"] = button
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

local lastCache = GetTime()
function core:ModifyRosterPane()
	-- change existing text
	local offlineText = GuildRosterShowOfflineButton:GetRegions()
	if offlineText:GetObjectType() == "FontString" then
		offlineText:SetText("Offline")
	
		-- make a button
		local frame = CreateFrame("CheckButton", "GuildRosterShowRaidersButton", GuildRosterFrame, "UICheckButtonTemplate")
		frame:SetSize(20, 20)
		frame:SetPoint("LEFT", offlineText, "RIGHT", 8, 0)
		frame:SetScript("OnClick", function(check)
			self.rosterRaidersOnly = check:GetChecked()
			HybridScrollFrame_SetOffset(GuildRosterContainer, 0)
			GuildRoster_Update()
			-- reset text to force an update ala Blizzard_GuildUI.lua:72
			local totalMembers, onlineMembers = GetNumGuildMembers()
			GuildFrameMembersCount:SetText(onlineMembers.." / "..totalMembers)
		end)
		local text = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
		text:SetText("Raiders")
		text:SetPoint("LEFT", frame, "RIGHT", 2, 1)
	end
	
	-- hook the members online text set
	local memberSetText = GuildFrameMembersCount.SetText
	GuildFrameMembersCount.SetText = function(self, str, ...)
		if core.rosterRaidersOnly and core.rosterRaidersOnline > 0 then
			str = format("%d / %d", core.rosterRaidersOnline, core.rosterRaidersCount)
		end
		return memberSetText(self, str, ...)
	end
	
	-- cache all raiders
	self:CacheRaiders()
end

function core:CacheRaiders()
	wipe(self.rosterRaidersCache)
	self.rosterRaidersCount = 0
	
	for i=1,GetNumGuildMembers() do
		if self:IsRaider(i) then
			self.rosterRaidersCache[GetGuildRosterInfo(i)] = true
			self.rosterRaidersCount = self.rosterRaidersCount + 1
		end
	end
end

function core:IsRaider(index)
	local name, _, rank, _, _, _, note, _, online = GetGuildRosterInfo(index)
	-- if a raider+ rank, or below and linked to a raider
	-- not name tests for out of bounds check
	if not name or ((rank <= 1) or (rank == 3) or (rank == 5) or ((rank == 4 or rank == 2) and online and self.rosterRaidersCache[note])) then
		return true
	end
	return false
end

local GUILD_ROSTER_MAX_COLUMNS = 5;
local GUILD_ROSTER_MAX_STRINGS = 4;
local GUILD_ROSTER_BAR_MAX = 239;
local GUILD_ROSTER_BUTTON_OFFSET = 2;
local GUILD_ROSTER_BUTTON_HEIGHT = 20;

function core:RosterUpdatePostHook()
	if not self.rosterRaidersOnly then
		return
	end
	if GetTime() - lastCache > 60*5 then
		self:CacheRaiders()
	end
	
	-- begin modified blizzard code
	
	local scrollFrame = GuildRosterContainer;
	local offset = HybridScrollFrame_GetOffset(scrollFrame);
	local buttons = scrollFrame.buttons;
	local numButtons = #buttons;
	local button, index, class;
	local totalMembers, onlineMembers = GetNumGuildMembers();
	local selectedGuildMember = GetGuildRosterSelection();
	local currentGuildView = self.guildView or GuildRosterViewDropdown.selectedValue

	if ( currentGuildView == "tradeskill" ) then
		return;
	end

	local maxWeeklyXP, maxTotalXP = GetGuildRosterLargestContribution();
	local maxAchievementsPoints = GetGuildRosterLargestAchievementPoints();
	-- numVisible
	local visibleMembers = 0;
	for i=1,onlineMembers do
		if self:IsRaider(i) then
			visibleMembers = visibleMembers + 1
		end
	end
	-- copy visibleMembers to local for referencing
	self.rosterRaidersOnline = visibleMembers
	
	if ( GetGuildRosterShowOffline() ) then
		visibleMembers = self.rosterRaidersCount;
	end
	
	
	-- self:Print("Start", visibleMembers, self.rosterRaidersCount)
	local safety = 1000
	local numRaidersDisp = 0
	local i = 1
	local nonMembers = 0
	while i <= numButtons do
		safety = safety - 1
		if safety == 0 then
			error("SAFTEY BROKEN")
			return
		end
		button = buttons[i];
		index = i + nonMembers;
		local name, rank, rankIndex, level, class, zone, note, officernote, online, status, classFileName, achievementPoints, achievementRank, isMobile = GetGuildRosterInfo(index);
		-- self:Print(name, index, rank, note, online, self:IsRaider(index))
		if ( name and i <= visibleMembers) then
			if self:IsRaider(index) then
				-- self:Print(offset, name)
				if offset == 0 then
					i = i + 1
					button.guildIndex = index;
					local displayedName = name;
					if ( isMobile ) then
						displayedName = ChatFrame_GetMobileEmbeddedTexture(119/255, 137/255, 119/255)..displayedName;
					end
					button.online = online;
					if ( currentGuildView == "playerStatus" ) then
						GuildRosterButton_SetStringText(button.string1, level, online)
						button.icon:SetTexCoord(unpack(CLASS_ICON_TCOORDS[classFileName]));
						GuildRosterButton_SetStringText(button.string2, displayedName, online, classFileName)
						GuildRosterButton_SetStringText(button.string3, isMobile and REMOTE_CHAT or zone, online)
					elseif ( currentGuildView == "guildStatus" ) then
						GuildRosterButton_SetStringText(button.string1, displayedName, online, classFileName)
						GuildRosterButton_SetStringText(button.string2, rank, online)
						GuildRosterButton_SetStringText(button.string3, note, online)
						if ( online ) then
							GuildRosterButton_SetStringText(button.string4, GUILD_ONLINE_LABEL, online);					
						else
							GuildRosterButton_SetStringText(button.string4, GuildRoster_GetLastOnline(index), online);
						end
					elseif ( currentGuildView == "weeklyxp" ) then
						local weeklyXP, totalXP, weeklyRank, totalRank = GetGuildRosterContribution(index);
						GuildRosterButton_SetStringText(button.string1, level, online)
						button.icon:SetTexCoord(unpack(CLASS_ICON_TCOORDS[classFileName]));
						GuildRosterButton_SetStringText(button.string2, displayedName, online, classFileName)
						GuildRosterButton_SetStringText(button.string3, weeklyXP, online)
						if ( weeklyXP == 0 ) then
							button.barTexture:Hide();
						else
							button.barTexture:SetWidth(weeklyXP / maxWeeklyXP * GUILD_ROSTER_BAR_MAX);
							button.barTexture:Show();
						end
						GuildRosterButton_SetStringText(button.barLabel, "#"..weeklyRank, online);
					elseif ( currentGuildView == "totalxp" ) then
						local weeklyXP, totalXP, weeklyRank, totalRank = GetGuildRosterContribution(index);
						GuildRosterButton_SetStringText(button.string1, level, online);
						button.icon:SetTexCoord(unpack(CLASS_ICON_TCOORDS[classFileName]));
						GuildRosterButton_SetStringText(button.string2, displayedName, online, classFileName);
						GuildRosterButton_SetStringText(button.string3, totalXP, online);
						if ( totalXP == 0 ) then
							button.barTexture:Hide();
						else
							button.barTexture:SetWidth(totalXP / maxTotalXP * GUILD_ROSTER_BAR_MAX);
							button.barTexture:Show();
						end
						GuildRosterButton_SetStringText(button.barLabel, "#"..totalRank, online);			
					elseif ( currentGuildView == "pve" ) then
						GuildRosterButton_SetStringText(button.string1, level, online);
						button.icon:SetTexCoord(unpack(CLASS_ICON_TCOORDS[classFileName]));
						GuildRosterButton_SetStringText(button.string2, displayedName, online, classFileName);
						GuildRosterButton_SetStringText(button.string3, valor, online);
						GuildRosterButton_SetStringText(button.string4, hero, online);
					elseif ( currentGuildView == "pvp" ) then
						local bgRating, arenaRating, arenaTeam = GetGuildRosterPVPRatings(index);
						GuildRosterButton_SetStringText(button.string1, level, online);
						button.icon:SetTexCoord(unpack(CLASS_ICON_TCOORDS[classFileName]));
						GuildRosterButton_SetStringText(button.string2, displayedName, online, classFileName);
						GuildRosterButton_SetStringText(button.string3, bgRating, online);
						GuildRosterButton_SetStringText(button.string4, string.format(GUILD_ROSTER_ARENA_RATING, arenaRating, arenaTeam, arenaTeam), online);
					elseif ( currentGuildView == "achievement" ) then
						GuildRosterButton_SetStringText(button.string1, level, online);
						button.icon:SetTexCoord(unpack(CLASS_ICON_TCOORDS[classFileName]));
						GuildRosterButton_SetStringText(button.string2, displayedName, online, classFileName);
						if ( achievementPoints >= 0 ) then
							GuildRosterButton_SetStringText(button.string3, achievementPoints, online);
							if ( achievementPoints == 0 ) then
								button.barTexture:Hide();
							else
								button.barTexture:SetWidth(achievementPoints / maxAchievementsPoints * GUILD_ROSTER_BAR_MAX);
								button.barTexture:Show();
							end
						else
							GuildRosterButton_SetStringText(button.string3, NO_ROSTER_ACHIEVEMENT_POINTS, online);
							button.barTexture:Hide();
						end
						GuildRosterButton_SetStringText(button.barLabel, "#"..achievementRank, online);
					end
					button:Show();
					if ( mod(index, 2) == 0 ) then
						button.stripe:SetTexCoord(0.36230469, 0.38183594, 0.95898438, 0.99804688);
					else
						button.stripe:SetTexCoord(0.51660156, 0.53613281, 0.88281250, 0.92187500);
					end
					if ( selectedGuildMember == index ) then
						button:LockHighlight();
					else
						button:UnlockHighlight();
					end
				else
					offset = offset - 1
					nonMembers = nonMembers + 1
				end
			else
				nonMembers = nonMembers + 1
			end			
		else
			-- self:Print("Break", i, visibleMembers, offset + i + nonMembers)
			break
		end
	end
	-- self:Print("End", i, visibleMembers, offset + i + nonMembers)
	for i=i, numButtons do
		buttons[i]:Hide()
	end
	local totalHeight = visibleMembers * (GUILD_ROSTER_BUTTON_HEIGHT + GUILD_ROSTER_BUTTON_OFFSET);
	local displayedHeight = numButtons * (GUILD_ROSTER_BUTTON_HEIGHT + GUILD_ROSTER_BUTTON_OFFSET);
	-- self:Print("Hybrid", scrollFrame, totalHeight, displayedHeight)
	local guildUpdate = GuildRosterContainer.update
	GuildRosterContainer.update = function() end
	HybridScrollFrame_Update(scrollFrame, totalHeight, displayedHeight);
	GuildRosterContainer.update = guildUpdate
end

--[[
-- hook GetNumGuildMembers() second return result?
-- local GetNumGuildMembersHook = GetNumGuildMembers
-- function GetNumGuildMembers()
	-- local total, online = GetNumGuildMembers
-- end

GetGuildRosterInfoHook = GetGuildRosterInfo
local GetGuildRosterInfoHook = GetGuildRosterInfoHook
local function nameNum(ind)
	if ind and GetGuildRosterInfoHook(ind) then
		return format("%s(%d)", GetGuildRosterInfoHook(ind), ind)
	else
		return format("nil(%d)", ind)
	end
end
function GetGuildRosterInfo(index)	
	-- no need
	if not core.rosterRaidersOnly then
		-- core:Print("Request for", index, "FAILED: core.rosterRaidersOnly=",core.rosterRaidersOnly, "  core.inRosterUpdate=", core.inRosterUpdate)
		return GetGuildRosterInfoHook(index)
	end
	
	local cache = core.rosterAlteredCache
	local baseIndex = index -- the ACTUAL index that is mapped to whatever index is
	
	-- check cache
	index = cache[index] or index
	
	isRaider = false
	-- check if raider
	if core:IsRaider(index) then
		-- if they are, set flag
		isRaider = true
	else
		-- if not, begin looking ahead
		for j=baseIndex+1,GetNumGuildMembers() do
			if core:IsRaider(cache[j] or j) then
				-- when you find one, set foundIndex's cache to index and baseIndex's cache to foundIndex's
				core:Print("Swapping",nameNum(baseIndex),"with",nameNum(j))
				cache[j] = index
				cache[baseIndex] = j
				-- and set our locals
				index = j
				isRaider = true
				break
			end
		end
		-- if you don't find one, index is unaltered
	end
	
	core:Print("Request for", nameNum(baseIndex), "returning", nameNum(index), "  isRaider =",isRaider)
	
	-- check flag if they're a raider
	if isRaider or not core.inRosterUpdate then
		-- if true, return actual stuff
		if not GetGuildRosterShowOffline() and core.inRosterUpdate then
			local online = select(9, GetGuildRosterInfoHook(index))
			if not online then
				return nil
			end
		end
		
		return GetGuildRosterInfoHook(index)
	end
	-- if false, return nil
end

function core:IsRaider(index)
	local name, _, rank, _, _, _, note, _, online = GetGuildRosterInfoHook(index)
	-- if a raider+ rank, or below and linked to a raider
	-- not name tests for out of bounds check
	if not name or ((rank <= 1) or (rank == 3) or ((rank == 4 or rank == 2) and online and self.rosterRaidersCache[note])) then
		return true
	end
	return false
end

function core:RosterUpdatePreHook()
	wipe(self.rosterAlteredCache)
	self.inRosterUpdate = true
	if self.rosterRaidersOnly then
		self:Print("Update pre hook")
	end
end

function core:RosterUpdatePostHook()
	self.inRosterUpdate = false
	if self.rosterRaidersOnly then
		self:Print("Update post hook")
	end
end]]

function core:SetupPrat()
	local module = Prat.Addon:GetModule('AltNames')
	Prat.RegisterMessageItem('ALTNAMES', 'PLAYER')
	module.padfmt = '||%s'
	module.setMainPos = function() end

	-- Prevent dropdown menu option from being displayed
	module.menusAdded = true

	-- /run Prat.Addon:ChatFrame_MessageEventHandler(ChatFrame1, "CHAT_MSG_SYSTEM", "Batche has gone offline.", "", "", "", "", "", 0, 0, "", 0, 3991, "", 0, true, false)
	-- PreAddMessage hook to limit main print to 3 characters and make sure player is added for logouts
	local PreAddMessage = module.Prat_PreAddMessage
	module.Prat_PreAddMessage = function(self, e, message, frame, event, ...)
		-- check to see if we have a log off
		if event == "CHAT_MSG_SYSTEM" then
			-- .MESSAGE contains modified message with color, .OUTPUT contains raw
			local p, m = message.OUTPUT:match("(%S+)( has gone offline.*)")
			if p then
				local class = Prat.Addon:GetModule('PlayerNames'):GetData(p)
				-- inline coloring won't work (fires before) so we do it manually
				-- set PLAYERLINK for AltNames to read
				message.MESSAGE, message.PLAYER, message.PLAYERLINK = m, Prat.CLR:Player(p, p:lower(), class), p
			end
		end

		-- call normal
		PreAddMessage(self, e, message, frame, event, ...) 

		-- unset PLAYERLINK if we have a log off so as not to have it display
		if not message.lL or message.lL == "" then
			message.PLAYERLINK = nil
		end

		-- limit to 3 characters in the main
		if message.ALTNAMES and message.ALTNAMES ~= "" then
			-- 12 characters of color padding; so sub(1, 12+length)
			self.ALTNAMES = self.ALTNAMES:sub(1, 15).."|r"
			message.ALTNAMES = self.ALTNAMES
		end
	end
end

function core:BugInit()
	local f = CreateFrame("frame")
	f:SetSize(50, 50)
	f:SetPoint("CENTER")
	f:SetScript("OnMouseUp", function()
		f.finish:Play()
		f:SetScript("OnMouseUp", nil)
	end)

	f.s = f:CreateFontString(nil, nil, "SystemFont_Outline_Small")
	f.s:SetText("Test")
	f.s:SetPoint("CENTER")

	f.t = f:CreateTexture()
	f.t:SetTexture(0, 0, 0)
	f.t:SetAlpha(0.5)
	f.t:SetAllPoints()

	f.finish = f:CreateAnimationGroup()

	-- f.finishAlpha = f.finish:CreateAnimation("Alpha")
	-- f.finishAlpha:SetChange(-1)
	-- f.finishAlpha:SetDuration(.85)

	f.finishScale = f.finish:CreateAnimation("Scale")
	f.finishScale:SetScale(2, 2)
	f.finishScale:SetDuration(.85)

	f.finish:SetScript("OnPlay", function()
		-- f.s:Hide()
	end)
	f.finish:SetScript("OnFinished", function()
		-- f.s:Show()
		local t = GetTime()
		f:SetScript("OnUpdate", function()
			if GetTime()-t > 0.5 then
				f.finish:Play()
				f:SetScript("OnUpdate", nil)
			end
		end)
	end)

	g_f = f
end

function core:Nostromo()
	local keys = {"W", "A", "S", "D"}
	local xVal = {1, 0, 1, 2}
	local yVal = {0, 1, 1, 1}
	local width, height = 50, 50
	local padding = 10
	local offsetX, offsetY = -1.5, 3
	core.frameSet = {}

	for i in ipairs(keys) do
		local frame = CreateFrame("frame", UIParent)
		frame:SetSize(width, height)
		frame:SetPoint("CENTER", UIParent, "CENTER", (offsetX + xVal[i])*width + padding*xVal[i], (offsetY - yVal[i])*height - padding*yVal[i])
		frame:EnableKeyboard(false)

		local texture = frame:CreateTexture()
		texture:SetAllPoints()
		texture:SetTexture(0, 0, 0)
		texture:SetAlpha(0.4)

		if false then
			frame:SetScript("onkeydown", function(self, key)
				if key == keys[i] then
					texture:SetAlpha(0.8)
				end
			end)
			frame:SetScript("onkeyup", function(self, key)
				if key == keys[i] then
					texture:SetAlpha(0.4)
				end
			end)
		end

		table.insert(core.frameSet, frame)
	end
end

-- creates a text string and hooks every CLEU to try and find a problematic addon
function core:SetupAddonDebug()
	local frame = CreateFrame("frame")
	frame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", self.db.profile.addonDebug.x, self.db.profile.addonDebug.y)
	frame:SetSize(100, 30)
	frame:EnableMouse(true)
	frame:SetMovable(true)
	frame:SetClampedToScreen(true)
	frame:RegisterForDrag("LeftButton")
	frame:SetScript("OnDragStart", function(self)
		self:StartMoving()
	end)
	frame:SetScript("OnDragStop", function(self)
		self:StopMovingOrSizing()
		core.db.profile.addonDebug.x = self:GetLeft()
		core.db.profile.addonDebug.y = self:GetTop()
	end)

	local text = frame:CreateFontString(nil, nil, "GameFontNormal")
	text:SetAllPoints()
	text:SetText("TEST")
	text:SetJustifyH("RIGHT")

	-- non ace
    local events = {GetFramesRegisteredForEvent("COMBAT_LOG_EVENT_UNFILTERED")}
	for _,f in ipairs(events) do
		if f ~= AceEvent30Frame then
			local name = f:GetName() or f.name or tostring(f)
			self:RawHookScript(f, "OnEvent", function(frame, event, ...)
				if event == "COMBAT_LOG_EVENT_UNFILTERED" then
					text:SetText(name)
					self.hooks[f].OnEvent(frame, event, ...)
					text:SetText("")
				end
			end)
		end
	end

	-- ace
	local CLEU = LibStub:GetLibrary("AceEvent-3.0").events.events.COMBAT_LOG_EVENT_UNFILTERED
	if CLEU then
		for addon, event in pairs(CLEU) do
			local old = CLEU[addon]
			CLEU[addon] = function(...)
				text:SetText(addon.name or tostring(addon))
				old(...)
				text:SetText("")
			end
		end
	end
end

function core:GUILDBANKFRAME_OPENED()
	-- local numTabs = GetNumGuildBankTabs()
	-- for tab = 1, numTabs do
	-- 	self:ScheduleTimer(function()QueryGuildBankTab(tab)end, tab)
	-- end
end

local function my_hash(key, ...)
	local i, j, str;
	for i=1,select('#', ...) do
		j=0;
		str=select(i, ...);
		key = key:gsub(".", function(k)
			j = (j % strlen(str))+1;
			return strchar((strbyte(k,1)*strbyte(str,j)) % 256);
		end);
	end
	i=0;
	for j=1,strlen(key) do
		i = (i + strbyte(key,j)) % 100;
	end
	return i;
end

local chatEvents = {
	"CHAT_MSG_ACHIEVEMENT",
	"CHAT_MSG_ADDON",
	"CHAT_MSG_AFK",
	"CHAT_MSG_BATTLEGROUND",
	"CHAT_MSG_BATTLEGROUND_LEADER",
	"CHAT_MSG_BG_SYSTEM_ALLIANCE",
	"CHAT_MSG_BG_SYSTEM_HORDE",
	"CHAT_MSG_BG_SYSTEM_NEUTRAL",
	"CHAT_MSG_BN_CONVERSATION",
	"CHAT_MSG_BN_CONVERSATION_LIST",
	"CHAT_MSG_BN_CONVERSATION_NOTICE",
	"CHAT_MSG_BN_INLINE_TOAST_ALERT",
	"CHAT_MSG_BN_INLINE_TOAST_BROADCAST",
	"CHAT_MSG_BN_INLINE_TOAST_BROADCAST_INFORM",
	"CHAT_MSG_BN_INLINE_TOAST_CONVERSATION",
	"CHAT_MSG_BN_WHISPER",
	"CHAT_MSG_BN_WHISPER_INFORM",
	"CHAT_MSG_CHANNEL",
	"CHAT_MSG_CHANNEL_JOIN",
	"CHAT_MSG_CHANNEL_LEAVE",
	"CHAT_MSG_CHANNEL_LIST",
	"CHAT_MSG_CHANNEL_NOTICE",
	"CHAT_MSG_CHANNEL_NOTICE_USER",
	"CHAT_MSG_COMBAT_FACTION_CHANGE",
	"CHAT_MSG_COMBAT_GUILD_XP_GAIN",
	"CHAT_MSG_COMBAT_HONOR_GAIN",
	"CHAT_MSG_COMBAT_MISC_INFO",
	"CHAT_MSG_COMBAT_XP_GAIN",
	"CHAT_MSG_DND",
	"CHAT_MSG_EMOTE",
	"CHAT_MSG_FILTERED",
	"CHAT_MSG_GUILD",
	"CHAT_MSG_GUILD_ACHIEVEMENT",
	"CHAT_MSG_IGNORED",
	"CHAT_MSG_LOOT",
	"CHAT_MSG_MONEY",
	"CHAT_MSG_MONSTER_EMOTE",
	"CHAT_MSG_MONSTER_PARTY",
	"CHAT_MSG_MONSTER_SAY",
	"CHAT_MSG_MONSTER_WHISPER",
	"CHAT_MSG_MONSTER_YELL",
	"CHAT_MSG_OFFICER",
	"CHAT_MSG_OPENING",
	"CHAT_MSG_PARTY",
	"CHAT_MSG_PARTY_LEADER",
	"CHAT_MSG_PET_INFO",
	"CHAT_MSG_RAID",
	"CHAT_MSG_RAID_BOSS_EMOTE",
	"CHAT_MSG_RAID_BOSS_WHISPER",
	"CHAT_MSG_RAID_LEADER",
	"CHAT_MSG_RAID_WARNING",
	"CHAT_MSG_RESTRICTED",
	"CHAT_MSG_SAY",
	"CHAT_MSG_SKILL",
	"CHAT_MSG_SYSTEM",
	"CHAT_MSG_TARGETICONS",
	"CHAT_MSG_TEXT_EMOTE",
	"CHAT_MSG_TRADESKILLS",
	"CHAT_MSG_WHISPER",
	"CHAT_MSG_WHISPER_INFORM",
	"CHAT_MSG_YELL",
}
local contentFilters = { }
local sourceFilters = { }

function core:FilterAll(filter, source)
	if filter or source then
		if not next(contentFilters) then
			for _,v in ipairs(chatEvents) do
				ChatFrame_AddMessageEventFilter(v, function(self, event, msg, sender)
					if sourceFilters[sender] then
						return true
					end
					for filter in pairs(contentFilters) do
						if (filter and msg:find(filter)) then
							return true
						end
					end
				end)
			end
		end
		
		if filter then contentFilters[filter] = true end
		if source then sourceFilters[source] = true end
	end
end

-- core:FilterAll("achievement:284")
core:FilterAll(nil, "Alabrooke")
core:FilterAll(nil, "Warrwarr")
-- core:FilterAll("achievement:284")

-- test fix
--[[local addon = CreateFrame("frame", "HorsemanSummonFix");
  
function HorsemanSummonFix_ZoneChange()
	if((GetSubZoneText() == "Forlorn Cloister")) then
		GameTooltip.temp = function() GameTooltip:Hide() end;  
		GameTooltip:SetScript("OnShow",GameTooltip.temp);
	else
		GameTooltip:SetScript("OnShow",GameTooltip.Show);
	end
end
 
addon:SetScript("OnEvent", HorsemanSummonFix_ZoneChange);
addon:RegisterEvent("ZONE_CHANGED");
addon:RegisterEvent("ZONE_CHANGED_NEW_AREA");
HorsemanSummonFix_ZoneChange();]]
