--[[
____  ___ __   __
| __|/ _ \\ \ / /
| _|| (_) |> w <
|_|  \___//_/ \_\
FOX's Backpack Fix

Github: https://github.com/Bitslayn/Wayfigura-Libraries/blob/main/BackpackFix
]]

function events.tick()
	local item = player:getItem(5)
	local is_backpack = item and (item.id == "wayward:backpack" or item.id == "wayward:rucksack")
	vanilla_model.CHESTPLATE:visible(is_backpack)
end
