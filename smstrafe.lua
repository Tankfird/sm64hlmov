-- name: TAS Strafe Helper
-- incompatible:
local stickTable = {}

local floor = math.floor
local sqrt = math.sqrt



-- Physics helpers, not very clean atm, eventually should just get access directly
local SurfaceStandableMinimum = {
	[SURFACE_CLASS_NOT_SLIPPERY] = 0.01,
	[SURFACE_HARD_NOT_SLIPPERY] = 0.01,
	[SURFACE_CLASS_SLIPPERY] = 0.7,
	[SURFACE_HARD_SLIPPERY] = 0.7,
	[SURFACE_NO_CAM_COL_SLIPPERY] = 0.7,
	[SURFACE_NOISE_SLIPPERY] = 0.7,
	[SURFACE_SLIPPERY] = 0.7,
	[SURFACE_CLASS_VERY_SLIPPERY] = 0.8,
	[SURFACE_HARD_VERY_SLIPPERY] = 0.8,
	[SURFACE_NO_CAM_COL_VERY_SLIPPERY] = 0.8,
	[SURFACE_VERY_SLIPPERY] = 0.8,
	[SURFACE_NOISE_VERY_SLIPPERY] = 0.8,
	[SURFACE_NOISE_VERY_SLIPPERY_73] = 0.8,
	[SURFACE_NOISE_VERY_SLIPPERY_74] = 0.8
} 						     

local SurfaceFriction = {
	[SURFACE_CLASS_NOT_SLIPPERY] = 1.0,
	[SURFACE_HARD_NOT_SLIPPERY] = 1.0,
	[SURFACE_CLASS_SLIPPERY] = 0.8,
	[SURFACE_HARD_SLIPPERY] = 0.8,
	[SURFACE_NO_CAM_COL_SLIPPERY] = 0.8,
	[SURFACE_NOISE_SLIPPERY] = 0.8,
	[SURFACE_SLIPPERY] = 0.8,
	[SURFACE_CLASS_VERY_SLIPPERY] = 0.4,
	[SURFACE_HARD_VERY_SLIPPERY] = 0.4,
	[SURFACE_NO_CAM_COL_VERY_SLIPPERY] = 0.4,
	[SURFACE_VERY_SLIPPERY] = 0.4,
	[SURFACE_NOISE_VERY_SLIPPERY] = 0.4,
	[SURFACE_NOISE_VERY_SLIPPERY_73] = 0.4,
	[SURFACE_NOISE_VERY_SLIPPERY_74] = 0.4
}

local AreaTypeFriction = {
	[TERRAIN_SLIDE] = 0.225, -- incase i wanna give other types different friction values
	[TERRAIN_SNOW] = 0.90 -- incase i wanna give other types different friction values
}
local AreaTypeStandable = {
	[TERRAIN_SLIDE] = 2.75, 
	[TERRAIN_SNOW] = 1.10
}

local function SV_GetAreaFriction(type) 
	if AreaTypeFriction[type] ~= nil then return AreaTypeFriction[type] end
	return 1.0
end
local function SV_GetAreaStandable(type) 
	if AreaTypeStandable[type] ~= nil then return AreaTypeStandable[type] end
	return 1.0
end

local function SV_GetSurfaceStandableMinimum(type,areaType) 
	areaFactor = SV_GetAreaStandable(areaType)
	standableMinimum = 0.675
	if SurfaceStandableMinimum[type] ~= nil then standableMinimum = SurfaceStandableMinimum[type] end
	return clampf(standableMinimum * areaFactor,0.01,0.999)
end

local function SV_GetSurfaceStandableFrictionMultiplier(type,areaType)
	areaFactor = SV_GetAreaFriction(areaType)
	standableMinimum = 1.0
	if SurfaceFriction[type] ~= nil then standableMinimum = SurfaceFriction[type] end
	return clampf(standableMinimum * areaFactor,0.01,1.0)
end



local function getStickAngles(ang)
	local s0 = 1
	local s1 = 1
	local s2 = 1

	if (ang > 32768 or ang < -32768) then
		--Rewrite to convert into range
		print("Problem Angle OOB: " .. ang)
		return {x = 0, y = 0, d = 0}
	end

	if (ang < 0) then
		s0 = -1
		ang = -ang
	end
	if (ang >= 16384) then
        s1 = -1
        ang = 32768 - ang
	end
    if (ang > 8192) then
        s2 = -1
        ang = 16384 - ang
	end
    local stick = {x = 0, y = 0, d = 0}
	if (stickTable[ang] == nil) then
		print("Problem Angle: "..ang)
		return stick
	end
    if (s2 > 0) then
		stick.x = s1 * stickTable[ang].x
        stick.y = s0 * stickTable[ang].y
        stick.d = s2 * stickTable[ang].d
    else
        stick.x = s1 * stickTable[ang].y
        stick.y = s0 * stickTable[ang].x
        stick.d = s2 * stickTable[ang].d
	end
    return stick
end

local function tasAuto(frameData, m) 
	local gCurrentFrameInputs = 0
	local gJoystickX = 0
	local gJoystickY = 0
	local gJoystickMag = 0
	local gYawSpeed = 0
	local gPitchSpeed = 0

	local currVel = sqrt(m.vel.x*m.vel.x + m.vel.z*m.vel.z)
	--print(string.format("%.2f ",currVel))
	local airAccel = 0
	local groundAccel = -1
	local friction = 0.8*SV_GetSurfaceStandableFrictionMultiplier(m.floor.type,m.area.terrainType)
	
	-- Hacky 1073742848 seems to represent onground, probably should change
	if (m.action == 1073742848) then 
		--Adjust to actual formulas at some point
		airAccel = sqrt(currVel*currVel + 30*30)
		groundAccel = sqrt(friction*friction*currVel*currVel + 18000)
	end
	if (airAccel < groundAccel) then 
		if (currVel < 150) then 
			gJoystickX = 0
			gJoystickY = 127
			gJoystickMag = 127
			gFirstPersonCamera.yaw = frameData.tYaw
		else
			local inputYaw = floor(math.acos(120/(friction*currVel)) * 32768 / math.pi)
			local velYaw = atan2s(-m.vel.z, -m.vel.x)
			local deltaYaw = frameData.tYaw - velYaw
			deltaYaw = ((deltaYaw + 32768) % 65536) - 32768

			if (deltaYaw > 0) then
				inputYaw = inputYaw - deltaYaw
				sInputs = getStickAngles(inputYaw)
			else 
				inputYaw = -inputYaw - deltaYaw
				sInputs = getStickAngles(inputYaw)
			end
			
			gJoystickX = -sInputs.y
			gJoystickY = sInputs.x
			gJoystickMag = 127
			gFirstPersonCamera.yaw = frameData.tYaw
		end
	else	
		gCurrentFrameInputs = frameData.buttons
		-- added 0.01 as a small epsilon for float math
		if (currVel+0.01 < 30) then
			gFirstPersonCamera.yaw = frameData.tYaw
			gJoystickX = 0
			gJoystickY = 127
			gJoystickMag = 127
		else
			if (true) then
				local prevYaw = frameData.tYaw
				if (gFirstPersonCamera ~= nil) then 
					prevYaw = gFirstPersonCamera.yaw
				end
				local prevYawDelta = ((frameData.tYaw - prevYaw + 32768) % 65536) - 32768
				local velYaw = atan2s(-m.vel.z, -m.vel.x)
				local deltaYaw = frameData.tYaw - velYaw
				deltaYaw = ((deltaYaw + 32768) % 65536) - 32768
				local yawSign = deltaYaw > 0

				if (prevYawDelta * deltaYaw > 0) then
					--If they are the same sign, velocity yaw 
					deltaYaw = 0
					gFirstPersonCamera.yaw = velYaw
				else
					-- Otherwise, TargetYaw
					gFirstPersonCamera.yaw = frameData.tYaw
				end

				local sInputs = {x = 0, y = 0, d = 0}
				if (yawSign) then
					sInputs = getStickAngles(16384 - deltaYaw)
				else 
					sInputs = getStickAngles(-16384 - deltaYaw)
				end
				gJoystickX = -sInputs.y
				gJoystickY = sInputs.x
				gJoystickMag = 127
			else
				-- Old Naive Strafing, Look at velocity, input orthogonal to velocity
				local velYaw = atan2s(-m.vel.z, -m.vel.x)
				local deltaYaw = frameData.tYaw - velYaw
				if (deltaYaw < 0) then
					gJoystickX = 127
				else 
					gJoystickX = -127
				end
				if (math.abs(deltaYaw) > 32768) then
					gJoystickX = -1 * gJoystickX
				end
				
				gJoystickY = 0
				gJoystickMag = 127
				gYawSpeed = velYaw - gFirstPersonCamera.yaw
			end
		end
	end
	return gCurrentFrameInputs, gJoystickX, gJoystickY, gJoystickMag, gYawSpeed, gPitchSpeed
end

hook_event(HOOK_ON_MODS_LOADED, function()
	stickTable = _G.vTable.getTable()
end)

local api = {
	tasAuto = tasAuto
}

_G.smstrafe = api


