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
			local item = world.newItem(substring)
			extra[#extra + 1] = {
				text = item:getName(),
				color = rarity_colors[item:getRarity()],
				hoverEvent = { contents = { id = item.id, components = parseJson(substring:match("\1(.*)\2")) }, action = "show_item" },
			}
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

		---@type table<integer, string>
		local last = {}
		for i = 1, #last_contents do
			local slot = last_contents[i].slot + 1
			last[slot] = last_contents[i].item.id ..
			"\0" .. last_contents[i].item.count .. "\0\1" .. toJson(last_contents[i].item.components or {}) .. "\2"
			marked[slot] = true
		end

		-- Store current contents by slot

		---@type table<integer, string>
		local curr = {}
		for i = 1, #contents do
			local slot = contents[i].slot + 1
			curr[slot] = contents[i].item.id .. "\0" .. contents[i].item.count .. "\0\1" .. toJson(contents[i].item.components or {}) .. "\2"
			marked[slot] = true
		end

		-- Compare slots
		for slot in pairs(marked) do
			local last_id, last_count, last_components = string.match(last[slot] or "", "(.*)\0(.*)\0(.*)")
			local curr_id, curr_count, curr_components = string.match(curr[slot] or "", "(.*)\0(.*)\0(.*)")

			if last[slot] ~= curr[slot] then
				if last[slot] and curr[slot] then
					-- Item modified
					if last_id == curr_id then
						-- Item count changed
						last_count = tonumber(last_count)
						curr_count = tonumber(curr_count)

						if last_count < curr_count then
							log_changes(curr_id .. curr_components .. " increased by " .. curr_count - last_count .. " in slot " .. slot)
						else
							log_changes(curr_id .. curr_components .. " decreased by " .. last_count - curr_count .. " in slot " .. slot)
						end
					else
						-- Item replaced
						log_changes(last_id .. last_components .. " replaced with " .. curr_id .. curr_components .. " in slot " .. slot)
					end
				elseif last[slot] then
					-- Item removed
					log_changes(last_id .. last_components .. " removed from slot " .. slot)
				else
					-- Item added
					log_changes(curr_id .. curr_components .. " added to slot " .. slot)
				end
			end
		end

		last_stack, last_contents = stack, contents
	end
end
