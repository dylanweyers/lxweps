--Including serverside and clientside scripts
if (SERVER) then
	include("lweps/server/sv_lweps.lua")
	include("lweps/lweps_cfg.lua")
	AddCSLuaFile("lweps/client/cl_lweps.lua")
	AddCSLuaFile("lweps/lweps_cfg.lua")
else
	include("lweps/client/cl_lweps.lua")
end