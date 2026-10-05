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
				head, found = part, true
			else
				for _, child in pairs(part:getChildren()) do
					find_head(child)
				end
			end
		end
	end
	find_head(models)

	local helmet = head:newEntity("helmet")

	function events.render()
		helmet:matrix(matrices.mat4()
			-- Fixes offset

			* matrices.translate4(0, -24, 0)
			* matrices.yRotation4(180)
		)
	end

	function events.on_play_sound()
		local function tick()
			-- Get worn helmet item

			local item = player:getItem(6)

			-- Hide helmet model if no longer wearing a helmet

			if not item or not item:isArmor() then
				helmet:visible(false)
				return
			end

			-- Set helmet model to worn helmet item

			helmet:setNbt("armor_stand", toJson({
				Invisible = true,
				ArmorItems = { {}, {}, {}, {
					id = item.id,
					components = {
						["vanity:style"] = item.tag["vanity:style"],
						["minecraft:dyed_color"] = item.tag["minecraft:dyed_color"],
					},
				} },
			})):visible(true)

			events.tick:remove(tick)
		end
		events.tick:register(tick)
	end
end
