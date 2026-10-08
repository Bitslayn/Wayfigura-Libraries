--[[
____  ___ __   __
| __|/ _ \\ \ / /
| _|| (_) |> w <
|_|  \___//_/ \_\
FOX's Backpack Logger

Github: https://github.com/Bitslayn/Wayfigura-Libraries/blob/main/BackpackLogger
]]

if not host:isHost() then return end

---@type string?, table[]?
local last_stack, last_contents

local rarity_colors = {
	COMMON = "white",
	UNCOMMON = "yellow",
	RARE = "aqua",
	EPIC = "light_purple",
}

---@param text string
local function log_changes(text)
	local extra = { { text = "[Backlog] ", color = "#fc6c85" } }

	---@type integer[]
	local markers = { 0 }
	for pos_a, pos_b in text:gmatch("()%S+:%S+\1.-\2()") do
		markers[#markers + 1] = pos_a --[[@as integer]]
		markers[#markers + 1] = pos_b
	end
	markers[#markers + 1] = 0

	for i = 1, #markers - 1 do
		local substring = text:sub(markers[i], markers[i + 1] - 1)
		if substring:find(":") then
			-- Item json
			local ok, item = pcall(world.newItem, substring)
			if ok then
				extra[#extra + 1] = {
					text = item:getName(),
					color = rarity_colors[item:getRarity()],
					hoverEvent = { contents = { id = item.id, components = parseJson(substring:match("\1(.*)\2")) }, action = "show_item" },
				}
			else
				extra[#extra + 1] = { text = substring:match("(.*)\1"), color = "white" }
			end
		else
			-- Normal json
			extra[#extra + 1] = { text = substring }
		end
	end
	extra[#extra + 1] = { text = "\n" }

	printJson(toJson({ text = "", color = "gray", extra = extra }))
end

function events.tick()
	-- Try running every quarter second

	if world.getTime() % 5 ~= 0 then return end

	-- Check if host is wearing a backpack
	-- If a backpack isn't being worn, stop running and clear the last stack

	local item = player:getItem(5)
	if not item or item.id ~= "backpacks:backpack" then
		last_stack, last_contents = nil, nil
		return
	end

	-- Get the stack of the backpack on this tick

	local stack = item:toStackString()

	-- Check if the stack hasn't been stored before
	-- If it hasn't then store it and wait for the next quarter second

	if not last_stack then
		last_stack, last_contents = stack, item.tag["minecraft:container"]
		return
	end

	---@cast last_stack string
	---@cast last_contents table[]

	-- Check if backpack contents changed

	if last_stack ~= stack then
		---@type table[]
		local contents = item.tag["minecraft:container"]

		---@type table<integer, true>
		local marked = {}

		-- Store last contents by slot

		---@type {id: string, count: integer, components: table?}[]
		local last = {}
		for i = 1, #last_contents do
			local slot = last_contents[i].slot + 1
			last[slot] = last_contents[i].item
			marked[slot] = true
		end

		-- Store current contents by slot

		---@type {id: string, count: integer, components: table?}[]
		local curr = {}
		for i = 1, #contents do
			local slot = contents[i].slot + 1
			curr[slot] = contents[i].item
			marked[slot] = true
		end

		-- Compare slots
		for slot in pairs(marked) do
			local last_item = last[slot] or {}
			local curr_item = curr[slot] or {}

			if last_item.id ~= curr_item.id then
				if last_item.id and curr_item.id then
					-- Item modified
					if last_item.id == curr_item.id then
						-- Item count changed
						if last_item.count < curr_item.count then
							log_changes(curr_item.id .. "\1" .. toJson(curr_item.components or {}) .. "\2" ..
								" increased by " .. curr_item.count - last_item.count ..
								" in slot " .. slot)
						else
							log_changes(curr_item.id .. "\1" .. toJson(curr_item.components or {}) .. "\2" ..
								" decreased by " .. last_item.count - curr_item.count ..
								" in slot " .. slot)
						end
					else
						-- Item replaced
						log_changes(last_item.count .. "x " .. last_item.id .. "\1" .. toJson(last_item.components or {}) .. "\2" ..
							" replaced with " .. curr_item.count .. "x " .. curr_item.id .. "\1" .. toJson(curr_item.components or {}) .. "\2" ..
							" in slot " .. slot)
					end
				elseif last_item.id then
					-- Item removed
					log_changes(last_item.count .. "x " .. last_item.id .. "\1" .. toJson(last_item.components or {}) .. "\2" ..
						" removed from slot " .. slot)
				else
					-- Item added
					log_changes(curr_item.count .. "x " .. curr_item.id .. "\1" .. toJson(curr_item.components or {}) .. "\2" ..
						" added to slot " .. slot)
				end
			end
		end

		last_stack, last_contents = stack, contents
	end
end
