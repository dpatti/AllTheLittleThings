local core = LibStub("AceAddon-3.0"):GetAddon("AllTheLittleThings")
local mod = core:NewModule("Spellcast", "AceEvent-3.0", "AceTimer-3.0")
local db

local defaults = {
	anchor = {
		x = 500,
		y = 500,
		locked = false,
	},

	buttonSize = 40,
	textSize = 10,
	spacing = 5,
}
local options = {
	locked = {
		name = "Locked",
		type = 'toggle',
		order = 1,
		get = function() return db.anchor.locked end,
		set = function(_, val) db.anchor.locked = val mod:SetLocked(val) end,
	},
}

local spellWatch = {
	-- Polymorph
	[118] 	= "Polymorph",
	[61305] = "Polymorph",
	[28272] = "Polymorph",
	[61721] = "Polymorph",
	[61780] = "Polymorph",
	[28271] = "Polymorph",
	-- Counterspell
	[2139] 	= "Counterspell",
	-- Deep Freeze
	[44572] = "Deep Freeze",
	-- Frostbolt
	[116] 	= "Frostbolt",
}
local auras = {
	["Polymorph"] = true,
}
local durations = {
	["Polymorph"] = 8,
	["Deep Freeze"] = 30,
	["Counterspell"] = 24,
	["Ice Lance"] = 10,
}
local validZones = {
	-- Battlegrounds
	["Alterac Valley"] 				= true,
	["Arathi Basin"] 				= true,
	["Eye of the Storm"] 			= true,
	["Isle of Conquest"] 			= true,
	["Strand of the Ancients"] 		= true,
	["The Battle for Gilneas"] 		= true,
	["Twin Peaks"] 					= true,
	["Warsong Gulch"] 				= true,

	-- Arenas
	["Blade's Edge Arena"] 			= true,
	["Dalaran Arena"] 				= true,
	["Nagrand Arena"] 				= true,
	["Ruins of Lordaeron"] 			= true,
	["The Ring of Valor"] 			= true,

	-- Testing
	-- ["Stormwind City"] 				= true,
}
local combatEvents = {
	["SPELL_AURA_APPLIED"] = true,
	["SPELL_AURA_REFRESHED"] = true,
	["SPELL_AURA_REMOVED"] = true,
}
local icons = {}
local lastAvailable = {}
local anchor, enabled, updateTimer

function mod:OnInitialize()
	self:RegisterOptions(options, defaults, function(d) db = d end)
end

function mod:OnEnable()
	self:SetupIcons()
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")

	-- This doesn't always fire on load
	self:ZONE_CHANGED_NEW_AREA()
end

function mod:SetLocked(val)
	if val then 
		anchor:Hide()
	else
		anchor:Show()
	end
end

function mod:ZONE_CHANGED_NEW_AREA()
	local before = enabled
	enabled = not not validZones[GetRealZoneText() or ""]

	if before ~= enabled then
		-- wipe last table so that we don't have an accumulated time
		wipe(lastAvailable)
		self:UpdateDisplay()
	end

	if not enabled then
		self:CancelTimer(updateTimer, true)
		updateTimer = nil
	end

	if enabled and not updateTimer then
		updateTimer = self:ScheduleRepeatingTimer("UpdateDisplay", 0.1)
	end
end

function mod:COMBAT_LOG_EVENT_UNFILTERED(_, _, event, _, ...)
	if not enabled or not combatEvents[event] then return end

	local srcGUID, dstGUID, spellId, _
	if select(4, GetBuildInfo()) > 40100 then
		srcGUID, _, _, _, dstGUID, _, _, _, spellId = ...
	else
		srcGUID, _, _, dstGUID, _, _, spellId = ...
	end

	-- source is player
	if UnitGUID("player") ~= srcGUID then return end

	local category = spellWatch[spellId]
	if category then
		-- only handling auras here
		if auras[category] then
			if event == "SPELL_AURA_APPLIED" then
				local endTime = select(7, UnitDebuff(self:FindGUID(dstGUID), GetSpellInfo(spellId))) or (durations[category] or 0)+GetTime()
				self:SpellStart(category, endTime)
			elseif event == "SPELL_AURA_REMOVED" then
				self:SpellStop(category)
			end
		end
	end
end

function mod:UNIT_SPELLCAST_SUCCEEDED(_, unit, _, _, _, spellId)
	if not enabled or UnitGUID(unit) ~= UnitGUID("player") then return end
	
	local category = spellWatch[spellId]
	if category then
		-- self:Print("UNIT_SPELLCAST_SUCCEEDED", category, spellId)
		if not auras[category] then
			local duration = durations[category]
			if not duration then
				-- no duration means it has no cooldown, so we just start the timer
				self:SpellStop(category, true)
			else
				self:SpellStart(category, duration+GetTime())
			end
		end
	end
end

function mod:SpellStart(category, endTime)
	local icon = icons[category]
	local time = GetTime()
	if not icon or endTime<time then return end

	-- self:Print("Start", category, endTime-GetTime())

	lastAvailable[category] = nil
	local duration = endTime - time
	icon.cooldown = duration
	icon:SetCooldown(time, duration)
	icon:SetText("")
end

function mod:SpellStop(category, nocd)
	local icon = icons[category]
	if not icon then return end

	-- self:Print("Stop", category)

	lastAvailable[category] = GetTime()
	icon.cooldown = 0
	if not nocd then
		icon:SetCooldown(0, 0)
	end
	icon:SetText("0:00")
end

function mod:FindGUID(guid)
	if UnitGUID("target") == guid then
		return "target"
	elseif UnitGUID("focus") == guid then
		return "focus"
	else
		for i=1,5 do 
			if UnitGUID("arena"..i) == guid then
				return "arena"..i
			end
		end
	end

	-- return a valid string so that UnitAura doesn't error
	return ""
end

function mod:SetupIcons()
	-- return if we've already set up
	if anchor then return end

	anchor = self:SetupAnchor()
	local last = anchor

	-- each icon chains to the last
	for spellId, category in pairs(spellWatch) do
		if not icons[category] then
			last = self:SetupIcon(spellId, last)
			icons[category] = last
		end
	end

	self:UpdateDisplay()
end

function mod:SetupAnchor()
	local frame = CreateFrame("Frame", nil, UIParent)
	frame:SetFrameStrata("LOW")
	frame:SetSize(db.buttonSize, db.buttonSize)
	frame:SetMovable(true)
	frame:SetClampedToScreen(true)
	frame:RegisterForDrag("LeftButton")
	frame:EnableMouse(true)
	frame:SetScript("OnDragStart", function(self)
		if not db.anchor.locked then
			self:StartMoving()
		end
	end)
	frame:SetScript("OnDragStop", function(self)
		local scale = self:GetEffectiveScale()
		self:StopMovingOrSizing()
		db.anchor.x = self:GetLeft()*scale
		db.anchor.y = self:GetBottom()*scale
	end)

	local texture = frame:CreateTexture()
	texture:SetAllPoints()
	texture:SetTexture(0, 0, 0, 0.6)

	local scale = frame:GetEffectiveScale()
	frame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", db.anchor.x/scale, db.anchor.y/scale)

	if db.anchor.locked then
		frame:Hide()
	end

	return frame
end

function mod:SetupIcon(spellId, anchor)
	local frame = CreateFrame("Frame", nil, UIParent)
	frame:SetSize(db.buttonSize, db.buttonSize)
	frame:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -db.spacing)
	
	local texture = frame:CreateTexture()
	texture:SetAllPoints()
	texture:SetTexture(select(3, GetSpellInfo(spellId)))

	local clock = CreateFrame("Cooldown", nil, frame)
	clock:SetAllPoints()

	local text = frame:CreateFontString(nil, nil, "GameFontNormal")
	text:SetSize(100, 20)
	-- text:SetText("0:00")
	text:SetPoint("BOTTOMLEFT", frame, "BOTTOMRIGHT", 5, 0)
	text:SetJustifyH("LEFT")

	-- methods and members
	frame.cooldown = 0
	frame.spell = spellId
	frame.SetText = function(self, ...)
		text:SetText(...)
	end
	frame.SetFormattedText = function(self, ...)
		text:SetFormattedText(...)
	end
	frame.SetCooldown = function(self, ...)
		clock:SetCooldown(...)
	end

	return frame
end

function mod:UpdateDisplay()
	if not enabled then
		anchor:Hide()
		for _,frame in pairs(icons) do
			frame:Hide()
		end
	else
		if not db.anchor.locked then
			anchor:Show()
		end
		for category, frame in pairs(icons) do
			if not frame:IsVisible() then
				frame:Show()
				frame:SetText("")
			end

			-- update text
			if lastAvailable[category] then
				local diff = GetTime()-lastAvailable[category]
				frame:SetFormattedText("%d:%02d", diff/60, diff%60)
			end

			-- if a cooldown, check that it's still on cd
			if not auras[category] and frame.cooldown > 0 then
				local _, duration = GetSpellCooldown(frame.spell)
				-- within a global, we must not have it on cd
				if duration < 1.5 then
					self:SpellStop(category)
				end
			end
		end
	end
end

