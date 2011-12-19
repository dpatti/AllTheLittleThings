local core = LibStub("AceAddon-3.0"):GetAddon("AllTheLittleThings")
local mod = core:NewModule("Announce", "AceEvent-3.0", "AceTimer-3.0")
local db

local defaults = {
	interrupt = false,
	spellWatch = true,
	cauterize = "",
	armorGlyph = true,
    tbWatch = true,
}
local options = {
	interrupt = {
		name = "Interrupt printing",
		desc = "Toggles printing what you interrupted in party chat",
		type = "toggle",
	},
	spellWatch = {
		name = "Print important spells",
		desc = "Prints MD, ToTT, and taunts to ncafail",
		type = 'toggle',
	},
	cauterize = {
		name = "Cauterize Save",
		desc = "Tells target when my Cauterize saves me",
		type = 'input',
	},
	armorGlyph = {
		name = "Alert for unglyphed armor",
		desc = "Prints to self if an armor that is not glyphed was gained",
		type = 'toggle',
	},
    tbWatch = {
		name = "Tol Barad Control Shift",
		desc = "Prints to self when Tol Barad shifts control to player's faction",
		type = 'toggle',
    },
}

local interruptCasted = false
local zoneBlacklist = {
	["Wintergrasp"] = true,
	["Tol Barad"] = true,
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
}
local armorGlyphs = {
	[30482] = 56382,	 -- Molten Armor
	[6117]	= 56383,	 -- Mage Armor
}

function mod:OnInitialize()
	self:RegisterOptions(options, defaults, function(d) db=d end)
end

function mod:OnEnable()
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

    -- TB Watch
    self:TolBaradWatch()
end

function mod:COMBAT_LOG_EVENT_UNFILTERED(_, timestamp, event, _, srcGUID, srcName, srcFlags, _, dstGUID, dstName, dstFlags, _, spellid, spellName, spellSchool, extraSpellid, extraSpellName, ...)
	-- Interrupt ------------------------------------------------------------------
	if db.interrupt and GetNumPartyMembers()>0 then
		if event == "SPELL_INTERRUPT" and srcName == UnitName("player") then
			SendChatMessage("Interrupted " .. dstName .. "'s " .. extraSpellName, "party")
			interruptCasted = false
		end
		if (event == "SPELL_MISSED" or event == "SPELL_HIT") and srcName == UnitName("player") and spellName == "Counterspell" then
			SendChatMessage("Counterspell missed", "party")
			interruptCasted = false
		end
		if event == "SPELL_CAST_SUCCESS" and srcName == UnitName("player") and spellName == "Counterspell" then
			interruptCasted = true
			self:ScheduleTimer(function() if interruptCasted == true then 
				SendChatMessage("Counterspell failed", "party")
				interruptCasted = false
			end end, 0.3)
		end					
	end

	-- Spell Watch ----------------------------------------------------------------
	if (db.spellWatch and (UnitInRaid(srcName) or UnitInParty(srcName)) and (not UnitInBattleground("player")) and not zoneBlacklist[GetRealZoneText()]) then
		-- Special case for gripping Living Meteors on Ragnaros
		if (dstName == "Living Meteor") then
			return
		end
		local act = false;
		if ( (event == "SPELL_AURA_APPLIED" and spellWatch[spellName]) or 
			 (event == "SPELL_CAST_SUCCESS" and aoeSpellWatch[spellName]) ) then
			act = "casted";
		elseif (event == "SPELL_MISSED" and spellWatch[spellName]) then
			act = "missed";
		end
		if (act ~= false) then
			local target = (dstName and (" on %s"):format(dstName)) or "";
			SendChatMessage(format("%s %s %s%s", srcName, act, spellName, target), "channel", nil, GetChannelName("ncafail"));
		end
	end

	-- Cauterize ------------------------------------------------------------------
	if db.cauterizeTell and event == "SPELL_AURA_REMOVED" and dstGUID == UnitGUID("player") and spellName == "Cauterize" then
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
	
	-- Armor ----------------------------------------------------------------------
	if db.armorGlyph and event == "SPELL_AURA_APPLIED" and dstGUID == UnitGUID("player") then
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
			self:Print(format("Warning: %s is not glyphed", spellName))
		end
	end
end

local _, playerFaction = UnitFactionGroup("player")
local lastControl = nil         -- Last controlling faction; true = player's faction, false = opposite
function mod:TolBaradWatch()
    if db.tbWatch then
        -- Instances will bug us, so exit early
        if IsInInstance() then
            self:ScheduleTimer("TolBaradWatch", 60)
            return
        end

        --print ("TBWATCH GO", lastControl)
        -- Store map and change (708 = TB island)
        local current = GetCurrentMapAreaID()
        SetMapByID(708)

        -- Scan POI (708 = TB island)
        local _, text = GetMapLandmarkInfo(1)
        if not text then return end
        local control = not not text:find(playerFaction)
        --print ("control", control)

        -- Check if there was a change towards us
        if control and lastControl == false then
            self:TolBaradControl()
        end

        -- We'll update again when the next battle is about to take place
        -- If the battle is in progress, nextBattle will be 0, so let's wait 1 min
        local nextBattle = GetOutdoorPVPWaitTime() or 0
        --print("nextBattle", nextBattle)
        self:ScheduleTimer("TolBaradWatch", max(60, nextBattle))

        -- Check if we just recently defended it
        -- Note this will not spam because the next run will always be set as above
        if lastControl and control and nextBattle > 110*60 then
            self:TolBaradControl()
        end

        -- Store info for next update
        lastControl = control
        -- Reset to original map
        SetMapByID(current)
    end
end

-- Prints when you gain control
function mod:TolBaradControl()
    -- Check ChoreTracker
    local characters = {}
    local realm = GetRealmName()
    if IsAddOnLoaded("ChoreTracker") and ChoreTrackerDB and ChoreTrackerDB.global and ChoreTrackerDB.global[realm] then
        for char, data in pairs(ChoreTrackerDB.global[realm]) do
            if not data.lockouts or not data.lockouts["Baradin Hold"] or data.lockouts["Baradin Hold"].defeatedBosses == 0 then
                table.insert(characters, char)
            end
        end

        -- Done for the week
        if #characters == 0 then
            --print("fast end")
            return
        end
    end

    -- If we found some, amend our print with it
    local charList
    if #characters > 0 then
        charList = ("(%s)"):format(table.concat(characters, ", "))
    else
        charList = ""
    end

    -- Print
    core:Print(format("Tol Barad is under %s control %s", UnitFactionGroup("player"), charList))
end
