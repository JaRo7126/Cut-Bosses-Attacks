local cba = CutBossesAttacks
local cfg = cba.Save.Config

function cba:VisageHeart(Visage) --visage heart's tear circle attack init
	if cfg["General"]["VisageRestore"] == true 
	and Visage.Variant == 0 
	and Visage.State == 116 then --weird state num, but ok
	
		for _, tear in ipairs(Isaac.FindInRadius(Visage.Position, 40, EntityPartition.BULLET)) do
			local tdata = cba.GetData(tear)
		
			if tear.SpawnerType == EntityType.ENTITY_VISAGE 
			and tear.SpawnerVariant == 0 
			and not tdata.VS_iotears then
			
				tear.Velocity = tear.Velocity:Normalized() * 15
				tear:ToProjectile().FallingAccel = -0.1
				
				tear:ToProjectile():AddProjectileFlags(ProjectileFlags.NO_WALL_COLLIDE)
				
				tdata.VS_iotears = {1, 15} --some useful data for later (1 - direction, 2 - speed)
			end
		end
	end
end

cba:AddCallback(ModCallbacks.MC_NPC_UPDATE, cba.VisageHeart, EntityType.ENTITY_VISAGE)

function cba:VisageTearLogic(Tear) --tear logic
	if cba.GetData(Tear).VS_iotears then
		local data = cba.GetData(Tear)
		
		if data.VS_iotears[1] == 1 then --direction "out"
			data.VS_iotears[2] = data.VS_iotears[2] - 0.5 --reduce speed
			
			if data.VS_iotears[2] == 0 then --on stop
			
				Tear.Velocity = Tear.Velocity:Normalized():Rotated(180) * 0.5 --turn proj back
				
				data.VS_iotears[1] = 2 --change direction to "in"
				
			else
			
				Tear.Velocity = Tear.Velocity:Normalized() * data.VS_iotears[2] --apply speed
			end
			
		elseif data.VS_iotears[1] == 2 then
			data.VS_iotears[2] = data.VS_iotears[2] + 0.5 --increase speed
			
			if data.VS_iotears[2] == 15 then --on max speed
			
				Tear.Height = -4 --force tear to fall
			else
			
				Tear.Velocity = Tear.Velocity:Normalized() * data.VS_iotears[2] --apply speed
			end
		end
	end
end

cba:AddCallback(ModCallbacks.MC_POST_PROJECTILE_UPDATE, cba.VisageTearLogic, 0)