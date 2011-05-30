local core = LibStub("AceAddon-3.0"):GetAddon("AllTheLittleThings")
local mod = core:NewModule("Prat", "AceEvent-3.0")
local db

local defaults = {
}
local options = {
}

function mod:OnInitialize()
	db = core.db.profile[self:GetName()] or {}
	self:RegisterEvent("ADDON_LOADED")
end

function mod:ADDON_LOADED(_, name)
	if name == "Prat" then
		local module = Prat.Addon:GetModule('AltNames')
		Prat.RegisterMessageItem('ALTNAMES', 'PLAYER')
		module.padfmt = '||%s'
		module.setMainPos = function() end

		-- Prevent dropdown menu option from being displayed
		module.menusAdded = true

		-- /run Prat.Addon:ChatFrame_MessageEventHandler(ChatFrame1, "CHAT_MSG_SYSTEM", "Batche has gone offline.", "", "", "", "", "", 0, 0, "", 0, 3991, "", 0, true, false)
		-- PreAddMessage hook to limit main print to 3 characters and make sure player is added for logouts
		local PreAddMessage = module.Prat_PreAddMessage
		module.Prat_PreAddMessage = function(self, e, message, frame, event, ...)
			-- check to see if we have a log off
			if event == "CHAT_MSG_SYSTEM" then
				-- .MESSAGE contains modified message with color, .OUTPUT contains raw
				local p, m = message.OUTPUT:match("(%S+)( has gone offline.*)")
				if p then
					local class = Prat.Addon:GetModule('PlayerNames'):GetData(p)
					-- inline coloring won't work (fires before) so we do it manually
					-- set PLAYERLINK for AltNames to read
					message.MESSAGE, message.PLAYER, message.PLAYERLINK = m, Prat.CLR:Player(p, p:lower(), class), p
				end
			end

			-- call normal
			PreAddMessage(self, e, message, frame, event, ...) 

			-- unset PLAYERLINK if we have a log off so as not to have it display
			if not message.lL or message.lL == "" then
				message.PLAYERLINK = nil
			end

			-- limit to 3 characters in the main
			if message.ALTNAMES and message.ALTNAMES ~= "" then
				-- 12 characters of color padding; so sub(1, 12+length)
				self.ALTNAMES = self.ALTNAMES:sub(1, 15).."|r"
				message.ALTNAMES = self.ALTNAMES
			end
		end

		self:UnregisterEvent("ADDON_LOADED")
	end
end
