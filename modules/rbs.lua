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

    -- hide trash button
    local tb = RaidBuffStatus.trashbutton
    tb:Hide()
    tb.Show = tb.Hide
    -- reposition World Marker Button so we don't have taint
    local marker = CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton
    marker:ClearAllPoints()
    marker:SetParent(RaidBuffStatus.frame)
    marker:SetPoint("TOPLEFT", tb, "TOPLEFT")
    marker:SetPoint("BOTTOMRIGHT", tb, "BOTTOMRIGHT")
    -- skin it to match
    marker:SetText("Mark")
    for _,s in pairs({"NormalFontObject", "HighlightFontObject", "DisabledFontObject", "NormalTexture", "PushedTexture", "DisabledTexture", "HighlightTexture"}) do
        marker["Set"..s](marker, tb["Get"..s](tb))
    end
    for _,e in pairs({"OnLeave", "OnEnter", "OnEnable", "OnShow", "OnMouseUp", "OnMouseDown"}) do
        marker:SetScript(e, nil)
    end
    _G[marker:GetName().."Text"]:SetPoint("CENTER")
    -- weird text hack to get it to display the correct color
    marker:LockHighlight()
    marker:UnlockHighlight()
	
    -- set backdrop for extra buttons
    local bg = RaidBuffStatus.frame:GetBackdrop()
    bg.insets = { top = 0, left = 3, right = 3, bottom = -20 }
    bg.edgeFile = nil
    RaidBuffStatus.frame:SetBackdrop(bg)
    RaidBuffStatus:SetFrameColours()

	-- hook old show/hide
	local rbShow = RaidBuffStatus.readybutton.Show
	RaidBuffStatus.readybutton.Show = function(...)
		RaidBuffStatus.FlaskButton:Show()
		RaidBuffStatus.CountButton:Show()
		RaidBuffStatus.LootButton:Show()
        marker:Show()
        -- backdrop
        bg.insets.bottom = -20
        RaidBuffStatus.frame:SetBackdrop(bg)
        RaidBuffStatus:SetFrameColours()
		return rbShow(...)
	end
	local rbHide = RaidBuffStatus.readybutton.Hide
	RaidBuffStatus.readybutton.Hide = function(...)
		RaidBuffStatus.FlaskButton:Hide()
		RaidBuffStatus.CountButton:Hide()
		RaidBuffStatus.LootButton:Hide()
        marker:Hide()
        -- backdrop
        bg.insets.bottom = 2
        RaidBuffStatus.frame:SetBackdrop(bg)
        RaidBuffStatus:SetFrameColours()
		return rbHide(...)
	end
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
