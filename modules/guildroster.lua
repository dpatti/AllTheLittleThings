local core = LibStub("AceAddon-3.0"):GetAddon("AllTheLittleThings")
local mod = core:NewModule("GuildRoster", "AceEvent-3.0", "AceHook-3.0")
local db

local defaults = {
	easyInvites = true,
}
local options = {
	easyInvites = {
		name = "Easy Raid Invites",
		desc = "Colors names and allows you to alt+click to invite.",
		type = "toggle",
	},
}

local guildView = nil
local rosterRaidersOnly = false
local rosterRaidersCache = {} -- mains who are raiders
local rosterRaidersCount = 0
local rosterRaidersOnline = 0

function mod:OnInitialize()
	self:RegisterOptions(options, defaults, function(d) db=d end)
end

function mod:OnEnable()
	self:RegisterEvent("RAID_ROSTER_UPDATE")
	self:RegisterEvent("ADDON_LOADED")
end

function mod:ADDON_LOADED(_, name)
	if name == "Blizzard_GuildUI" then
		self:SecureHook("GuildRoster_SetView")
		self:SecureHook("GuildRoster_Update")
		self:SecureHook(GuildRosterContainer, "update", "GuildRoster_Update")
		local buttons = GuildRosterContainer.buttons
		for i=1, #buttons do
			buttons[i].stripe.texture = buttons[i].stripe:GetTexture()
			self:RawHookScript(buttons[i], "OnClick", "GuildRosterButton_OnClick")
		end
		-- self:RawHook("GuildRosterButton_OnClick", true)
		self:UnregisterEvent("ADDON_LOADED")

		-- modify physical guild pane
		-- change existing text
		local offlineText = GuildRosterShowOfflineButton:GetRegions()
		if offlineText:GetObjectType() == "FontString" then
			offlineText:SetText("Offline")
		
			-- make a button
			local frame = CreateFrame("CheckButton", "GuildRosterShowRaidersButton", GuildRosterFrame, "UICheckButtonTemplate")
			frame:SetSize(20, 20)
			frame:SetPoint("LEFT", offlineText, "RIGHT", 8, 0)
			frame:SetScript("OnClick", function(check)
				rosterRaidersOnly = check:GetChecked()
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
			if rosterRaidersOnly and rosterRaidersOnline > 0 then
				str = format("%d / %d", rosterRaidersOnline, rosterRaidersCount)
			end
			return memberSetText(self, str, ...)
		end
		
		-- cache all raiders
		self:CacheRaiders()
	end
end

function mod:RAID_ROSTER_UPDATE()
	if (_G["GuildRoster_Update"]) then
		self:GuildRoster_Update()
	end
end

function mod:GuildRoster_SetView(view)
	guildView = view
end

function mod:GuildRoster_Update()
	self:RosterUpdatePostHook()
	
	local view = guildView or GuildRosterViewDropdown.selectedValue
	local buttons = GuildRosterContainer.buttons
	local offset = HybridScrollFrame_GetOffset(GuildRosterContainer);
	for i=1, #buttons do
		local stripe = buttons[i].stripe
		if stripe.texture then
			stripe:SetTexture(stripe.texture)
		end
		
		if (UnitInRaid("player") and db.easyInvites) then
			if buttons[i].guildIndex then
				name = GetGuildRosterInfo(buttons[i].guildIndex)
				if name and UnitInRaid(name) and (view == "playerStatus" or view == "guildStatus") then
					buttons[i].stripe:SetTexture(1, 0.5, 0, 0.3)
				end
			end
		end
	end
end

local lastCache = GetTime()
function mod:ModifyRosterPane()
end

function mod:CacheRaiders()
	wipe(rosterRaidersCache)
	rosterRaidersCount = 0
	
	for i=1,GetNumGuildMembers() do
		if self:IsRaider(i) then
			rosterRaidersCache[GetGuildRosterInfo(i)] = true
			rosterRaidersCount = rosterRaidersCount + 1
		end
	end
end

function mod:IsRaider(index)
	local name, _, rank, _, _, _, note, _, online = GetGuildRosterInfo(index)
	-- if a raider+ rank, or below and linked to a raider
	-- not name tests for out of bounds check
	if not name or ((rank <= 1) or (rank == 3) or (rank == 5) or ((rank == 4 or rank == 2) and online and rosterRaidersCache[note])) then
		return true
	end
	return false
end
local GUILD_ROSTER_MAX_COLUMNS = 5;
local GUILD_ROSTER_MAX_STRINGS = 4;
local GUILD_ROSTER_BAR_MAX = 239;
local GUILD_ROSTER_BUTTON_OFFSET = 2;
local GUILD_ROSTER_BUTTON_HEIGHT = 20;

function mod:RosterUpdatePostHook()
	if not rosterRaidersOnly then
		return
	end
	if GetTime() - lastCache > 60*5 then
		self:CacheRaiders()
		lastCache = GetTime()
	end
	
	-- begin modified blizzard code
	
	local scrollFrame = GuildRosterContainer;
	local offset = HybridScrollFrame_GetOffset(scrollFrame);
	local buttons = scrollFrame.buttons;
	local numButtons = #buttons;
	local button, index, class;
	local totalMembers, onlineMembers = GetNumGuildMembers();
	local selectedGuildMember = GetGuildRosterSelection();
	local currentGuildView = guildView or GuildRosterViewDropdown.selectedValue

	if ( currentGuildView == "tradeskill" ) then
		return;
	end

	local maxWeeklyXP, maxTotalXP = GetGuildRosterLargestContribution();
	local maxAchievementsPoints = GetGuildRosterLargestAchievementPoints();
	-- numVisible
	local visibleMembers, onlineRaiders = 0, 0
	local numMembers = GetGuildRosterShowOffline() and totalMembers or onlineMembers
	for i=1,numMembers do
		if self:IsRaider(i) then
			visibleMembers = visibleMembers + 1
			if select(9, GetGuildRosterInfo(i)) then
				onlineRaiders = onlineRaiders + 1
			end
		end
	end
	-- copy visibleMembers to local for referencing
	rosterRaidersOnline = onlineRaiders
	
	-- self:Print("Start", visibleMembers, rosterRaidersCount)
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
					if ( index % 2 == 0 ) then
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
	if rosterRaidersOnline > 0 then
		-- Shouldn't need to pass a string
		GuildFrameMembersCount:SetText()
	end
end

function mod:GuildRosterButton_OnClick(this, button, ...)
	if db.easyInvites and IsAltKeyDown() then
		local guildIndex = this.guildIndex
		local name, _, _, _, _, _, _, _, online = GetGuildRosterInfo(guildIndex)
		if online then
			InviteUnit(name)
		end
	else
		self.hooks[this].OnClick(this, button, ...)
	end
end

-- Old attempt -----------------------------------------------------------------
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
	if not mod.rosterRaidersOnly then
		-- mod:Print("Request for", index, "FAILED: mod.rosterRaidersOnly=",mod.rosterRaidersOnly, "  mod.inRosterUpdate=", mod.inRosterUpdate)
		return GetGuildRosterInfoHook(index)
	end
	
	local cache = mod.rosterAlteredCache
	local baseIndex = index -- the ACTUAL index that is mapped to whatever index is
	
	-- check cache
	index = cache[index] or index
	
	isRaider = false
	-- check if raider
	if mod:IsRaider(index) then
		-- if they are, set flag
		isRaider = true
	else
		-- if not, begin looking ahead
		for j=baseIndex+1,GetNumGuildMembers() do
			if mod:IsRaider(cache[j] or j) then
				-- when you find one, set foundIndex's cache to index and baseIndex's cache to foundIndex's
				mod:Print("Swapping",nameNum(baseIndex),"with",nameNum(j))
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
	
	mod:Print("Request for", nameNum(baseIndex), "returning", nameNum(index), "  isRaider =",isRaider)
	
	-- check flag if they're a raider
	if isRaider or not mod.inRosterUpdate then
		-- if true, return actual stuff
		if not GetGuildRosterShowOffline() and mod.inRosterUpdate then
			local online = select(9, GetGuildRosterInfoHook(index))
			if not online then
				return nil
			end
		end
		
		return GetGuildRosterInfoHook(index)
	end
	-- if false, return nil
end

function mod:IsRaider(index)
	local name, _, rank, _, _, _, note, _, online = GetGuildRosterInfoHook(index)
	-- if a raider+ rank, or below and linked to a raider
	-- not name tests for out of bounds check
	if not name or ((rank <= 1) or (rank == 3) or ((rank == 4 or rank == 2) and online and rosterRaidersCache[note])) then
		return true
	end
	return false
end

function mod:RosterUpdatePreHook()
	wipe(rosterAlteredCache)
	inRosterUpdate = true
	if rosterRaidersOnly then
		self:Print("Update pre hook")
	end
end

function mod:RosterUpdatePostHook()
	inRosterUpdate = false
	if rosterRaidersOnly then
		self:Print("Update post hook")
	end
end]]
