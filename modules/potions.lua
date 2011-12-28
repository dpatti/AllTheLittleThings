local core = LibStub("AceAddon-3.0"):GetAddon("AllTheLittleThings")
local mod = core:NewModule("PotionMail", "AceEvent-3.0", "AceTimer-3.0", "AceHook-3.0")
local db

local defaults = {
    mailQueue = {}, -- used to store potion information per character
}
local options = {
}

local potList = {
	["a"] = 58146, -- Golemblood
	["b"] = 58145, -- Tol'vir
	["c"] = 58090, -- Earthen
	["d"] = 58091, -- Volcanic
	["e"] = 57194, -- Concentration
	["f"] = 57192, -- Mythical
	["g"] = 57192, -- Mysterious
}
local guildColors = {} -- for printing names in color
local currentSender -- the current person you are sending to
local matWarning = false -- flag so that we don't get print warning twice in a row

function mod:OnInitialize()
	self:RegisterOptions(options, defaults, function(d) db=d end)
	self:RegisterSlashCommand("AddPotions", "pots")
	self:RegisterSlashCommand("PrintPotions", "pp")
	self:RegisterSlashCommand("ClearPotions", "cp")
end

function mod:OnEnable()
    -- We use MAIL_SUCCESS instead of MAIL_SEND_SUCCESS because the latter fires on ClearSendMail() which we call
	self:RegisterEvent("MAIL_SUCCESS", "MailQueueCheck"); 
	self:RegisterEvent("MAIL_SHOW", "MailQueueCheck");
    self:RegisterEvent("MAIL_CLOSED", function() currentSender = nil end); -- clear the sender
    self:Hook("SendMail", true)

    self:CacheGuild()
end

function mod:CacheGuild()
	-- get all guild members
	for i=1,GetNumGuildMembers() do
		local name, rank = GetGuildRosterInfo(i)
		name = name:lower()
		if rank == "Applicant" or rank == "Member" or rank == "Officer" or rank == "Guild Master" then
			guildColors[name] = RAID_CLASS_COLORS[select(11, GetGuildRosterInfo(i))]
			if db.mailQueue[name] == nil then
				db.mailQueue[name] = {}
			end
		end
	end
end

function mod:AddPotions(msg)
    -- Call again in case we removed some during potion distribution and added later
    self:CacheGuild()

	-- parse
	msg:gsub("([^%d%s]+)(%d+)(%w)", function(name, ct, type)
		local typeRef = potList[type]
		name = name:lower()
		ct = tonumber(ct)
		if typeRef and ct then
			for i,_ in pairs(db.mailQueue) do
				if i:match("^"..name) then
					db.mailQueue[i][typeRef] = ct
					-- print(format("Queued %dx %s for %s", ct, self:Link(typeRef), i))
				end
			end
		end
	end)
end

--[[ Things to do here still:
	- consumables.php: group names together in slash args (why?)
	- consumables.php: split slash by pots? (what?)
	- change subject line to include amount
	- do check when parsing slash command to make sure there are no ambiguous targets (Eternal/Eternity)
	- compress slash command more: 
		limit to first 4 letters (chir40d, chir->chira)? 3 may be possible but has higher collisions
		allow for chaining (chira40d2e6f - 40d, 2e, 6f)?
		include length of name after characters *in hex* (chi540d - "chira" has length of 5)
	- re-consolidate stacks at the end of the queue
    - handle situations where more than 12 slots are needed
]]
local mailQueueTimer
local delay = 0.5
function mod:MailQueueCheck(caller)
    -- First do some preliminary checks
	if caller == "MAIL_SUCCESS" then
		-- MAIL_SUCCESS fires on open too, so going to make sure we're looking at a Send Mail screen
		if MailFrame.selectedTab ~= 2 then
			return
		end

        -- if we have a currentSender, remove them from the queue
        if currentSender then
            db.mailQueue[currentSender] = nil
        end
	end
    -- Check that there is no mailQueueTimer
	if mailQueueTimer then
		self:CancelTimer(mailQueueTimer, true)
	end

    mailQueueTimer = self:ScheduleTimer("MailStockCheck", delay)
end

function mod:MailStockCheck()
    -- Find a player that we can mail to
    local name, empty = nil, true
    for player, data in pairs(db.mailQueue) do
        -- Check that we have enough mats for this character
        local have = true
        for item, ct in pairs(data) do
            if ct > 0 then
                empty = false
                -- Checking our inventory
                local inv = GetItemCount(item)
                if inv < ct then
                    have = false
                    break
                end
            end
        end
        -- Breaking out of outer loop, but make sure we had something
        if have and next(data) then 
            name = player
            break 
        end
    end
    -- Check if the search was successful
    if not name and not empty then
        if not matWarning then
            matWarning = true
            self:Print("We don't have enough mats for anyone else. The following is needed:")
            self:PrintPotions(true)
        end
        return
    end
    -- If we got this far, reset flag to print next time
    matWarning = false

    -- Check that there is no mailQueueTimer
	if mailQueueTimer then
		self:CancelTimer(mailQueueTimer, true)
	end

    -- Call with this guy
    self:MailProcess(name)
end

function mod:MailProcess(name)
    -- Get our potion
	local data = db.mailQueue[name]
    -- Sanity check
	if not data then return end

	-- slight pause to allow for items to disappear
	mailQueueTimer = self:ScheduleTimer(function()
		-- find all slots for splitting onto
		local emptySlots = {}
		for bag=0,NUM_BAG_SLOTS do
			local free = GetContainerFreeSlots(bag)
			for _,slot in ipairs(free) do
				table.insert(emptySlots, bag*100+slot)
			end
		end
		
		-- need to keep track of what to push to Send Mail window when the item lock clears
		local pushQueue = {}
		local checkItemLock = function(_, bagID, slotID)
			local globalID = bagID*100+slotID
			-- self:Print("ITEM_LOCK_CHANGED fired", globalID)
			if pushQueue[globalID] then
				local _, _, locked = GetContainerItemInfo(bagID, slotID)
				if not locked then
					PickupContainerItem(bagID, slotID)
					ClickSendMailItemButton()
					pushQueue[globalID] = nil
					
					-- if our queue is empty
					if not next(pushQueue) then
						self:UnregisterEvent("ITEM_LOCK_CHANGED")
						-- self:Print("Unregistering ITEM_LOCK_CHANGED")
					end
				end
			end
		end
		local initializeQueue = function()
			self:RegisterEvent("ITEM_LOCK_CHANGED", checkItemLock)
			-- self:Print("Registering ITEM_LOCK_CHANGED")
		end
		
		-- swap tabs if we need to
		if MailFrame.selectedTab ~= 2 then
			MailFrameTab_OnClick(MailFrame, 2)
		end
		ClearSendMail()
		
		-- set name
		SendMailNameEditBox:SetText(name)
		
		-- fill out shit
		for item,ct in pairs(data) do
			-- print("--------- NEXT ITEM:", item)
			if ct > 0 then
				local inv = GetItemCount(item)
				-- print("Checking item count:", inv, ct, inv<ct)
				if inv < ct then
					-- we don't have enough. abort.
					self:Print(format("We don't have enough %s for %s. Needed %d; have %d.", self:Link(item), name, ct, inv))
					ClearSendMail()
					return
				end
				
				-- find container slot with item
				for bag=0,NUM_BAG_SLOTS do
					-- check if we're done
					if ct > 0 then
						for slot=1,GetContainerNumSlots(bag) do
							-- make sure the item we want is this slot
							if GetContainerItemID(bag, slot) == item then
								local _, slotCt, locked = GetContainerItemInfo(bag, slot)
								-- print("LOOP", GetItemInfo("item:"..item), slotCt, "/", ct, locked)
								if locked then
									-- the item is locked for whatever reason. abort?
									self:Print(format("%s in bag %d, slot %d is locked.", self:Link(item), bag, slot))
									return
								else
									-- if item too many; find empty spot to dump extras
									if slotCt > ct then
										-- check to make sure we can split
										if #emptySlots == 0 then
											-- print("Not enough bag space to split. Aborting.")
											ClearSendMail()
											mod:CancelAllTimers()
											return
										end
										-- pop empty slot off the list
										local extraSpace = table.remove(emptySlots)
										local extraBag, extraSlot = floor(extraSpace/100), extraSpace % 100
										-- split and place
										-- print("splitting", bag, slot, slotCt-ct)
										SplitContainerItem(bag, slot, slotCt-ct)
										-- print("extras at", extraBag, extraSlot)
										PickupContainerItem(extraBag, extraSlot) -- place
										
										-- check when lock is clear
										if not next(pushQueue) then
											initializeQueue()
										end
										pushQueue[bag*100+slot] = true -- register source as push target
										ct = 0
										break
									else
										-- item should have enough
										-- print("adding to mail", bag, slot, ct, slotCt, ct-slotCt)
										PickupContainerItem(bag, slot)
										ClickSendMailItemButton()
										ct = ct - slotCt
										-- print("and after", ct)
										if ct == 0 then
											break
										end
									end
								end
							end
						end
					end
				end
			end
		end

		-- click send
        currentSender = name
		-- self:ScheduleTimer(function()
			-- db.mailQueue[name] = nil
			-- ClearSendMail()
			-- self:MailQueueCheck()
		-- end, 5)
		
		mailQueueTimer = nil
	end, delay)
end

-- Optional flag to specify that you only want the potion summary printed
function mod:PrintPotions(onlySummary)
    self:CacheGuild()

    -- Remove printing if we want summary only
    local print = print
    -- Test against true because we get other slash command stuff
    if onlySummary == true then
        print = function() end
    end

    local totals = {}
	for name,details in pairs(db.mailQueue) do
        -- Check to make sure it is not an empty print
        if next(details) then
            print(("|cff%02x%02x%02x%s|r:"):format(guildColors[name].r*255, guildColors[name].g*255, guildColors[name].b*255, name:gsub("^(.)(.*)$", function(f, rest)
                return string.upper(f) .. rest
            end)))
            for pot,n in pairs(details) do
                print(("   %s: %d"):format(self:Link(pot, true), n))
                totals[pot] = (totals[pot] or 0) + n
            end
        end
	end

    if not next(totals) then
        self:Print("Potion queue is empty")
        return
    end

    -- print totals and what we have in bags
    print("Total:")
    for pot,n in pairs(totals) do
        local have = GetItemCount(pot)
        -- Explicitly call global print
        _G.print(("   %s: |cff%s%d / %d|r"):format(self:Link(pot, true), have >= n and "00ff00" or "ff0000", have, n))
    end
end

function mod:ClearPotions()
    db.mailQueue = {}
end

function mod:Link(id, icon)
	icon = icon and ("|T%s:0|t"):format((select(10, GetItemInfo(id)))) or ""
	return ("%s|Hitem:%d|h[%s]|h"):format(icon, id, (GetItemInfo(id)))
end

-- Double check when we try to send that we are sending to our auto-person,
-- otherwise it was not part of this addon and should not be removed from the
-- queue
function mod:SendMail(recipient)
    if currentSender and recipient:lower() ~= currentSender:lower() then
        currentSender = nil
    end
end
