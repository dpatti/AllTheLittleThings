local core = LibStub("AceAddon-3.0"):GetAddon("AllTheLittleThings")
local mod = core:NewModule("Quest Rewards", "AceHook-3.0", "AceTimer-3.0")
local db

local player = ("%s - %s"):format(UnitName("player"), GetRealmName())
local REQ, OPT, EXCL = 1, 2, 3
local CHOICE = {
    [REQ]  = "|cff00ff00Required|r",
    [OPT]  = "|cffffff00Optional|r",
    [EXCL] = "|cffff0000Exclude|r",
}
local AVOIDANCE = { STAT_MASTERY, STAT_DODGE, STAT_PARRY } -- stats to check for
local AVD_MIX   = {         true,      false,      false } -- whether the stat is not exclusive to avd
local defaults = {
    filter = {},
}
local options = {
    itemFilter = {
        name = "Stat Filter",
        type = 'group',
        inline = true,
        set = function(info, v) db.filter[player][info[#info]] = v end,
        get = function(info) return db.filter[player][info[#info]] end,
        args = {
            str = {
                name = "Strength",
                type = 'select',
                values = CHOICE,
                order = 10,
            },
            agi = {
                name = "Agility",
                type = 'select',
                values = CHOICE,
                order = 20,
            },
            int = {
                name = "Intellect",
                type = 'select',
                values = CHOICE,
                order = 30,
            },
            spi = {
                name = "Spirit",
                type = 'select',
                values = CHOICE,
                order = 40,
            },
            avd = {
                name = "Avoidance",
                desc = "Contains at least one of Dodge, Parry, and Mastery. Excluding will not exclude all items with mastery.",
                type = 'select',
                values = CHOICE,
                order = 50,
            },
        },
    },
}

-- Quest template tables and their indices to re-set
local QUEST_TEMPLATES = {
    [QUEST_TEMPLATE_DETAIL2.elements] = 13,
    [QUEST_TEMPLATE_LOG.elements] = 28,
    [QUEST_TEMPLATE_REWARD.elements] = 7,
    [QUEST_TEMPLATE_MAP2.elements] = 1,
}

-- Set defaults for current player
local class = UnitClass("player"):lower()
defaults.filter[player] = {
    str = (class == "paladin" or class == "warrior" or class == "death knight") and OPT or EXCL,
    agi = (class == "hunter" or class == "rogue" or class == "shaman") and OPT or EXCL,
    int = (class == "mage" or class == "warlock" or class == "priest" or class == "shaman" or class == "druid" or class == "paladin") and OPT or EXCL,
    spi = OPT, -- Don't want to remove all spirit items unless user wants to, will fall back on int anyway
    avd = (class == "paladin" or class == "warrior" or class == "death knight" or class == "druid") and OPT or EXCL,
}
-- We're only checking armor types over level 45, so assume armor upgrade
-- Also using an array so we can test against the tooltip string
local armorFilter = {
    ["Cloth"]   = (class == "priest" or class == "mage" or class == "warlock"),
    ["Leather"] = (class == "rogue" or class == "druid"),
    ["Mail"]    = (class == "shaman" or class == "hunter"),
    ["Plate"]   = (class == "death knight" or class == "paladin" or class == "warrior"),
}
-- Map options to string names
local statFilter = {
    str = SPELL_STAT1_NAME,
    agi = SPELL_STAT2_NAME,
    int = SPELL_STAT4_NAME,
    spi = SPELL_STAT5_NAME,
    -- avd is special case
}

function mod:OnInitialize()
	self:RegisterOptions(options, defaults, function(d) db=d end)
    self:CreateTooltip()
end

function mod:OnEnable()
    self:SecureHook("QuestInfo_ShowRewards", "ColorizeItems")

    -- Re-set the templates
    for tbl, index in pairs(QUEST_TEMPLATES) do
        tbl[index] = QuestInfo_ShowRewards
    end
end

local tooltip, gold
local leftLines, rightLines = {}, {}
function mod:CreateTooltip()
    -- Create tooltip for scanning
    tooltip = CreateFrame("GameTooltip")
    tooltip:SetOwner(UIParent, "ANCHOR_NONE")
    for i = 1, 30 do
        leftLines[i] = tooltip:CreateFontString()
        leftLines[i]:SetFontObject(GameFontNormal)

        rightLines[i] = tooltip:CreateFontString()
        rightLines[i]:SetFontObject(GameFontNormal)

        tooltip:AddFontStrings(leftLines[i], rightLines[i])
    end

    -- Create gold icon
    gold = CreateFrame("Frame")
    gold:SetSize(16, 16)
    local texture = gold:CreateTexture()
    texture:SetAllPoints()
    texture:SetTexture("Interface\\MINIMAP\\TRACKING\\Banker")
end

function mod:ColorizeItems()
    -- Different functions for quest log rewards and quest giver rewards (hilarious)
    local numChoices, GetNumChoices, SetItem, GetChoiceInfo
    if QuestInfoFrame.questLog then
        GetNumChoices, SetItem, GetChoiceInfo = GetNumQuestLogChoices, "SetQuestLogItem", GetQuestLogChoiceInfo
    else
        GetNumChoices, SetItem, GetChoiceInfo = GetNumQuestChoices, "SetQuestItem", function(i) return GetQuestItemInfo("choice", i) end
    end
    numChoices = GetNumChoices()

    -- Hide gold icon
    gold:Hide()

    local bestSell, bestSellValue = 0, 0
    local finished = 0
    for i = 1, numChoices do
        local item = _G["QuestInfoItem"..i]
        -- Reset saturation
        SetItemButtonDesaturated(item, false)

        -- Do this in a timer so that we don't block
        self:ScheduleTimer(function()
            -- Return if the quest was abandoned to prevent lua error
            if numChoices ~= GetNumChoices() then return end

            -- Check gold
            local value = self:GoldValue(i, SetItem)
            if bestSell == 0 or value > bestSellValue then
                bestSell, bestSellValue = i, value
            end

            -- Check usability and filter further
            local _, _, _, _, isUsable = GetChoiceInfo(i)
            if isUsable then
                -- Check armor
                if UnitLevel("player") > 45 and not self:CheckArmor(i, SetItem) then
                    SetItemButtonTextureVertexColor(item, 0.9, 0, 0)
                    SetItemButtonNameFrameVertexColor(item, 0.9, 0, 0)
                else
                    -- Still valid, check stats
                    local stat = self:CheckStats(i, SetItem)
                    if stat == -1 then
                        SetItemButtonTextureVertexColor(item, 0.9, 0, 0)
                        SetItemButtonNameFrameVertexColor(item, 0.9, 0, 0)
                    elseif stat == 0 then
                        SetItemButtonDesaturated(item, true)
                    end
                end
            end

            -- If we did all items, place gold icon
            finished = finished + 1
            if finished == numChoices then
                if bestSell > 0 then
                    local parent = _G["QuestInfoItem" .. bestSell]
                    gold:SetParent(parent)
                    gold:ClearAllPoints()
                    gold:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -2, 4)
                    gold:Show()
                end
            end
        end, 0)
    end
end

function mod:GoldValue(i, setFunc)
    tooltip[setFunc](tooltip, "choice", i)
    local _, info = tooltip:GetItem()
    local _, _, _, _, _, _, _, _, _, _, vendorPrice = GetItemInfo(info)

    return vendorPrice or 0
end

function mod:CheckArmor(i, setFunc)
    tooltip[setFunc](tooltip, "choice", i)

    -- Scan right lines for an armor type
    for i = 1, tooltip:NumLines() do
        local text = rightLines[i]:GetText()
        -- nil check because it could be false
        if armorFilter[text] ~= nil then
            return armorFilter[text]
        end
    end

    return true
end

function mod:CheckStats(i, setFunc)
    tooltip[setFunc](tooltip, "choice", i)

    -- Stores key -> bool whether it is in or not, so we can separate logic
    local statMap = { }

    -- For each stat
    for key, str in pairs(statFilter) do
        -- If it's optional, we can skip because we don't care
        if db.filter[player][key] ~= OPT then
            statMap[key] = self:ScanTip(leftLines, str, 3)
        end
    end

    -- Check stats in AVOIDANCE
    if db.filter[player].avd ~= OPT then
        for i, str in ipairs(AVOIDANCE) do
            -- Here's the catch: if it's a mix stat (e.g., mastery), we need to
            -- not consider it if the mode is in exclude
            if not AVD_MIX[i] or db.filter[player]['avd'] ~= EXCL then
                statMap['avd'] = statMap['avd'] or self:ScanTip(leftLines, str, 3)
            end
        end
    end

    -- Check our results against db
    local requirement = true
    for stat, setting in pairs(db.filter[player]) do
        -- If we failed to meet a requirement, set the flag
        if setting == REQ and not statMap[stat] then
            requirement = false
        end

        -- If it is excluded, return instantly
        if setting == EXCL and statMap[stat] then
            return -1
        end
    end

    -- Check our requirement to determine normal or desaturated
    return requirement and 1 or 0
end

-- Case insensitive tooltip scanning
-- Searches the lines in col (table of strings) for str starting at index `start`
function mod:ScanTip(col, str, start)
    str = str:lower()
    for i = start or 1, tooltip:NumLines() do
        local text = col[i]:GetText():lower()
        if text:find(str) then
            return true
        end
    end

    return false
end
