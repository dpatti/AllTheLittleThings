local core = LibStub("AceAddon-3.0"):GetAddon("AllTheLittleThings")
local mod = core:NewModule("RBS", "AceEvent-3.0", "AceHook-3.0")
local db

local defaults = {
}
local options = {
}

function mod:OnInitialize()
end

function mod:OnEnable()
	if RaidBuffStatus then
		self:SecureHook(RaidBuffStatus, "SetupFrames", "SetupRBS")
	end	
end

function mod:RunMacro(name)
	local macros = core:GetModule("Macros")
	if not macros or not macros[name] then return end
	
	macros[name](macros)
end

local didSetup = false
function mod:SetupRBS()
	if didSetup or not RaidBuffStatus or not RaidBuffStatus.frame then 
		return
	end
	didSetup = true
	
	-- register new buttons
	self:NewRBSButton("Flask", function()
		self:RunMacro("FlaskCheck")
	end, 45, "TOPLEFT", "BOTTOMLEFT", 7, 5)
	self:NewRBSButton("Count", function()
		self:RunMacro("Countdown")
	end, 45, "TOP", "BOTTOM", 0, 5)
	self:NewRBSButton("Loot", function()
		self:RunMacro("MasterLoot")
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

function mod:NewRBSButton(label, func, width, anchorFrom, anchorTo, anchorX, anchorY)
	local button = CreateFrame("Button", "", RaidBuffStatus.frame, "OptionsButtonTemplate")
	button:SetText(label)
	button:SetWidth(width)
	button:SetPoint(anchorFrom, RaidBuffStatus.frame, anchorTo, anchorX, anchorY)
	button:SetScript("OnClick", func)
	button:Show()
	RaidBuffStatus[label.."Button"] = button
end
