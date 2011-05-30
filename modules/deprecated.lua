-- These are here for historical purposes only -- do not include in .toc
local core = LibStub("AceAddon-3.0"):GetAddon("AllTheLittleThings")
local mod = core:NewModule("Deprecated", "AceEvent-3.0")
local db = core.db.profile[mod:GetName()]

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
	core:RegisterOptions(options, defaults)
	core:RegisterSlashCommand("method", "slsh1", "slash2")
end

-- Lich King Flame Cap Macro ---------------------------------------------------
local macro = "MI+FC";
function core:ZoneChange()
	if (db.macroSwap and UnitName("player")=="Chira" and GetMacroIndexByName(macro)>0) then
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

-- Attempt to monitor n52 problem ----------------------------------------------
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

-- Bug with text in animations -------------------------------------------------
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
