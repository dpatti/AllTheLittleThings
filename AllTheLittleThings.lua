local core = LibStub("AceAddon-3.0"):NewAddon("AllTheLittleThings", "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0", "AceTimer-3.0")
atlt = core

local defaults = {
	profile = {
	
	},
}
local options_setter = function(info, v) local t=core.db.profile for k=1,#info-1 do t=t[info[k]] end t[info[#info]]=v core:UpdatePins(true) end
local options_getter = function(info) local t=core.db.profile for k=1,#info-1 do t=t[info[k]] end return t[info[#info]] end
local options = {
	name = "AllTheLittleThings",
	type = 'group',
	set = options_setter,
	get = options_getter,
	args = {
	
	},
}

function core:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("AllTheLittleThingsDB", defaults, "Default")
	-- self:RegisterChatCommand("atlt", function() end)
	
	-- LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("AllTheLittleThings", options)
	-- local ACD = LibStub("AceConfigDialog-3.0")
	-- ACD:AddToBlizOptions("AllTheLittleThings", "AllTheLittleThings")
	
	self:SetDefaultModulePrototype({
		OnEnable = function(self)
		end,
	})
end

function core:OnEnable()

end

function core:OnDisable()
	
end

function core:RegisterOptions(module, options, defaults)
	local name = module:GetName()
	defaults.profile[name] = defaults
	options.args[name] = {
		name = name,
		type = 'group',
		args = options
	}
end

