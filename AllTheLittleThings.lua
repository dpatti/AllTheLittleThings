local core = LibStub("AceAddon-3.0"):NewAddon("AllTheLittleThings", "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0", "AceTimer-3.0")
local db
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
	db = LibStub("AceDB-3.0"):New("AllTheLittleThingsDB", defaults, "Default")
	self.db = db
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
local defaultsTimer
function core:RegisterOptions(modOptions, modDefaults)
	local name = self:GetName()
	defaults.profile[name] = modDefaults
	options.args[name] = {
		name = name,
		type = 'group',
		args = modOptions
	}

	if defaultsTimer then
		core:CancelTimer(defaultsTimer)
	end
	defaultsTimer = core:ScheduleTimer(function()
		db:RegisterDefaults(defaults)
	end, 0.01)
end

function core:RegisterSlashCommand(callback, ...)
	local keyword
	for i=1,select('#', ...) do
		local slash = select(i, ...)
		if slashCallback[slash] then
			error(("Slash command paramter already registered: '%s'"):format(slash))
		end
		slashCallback[slash] = self[callback]

		if not keyword or slash:len() < keyword:len() then
			keyword = slash
		end
	end

	slashList[("|cff33ff99%s|r:|cffcc7833%s()|r"):format(self:GetName(), callback)] = keyword
end

function core:MainSlashHandle(msg)
	local _, e, command = msg:find("(%S+)")

	if command and slashCallback[command] then
		msg = msg:sub(e+1)
		slashCallback[command](msg)
	else
		-- print all commands
		print("|cff33ff99AllTheLittleThings|r available commands:")
		for cmd,call in pairs(slashList) do
			print(("    %s - %s"):format(cmd, call))
		end
	end
end

-- fill out our prototype now that our addon's indicies are populated
prototype.RegisterOptions = core.RegisterOptions
prototype.RegisterSlashCommand = core.RegisterSlashCommand

