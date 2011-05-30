TextRegistry = {
	pos = {x=0, y=0},
	dispRegistry = {},
	openTexts = 0,
	numTexts = 0,
};
local TextRegistry = TextRegistry;

-- =================================
-- API
-- =================================

function TextRegistry:Unlock(callback)
	self.anchorFrame:SetBackdropColor(0.1, 0.1, 0.1, 0.75);
	self.anchorFrame:EnableMouse(true);
	
end

function TextRegistry:Lock()

end

-- TextRegistry:SetPosition - sets (x,y) coordinates of the frame; also accepts a table with x and y keys
function TextRegistry:SetPosition(x, y)
	if (type(x) == "table") then
		y = x.y or 0;
		x = x.x or 0;
	end
	local s = self.anchorFrame:GetEffectiveScale();
end

function TextRegistry:GetPosition()
	return self.pos.x, self.pos.y;
end

function TextRegistry:AddText(id, text, color)

end

function TextRegistry:UpdateText(id, val, color)

end

function TextRegistry:ClearAllTexts()

end
