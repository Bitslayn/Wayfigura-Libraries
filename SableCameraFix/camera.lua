--[[
____  ___ __   __
| __|/ _ \\ \ / /
| _|| (_) |> w <
|_|  \___//_/ \_\
FOX's Sable Camera Fix

Github: https://github.com/Bitslayn/Wayfigura-Libraries/blob/main/SableCameraFix
]]

if not host:isHost() then return end

function events.world_render(delta)
	if not player:isLoaded() then return end

	local vehicle = player:getVehicle()
	local is_sable = vehicle and vehicle:getPos():length() > 25000000
	local is_backwards = renderer:isCameraBackwards()

	-- Sourced from KingRoboLizard's snippet
	renderer:cameraRot(is_sable and ((player:getRot(delta).xy_ + vec(0, is_backwards and 180 or 0, 0))) * vec(is_backwards and -1 or 1, 1, 1) or nil)
end
