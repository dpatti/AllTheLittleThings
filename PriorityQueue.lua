PriorityQueue = {
	size = 0,
	heap = {},
	cmp = function(a,b) return a<b end;
};
local PriorityQueue = PriorityQueue;

local function deepcopy(dst, src)
	for k,v in pairs(src) do
		if (type(v) == "table") then
			dst[k] = {};
			deepcopy(dst[k], v);
		else
			dst[k] = v;
		end
	end
end

-- ---------------------------
-- ----------- API -----------
-- ---------------------------

-- local pq = PriorityQueue:New();
-- local pq = PriorityQueue:New{ default=1, values=2 };
function PriorityQueue:New(init)
	local pq = {};
	deepcopy(pq, self);
	if (init) then
		for k,v in pairs(init) do
			table.insert(pq.heap, {key=k, val=v});
			pq.size = pq.size + 1;
		end
		for i=#pq.heap,1,-1 do
			pq:PushDown(i);
		end
	end
	return pq;
end

-- pq:Insert(key, priority);
function PriorityQueue:Insert(key, value)
	if (not key or not value) then
		error("Usage - myPriorityQueue:Insert(key, value);");
	end
	local i = self.size+1;
	local parent = floor(i/2);
	
	if (type(self.heap[i]) == "table") then
		self.heap[i].key = key;
		self.heap[i].val = value;
	else
		self.heap[i] = {key=key, val=value};
	end
	self.size = self.size + 1;
	while (parent>0 and self:Compare(i, parent)) do
		self:Swap(i, parent);
		i = parent;
		parent = floor(i/2);
	end
end

-- local next = pq:Peek();
function PriorityQueue:Peek()
	if (self.size <= 0) then
		return nil;
	end
	local node = self.heap[1];
	return node.key, node.val;
end

-- local next = pq:Remove();
function PriorityQueue:Remove()
	if (self.size <= 0) then
		return nil;
	end
	self:Swap(1, self.size);
	self:PushDown(1);	
	self.size = self.size - 1;
	local node = self.heap[self.size+1];
	return node.key, node.val;
end


-- ---------------------------
-- ------ Class Methods ------
-- ---------------------------

function PriorityQueue:PushDown(index)
	local lc = index*2;
	local rc = lc + 1;
	if (lc <= self.size) then
		if (rc <= self.size and self:Compare(rc, lc)) then
			rc = lc;
		end
		if (self:Compare(lc, index)) then
			self:Swap(lc, index);
		end
	end
end

function PriorityQueue:Swap(i, j)
	local temp = self.heap[i];
	self.heap[i] = self.heap[j];
	self.heap[j] = temp;
end

function PriorityQueue:Compare(i, j)
	return self.cmp(self.heap[i].val, self.heap[j].val);
end