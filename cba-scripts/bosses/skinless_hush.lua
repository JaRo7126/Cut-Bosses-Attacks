local cba = CutBossesAttacks
----!!!WIP!!!----
cba.Save.Config["SkinlessHush"] = {
	["IsSkinlessWomb"] = false
}

function cba:IsSkinlessHushRoom()
	local room = Game():GetRoom()
	
	return cba.IsSkinlessWombRoom() and room:GetType() == RoomType.ROOM_BOSS and room:GetBossID() == 63
end

--Behavior--

function cba:SHInit(SH)
	SH:GetSprite():Load("gfx/cba/bosses/skinless_hush/408.000_hush_skinless.anm2", true)
	SH:GetSprite():Play("Appear", true)
	SH.Visible = false
	--SH.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
	SH.MaxHitPoints = 6666
	SH.HitPoints = 6666
	SH:SetShieldStrength(100)
	cba.GetData(SH).SH_frames_without_attack = 0
	cba.GetData(SH).SH_frames_attacking = 0
end


cba:AddCallback(ModCallbacks.MC_POST_NPC_INIT, cba.SHInit, EntityType.ENTITY_HUSH_SKINLESS)


function cba:SHUpdate(SH)

	if SH.Type ~= EntityType.ENTITY_HUSH_SKINLESS then
		return 
	end
	
	local data = cba.GetData(SH)
	local target = SH:GetPlayerTarget()
	local state = SH.State
	local sprite = SH:GetSprite()
	local anim = sprite:GetAnimation()
	local frame = sprite:GetFrame()
	local healthPercent = SH.HitPoints / SH.MaxHitPoints
	
	if not PlayerManager.IsCoopPlay() then
		Game():GetRoom():GetCamera():SetFocusPosition(SH.Position + (target.Position - SH.Position) / 2)
	end
	
	if state == NpcState.STATE_INIT and anim == "Appear" then
	
		if frame < 150 then
		
			if SH.Visible ~= false then
				SH.Visible = false
			end
			
			if frame > 1 and frame < 148 and frame % 37 == 0 then
				SFXManager():Play(SoundEffect.SOUND_FORESTBOSS_STOMPS)
			end

		elseif frame == 150 then
			SH.Visible = true
			
			SFXManager():Play(SoundEffect.SOUND_HELLBOSS_GROUNDPOUND)
			SFXManager():Play(SoundEffect.SOUND_DEATH_BURST_LARGE)
			
			Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 3, SH.Position, Vector(0, 0), SH)
			Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 4, SH.Position, Vector(0, 0), SH)
			Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 5, SH.Position, Vector(0, 0), SH)
			
			for i = 0, 25 do
				Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_PARTICLE, 0, SH.Position, Vector(math.random(-10, 10), math.random(-10, 10)), SH)
			end
			
		elseif frame > 154 and frame < 178 then
			
			if frame == 155 then
				SFXManager():Play(SoundEffect.SOUND_BEAST_SWITCH_SIDES)
			end
			
			if frame % 2 == 1 then
				
				for i = 0, 1 do
					local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BIG_ATTRACT, 10 + i, SH.Position, Vector(0, 0), SH):ToEffect()
					
					effect:SetTimeout(10)
					effect:GetSprite().Color = Color(1, 0, 0, 1)
				end
			
			end
	
		elseif sprite:IsFinished() then
			SH.State = NpcState.STATE_IDLE
			sprite:Play("Idle")
		end
		
	elseif state == NpcState.STATE_IDLE then
		data.SH_frames_without_attack = data.SH_frames_without_attack + 1
		SH.Velocity = Vector(0, 0)
		
		if data.SH_frames_without_attack >= math.floor(60 + 440 * healthPercent) then
		
			SH.State = NpcState.STATE_ATTACK2 --math.random(NpcState.STATE_ATTACK, NpcState.STATE_ATTACK4)
			
			data.SH_frames_without_attack = 0
		end
		
	elseif state == NpcState.STATE_ATTACK then
		SH.Velocity = Vector(0, 0)
	
		if anim == "Idle" then
			sprite:Play("AttackStart", true)
			
		elseif anim == "AttackStart" and sprite:IsFinished() then
			
			local angle = cba.GetAngle(target.Position - SH.Position)
			
			for i = 0, 1 do
			
				local brim = Isaac.Spawn(EntityType.ENTITY_LASER, LaserVariant.THICK_RED, 0, SH.Position, Vector(0, 0), SH):ToLaser()
				brim.Parent = SH
				brim.AngleDegrees = angle + (i == 0 and 60 or -60)
				brim:SetActiveRotation(0, angle + (i == 0 and 20 or -20), i == 0 and -0.25 or 0.25, false)
				brim:SetTimeout(180)
				
				cba.GetData(brim).SH_atk1_brim_frames = 0
			end
				
			sprite:Play("AttackLoop")
			
		elseif anim == "AttackEnd" and sprite:IsFinished() then
		
			SH.State = NpcState.STATE_IDLE
			sprite:Play("Idle")
		end
		
	elseif state == NpcState.STATE_ATTACK2 then
	
		if anim == "Idle" then
			data.SH_charge_vel = (target.Position - SH.Position):Normalized() * 25
			data.SH_charge_count = 0
			sprite:Play("AttackStart", true)
			
		elseif anim == "AttackStart" and sprite:IsFinished() then
			sprite:Play("AttackLoop", true)
		
		elseif anim == "AttackLoop" then
			SH.Velocity = data.SH_charge_vel
			
			if data.SH_charge_wallhit then
				local room = Game():GetRoom()
			
				if SH.GridCollisionClass ~= EntityGridCollisionClass.GRIDCOLL_NONE then
					SH.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
				end
				
				if room:GetGridIndex(SH.Position) == -1 then
					
					if data.SH_charge_count < 4 then
						local positions = {
						Vector(60, math.random(120, room:GetBottomRightPos().Y - 80)),
						Vector(room:GetBottomRightPos().X - 60, math.random(120, room:GetBottomRightPos().Y - 80)),
						Vector(math.random(120, room:GetBottomRightPos().X - 80), 60),
						Vector(math.random(120, room:GetBottomRightPos().X - 80), room:GetBottomRightPos().Y - 60),
						}
						
						SH.Position = positions[math.random(4)]
					else
						SH.Position = room:GetCenterPos()
					end
					
					SH.Visible = false
					data.SH_charge_wait = 60
					data.SH_charge_count = data.SH_charge_count + 1
					data.SH_charge_wallhit = nil
					data.SH_charge_vel = Vector(0, 0)
					SH.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
				end
				
			elseif data.SH_charge_wait then
				data.SH_charge_wait = data.SH_charge_wait - 1
				
				if data.SH_charge_wait == 0 then
					SH.Visible = true
					
					if data.SH_charge_count < 5 then
						data.SH_charge_vel = (target.Position - SH.Position):Normalized() * 25
						SH.Velocity = data.SH_charge_vel
					else
						data.SH_charge_count = nil
						sprite:Play("AttackEnd", true)
					end
						
					data.SH_charge_wait = nil
				end
			end
			
		elseif anim == "AttackEnd" and sprite:IsFinished() then
			SH.State = NpcState.STATE_IDLE
			sprite:Play("Idle")
		end
	end
end


cba:AddCallback(ModCallbacks.MC_NPC_UPDATE, cba.SHUpdate)


function cba:SHLaserUpdate(laser)
	local data = cba.GetData(laser)
	
	if data.SH_atk1_brim_frames and laser.Parent then
		data.SH_atk1_brim_frames = data.SH_atk1_brim_frames + 1
	
		if data.SH_atk1_brim_frames % 20 == 0 then
			local dir = Vector.FromAngle(laser.AngleDegrees)
			local start = laser.Position + dir * 80
			local count = (laser:GetEndPoint() - laser.Position):Rotated(laser.AngleDegrees * -1).X // 80
			
			for i = 0, count do
				local pos = start + dir * i * 80
				
				for p = 0, 1 do
					local velocity = dir:Rotated(p == 0 and 90 or -90) * 8
					local proj = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, ProjectileVariant.PROJECTILE_HUSH, 0, pos, velocity, laser.Parent):ToProjectile()
					
					proj.FallingAccel = -0.1
					
					proj:GetSprite().Color:SetColorize(1, 0, 0, 1)
				end
			end
			
			if data.SH_atk1_brim_frames == 40 then
				data.SH_atk1_brim_frames = 0
			end
		end
	
		if laser.Timeout == 1 then
			laser.Parent:GetSprite():Play("AttackEnd", true)
		end
	end
end


cba:AddCallback(ModCallbacks.MC_POST_LASER_UPDATE, cba.SHLaserUpdate)


function cba:SHWallHit(SH, Idx, Wall)
	local data = cba.GetData(SH)
	
	if Wall 
	and Wall:GetType() == GridEntityType.GRID_WALL 
	and SH.State == NpcState.STATE_ATTACK2
	and not data.SH_charge_wallhit then
		local room = Game():GetRoom()
	
		local wall_angle = cba.GetAngle(room:GetGridPosition(Idx) - SH.Position)
		local vel_angle = cba.GetAngle(data.SH_charge_vel)
		
		if vel_angle < 45 or vel_angle > 315 then
			
			if wall_angle >= vel_angle - 45 
			or wall_angle <= vel_angle + 45 then
				
				data.SH_charge_wallhit = true
				Game():ShakeScreen(10)
			end
		else
			if wall_angle >= vel_angle - 45 
			and wall_angle <= vel_angle + 45 then
			
				data.SH_charge_wallhit = true
				Game():ShakeScreen(10)
			end
		end
	end
end


cba:AddCallback(ModCallbacks.MC_PRE_NPC_GRID_COLLISION, cba.SHWallHit, EntityType.ENTITY_HUSH_SKINLESS)