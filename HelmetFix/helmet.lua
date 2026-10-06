--[[
____  ___ __   __
| __|/ _ \\ \ / /
| _|| (_) |> w <
|_|  \___//_/ \_\
FOX's Helmet Fix

Github: https://github.com/Bitslayn/Wayfigura-Libraries/blob/main/HelmetFix
]]

function events.entity_init()
	local head, found = models, false

	---Runs recursion through all ModelParts, stopping when the head is found
	---@param part ModelPart
	local function find_head(part)
		if found then return end
		if part:getType() == "GROUP" then
			if part:getParentType():find("^Helmet") then
				head, found = part:getParent() --[[@as ModelPart]], true
			else
				for _, child in pairs(part:getChildren()) do
					find_head(child)
				end
			end
		end
	end
	find_head(models)

	local helmet = head:newEntity("helmet")

	local function render()
		helmet:matrix(matrices.mat4()
			-- Fixes offset

			* matrices.translate4(0, -23, 0)
			* matrices.yRotation4(180)

			-- Fixes crouching, must be ran in render

			* matrices.translate4(vanilla_model.HEAD:getOriginPos())
		)
	end

	if head:getParentType() == "Head" then
		events.render:register(render)
	else
		render()
	end

	function events.on_play_sound()
		if events.tick:getRegisteredCount("await_helmet") > 0 then return end

		local function tick()
			-- Get worn helmet item

			local item = player:getItem(6)

			-- Set helmet model to worn helmet item if one is worn

			if item and item:isArmor() then
				helmet:setNbt("armor_stand", toJson({
					Invisible = true,
					ArmorItems = { {}, {}, {}, {
						id = item.id,
						components = {
							["vanity:style"] = item.tag["vanity:style"],
							["minecraft:dyed_color"] = item.tag["minecraft:dyed_color"],
						},
					} },
				}))
			else
				helmet:setNbt("armor_stand", toJson({
					Invisible = true,
					ArmorItems = { {}, {}, {}, {} },
				}))
			end

			events.tick:remove(tick)
		end
		events.tick:register(tick, "await_helmet")
	end
end
