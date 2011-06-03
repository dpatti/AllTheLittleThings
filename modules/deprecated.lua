-- These are here for historical purposes only -- do not include in .toc
local core = LibStub("AceAddon-3.0"):GetAddon("AllTheLittleThings")
local mod = core:NewModule("Deprecated", "AceEvent-3.0")
local db

local defaults = {
	macroSwap = false,
}
local options = {
	macroSwap = {
		name = "Flame Caps for Lich King",
		desc = "Swaps the macro to use Flame Caps for HLK",
		type = 'toggle',
	},
}

function mod:OnInitialize()
	self:RegisterOptions(options, defaults, function(d) db=d end)
	self:RegisterSlashCommand("method", "slsh1", "slash2")
end

-- Lich King Flame Cap Macro ---------------------------------------------------
local macro = "MI+FC";
function mod:ZoneChange()
	if (db.macroSwap and UnitName("player")=="Chira" and GetMacroIndexByName(macro)>0) then
		if (GetSubZoneText() == "The Frozen Throne" and self:GetMode()>3) then
			EditMacro(GetMacroIndexByName(macro), nil, nil, GetMacroBody(macro):gsub("Flame Caq", "Flame Cap"));
		else
			EditMacro(GetMacroIndexByName(macro), nil, nil, GetMacroBody(macro):gsub("Flame Cap", "Flame Caq"));
		end
	end
end

function mod:GetMode()
	local _, _, diff, _, _, dynHeroic, dynFlag = GetInstanceInfo(); 
	return diff; -- (dynFlag and (2-(diff%2)+2*dynHeroic)) or diff; 
end

-- Attempt to monitor n52 problem ----------------------------------------------
function mod:Nostromo()
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
function mod:SetupAddonDebug()
	local frame = CreateFrame("frame")
	frame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", db.addonDebug.x, db.addonDebug.y)
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
		db.addonDebug.x = self:GetLeft()
		db.addonDebug.y = self:GetTop()
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

-- Bug with text in animations -------------------------------------------------
function mod:BugInit()
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
end

-- Experimental hash function --------------------------------------------------
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

-- Saampson Shards and Deathblood Venom deposit --------------------------------
function mod:CHAT_MSG_LOOT(_, message, source)
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

-- Consolidate Thresh
function mod:UnitAura(...)
	name, rank, icon, count, dispelType, duration, expires, caster, isStealable, shouldConsolidate, spellID = self.hooks["UnitAura"](...)
	if expires and (db.consolidateThresh > 0) then
		if ((expires-GetTime())/60 > db.consolidateThresh) or (name:find("Aura") or name:find("Totem")) or (shouldConsolidate == 1) then
			shouldConsolidate = 1
		else
			shouldConsolidate = nil
		end
	end
	
	return name, rank, icon, count, dispelType, duration, expires, caster, isStealable, shouldConsolidate, spellID
end


-- Slash Commands
function mod:SlashProcess(msg)
	if msg == "ilevel" or msg == "il" then
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
	elseif msg == "markxp" then
		-- write all current
		local db = db.guildXPMarks or {}
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
		local set = setNum and db.guildXPMarks[setNum]
		
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


-- Hallow's end
self.hallowBuff = nil
function mod:UNIT_AURA(_, unit)
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
			db.halloween = db.halloween + 1;
			-- pick transitive
			local transitive = TRANSITIVES[math.random(#TRANSITIVES)];
			self:Print(format("I will %s %d babies this year", transitive, db.halloween))
			self.hallowBuff = true;
		end
	end
end

-- Dedicated Insanity info -----------------------------------------------------
-- local DedicatedInsanity = {46017,47069,47079,47082,47093,47072,47073,47090,47071,47094,47081,47092,47070,47080,47104,47138,47114,47121,47142,47108,47106,47107,47140,47126,47139,47116,47148,47193,47233,47150,47234,47195,47184,47204,47151,47186,47235,47183,47194,47187,47225,47203,47054,47182,46958,46976,46985,46996,46994,46979,46963,46962,46997,47052,47057,46999,46961,46960,47083,46990,47152,47056,47000,46988,46974,47055,46992,47051,46972,47141,47042,47043,47041,47115,46959,47053,49500,49494,49465,49493,49490,49496,49497,49499,49495,49501,49498,49466,49467,49474,49475,49476,49478,49479,49480,49468,49469,49470,49471,49472,49473,49477,49481,49482,49483,49484,49491,49489,49492,49464,49488,47078,47085,47086,47098,47076,47074,47087,47099,47077,47096,47084,47097,47095,47075,47088,47001,47156,46995,46980,46969,47113,47521,47206,47526,47519,47239,46964,47130,47524,47525,47517,47506,47515,46968,47147,46986,47003,47154,47240,47061,47067,47132,47002,47207,46967,47111,46965,47209,47109,47191,46991,47153,47068,47004,46989,46975,47190,47112,47145,47066,47155,46993,47129,47205,47236,47062,47189,46973,47143,47208,46971,46977,47063,47192,47238,47545,47547,47549,47552,47553,47237,47060,47110,47133,47144,47059,47131,47188,47224,47157,46966,47146,47064,
-- 42210,42229,42234,42244,42250,42257,42262,42267,42272,42277,42282,42287,42292,42319,42324,42329,42334,42348,42354,42366,42386,42392,42483,42487,42492,42498,42504,42515,42521,44423,44424,48402,48404,48406,48408,48410,48412,48414,48420,48422,48424,48426,48428,48432,48435,48438,48440,48442,48444,48507,48509,48511,48513,48515,48517,48519,48521,48523,49185,49189,49191,
-- 40790,40791,40792,40810,40811,40812,40829,40830,40831,40850,40851,40852,40870,40871,40872,40883,40884,40890,40910,40928,40934,40940,40964,40978,40979,40984,40994,40995,41002,41008,41014,41020,41028,41034,41039,41045,41052,41056,41061,41066,41071,41076,41082,41088,41138,41144,41152,41158,41200,41206,41212,41218,41226,41231,41236,41276,41282,41288,41294,41299,41305,41311,41317,41322,41328,41618,41622,41626,41631,41636,41641,41651,41656,41662,41668,41673,41679,41684,41716,41768,41774,41833,41837,41841,41855,41860,41865,41870,41875,41882,41886,41894,41899,41904,41910,41916,41922,41928,41935,41941,41947,41954,41960,41966,41972,41994,41999,42006,42012,42018,42041,42042,42043,42044,42045,42046,42047,42076,42077,42078,42079,42080,42081,42082,42118,42119,42527,42533,42539,42561,42566,42572,42580,42585,42591,42599,42604,42609,42616,42622,42854,46374,49086,49179,49181,49183,49187,
-- 48646,48645,48644,48643,48642,48616,48615,48614,48613,48612,48584,48583,48582,48581,48580,48547,48546,48545,48544,48543,48490,48489,48488,48487,48486,48455,48453,48451,48447,48433,48385,48384,48383,48382,48381,48355,48354,48353,48352,48351,48325,48324,48323,48322,48321,48294,48293,48292,48291,48290,48264,48263,48262,48261,48260,48232,48231,48230,48229,48228,48207,48206,48205,48204,48203,48172,48171,48170,48169,48168,48142,48141,48140,48139,48138,48086,48085,48084,48083,48082,48037,48035,48033,48031,48029,47792,47791,47790,47789,47788,47762,47761,47760,47759,47758,
-- }

-- Used these for debugging auto complete problem ------------------------------
function ChatHooky(func)
	if not _G[func] then return end

	local old = _G[func]
	_G[func] = function(...)
		print("----"..func.."----")

		local t = ...
		if t == ChatFrame1EditBox then
			print("Before GetText():", t:GetText())
		end

		print("Params:", ...)
		local r = old(...)
		print("Return value:", r)

		if t == ChatFrame1EditBox then
			print("After GetText():", t:GetText())
		end

		print("----/"..func.."----")

		return r
	end
end
-- ChatHooky("ChatEdit_ParseText")
-- ChatHooky("ChatEdit_SendText")
-- ChatHooky("ChatEdit_HandleChatType")
-- ChatHooky("ChatEdit_ExtractTellTarget")


