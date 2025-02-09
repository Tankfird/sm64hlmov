-- name: BOB Island TAS run
-- incompatible:
local TOOLS = _G.TAS


hook_event(HOOK_ON_MODS_LOADED, function()
	TOOLS = _G.TAS
end)

hook_event(HOOK_ON_LEVEL_INIT, function()
	-- prevent this from loading inputs multiple times
	if (final ~= nil) then return end
	final = true
	
	-- first param is offset from last frame (if 0 it will run on the same frame as the last input / very start of the run if its the first input)
	-- then, it's the button mask, yaw speed, pitch speed, joystick x and finally joystick y
	
	TOOLS.AddWarp(0, 9, 1, 1)
	TOOLS.AddAuto(15,A_BUTTON,-18000)
	TOOLS.AddAuto(15,A_BUTTON,-16000)
	TOOLS.AddAuto(10,A_BUTTON,-5000)
	TOOLS.AddAuto(8,A_BUTTON,-9000)
	TOOLS.AddAuto(20,A_BUTTON,-7000)
	TOOLS.AddAuto(30,A_BUTTON,-6000)
	TOOLS.AddAuto(18,A_BUTTON,-8000)
	TOOLS.AddAuto(8,0,-10000)
	TOOLS.AddInputs(1,Z_TRIG, 0, 0, 0, 0)
	TOOLS.AddAuto(18,A_BUTTON,-10000)
	TOOLS.AddAuto(10,A_BUTTON,-11000)
	TOOLS.AddAuto(5,A_BUTTON,-13000)
	TOOLS.AddAuto(2,0,-14000)
	TOOLS.AddInputs(1,Z_TRIG, 0, 0, 0, 0)
	TOOLS.AddAuto(10,A_BUTTON,-13000)
	TOOLS.AddAuto(6,0,-13000)
	TOOLS.AddInputs(1,Z_TRIG, 0, 0, 0, 0)
	TOOLS.AddInputs(1,A_BUTTON, 7000, 0, 0, 0)
	TOOLS.AddAuto(12,A_BUTTON,-6000)
	TOOLS.AddAuto(6,B_BUTTON,-2800)
	TOOLS.AddAuto(30,A_BUTTON,-31000)
	TOOLS.AddAuto(12,A_BUTTON,-29000)
	TOOLS.AddInputs(1,Z_TRIG, 0, 0, 0, 0)
	TOOLS.AddInputs(1,0, 0, 0, 0, 0)
	TOOLS.AddInputs(1,Z_TRIG, 0, 0, 0, 0)
	TOOLS.AddInputs(1,A_BUTTON, 0, 0, 0, 0)
	--TOOLS.AddInputs(1,START_BUTTON, 0, 0, 0, 0)
	TOOLS.AddInputs(20,0, 0, 0, 0, 0)
	TOOLS.Play()
end)

