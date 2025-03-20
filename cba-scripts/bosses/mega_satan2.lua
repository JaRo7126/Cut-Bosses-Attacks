local cba = CutBossesAttacks

local cfg = cba.Save.Config

local handsanm = "gfx/cba/bosses/mega_satan/275.001_megasatan2hand.anm2" --new hands gfx paths
local rhandgfx = "gfx/cba/bosses/mega_satan/megasatan_righthand.png"
local lhandgfx = "gfx/cba/bosses/mega_satan/megasatan_lefthand.png"


function cba:MegaSatanMSsUpdate(MS)
	if cfg["General"]["MegaSatanRestore"] == true then 
		local data = cba.GetData(MS)
		
		----------------------------------
		-------------MS logic-------------
		----------------------------------
		
		if MS.Variant == 0 then
	
	
			if not data.MS_hands then --if MS don't have his hands
			
				data.MS_hands = {}
				data.MS_handtimer = {}
				
				for i = 0, 1 do --spawn his hands for him
					
					local pos = Vector(240 + 160 * i, 340)
					local hand = Isaac.Spawn(EntityType.ENTITY_MEGA_SATAN_2, i + 1, 0, pos, Vector(0, 0), MS):ToNPC()
					
					hand:GetSprite():Load(handsanm, true) --load gfx
					hand:GetSprite():ReplaceSpritesheet(0, i == 1 and rhandgfx or lhandgfx, true)
					
					hand.State = 3 --reset state
					hand.MaxHitPoints = cfg["MS2"]["HandsHP"] --set HP
					hand.HitPoints = cfg["MS2"]["HandsHP"]
					hand.Parent = MS --set MS as parent
					hand:SetInvincible(false) --set that hand can be damaged
					hand:GetSprite().Color.A = 0 --fade in anim start
					hand:SetShadowSize(0) --remove shadow
					hand.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE --remove collision
					hand.Visible = true --set visible
					
					cba.GetData(hand).MS_ishand = true --set data hook
					data.MS_hands[i + 1] = hand --add hand ref
					data.MS_handtimer[i + 1] = 0 --reset without-hands timer
					
				end
				
			elseif data.MS_hands then --if MS "have" his hands
				for i, hand in pairs(data.MS_hands) do
				
					if not hand:Exists() then --if hand died
						data.MS_handtimer[i] = data.MS_handtimer[i] + 1 --start timer
						if data.MS_handtimer[i] == 600 then --if enough time has passed
							
							local pos = Vector(MS.Position.X - 80 + 160 * (i - 1), MS.Position.Y + 100)
							local newhand = Isaac.Spawn(EntityType.ENTITY_MEGA_SATAN_2, i, 0, pos, Vector(0, 0), MS):ToNPC() --spawn new hand
							
							newhand:GetSprite():Load(handsanm, true)
							newhand:GetSprite():ReplaceSpritesheet(0, i == 2 and rhandgfx or lhandgfx, true)
							
							--same actions as above--
							
							newhand.State = 3
							newhand.MaxHitPoints = cfg["MS2"]["HandsHP"]
							newhand.HitPoints = cfg["MS2"]["HandsHP"]
							newhand.Parent = MS
							newhand:SetInvincible(false)
							newhand:GetSprite().Color.A = 0
							newhand:SetShadowSize(0)
							newhand.Visible = true
							newhand.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
							
							cba.GetData(newhand).MS_ishand = true
							data.MS_hands[i] = newhand
							data.MS_handtimer[i] = 0
						end
					end
					
				end
			end
			
			if MS.State == 9 and not data.chance_calc then --if MS is attacking
				local chance = math.random(100)
				
				if chance <= cfg["MS2"]["AttackChance"] 
				and (data.MS_hands[1]:Exists() or data.MS_hands[2]:Exists()) then --if at least 1 hand exists
				
					data.MS_handattack = 1 --set hand attack start state
					MS.State = 3 --prevent MS from attacking
					
				end
				
				data.chance_calc = true --chance has been calculated
				
			elseif data.MS_handattack then --on hand attack
			
				if MS.State ~= 3 then --prevent MS from attacking
					MS.State = 3
				end
				
				if not data.chance_calc2 then --if hand hasn't attacked yet
					local num = math.random(2) --randomizing attacking hand
					
					if data.MS_hands[num]:Exists() and data.MS_hands[num].FrameCount > 20 then --if selected hand exists enough time
						
						data.MS_hands[num].State = 8 --ATTACK
						data.MS_handattack = 2 --set hand attack state
					
					else
						num = num == 1 and 2 or 1 --select other hand
						
						if data.MS_hands[num]:Exists() and data.MS_hands[num].FrameCount > 20 then --same check from above
							
							data.MS_hands[num].State = 8 --same actions
							data.MS_handattack = 2
						
						else
						
							data.MS_handattack = nil --prevent hands from attacking
							return
						
						end
					end
					
					data.chance_calc2 = true --chance has been calculated
					
				end
				
			elseif MS.State == 3 then --reset values on Idle

				if data.chance_calc then
					data.chance_calc = nil 
				end
				
				if not data.MS_handattack and data.chance_calc2 then 
					data.chance_calc2 = nil 
				end
				
				if data.MS_handattack and not(data.MS_hands[1]:Exists() or data.MS_hands[2]:Exists()) then 
					data.MS_handattack = nil 
				end
			
			end
		end
			
		------------------------------------
		-----------MS hands logic-----------
		------------------------------------
		
		if (MS.Variant == 1 or MS.Variant == 2) and data.MS_ishand then
		
			if MS.State == 3 and MS.Parent then --If Idle and has parent
			
				if MS.Parent:ToNPC().State == 2 then --If parent is appearing
					MS:SetInvincible(true) --set invulnerable
					
				elseif MS.Parent:ToNPC().State == 16 then --If parent is dying
					MS:Kill() --die
					
				elseif MS.Parent:ToNPC().State ~= 2 and MS:GetSprite().Color.A < 1 then --fade in anim stuff
				
					MS:SetShadowSize(0)
					MS:SetInvincible(true)
					MS:GetSprite().Color.A = MS:GetSprite().Color.A + 0.05
					
				else --If both Idle
				
					if MS:GetShadowSize() == 0 then
						MS:SetShadowSize(60) --add shadow
					end
					
					if MS:IsInvincible() == true then
						MS:SetInvincible(false) --set vulnerable
					end
					
					if MS.EntityCollisionClass == EntityCollisionClass.ENTCOLL_NONE then
						MS.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL --add collision
					end
				end
				
				if data.chance_calc then --reset values
					data.chance_calc = nil 
				end
				
				if data.MS_handattack_type then
					data.MS_handattack_type = nil 
				end
				
				MS.TargetPosition = Vector(MS.Parent.Position.X - 80 + 160 * (MS.Variant - 1), MS.Parent.Position.Y + 100) --movement logic (kinda)
				
				if cba.GetData(MS.Parent).MS_handattack == 2 then
					cba.GetData(MS.Parent).MS_handattack = nil
				end
				
			elseif not MS.SpawnerEntity and MS.FrameCount > 1 then --fix for bug that i don't remember
				MS:Remove()
				
				
			elseif MS.State == 8 then --if hand is ATTACKING
			
				if not data.chance_calc then --randomize attack pattern
					data.MS_handattack_type = math.random(6)
					data.chance_calc = true
					
				elseif MS:GetSprite():GetAnimation() == "SmashHand1" then --if animating attack
				
					if data.MS_handattack_type == 1 
					and MS:GetSprite():GetFrame() > 29 
					and MS:GetSprite():GetFrame() < 37 
					and MS:GetSprite():GetFrame() % 3 == 0 then --1'st pattern
						local speed = 10
						local num = 16
						local angleStep = 360 / num
						
						for i = 0, num - 1 do
							local angle = i * angleStep
							local velocity = Vector(speed * math.cos(math.rad(angle)), speed * math.sin(math.rad(angle)))
							
							local fire = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, ProjectileVariant.PROJECTILE_FIRE, 0, MS.Position, velocity, MS):ToProjectile()
							fire:ClearProjectileFlags(ProjectileFlags.HIT_ENEMIES) --fire can hit only player
							cba.GetData(fire).MS_handfire = true
							
							fire.FallingAccel = -0.1 --fire cannot fall
							fire.Color = Color(2, 1.8, 1.8, 1) --color stuff
							fire:GetSprite().Color:SetOffset(0, -1, -1)
							
						end
						
					elseif data.MS_handattack_type == 2 and MS:GetSprite():GetFrame() == 31 then --2'nd pattern (brimstone)
						local angle = math.random(0, 1)
						
						for i = 0, 3 do
							local laser = Isaac.Spawn(EntityType.ENTITY_LASER, LaserVariant.THICK_RED, 0, MS.Position, Vector(0,0), MS):ToLaser()
							
							laser.AngleDegrees = 90 * i - (45 * angle) --set direction
							laser.Timeout = 30
						end
						
					elseif data.MS_handattack_type == 3 
					and MS:GetSprite():GetFrame() > 29 
					and MS:GetSprite():GetFrame() < 40 
					and MS:GetSprite():GetFrame() % 3 == 0 then --3'rd pattern
						local speed = 10
						local tearCount = 12
						local angleStep = 360 / tearCount
						
						for i = 0, tearCount - 1 do
							local angle = i * angleStep
							local velocity = Vector(speed * math.cos(math.rad(angle)), speed * math.sin(math.rad(angle)))
							
							local fire = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, ProjectileVariant.PROJECTILE_FIRE, 0, MS.Position, velocity, MS):ToProjectile()
							fire:ClearProjectileFlags(ProjectileFlags.HIT_ENEMIES)
							fire:AddProjectileFlags(ProjectileFlags.SAWTOOTH_WIGGLE) --Z-like movement
							cba.GetData(fire).MS_handfire = true
							
							fire.FallingAccel = -0.1
							fire:GetSprite().Color:SetColorize(1, 1, 1, 1)
						end
						
					elseif data.MS_handattack_type == 4 
					and (MS:GetSprite():GetFrame() == 30 or MS:GetSprite():GetFrame() == 42) then --4'th pattern
						local speed = 5
						local tearCount = 12
						local angleStep = 360 / tearCount
						
						for i = 0, tearCount - 1 do
							local angle = i * angleStep
							local velocity = Vector(speed * math.cos(math.rad(angle)), speed * math.sin(math.rad(angle)))
							
							local fire = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, ProjectileVariant.PROJECTILE_FIRE, 0, MS.Position, velocity, MS):ToProjectile()
							fire:ClearProjectileFlags(ProjectileFlags.HIT_ENEMIES)
							cba.GetData(fire).MS_circle_curve_dir = MS:GetSprite():GetFrame() == 30 and 1 or -1
							cba.GetData(fire).MS_circle_center = MS.Position
							cba.GetData(fire).MS_circle_curve_speed = 2.5
							cba.GetData(fire).MS_handfire = true
							
							fire.FallingAccel = -0.1
							fire:GetSprite().Color:SetColorize(1.3, 1, 2, 1)
						end
						
					elseif data.MS_handattack_type == 5 
					and (MS:GetSprite():GetFrame() == 31 or MS:GetSprite():GetFrame() == 37) then --5'th pattern
						local speed = 5
						local tearCount = 12
						local angleStep = 360 / tearCount
						
						for i = 0, tearCount - 1 do
							local angle = i * angleStep
							local velocity = Vector(speed * math.cos(math.rad(angle)), speed * math.sin(math.rad(angle)))
							
							local fire = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, ProjectileVariant.PROJECTILE_FIRE, 0, MS.Position, velocity, MS):ToProjectile()
							fire:ClearProjectileFlags(ProjectileFlags.HIT_ENEMIES)
							fire:AddProjectileFlags(ProjectileFlags.BURST) --cricket's body burst
							cba.GetData(fire).MS_handfire = true
							
							fire.FallingAccel = -0.1
							fire:GetSprite().Color:SetColorize(1, 0.4, 0, 1)
						end
						
					elseif data.MS_handattack_type == 6 
					and MS:GetSprite():GetFrame() > 29 
					and MS:GetSprite():GetFrame() < 40 
					and MS:GetSprite():GetFrame() % 3 == 0 then --6'th pattern
						local speed = 7.5
						local tearCount = 16
						local angleStep = 360 / tearCount
						
						for i = 0, tearCount - 1 do
							local angle = i * angleStep
							local velocity = Vector(speed * math.cos(math.rad(angle)), speed * math.sin(math.rad(angle)))
							
							local fire = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, ProjectileVariant.PROJECTILE_FIRE, 0, MS.Position, velocity, MS):ToProjectile()
							fire:ClearProjectileFlags(ProjectileFlags.HIT_ENEMIES)
							fire:AddProjectileFlags(ProjectileFlags.MEGA_WIGGLE)
							fire:AddProjectileFlags(ProjectileFlags.SINE_VELOCITY) --cool weird pattern from one of MS attacks
							cba.GetData(fire).MS_handfire = true
							
							fire.FallingAccel = -0.1
							fire:GetSprite().Color:SetColorize(0.5, 0.5, 0.5, 1)
						end
					end
					
					if data.MS_handattack_type and MS:GetSprite():GetFrame() == 31 then --change shockwave to cool fire circle
						
						for _, shockwave in ipairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.SHOCKWAVE)) do --remove all shockwaves
							
							if shockwave.SpawnerEntity 
							and shockwave.SpawnerEntity:GetData().MS_handattack_type == data.MS_handattack_type then
								shockwave:Remove()
							end
						end
						
						local color = Color(1, 1, 1, 1) --set color based on attack color
						if data.MS_handattack_type == 1 then
							color = Color(2, 1.8, 1.8, 1)
							color:SetOffset(0, -1, -1)
						elseif data.MS_handattack_type == 2 then
							color:SetColorize(1, 0, 0, 1)
						elseif data.MS_handattack_type == 3 then
							color:SetColorize(1, 1, 1, 1)
						elseif data.MS_handattack_type == 4 then
							color:SetColorize(1.3, 1, 2, 1)
						elseif data.MS_handattack_type == 5 then
							color:SetColorize(1, 0.4, 0, 1)
						elseif data.MS_handattack_type == 6 then
							color:SetColorize(0.5, 0.5, 0.5, 1)
						end
						
						local speed = 5
						local tearCount = 24
						local angleStep = 360 / tearCount
						
						for i = 0, tearCount - 1 do --spawn fires
							local angle = i * angleStep
							local velocity = Vector(speed * math.cos(math.rad(angle)), speed * math.sin(math.rad(angle)))
							
							local fire = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, ProjectileVariant.PROJECTILE_FIRE, 0, MS.Position, velocity, MS):ToProjectile()
							fire:ClearProjectileFlags(ProjectileFlags.HIT_ENEMIES)
							fire:AddProjectileFlags(ProjectileFlags.DECELERATE)
							
							fire:GetSprite().Color = color
						end
					end
				end
			end
		end	
	end
end

cba:AddCallback(ModCallbacks.MC_NPC_UPDATE, cba.MegaSatanMSsUpdate, EntityType.ENTITY_MEGA_SATAN_2)

cba:AddCallback(ModCallbacks.MC_POST_PROJECTILE_UPDATE, function(_, fire)
	local data = cba.GetData(fire)
	
	if data.MS_handfire then 
	
		if fire.SpawnerEntity 
		and fire.SpawnerEntity.Parent 
		and fire.SpawnerEntity.Parent.State ~= 3 then --prevent MS from attacking if there are still fires on screen
		
			fire.SpawnerEntity.Parent:ToNPC().State = 3
		end
	end
	
	if Game():GetRoom():GetBossID() == 55 
	and Game():GetRoom():GetGridIndex(fire.Position) == -1 --if fire is behind screen
	and (cba.GetData(fire).MS_handfire or fire.FrameCount > 120) then
		fire.Height = -4 --remove fire
	end
	
	if data.MS_circle_curve_dir then
		posOffset = Vector(2.5, 0):Rotated((fire.Position - data.MS_circle_center):GetAngleDegrees())
		targetPos = (fire.Position + posOffset - data.MS_circle_center):Rotated(data.MS_circle_curve_dir * 1) + data.MS_circle_center
		fire.Velocity = (targetPos - fire.Position) * data.MS_circle_curve_speed
	end
	
end, ProjectileVariant.PROJECTILE_FIRE)

cba:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function(_, entity, dmg, dmgflags, source)

	if source.Entity and source.Entity.Type == EntityType.ENTITY_MEGA_SATAN_2 then --hands and MS cannot damage each other
		return false
	end
end, EntityType.ENTITY_MEGA_SATAN_2)
