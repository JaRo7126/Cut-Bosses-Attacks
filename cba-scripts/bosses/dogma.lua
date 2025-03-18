local cba = CutBossesAttacks

local cfg = cba.Save.Config

function cba:DogmaAttacks(Dogma)
	if cfg["General"]["DogmaRestore"] == true then
		local data = cba.GetData(Dogma) --Dogma's data
		local anim = Dogma:GetSprite():GetAnimation()
		local frame = Dogma:GetSprite():GetFrame()
		
		----------------------------------------	
		---------------2'nd Phase---------------
		----------------------------------------
		
		if Dogma.Variant == 2 then
		
			if Dogma.State == 10 then --On Spining attack
			
				if not data.chance_calc and cfg["Dogma"]["BlackHole"] == true then --check for chance
				
					local chance = math.random(100)
					if chance <= cfg["Dogma"]["BlackHoleChance"] then
						SFXManager():Stop(SoundEffect.SOUND_DOGMA_RING_START) --pause spining sound
						data.D_blackhole = true
						Dogma.State = 7 --special state
						Dogma.Velocity = Vector(0, 0) --stop Dogma
						Dogma:GetSprite():Play("RingStart", true) --play anim
						SFXManager():Play(SoundEffect.SOUND_DOGMA_BLACKHOLE_CHARGE) --play bh sound
					end
					data.chance_calc = true --set that chance is calculated
					
				elseif cfg["Dogma"]["AngelSummon"] == true then --spawn babies on spin attack
				
					if not data.D_spinframes then data.D_spinframes = 0 end --set frames variable
					data.D_spinframes = data.D_spinframes + 1 --add 1 every frame
					if data.D_spinframes == 90 then --if enough time has passed
						local minus = math.random(-1, 0) == -1 and -1 or 1 --randomizing negative dir
						local pos = Isaac.GetPlayer().Position + Vector(math.random(80, 160) * minus, math.random(80, 160) * minus)
						Isaac.Spawn(EntityType.ENTITY_DOGMA, 10, 0, pos, Vector(0,0), Dogma)
						data.D_spinframes = 0 --reset timer
					end
					
				end
				
			elseif Dogma.State == 3 and data.chance_calc then --on Idle
				data.chance_calc = nil --reset values
				
			elseif data.D_blackhole then --Blackhole attack logic
				if anim == "RingStart" and frame == 28 then
					Dogma:GetSprite():Play("RingEnd", true) --anim stuff
				elseif anim == "RingEnd" then
					if frame == 1 then
						local vel = (Isaac.GetPlayer().Position - Dogma.Position):Normalized() * 20 --to player dir
						Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.DOGMA_BLACKHOLE, 0, Dogma.Position, vel, Dogma)
						SFXManager():Play(SoundEffect.SOUND_DOGMA_BLACKHOLE_SHOOT)
					elseif frame == 26 then
						Dogma:GetSprite():Play("Idle", true) --anim stuff
					end
				elseif anim == "Idle" then
					if #Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.DOGMA_BLACKHOLE) == 0 then --if there is no blackholes
						Dogma.State = 3 --reset state
						data.D_blackhole = nil --reset values
					end
					Dogma.Velocity = (Isaac.GetPlayer().Position - Dogma.Position):Normalized() --a little bit of movement to player dir
				end
			end
			
		----------------------------------------	
		---------------1'st Phase---------------
		----------------------------------------
			
		elseif Dogma.Variant == 0 then
		
			if Dogma.State >= 8 and Dogma.State <= 11 then --if doing specific attacks
			
				if not data.chance_calc2 then --chance check
					local chance = math.random(100)
					if chance <= cfg["Dogma"]["BlackHoleChance1"] then
						Dogma.State = 12 --set blackhole state
						data.D_blackhole = true --set values
						Dogma:GetSprite():Play("BlackholeAttack", true) --anim stuff
						SFXManager():Stop(SoundEffect.SOUND_DOGMA_BRIMSTONE_CHARGE) --pause brim noise
						SFXManager():Play(SoundEffect.SOUND_DOGMA_BLACKHOLE_CHARGE) --play blackhole sound
					end
					data.chance_calc2 = true --chance has been calculated
				end
				
			elseif data.D_blackhole then --Blackhole attack logic
				if anim == "BlackholeAttack" and frame == 74 then
					Dogma:GetSprite():Play("Idle", true) --anim stuff
				elseif Dogma:GetSprite():GetAnimation() == "Idle" then
					if #Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.DOGMA_BLACKHOLE) == 0 then --if there is no blackholes
						Dogma.State = 3 --reset state
						data.D_blackhole = nil --reset values
					end
				end
				
			elseif Dogma.State == 3 and data.chance_calc2 then --reset values on Idle
				data.chance_calc2 = nil
			end
		end
	end
end

cba:AddCallback(ModCallbacks.MC_NPC_UPDATE, cba.DogmaAttacks, EntityType.ENTITY_DOGMA)

function cba:DogmaBlackHole(Hole) --Blackhole projs' speed cap
	if cfg["Dogma"]["BlackHoleCap"] == true then
	
		for _, proj in ipairs(Isaac.FindByType(EntityType.ENTITY_PROJECTILE)) do --for every proj...
		
			if proj.SpawnerType == EntityType.ENTITY_DOGMA and proj.SpawnerVariant ~= 1 then --...that dogma spawned
			
				local cap = (proj.Velocity:Normalized() * 10)
				
				if proj.Velocity.X > cap.X or proj.Velocity.Y > cap.Y then --set speed cap
				
					proj.Velocity = cap
					
				end
			end
		end
	end
end

cba:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, cba.DogmaBlackHole, EffectVariant.DOGMA_BLACKHOLE)

function cba:DogmaAngelsSpeedUp(Angel) --speeding up dogma's babies a little

	if Angel.Variant == 10 and Angel.State ~= 1 and Angel.State ~= 8 then
	
		Angel.State = 8
		
	end
end

cba:AddCallback(ModCallbacks.MC_NPC_UPDATE, cba.DogmaAngelsSpeedUp, EntityType.ENTITY_DOGMA)

function cba:DogmaAngelsFix(Angel, _, _, source) --Dogma CANNOT damage it's babies

	if Angel.Variant == 10 and source.Type == EntityType.ENTITY_DOGMA then
	
		return false
		
	end
end

cba:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, cba.DogmaAngelsFix, EntityType.ENTITY_DOGMA)