--[[
____  ___ __   __
| __|/ _ \\ \ / /
| _|| (_) |> w <
|_|  \___//_/ \_\
FOX's Backpack Fix

Github: https://github.com/Bitslayn/Wayfigura-Libraries/blob/main/BackpackFix
]]

local body, found = models, false

---Runs recursion through all ModelParts, stopping when the body is found
---@param part ModelPart
local function find_body(part)
	if found then return end
	if part:getType() == "GROUP" then
		if part:getParentType() == "Body" then
			body, found = part, true
		else
			for _, child in pairs(part:getChildren()) do
				find_body(child)
			end
		end
	end
end
find_body(models)

local backpack = body:newEntity("backpack")

function events.render()
	backpack:matrix(matrices.mat4()
		-- Fixes offset

		* matrices.translate4(0, -24, 0)
		* matrices.yRotation4(180)

		-- Fixes crouching, must be ran in render

		* matrices.translate4(vanilla_model.BODY:getOriginPos())
	)
end

local tick = 0
function events.tick()
	tick = tick % 20 + 1
	if tick ~= 1 then return end

	-- Get worn backpack item

	local item = player:getItem(5)

	-- Hide backpack model if no longer wearing backpack

	if not item or item.id ~= "backpacks:backpack" then
		backpack:visible(false)
		return
	end

	-- Set backpack model to worn backpack item

	backpack:setNbt("armor_stand", toJson({
		Invisible = true,
		ArmorItems = { {}, {}, { id = "backpacks:backpack", count = 1, components = {
			["vanity:style"] = item.tag["vanity:style"],
			["minecraft:dyed_color"] = item.tag["minecraft:dyed_color"],
		} }, {} },
	})):visible(true)
end
