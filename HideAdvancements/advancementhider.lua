--[[
____  ___ __   __
| __|/ _ \\ \ / /
| _|| (_) |> w <
|_|  \___//_/ \_\
FOX's Wayfarer Advancement Hider

Github: https://github.com/Bitslayn/Wayfigura-Libraries/blob/main/HideAdvancements
]]

function events.chat_receive_message(_, raw)
	local comp = parseJson(raw)

	-- Look for and hide advancements in chat

	if comp.translate:find("chat.wayfarer_core.achievement") then
		return false
	end
end
