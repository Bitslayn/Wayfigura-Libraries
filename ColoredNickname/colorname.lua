--[[
____  ___ __   __
| __|/ _ \\ \ / /
| _|| (_) |> w <
|_|  \___//_/ \_\
FOX's Wayfarer Colored Nicknames

Github: https://github.com/Bitslayn/Wayfigura-Libraries/blob/main/ColoredNickname
]]

local uuids_cache = {}

---Synchronously gets the uuid from cache or from loaded players
---@param name string
local function get_uuid(name)
	if uuids_cache[name] then return uuids_cache[name] end

	-- Attempts to get the uuid from loaded players

	local plr = world.getPlayers()[name]
	local uuid = plr and plr:getUUID()
	uuids_cache[name] = uuid

	return uuid
end

---Asynchronously fetches the uuid from the username abusing skull NBT autofill
---@param name string
local function fetch_uuid(name)
	local skull = world.newItem(string.format("player_head{SkullOwner:%s}", name))

	local function tick()
		-- Read UUID provided to us by the game from the skull

		local i1, i2, i3, i4 = skull:toStackString():match("%[I;(%-?%d+),(%-?%d+),(%-?%d+),(%-?%d+)%]")
		if not i1 then return end
		uuids_cache[name] = client.intUUIDToString(i1, i2, i3, i4)

		events.tick:remove(tick)
	end
	events.tick:register(tick)
end

function events.chat_receive_message(_, raw)
	local comp = parseJson(raw)

	-- Ignore chat messages not sent by users

	if comp.translate ~= "chat.type.text" then return end

	-- Attempt to get the uuid when only the username is known

	local name = comp.with[1].insertion
	local uuid = get_uuid(name)
	if not uuid then return fetch_uuid(name) end

	-- Attempt to get the sender's avatar vars

	local vars = world.avatarVars()[uuid]
	if not vars then return end

	-- Attempt to color the nickname

	comp.with[1].color = vars.nick_color or vars.color
	return toJson(comp)
end
