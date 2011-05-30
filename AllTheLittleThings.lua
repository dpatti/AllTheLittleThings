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
local slashCallback = {}
local slashList = {}

local prototype = {}
core:SetDefaultModulePrototype(prototype)
core:SetDefaultModuleLibraries("AceConsole-3.0")

function core:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("AllTheLittleThingsDB", defaults, "Default") or {}
	self:RegisterChatCommand("atlt", "MainSlashHandle")
	
	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("AllTheLittleThings", options)
	local ACD = LibStub("AceConfigDialog-3.0")
	ACD:AddToBlizOptions("AllTheLittleThings", "AllTheLittleThings")
end

function core:OnEnable()
end

function core:OnDisable()
end

-- two registry functions called with self=mod
function core:RegisterOptions(modOptions, modDefaults)
	local name = self:GetName()
	defaults.profile[name] = modDefaults
	options.args[name] = {
		name = name,
		type = 'group',
		args = modOptions
	}
end

function core:RegisterSlashCommand(callback, ...)
	local long = ""
	for i=1,select('#', ...) do
		local slash = select(i, ...)
		slashCallback[slash] = self[callback]
		long = string.len(slash)>string.len(long) and slash or long
	end

	slashList[long] = ("%s:%s()"):format(self:GetName(), callback)
end

function core:MainSlashHandle(msg)
	local _, e, command = string.find("(%S+)", msg)
	msg = string.sub(msg, e+1)

	if command and slashCallback[command] then
		slashCallback[command](msg)
	else
		-- print all commands
	end
end

-- fill out our prototype now that our addon's indicies are populated
prototype.RegisterOptions = core.RegisterOptions
prototype.RegisterSlashCommand = core.RegisterSlashCommand

