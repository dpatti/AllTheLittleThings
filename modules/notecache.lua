local core = LibStub("AceAddon-3.0"):GetAddon("AllTheLittleThings")
local mod = core:NewModule("Guild Note Cache", "AceEvent-3.0")
local db

local defaults = {
    notes = {},
    onotes = {},
}
local options = {
}

function mod:OnInitialize()
	self:RegisterOptions(options, defaults, function(d) db=d end)
end

function mod:OnEnable()
    self:RegisterEvent("GUILD_ROSTER_UPDATE", "Scan")
end

function mod:Scan()
    for i=1,GetNumGuildMembers() do
        local name, _, _, _, _, _, note, onote = GetGuildRosterInfo(i)
        self:Push(db.notes, name, note)
        self:Push(db.onotes, name, onote)
    end
end

function mod:Push(tbl, key, value)
    -- skip if value is empty
    if value == "" or key == nil then
        return
    end

    -- if it doesn't exist, use a simple key-value pairing
    if not tbl[key] then
        tbl[key] = value
        return
    end

    -- if it exists as a string and doesn't match, convert to table
    if type(tbl[key]) == "string" then
        if tbl[key] == value then
            return
        end
        tbl[key] = {tbl[key]}
    end

    -- only push if last entry is different
    if tbl[key][#tbl[key]] ~= value then
        table.insert(tbl[key], value)
    end
end
