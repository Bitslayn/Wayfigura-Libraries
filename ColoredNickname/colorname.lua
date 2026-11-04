--[[
____  ___ __   __
| __|/ _ \\ \ / /
| _|| (_) |> w <
|_|  \___//_/ \_\
FOX's Wayfarer Colored Nicknames

Github: https://github.com/Bitslayn/Wayfigura-Libraries/blob/main/ColoredNickname
]]

if not client.isModLoaded("wayfarer_core") then return end

local colors = {}

-- Initialization

local set_target
avatar:store("colorname$auth", function()
	return set_target
end)

avatar:store("colorname$set", function(uuid, nick, color)
	local vars = world.avatarVars()[uuid]
	if vars["colorname$auth"]() ~= avatar:getUUID() then return end
	if type(nick) ~= "string" then return end
	if type(color) ~= "string" then return end

	colors[nick] = color
end)

local function post_init()
	pcall(function()
		local viewer = client.getViewer()
		local vars, uuid = viewer:getVariable(), viewer:getUUID()

		set_target = uuid
		vars["colorname$set"](uuid, vars.nickname, vars.nick_color)
		set_target = nil
	end)
end

local function wait()
	post_init()
	events.tick:remove(wait)
end
events.tick:register(wait)

-- Chat messages

function events.chat_receive_message(_, raw)
	local comp = parseJson(raw)

	-- Ignore chat messages not sent by users

	if comp.translate ~= "chat.type.text" then return end

	-- Attempt to get the uuid when only the username is known

	local nick = comp.with[1].insertion
	if not nick then return end

	-- Attempt to color the nickname

	comp.with[1].color = colors[nick]
	return toJson(comp)
end
