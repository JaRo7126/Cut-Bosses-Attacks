local cba = CutBossesAttacks

local cfg = cba.Save.Config

------------------------------
----------Mom's Foot----------
------------------------------

local directions = {
	[7] = Vector(0, 1),
	[60] = Vector(1, 0),
	[74] = Vector(-1, 0),
	[127] = Vector(0, -1)
}
function cba:MomArmAttack(Mom)
	if Mom.Variant == 0 and Mom.SubType == 3 and cfg["General"]["MomRestore"] == true then
		local data = cba.GetData(Mom)
	
		if Mom.State == 10 and not data.chance_calc then --on enemy spawn attack
			local chance = math.random(100)
			
			if chance <= cfg["Mom"]["ArmSpawnChance"] then
			
				Mom.State = 9 --set needed state
				Mom:GetSprite():Play("ArmOpen", true) --play anim
			end
			
			data.chance_calc = true
			
		elseif Mom.State == 11 and not data.chance_calc then --on eye attack
			local chance = math.random(100)
			
			if chance <= cfg["Mom"]["ArmEyeChance"] then
			
				Mom.State = 9 --same actions
				Mom:GetSprite():Play("ArmOpen", true)
			end
			
			data.chance_calc = true
			
		elseif Mom.State == 8 and Mom:GetSprite():GetFrame() == 25 then --on eye looking anim
		
			Mom.State = 9 --same actions
			Mom:GetSprite():Play("ArmOpen", true)
			
		elseif Mom.State == 9 then --on hand attack
		
			if data.chance_calc then --reset values
				data.chance_calc = nil
			end
			
			if Mom:GetSprite():GetFrame() == 10 then
				local dir = directions[Game():GetRoom():GetGridIndex(Mom.Position)]
				
				for i = -2, 2 do --spawn a few bouncy projs
				
					local velocity = (dir * 10):Rotated(20 * i)
					
					local proj = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, 0, 0, Mom.Position + dir * 80, velocity, Mom):ToProjectile()
					proj:AddProjectileFlags(ProjectileFlags.BOUNCE)
					
					proj.Height = -30
					proj.Scale = 1.5
				end
			end
			
		elseif Mom.State == 3 and data.chance_calc then --on Idle
			data.chance_calc = nil --reset values
			
		end
	end
end

cba:AddCallback(ModCallbacks.MC_NPC_UPDATE, cba.MomArmAttack, EntityType.ENTITY_MOM)

function cba:MomFootAttack(effect)
	if cfg["General"]["MomRestore"] == true 
	and effect.SpawnerEntity 
	and effect.SpawnerType == EntityType.ENTITY_MOM 
	and effect.SpawnerVariant == 10 
	and effect.SpawnerEntity.SubType == 3 then --if it's mom's crackwave
	
		if effect.Variant == EffectVariant.CRACKWAVE then
			local var = Game():GetLevel():GetStageType() == StageType.STAGETYPE_REPENTANCE_B and 2 or 1 --floor variations
			
			local fire = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.FIRE_WAVE, var, effect.Position, effect.Velocity, effect.SpawnerEntity):ToEffect()
			
			fire.Rotation = effect.Rotation
			fire.Parent = effect.Parent
			effect:Remove() --remove crackwave
			
		elseif effect.Variant == EffectVariant.POOF02 
		and (effect.SubType == 3 or effect.SubType == 4) then --colorizing blood poof
		
			local color = Color(1, 1, 1, 1)
			color:SetColorize(5, 1, 5, 1)
			
			if Game():GetLevel():GetStageType() == StageType.STAGETYPE_REPENTANCE_B then
				color:SetColorize(5, 1, 1, 1)
			end
			
			effect:GetSprite().Color = color
		end
	end
end

cba:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, cba.MomFootAttack)

function cba:MomFootFix(Mom, dmg, dmgflags, source, frames)
	if source.Entity 
	and source.Entity.SpawnerEntity 
	and source.Entity.SpawnerEntity.Type == EntityType.ENTITY_MOM then --fire cannot damage mom
		return false
	end
end

cba:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, cba.MomFootFix, EntityType.ENTITY_MOM)

-------------------------------
----------Mom's Heart----------
-------------------------------

cba.MMHSummonTable = {
	{
		{EntityType.ENTITY_EYE, 2, 0, Vector(-180, 0), Vector(180, 0)},
		{EntityType.ENTITY_BLURB, 3, 0, Vector(-40, 0), Vector(40, 0), Vector(0, 40)},
		{EntityType.ENTITY_WHIPPER , 3, 0, Vector(-40, 0), Vector(40, 0), Vector(0, 40)}
	},
	{
		{EntityType.ENTITY_EYE, 2, 1, Vector(-180, 0), Vector(180, 0)},
		{EntityType.ENTITY_BUBBLES, 2, 0, Vector(-40, 0), Vector(40, 0)},
		{EntityType.ENTITY_WHIPPER , 2, 1, Vector(-40, 0), Vector(40, 0)}
	},
	{
		{EntityType.ENTITY_HEART , 4, 1, Vector(-40, 0), Vector(40, 0), Vector(0, 40), Vector(0, -40), 1},
		{EntityType.ENTITY_BOUNCER , 2, 0, Vector(-40, 0), Vector(40, 0)},
		{EntityType.ENTITY_WHIPPER, 2, 2, Vector(-40, 0), Vector(40, 0)}
	}
}
local SummonTable = cba.MMHSummonTable

function cba:MomHeartAttacks(Heart)
	if cfg["General"]["HeartRestore"] == true and Heart.Variant == 0 and Heart.SubType == 1 then 
		local data = cba.GetData(Heart)
		local anim = Heart:GetSprite():GetAnimation()
		
		if Heart.State == 8 then --if shooting projs
		
			if not data.chance_calc then
				local chance = math.random(2)
				
				if chance == 2 then --50% chance
					data.IsMausoleumHeartSummoning = true
					Heart.State = 3
					
					local state
					
					if anim == "Heartbeat1" then
						state = 1
						
					elseif anim == "Heartbeat2" then 
						state = 2
						
					elseif anim == "Heartbeat3" 
					and Heart.HitPoints > Heart.MaxHitPoints / 10 then 
						state = 3
						
					end --getting phase
					
					if state then
					
						if state ~= 3 then
							data.MMH_enttcount = 0 --count for additional spawned enemies
						else
							data.MMH_enttcount = nil
						end
						
						local groupType = math.random(3) --randomize enemies
						data.MMH_enttgroup = {groupType, state} --saving these enemies for later
						
						for i = 1, SummonTable[state][groupType][2] do
							local subtype

							if SummonTable[state][groupType][#SummonTable[state][groupType]] and (i == 2 or i == 3) then
								subtype = 1
							end
							
							local enemy = Isaac.Spawn(SummonTable[state][groupType][1],
							SummonTable[state][groupType][3], 
							subtype or 0,
							Heart.Position + SummonTable[state][groupType][3 + i], 
							Vector(0,0),
							Heart)
							
							cba.GetData(enemy).MMH_fromheart = true
							
						end
					end
					
					SFXManager():Play(SoundEffect.SOUND_SUMMONSOUND) --play sound
				end
				
				data.chance_calc = true
			end
		elseif Heart.State ~= 8 and data.chance_calc then --reset values
			data.chance_calc = nil
		end
	end
end

cba:AddCallback(ModCallbacks.MC_NPC_UPDATE, cba.MomHeartAttacks, EntityType.ENTITY_MOMS_HEART)

cba:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function(_, npc, _, _, source)
	if npc.Variant == 0 and npc.SubType == 1 and source.Entity and cba.GetData(source.Entity).MMH_fromheart then
		return false --enemies summoned by heart cannot damage it
	end
end, EntityType.ENTITY_MOMS_HEART)

function cba:MomHeartNPCDeath(npc)
	if npc.SpawnerEntity and cba.GetData(npc.SpawnerEntity).MMH_enttcount 
	and (cba.GetData(npc.SpawnerEntity).MMH_enttcount < 2 
	or (cba.GetData(npc.SpawnerEntity).MMH_enttcount < 3 
	and (npc.Type == EntityType.ENTITY_GUSHER or npc.Type == EntityType.ENTITY_BLURB))) then
		local newtype
		
		if npc.Type == EntityType.ENTITY_GUSHER then --fix for blurb's body
			newtype = EntityType.ENTITY_BLURB
		end
		
		local pos = {math.random(80, 260), math.random(380, 560)}
		pos = pos[math.random(2)] --randomizing position
		
		--spawn additional enemy--
		local enemy = Isaac.Spawn(newtype or npc.Type, npc.Variant, npc.SubType, Vector(pos, 160), Vector(0, 0), npc.SpawnerEntity)

		cba.GetData(npc.SpawnerEntity).MMH_enttcount = cba.GetData(npc.SpawnerEntity).MMH_enttcount + 1 --increase count
	end
end

cba:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, cba.MomHeartNPCDeath)

cba:AddCallback(ModCallbacks.MC_POST_NPC_INIT, function(_, npc)
	local stage = Game():GetLevel():GetStage()
	local stype = Game():GetLevel():GetStageType()
	if not (
		(
			(stage == LevelStage.STAGE1_1 or stage == LevelStage.STAGE1_2) 
			and (stype == StageType.STAGETYPE_REPENTANCE or stype == StageType.STAGETYPE_REPENTANCE_B)
		)
		or (
			(stage == LevelStage.STAGE2_1 or stage == LevelStage.STAGE2_2) 
			and stype == StageType.STAGETYPE_AFTERBIRTH
		)
	) then --not in downpour, dross and flooded caves
	
		--new bubbles sprites--
		npc:GetSprite():ReplaceSpritesheet(0, "gfx/monsters/repentance/806.000_bubbles_normal.png", true)
		npc:GetSprite():ReplaceSpritesheet(1, "gfx/monsters/repentance/806.000_bubbles_normal.png", true)
	end
end, EntityType.ENTITY_BUBBLES)