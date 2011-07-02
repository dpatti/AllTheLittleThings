local core = LibStub("AceAddon-3.0"):GetAddon("AllTheLittleThings")
local mod = core:NewModule("Announce", "AceEvent-3.0", "AceTimer-3.0")
local db

local defaults = {
	interrupt = false,
	spellWatch = true,
	cauterize = "",
	armorGlyph = true,
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

