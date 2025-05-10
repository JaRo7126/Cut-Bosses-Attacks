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
		
		if data.SH_frames_without_attack >= math.floor(60 + 440 * healthPercent) then
		
			SH.State = NpcState.STATE_ATTACK --math.random(NpcState.STATE_ATTACK, NpcState.STATE_ATTACK4)
			
			data.SH_frames_without_attack = 0
		end
		
	elseif state == NpcState.STATE_ATTACK then
	
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