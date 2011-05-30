local core = LibStub("AceAddon-3.0"):GetAddon("AllTheLittleThings")
local mod = core:NewModule("Chat Filter")
local db = core.db.profile[mod:GetName()]

local defaults = {
}
local options = {
	filterOn = {
		name = "Filter On",
		desc = "Filters things I don't want",
		type = 'toggle',
	},
}

function mod:OnInitialize()
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
	if not db.filterOn then return end

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
