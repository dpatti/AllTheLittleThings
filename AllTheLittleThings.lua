local core = LibStub("AceAddon-3.0"):NewAddon("AllTheLittleThings", "AceEvent-3.0", "AceHook-3.0", "AceTimer-3.0")
local db
atlt = core

local defaults = {
	profile = {
	
	},
}
local options_setter = function(info, v) local t=core.db.profile for k=1,#info-1 do t=t[info[k]] end t[info[#info]]=v end
local options_getter = function(info) local t=core.db.profile for k=1,#info-1 do t=t[info[k]] end return t[info[#info]] end
local options = {
	name = "AllTheLittleThings",
	type = 'group',
	set = options_setter,
	get = options_getter,
	args = {
	},
}
local databaseCallback = {} -- functions to call when database is ready
local slashCallback = {}
local slashList = {}

local prototype = {}
local mixins = {
	"RegisterOptions",
	"RegisterSlashCommand",
	"Print",
}
core:SetDefaultModulePrototype(prototype)

function core:OnInitialize()
	-- Not embedding AceConsole-3.0 so that we can have our own :Print()
	LibStub("AceConsole-3.0").RegisterChatCommand(self, "atlt", "MainSlashHandle")
	self.db = LibStub("AceDB-3.0"):New("AllTheLittleThingsDB", defaults, "Default")
	db = self.db.profile
	
	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("AllTheLittleThings", options)
	local ACD = LibStub("AceConfigDialog-3.0")
	ACD:AddToBlizOptions("AllTheLittleThings", "AllTheLittleThings")
end

function core:OnEnable()
	self.db:RegisterDefaults(defaults)
	for mod,fn in pairs(databaseCallback) do fn(db[mod]) end
end

function core:OnDisable()
end

-- two registry functions called with self=mod
function core:RegisterOptions(modOptions, modDefaults, callback)
	local name = self:GetName()
	defaults.profile[name] = modDefaults
	options.args[name] = {
		name = name,
		type = 'group',
		args = modOptions
	}

	databaseCallback[name] = callback
end

function core:RegisterSlashCommand(callback, ...)
	local keyword
	for i=1,select('#', ...) do
		local slash = select(i, ...)
		if slashCallback[slash] then
			error(("Slash command paramter already registered: '%s'"):format(slash))
		end
		slashCallback[slash] = function(...)
			self[callback](self, ...)
		end

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

function core:Print(...)
	LibStub("AceConsole-3.0").Print('atlt', ...)
end


-- fill out our prototype now that our addon's indicies are populated
for _,method in ipairs(mixins) do
	prototype[method] = core[method]
end

