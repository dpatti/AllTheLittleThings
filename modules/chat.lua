local core = LibStub("AceAddon-3.0"):GetAddon("AllTheLittleThings")
local mod = core:NewModule("Chat")
local db

local LOOT_ALL, LOOT_ROLL, LOOT_RESULT = 1, 2, 3
local defaults = {
	nixAFK = true,
	markMsgFilter = true,
    lootRoll = LOOT_ROLL,
}
local options = {
	nixAFK = {
		name = "Remove AFK Responses",
		desc = "Removes AFK responses when whispering AFK players.",
		type = "toggle",
	},
	markMsgFilter = {
		name = "Mark Message Filter",
		desc = "Filters mark messages caused by the player.",
		type = 'toggle',
	},
    lootRoll = {
        name = "Loot Roll Display",
        desc = "How to display loot info when using a rolling loot method.",
        type = 'select',
        values = {
            [LOOT_ALL]    = "Show All",
            [LOOT_ROLL]   = "Only Rolls",
            [LOOT_RESULT] = "Only Results",
        },
    },
}

function mod:OnInitialize()
	self:RegisterOptions(options, defaults, function(d) db=d end)
end

function mod:OnEnable()
	-- nix afk
	ChatFrame_AddMessageEventFilter("CHAT_MSG_AFK", function(...) return self:NixAFK(...) end)

	-- filter self targets
	ChatFrame_AddMessageEventFilter("CHAT_MSG_TARGETICONS", function(_,_,msg) if (msg:find("%["..UnitName("player").."%]")) then return true end end)

    -- Tarecgosa staff spam
    ChatFrame_AddMessageEventFilter("CHAT_MSG_TEXT_EMOTE", function(self, event, msg)
        return msg == "The warm embrace of Tarecgosa's presence encircles you."
    end)

    -- Loot rolls
    ChatFrame_AddMessageEventFilter("CHAT_MSG_LOOT", function(_, _, msg, ...) return self:LootFilter(msg, ...) end)
end

function mod:NixAFK(_, _, ...)
	return (not not db.nixAFK), ...
end

local lastRoll = {}     -- map of name -> roll number
local lastChoice = {}   -- map of name -> roll choice
function mod:LootFilter(message, ...)
    -- If we are showing all details, just let it through
    if db.lootRoll == LOOT_ALL then
        return false
    end

    -- If it's a choice (Chira has selected Green for: [item]), hide it
    if message:find("ha[sve]+ selected") or message:find("passed on: ") then
        -- print("CHOICE")
        return true
    end

    -- If it's a roll, hide if LOOT_RESULT
    local choice, roll, name = message:match("(%w+) Roll %- (%d+) for .+ by (.+)")
    if db.lootRoll == LOOT_RESULT and name and roll then
        -- print("ROLL", name, roll, choice)
        lastRoll[name] = roll
        lastChoice[name] = choice
        return true
    end

    -- If it's a win event, alter if LOOT_RESULT
    local name = message:match("(%w+) won: ")
    if name == "You" then
        name = UnitName("player")
    end
    if db.lootRoll == LOOT_RESULT and name then
        -- print("RESULT", name)
        return false, ("%s |cff999999(%s - %d)|r"):format(message, lastChoice[name] or "", lastRoll[name] or 0), ...
    end
end

-- You can use this to filter every source containing a string {{{
local chatEvents = { "ACHIEVEMENT","ADDON","AFK","BATTLEGROUND","BATTLEGROUND_LEADER","BG_SYSTEM_ALLIANCE","BG_SYSTEM_HORDE","BG_SYSTEM_NEUTRAL","BN_CONVERSATION","BN_CONVERSATION_LIST","BN_CONVERSATION_NOTICE","BN_INLINE_TOAST_ALERT","BN_INLINE_TOAST_BROADCAST","BN_INLINE_TOAST_BROADCAST_INFORM","BN_INLINE_TOAST_CONVERSATION","BN_WHISPER","BN_WHISPER_INFORM","CHANNEL","CHANNEL_JOIN","CHANNEL_LEAVE","CHANNEL_LIST","CHANNEL_NOTICE","CHANNEL_NOTICE_USER","COMBAT_FACTION_CHANGE","COMBAT_GUILD_XP_GAIN","COMBAT_HONOR_GAIN","COMBAT_MISC_INFO","COMBAT_XP_GAIN","DND","EMOTE","FILTERED","GUILD","GUILD_ACHIEVEMENT","IGNORED","LOOT","MONEY","MONSTER_EMOTE","MONSTER_PARTY","MONSTER_SAY","MONSTER_WHISPER","MONSTER_YELL","OFFICER","OPENING","PARTY","PARTY_LEADER","PET_INFO","RAID","RAID_BOSS_EMOTE","RAID_BOSS_WHISPER","RAID_LEADER","RAID_WARNING","RESTRICTED","SAY","SKILL","SYSTEM","TARGETICONS","TEXT_EMOTE","TRADESKILLS","WHISPER","WHISPER_INFORM","YELL" }
local contentFilters = { }
local sourceFilters = { }
function mod:FilterAll(filter, source)
	if filter or source then
		if not next(contentFilters) then
			-- first time registry
			for _,v in ipairs(chatEvents) do
				ChatFrame_AddMessageEventFilter(v, function(self, event, msg, sender)
					if not db.filterOn then return end
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
-- }}}
