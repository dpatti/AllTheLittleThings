local core = LibStub("AceAddon-3.0"):GetAddon("AllTheLittleThings")
local mod = core:NewModule("PotionMail", "AceEvent-3.0")
local db

local defaults = {
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
}
local mailQueue = {} -- used in /atlt pots

function mod:OnInitialize()
	self:RegisterSlashCommand("AddPotions", "pots")
end

function mod:OnEnable()
	self:RegisterEvent("MAIL_SHOW", "MailQueueCheck");
	self:RegisterEvent("MAIL_SUCCESS", "MailQueueCheck");
end

function mod:AddPotions()
	-- get all guild members
	for i=1,GetNumGuildMembers() do
		local name, rank = GetGuildRosterInfo(i)
		name = name:lower()
		if rank == "Member" or rank == "Officer" or rank == "Guild Master" then
			if mailQueue[name] == nil then
				mailQueue[name] = {}
			end
		end
	end
	-- parse
	msg:gsub("([^%d%s]+)(%d+)(%w)", function(name, ct, type)
		local typeRef = potList[type]
		name = name:lower()
		ct = tonumber(ct)
		if typeRef and ct then
			for i,_ in pairs(mailQueue) do
				if i:match("^"..name) then
					mailQueue[i][typeRef] = ct
					print(format("Queued %dx |Hitem:%d|h[%s]|h for %s", ct, typeRef, GetItemInfo("item:"..typeRef), i))
				end
			end
		end
	end)
	-- cleanup array
	for name,data in pairs(mailQueue) do
		local ct = 0
		for i,v in pairs(data) do
			ct = ct + v
		end
		if ct == 0 then
			mailQueue[name] = nil
		end
	end
end

--[[ Things to do here still:
	- remove debug
	- consumables.php: group names together in slash args
	- consumables.php: split slash by pots?
	- if we don't have mats for this player, move to end of queue
	- use a flag of sorts to keep track of who was moved and who was not; reset flags on... mailbox close? this way we don't keep going through the queue over and over at the end
	- change data structure to numerical array (so we can move to the end)
	- change subject line to include amount
	- the lowercase first letter bugs me
	- do check when parsing slash command to make sure there are no ambiguous targets (Eternal/Eternity)
	- compress slash command more: 
		limit to first 4 letters (chir40d, chir->chira)? 3 may be possible but has higher collisions
		allow for chaining (chira40d2e6f - 40d, 2e, 6f)?
		include length of name after characters *in hex* (chi540d - "chira" has length of 5)
	- re-consolidate stacks at the end of the queue
	- add a command to display how much left of each is needed vs how much you have
]]
local mailQueueTimer
function mod:MailQueueCheck(caller, passData)
	local name,data = next(mailQueue)
	if not data then
		return -- no need to process queue
	end

	local delay = 0.5
	if caller == "MAIL_SUCCESS" then
		-- MAIL_SUCCESS fires on open too, so going to make sure we're looking at a Send Mail screen
		if MailFrame.selectedTab ~= 2 then
			return
		end
	end
	if mailQueueTimer then
		self:CancelTimer(mailQueueTimer, true)
	end
	-- slight pause to allow for items to disappear
	mailQueueTimer = self:ScheduleTimer(function()
		do
			self:Print(caller)
			-- return
		end
		
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
			self:Print("ITEM_LOCK_CHANGED fired", globalID)
			if pushQueue[globalID] then
				local _, _, locked = GetContainerItemInfo(bagID, slotID)
				if not locked then
					PickupContainerItem(bagID, slotID)
					ClickSendMailItemButton()
					pushQueue[globalID] = nil
					
					-- if our queue is empty
					if not next(pushQueue) then
						self:UnregisterEvent("ITEM_LOCK_CHANGED")
						self:Print("Unregistering ITEM_LOCK_CHANGED")
					end
				end
			end
		end
		local initializeQueue = function()
			self:RegisterEvent("ITEM_LOCK_CHANGED", checkItemLock)
			self:Print("Registering ITEM_LOCK_CHANGED")
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
			print("--------- NEXT ITEM:", item)
			if ct > 0 then
				local inv = GetItemCount(item)
				print("Checking item count:", inv, ct, inv<ct)
				if inv < ct then
					-- we don't have enough. abort.
					self:Print(format("We don't have enough |Hitem:%d|h[%s]|h for %s. Needed %d; have %d.", item, GetItemInfo("item:"..item), name, ct, inv))
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
								print("LOOP", GetItemInfo("item:"..item), slotCt, "/", ct, locked)
								if locked then
									-- the item is locked for whatever reason. abort?
									self:Message("|Hitem:%d|h[%s]|h in bag %d, slot %d is locked.", item, GetItemInfo("item:"..item), bag, slot)
									return
								else
									-- if item too many; find empty spot to dump extras
									if slotCt > ct then
										-- check to make sure we can split
										if #emptySlots == 0 then
											print("Not enough bag space to split. Aborting.")
											ClearSendMail()
											mod:CancelAllTimers()
											return
										end
										-- pop empty slot off the list
										local extraSpace = table.remove(emptySlots)
										local extraBag, extraSlot = floor(extraSpace/100), extraSpace % 100
										-- split and place
										print("splitting", bag, slot, slotCt-ct)
										SplitContainerItem(bag, slot, slotCt-ct)
										print("extras at", extraBag, extraSlot)
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
										print("adding to mail", bag, slot, ct, slotCt, ct-slotCt)
										PickupContainerItem(bag, slot)
										ClickSendMailItemButton()
										ct = ct - slotCt
										print("and after", ct)
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
		mailQueue[name] = nil
		-- self:ScheduleTimer(function()
			-- mailQueue[name] = nil
			-- ClearSendMail()
			-- self:MailQueueCheck()
		-- end, 5)
		
		mailQueueTimer = nil
	end, delay)
end

