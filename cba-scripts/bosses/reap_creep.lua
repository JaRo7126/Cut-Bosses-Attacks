local cba = CutBossesAttacks

function cba:ReapCreepTearsAttack(RC)

	if cba.Save.Config["General"]["ReapCreepRestore"] == true then 
		local data = cba.GetData(RC)
	
		if RC.State == 8 then --on tear attack
		
			for _, tear in ipairs(Isaac.FindByType(EntityType.ENTITY_PROJECTILE)) do --for each proj
				local tdata = cba.GetData(tear)
				
				if tear.SpawnerType == EntityType.ENTITY_REAP_CREEP 
				and not tdata.RC_mod_proj then
					local playerAngle = cba.GetAngle(Isaac.GetPlayer().Position - tear.Position) - 90 --player direction
					
					if playerAngle > 40 then
						playerAngle = 40
					elseif playerAngle < -40 then
						playerAngle = -40
					end
					
					tear.Velocity = tear.Velocity:Rotated(playerAngle)
					tdata.RC_mod_proj = true
				end
			end
			
		elseif RC.State == 14 then
		
			if #Isaac.FindInRadius(RC.Position, 10, EntityPartition.ENEMY) ~= 0 then --if there are spiders in 10 px(i think) radius
			
				for _, npc in ipairs(Isaac.FindInRadius(RC.Position, 10, EntityPartition.ENEMY)) do 
				
					if npc.Type == EntityType.ENTITY_SPIDER then --for each spider
					
						if not data.chance_calc then
							local chance = math.random(100)
							
							if chance <= 50 then --50% chance
								npc:Remove()
								data.RC_tritespawn = true --RC's spawning trite
								
								Isaac.Spawn(EntityType.ENTITY_HOPPER, 1, 0, npc.Position, npc.Velocity, RC):ToNPC().State = 4
							end
							
							data.chance_calc = true --chance has been calculated
						
						elseif data.RC_tritespawn then
						
							npc:Remove()
						end
					end
				end
			end
		elseif RC.State == 3 then --reset values on Idle
		
			if data.chance_calc then
				data.chance_calc = nil
			end
			
			if data.RC_tritespawn then
				data.RC_tritespawn = nil
			end
		end
	end
end

cba:AddCallback(ModCallbacks.MC_NPC_UPDATE, cba.ReapCreepTearsAttack, EntityType.ENTITY_REAP_CREEP)