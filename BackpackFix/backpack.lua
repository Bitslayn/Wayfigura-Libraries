--[[
____  ___ __   __
| __|/ _ \\ \ / /
| _|| (_) |> w <
|_|  \___//_/ \_\
FOX's Backpack Fix

Github: https://github.com/Bitslayn/Wayfigura-Libraries/blob/main/BackpackFix
]]

function events.entity_init()
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

	function events.on_play_sound()
		if events.tick:getRegisteredCount("await_backpack") > 0 then return end

		local function tick()
			-- Get worn backpack item

			local item = player:getItem(5)

			-- Set backpack model only if a backpack is worn

			if item and item.id == "backpacks:backpack" then
				backpack:setNbt("armor_stand", toJson({
					Invisible = true,
					ArmorItems = { {}, {}, {
						id = "backpacks:backpack",
						components = {
							["vanity:style"] = item.tag["vanity:style"],
							["minecraft:dyed_color"] = item.tag["minecraft:dyed_color"],
						},
					}, {} },
				}))
			else
				backpack:setNbt("armor_stand", toJson({
					Invisible = true,
					ArmorItems = { {}, {}, {}, {} },
				}))
			end

			events.tick:remove(tick)
		end
		events.tick:register(tick, "await_backpack")
	end
end
