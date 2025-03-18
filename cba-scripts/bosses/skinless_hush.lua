local cba = CutBossesAttacks
----!!!WIP!!!----
cba.Save.Config["SkinlessHush"] = {
	["IsSkinlessWomb"] = false
}
--Stage--

cba:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_UPDATE, function(_, familiar)
	local data = Game():GetLevel():GetCurrentRoomDesc().Data
	if data and data.Type == RoomType.ROOM_DEFAULT and data.Variant == 1 and data.Subtype == 1 and data.StageID == 13 and cba.Save.Config["SkinlessHush"]["IsSkinlessWomb"] == false then
		if tostring(familiar.Position) ~= "320 280" then
			familiar.Position = Vector(320, 280)
		end
		if familiar:GetSprite():GetAnimation()~= "SWOpen" then
			familiar:GetSprite():Load("gfx/full_knife_SH_anim.anm2", true)
			familiar:GetSprite():Play("SWOpen", true)
		elseif familiar:GetSprite():GetFrame() > 15 and familiar:GetSprite():GetFrame() < 33 and familiar:GetSprite():GetFrame() % 2 == 0 then
			SFXManager():Play(SoundEffect.SOUND_DEATH_BURST_LARGE)
		elseif familiar:GetSprite():GetFrame() == 33 then
			Game():GetRoom():SetBackdropType(Isaac.GetBackdropIdByName("SkinlessWombCBA"), 1)
			Game():SetColorModifier(ColorModifier(1, 0, 0, 0.5, 0.01, 1), false, 0)
			for i = 0, Game():GetRoom():GetGridSize() do
				local grid = Game():GetRoom():GetGridEntity(i)
				if grid then 
					if ((grid:GetType() >= GridEntityType.GRID_ROCK and grid:GetType() <= GridEntityType.GRID_ROCK) or grid:GetType() == GridEntityType.GRID_ROCK_SS or (grid:GetType() >= GridEntityType.GRID_ROCK_SPIKED and grid:GetType() <= GridEntityType.GRID_ROCK_GOLD)) then
						grid:GetSprite():ReplaceSpritesheet(0, "gfx/grid/rocks_utero.png", true)
						grid:GetSprite():ReplaceSpritesheet(1, "gfx/grid/rocks_utero.png", true)
					elseif grid:GetType() == GridEntityType.GRID_PIT then
						grid:GetSprite():ReplaceSpritesheet(0, "gfx/grid/grid_pit_utero.png", true)
						grid:GetSprite():ReplaceSpritesheet(1, "gfx/grid/grid_pit_utero.png", true)
					elseif grid:GetType() == GridEntityType.GRID_DECORATION	then
						grid:GetSprite():ReplaceSpritesheet(0, "gfx/grid/props_07_utero.png", true)
						grid:GetSprite():ReplaceSpritesheet(1, "gfx/grid/props_07_utero.png", true)
					elseif grid:GetType() == GridEntityType.GRID_TRAPDOOR then
						grid:GetSprite():ReplaceSpritesheet(0, "gfx/grid/door_11_wombhole.png", true)
					end
				end
			end
			Game():GetRoom():SetWaterAmount(2)
			Game():GetRoom():SetWaterColor(KColor(0.5, 0, 0, 0.3))
			for _, slot in ipairs({DoorSlot.UP0, DoorSlot.LEFT0, DoorSlot.RIGHT0, DoorSlot.DOWN0}) do
				if Game():GetRoom():GetDoor(slot) then
					for i = 0, 5 do
						Game():GetRoom():GetDoor(slot):GetSprite():ReplaceSpritesheet(i, "gfx/grid/door_29_doortobluewomb.png", true)
					end
				end
			end
		elseif familiar:GetSprite():IsFinished() == true then
			familiar:Remove()
			if familiar.Player then
				familiar.Player:RemoveCollectible(CollectibleType.COLLECTIBLE_KNIFE_PIECE_1)
				familiar.Player:RemoveCollectible(CollectibleType.COLLECTIBLE_KNIFE_PIECE_2)
			end
			cba.Save.Config["SkinlessHush"]["IsSkinlessWomb"] = true
		end
		return true
	end
end, FamiliarVariant.KNIFE_FULL)

cba:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
	local data = Game():GetLevel():GetCurrentRoomDesc().Data
	if data and data.Type == RoomType.ROOM_DEFAULT and data.Variant == 1 and data.Subtype == 1 and data.StageID == 13 and cba.Save.Config["SkinlessHush"]["IsSkinlessWomb"] == true then
		Game():GetRoom():SetBackdropType(Isaac.GetBackdropIdByName("SkinlessWombCBA"), 1)
		for i = 0, Game():GetRoom():GetGridSize() do
			local grid = Game():GetRoom():GetGridEntity(i)
			if grid then 
				if ((grid:GetType() >= GridEntityType.GRID_ROCK and grid:GetType() <= GridEntityType.GRID_ROCK) or grid:GetType() == GridEntityType.GRID_ROCK_SS or (grid:GetType() >= GridEntityType.GRID_ROCK_SPIKED and grid:GetType() <= GridEntityType.GRID_ROCK_GOLD)) then
					grid:GetSprite():ReplaceSpritesheet(0, "gfx/grid/rocks_utero.png", true)
					grid:GetSprite():ReplaceSpritesheet(1, "gfx/grid/rocks_utero.png", true)
				elseif grid:GetType() == GridEntityType.GRID_PIT then
					grid:GetSprite():ReplaceSpritesheet(0, "gfx/grid/grid_pit_utero.png", true)
					grid:GetSprite():ReplaceSpritesheet(1, "gfx/grid/grid_pit_utero.png", true)
				elseif grid:GetType() == GridEntityType.GRID_DECORATION	then
					grid:GetSprite():ReplaceSpritesheet(0, "gfx/grid/props_07_utero.png", true)
					grid:GetSprite():ReplaceSpritesheet(1, "gfx/grid/props_07_utero.png", true)
				elseif grid:GetType() == GridEntityType.GRID_TRAPDOOR then
					grid:GetSprite():ReplaceSpritesheet(0, "gfx/grid/door_11_wombhole.png", true)
				end
			end
		end
		Game():GetRoom():SetWaterAmount(2)
		Game():GetRoom():SetWaterColor(KColor(0.5, 0, 0, 0.3))
		for _, slot in ipairs({DoorSlot.UP0, DoorSlot.LEFT0, DoorSlot.RIGHT0, DoorSlot.DOWN0}) do
			if Game():GetRoom():GetDoor(slot) then
				for i = 0, 5 do
					Game():GetRoom():GetDoor(slot):GetSprite():ReplaceSpritesheet(i, "gfx/grid/door_29_doortobluewomb.png", true)
				end
			end
		end
	elseif Game():GetLevel():GetStage() == LevelStage.STAGE4_3 and cba.Save.Config["SkinlessHush"]["IsSkinlessWomb"] == true then
		if Game():GetRoom():GetBackdropType() == BackdropType.BLUE_WOMB then
			Game():GetRoom():SetBackdropType(Isaac.GetBackdropIdByName("SkinlessWombCBA"), 1)
			for i = 0, Game():GetRoom():GetGridSize() do
				local grid = Game():GetRoom():GetGridEntity(i)
				if grid then 
					if ((grid:GetType() >= GridEntityType.GRID_ROCK and grid:GetType() <= GridEntityType.GRID_ROCK) or grid:GetType() == GridEntityType.GRID_ROCK_SS or (grid:GetType() >= GridEntityType.GRID_ROCK_SPIKED and grid:GetType() <= GridEntityType.GRID_ROCK_GOLD)) then
						grid:GetSprite():ReplaceSpritesheet(0, "gfx/grid/rocks_utero.png", true)
						grid:GetSprite():ReplaceSpritesheet(1, "gfx/grid/rocks_utero.png", true)
					elseif grid:GetType() == GridEntityType.GRID_PIT then
						grid:GetSprite():ReplaceSpritesheet(0, "gfx/grid/grid_pit_utero.png", true)
						grid:GetSprite():ReplaceSpritesheet(1, "gfx/grid/grid_pit_utero.png", true)
					elseif grid:GetType() == GridEntityType.GRID_DECORATION	then
						grid:GetSprite():ReplaceSpritesheet(0, "gfx/grid/props_07_utero.png", true)
						grid:GetSprite():ReplaceSpritesheet(1, "gfx/grid/props_07_utero.png", true)
					end
				end
			end
		end
		Game():GetRoom():SetWaterAmount(2)
		Game():GetRoom():SetWaterColor(KColor(0.5, 0, 0, 0.3))
		if Game():GetLevel():GetCurrentRoomDesc().GridIndex == 84 then
			for i = 0, 4 do
				Game():GetRoom():GetDoor(DoorSlot.UP0):GetSprite():ReplaceSpritesheet(i, "gfx/grid/skinlesshush_door.png", true)
			end
		elseif Game():GetLevel():GetCurrentRoomDesc().GridIndex == 58 then
			for i = 0, 4 do
				Game():GetRoom():GetDoor(DoorSlot.DOWN0):GetSprite():ReplaceSpritesheet(i, "gfx/grid/skinlesshush_door.png", true)
			end
			if Game():GetRoom():GetDoor(DoorSlot.UP1) then
				for i = 0, 4 do
					Game():GetRoom():GetDoor(DoorSlot.UP1):GetSprite():ReplaceSpritesheet(i, "gfx/grid/skinlesshush_door.png", true)
				end
			end
		elseif Game():GetLevel():GetCurrentRoomDesc().GridIndex == -9 then
			for i = 0, 4 do
				Game():GetRoom():GetDoor(DoorSlot.DOWN0):GetSprite():ReplaceSpritesheet(i, "gfx/grid/skinlesshush_door.png", true)
			end
		end
	end
end)
cba:AddCallback(ModCallbacks.MC_POST_RENDER, function()
	if Game():GetLevel():GetStage() == LevelStage.STAGE4_3 and cba.Save.Config["SkinlessHush"]["IsSkinlessWomb"] == true and Game():GetRoom():GetBossID() == 63 and RoomTransition.IsRenderingBossIntro() == true then
		local sprite = RoomTransition.GetVersusScreenSprite()
		sprite:ReplaceSpritesheet(0, "gfx/ui/boss/ground_skinlesshush.png", true)
		sprite:ReplaceSpritesheet(2, "gfx/ui/boss/bossspot_skinlesshush.png", true)
		sprite:ReplaceSpritesheet(3, "gfx/ui/boss/playerspot_skinlesswomb.png", true)
		sprite:ReplaceSpritesheet(4, "gfx/ui/boss/portrait_408.0_skinlesshush.png", true)
		sprite:ReplaceSpritesheet(7, "gfx/ui/boss/bossname_408.0_skinlesshush.png", true)
	end
end)
cba:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, function()
	if Game():GetLevel():GetStage() == LevelStage.STAGE4_3 and cba.Save.Config["SkinlessHush"]["IsSkinlessWomb"] == true then
		Game():GetLevel():SetName("¿¿¿")
		Game():GetLevel():GetRoomByIdx(58).Data = RoomConfigHolder.GetRoomByStageTypeAndVariant(StbType.SPECIAL_ROOMS, RoomType.ROOM_BOSS, 8040)
		for _, chest in ipairs(Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_LOCKEDCHEST)) do
			chest:Remove()
		end
		if GODMODE then
			for _, keys in ipairs(Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Isaac.GetCardIdByName("Key Cluster (8)"))) do
				keys:Remove()
			end
		end
		Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_REDCHEST, 0, Vector(200, 360), Vector(0, 0), nil)
		Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_REDCHEST, 0, Vector(200, 480), Vector(0, 0), nil)
		Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_REDCHEST, 0, Vector(440, 360), Vector(0, 0), nil)
		Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_REDCHEST, 0, Vector(440, 480), Vector(0, 0), nil)
	elseif Game():GetLevel():GetStage() ~= LevelStage.STAGE4_3 and Game():GetLevel():GetStage() ~= LevelStage.STAGE4_2 and cba.Save.Config["SkinlessHush"]["IsSkinlessWomb"] == true then
		cba.Save.Config["SkinlessHush"]["IsSkinlessWomb"] = false
	end
end)
local doorSlotToRoom = {
	[DoorSlot.UP0] = -13,
	[DoorSlot.LEFT0] = -1,
	[DoorSlot.RIGHT0] = 1,
	[DoorSlot.DOWN0] = 13
}
cba:AddCallback(ModCallbacks.MC_PRE_GRID_ENTITY_DOOR_RENDER, function(_, door)
	if Game():GetLevel():GetStage() == LevelStage.STAGE4_3 and cba.Save.Config["SkinlessHush"]["IsSkinlessWomb"] == true then
		if doorSlotToRoom[door.Slot] then
			local Idx = Game():GetLevel():GetCurrentRoomDesc().GridIndex + doorSlotToRoom[door.Slot]
			if Idx ~= 4 and Idx ~= 46 and Idx ~= 58 and Idx ~= 59 and Idx ~= 71 and Idx ~= 72 and Idx ~= 84 and Idx ~= 96 and Idx ~= 97 and Idx ~= 98 and Idx ~= 110 then
				SFXManager():Stop(SoundEffect.SOUND_UNLOCK00)
				Game():GetRoom():RemoveGridEntityImmediate(Game():GetRoom():GetGridIndex(door.Position), 0, false)
				Isaac.GridSpawn(GridEntityType.GRID_WALL, 0, door.Position, true)
				Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 4, door.Position, Vector(0, 0), nil)
				SFXManager():Play(SoundEffect.SOUND_HEARTOUT)
			end
		end
	end
end)
cba:AddCallback(ModCallbacks.MC_PRE_MUSIC_PLAY, function(id)
	if Game():GetLevel():GetStage() == LevelStage.STAGE4_3 and cba.Save.Config["SkinlessHush"]["IsSkinlessWomb"] == true then
		if Game():GetRoom():GetType() == RoomType.ROOM_DEFAULT or Game():GetRoom():GetType() == RoomType.ROOM_TREASURE or Game():GetRoom():GetType() == RoomType.ROOM_SHOP and id ~= Isaac.GetMusicIdByName("Skinless Womb") and id ~= Music.MUSIC_JINGLE_NIGHTMARE then
			return Isaac.GetMusicIdByName("Skinless Womb")
		elseif Game():GetRoom():GetType() == RoomType.ROOM_BOSS and not Game():GetRoom():IsClear() and id ~= Isaac.GetMusicIdByName("Skinless Hush") and id ~= Music.MUSIC_JINGLE_BOSS and RoomTransition.IsRenderingBossIntro() == false then
			return Isaac.GetMusicIdByName("Skinless Hush")
		end
	end
end)

cba:AddCallback(ModCallbacks.MC_POST_RENDER, function()
	local data = Game():GetLevel():GetCurrentRoomDesc().Data
	if (Game():GetLevel():GetStage() == LevelStage.STAGE4_3 or(data and data.Type == RoomType.ROOM_DEFAULT and data.Variant == 1 and data.Subtype == 1 and data.StageID == 13)) and cba.Save.Config["SkinlessHush"]["IsSkinlessWomb"] == true then
		if Game():GetCurrentColorModifier().R ~= 1
		or Game():GetCurrentColorModifier().G ~= 0
		or Game():GetCurrentColorModifier().B ~= 0
		or Game():GetCurrentColorModifier().A ~= 0.5
		or Game():GetCurrentColorModifier().Brightness ~= 0.01
		or Game():GetCurrentColorModifier().Contrast ~= 1 then
			Game():SetColorModifier(ColorModifier(1, 0, 0, 0.5, 0.01, 1), false, 0)
		end
	end
end)

--Behavior--
function cba:SkinlessHushInit(SH)
	SH.I1 = 0
	SH.State = 1
	SH:GetSprite():Play("Appear", true)
	SH.I2 = 360
	SH.MaxHitPoints = 6666
	SH.HitPoints = 6666
	SH:SetShieldStrength(100)
end

cba:AddCallback(ModCallbacks.MC_POST_NPC_INIT, cba.SkinlessHushInit, EntityType.ENTITY_HUSH_SKINLESS)

local ProjEffects = {
	[1] = {ProjectileFlags.MEGA_WIGGLE,
	ProjectileFlags.SAWTOOTH_WIGGLE,
	ProjectileFlags.SINE_VELOCITY},
	[2] = {ProjectileFlags.MEGA_WIGGLE,
	ProjectileFlags.SAWTOOTH_WIGGLE},
	[3] = {ProjectileFlags.MEGA_WIGGLE,
	ProjectileFlags.SAWTOOTH_WIGGLE,
	ProjectileFlags.SINE_VELOCITY,
	ProjectileFlags.MEGA_WIGGLE | ProjectileFlags.SINE_VELOCITY},
	[4] = {ProjectileFlags.MEGA_WIGGLE,
	ProjectileFlags.SAWTOOTH_WIGGLE,
	ProjectileFlags.SINE_VELOCITY,
	ProjectileFlags.MEGA_WIGGLE | ProjectileFlags.SINE_VELOCITY}
}

function cba:SkinlessHushLogic(SH)
	SH.Velocity = Vector(0,0)
	------------------INIT------------------
	if SH.State == 1 then
		Game():GetRoom():GetCamera():SetFocusPosition(SH.Position)
		if SH:GetSprite():GetFrame() < 151 and SH:GetSprite():GetFrame() % 50 == 0 then
			SFXManager():Play(SoundEffect.SOUND_FORESTBOSS_STOMPS)
		elseif SH:GetSprite():GetFrame() == 151 then
			SFXManager():Play(SoundEffect.SOUND_HELLBOSS_GROUNDPOUND)
			SFXManager():Play(SoundEffect.SOUND_DEATH_BURST_LARGE)
			Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 3, SH.Position, Vector(0, 0), SH)
			Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 4, SH.Position, Vector(0, 0), SH)
			Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 5, SH.Position, Vector(0, 0), SH)
			for i = 0, 25 do
				Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_PARTICLE, 0, SH.Position, Vector(math.random(-10, 10), math.random(-10, 10)), SH)
			end
		elseif SH:GetSprite():GetFrame() > 154 and SH:GetSprite():GetFrame() < 178 then
			if SH:GetSprite():GetFrame() == 155 then
				SFXManager():Play(SoundEffect.SOUND_BEAST_SWITCH_SIDES)
			end
			if SH:GetSprite():GetFrame() % 2 == 1 then
				for i = 0, 1 do
					local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BIG_ATTRACT, 10 + i, SH.Position, Vector(0, 0), SH):ToEffect()
					effect:SetTimeout(10)
					effect:GetSprite().Color = Color(1, 0, 0, 1)
				end
			end
		elseif SH:GetSprite():IsFinished() == true then
			SH.I1 = 0
			SH.State = 3
			SH:GetSprite():Play("Idle", true)
		end
	------------------IDLE------------------
	elseif SH.State == 3 then
		if SH:GetData().IsCBAChanceCalculated then SH:GetData().IsCBAChanceCalculated = nil end
		if SH:GetData().CBASHTearAttackPattern then SH:GetData().CBASHTearAttackPattern = nil end
		if (SH.HitPoints <= 4444 and not SH:GetData().HasCBASHDid1Transition)
		or (SH.HitPoints <= 2222 and not SH:GetData().HasCBASHDid2Transition) then
			SH.State = 2
			SH.I1 = 0
			return
		end
		if SH.I1 >= SH.I2 then
			SH.I1 = 0
			SH.I2 = math.random(50, 200)
			if SH.HitPoints < 4444 then
				SH.State = math.random(8, 10)
			else
				SH.State = 8
				SH:GetSprite():Play("AttackStart", true)
			end
		end
	------------------TRANSITION------------------
	elseif SH.State == 2 then
		if SH.I1 >= 600 then
			
		end
	------------------ATTACK------------------
	elseif SH.State == 8 then
		if SH:GetSprite():GetAnimation() == "AttackStart" and SH:GetSprite():IsFinished() == true then
			SH:GetSprite():Play("AttackLoop", true)
			SH.I1 = 0
			SH:GetData().CBASHTearAttackPattern = math.random(4)
			SH:GetData().CBASHTearAttackFlags = ProjEffects[SH:GetData().CBASHTearAttackPattern][math.random(#ProjEffects[SH:GetData().CBASHTearAttackPattern])]
			SH:GetData().IsCBAChanceCalculated = true
		elseif SH:GetSprite():GetAnimation() == "AttackLoop" then
			if SH:GetData().CBASHTearAttackPattern == 1 then
				if SH.I1 % 20 == 0 and SH.I1 <= 120 then
					local speed = 10
					local tearCount = 12
					local angleStep = 360 / tearCount
					for i = 0, tearCount - 1 do
						local angle = i * angleStep + 5 * (SH.I1 / 10 - 1)
						local velocity = Vector(speed * math.cos(math.rad(angle)), speed * math.sin(math.rad(angle)))
						local proj = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, ProjectileVariant.PROJECTILE_HUSH, 0, SH.Position, velocity, SH):ToProjectile()
						proj:ClearProjectileFlags(ProjectileFlags.HIT_ENEMIES)
						proj:AddProjectileFlags(ProjectileFlags.CONTINUUM)
						if SH:GetData().CBASHTearAttackFlags & ProjectileFlags.ORBIT_CW ~= 0 then
							SH:GetData().CBASHTearAttackFlags = SH:GetData().CBASHTearAttackFlags ~ ProjectileFlags.ORBIT_CW
							proj:GetData().IsCBAOrbitCircleProj = {math.random(2), SH.Position, 2}
						end
						proj:AddProjectileFlags(SH:GetData().CBASHTearAttackFlags)
						proj.FallingAccel = -0.1
						proj:GetData().IsCBATimerDieProj = 360
						proj:GetData().IsCBASHContinuumProj = true
					end
				end
				if SH.I1 == 120 then
					SH:GetSprite():Play("AttackEnd", true)
				end
			elseif SH:GetData().CBASHTearAttackPattern == 2 then
				if SH.I1 % 20 == 0 and SH.I1 <= 120 then
					local speed = 7
					local tearCount = 6
					local angleStep = 360 / tearCount
					for i = 0, tearCount - 1 do
						local angle = i * angleStep
						local velocity = Vector(speed * math.cos(math.rad(angle)), speed * math.sin(math.rad(angle)))
						local proj = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, ProjectileVariant.PROJECTILE_HUSH, 0, SH.Position, velocity, SH):ToProjectile()
						proj:ClearProjectileFlags(ProjectileFlags.HIT_ENEMIES)
						proj:AddProjectileFlags(SH:GetData().CBASHTearAttackFlags)
						proj:AddProjectileFlags(ProjectileFlags.BURST)
						proj.FallingAccel = -0.1
						proj.Color = Color(1, 0, 0, 1)
						proj.Scale = 2
					end
				end
				if SH.I1 == 120 then
					SH:GetSprite():Play("AttackEnd", true)
				end
			elseif SH:GetData().CBASHTearAttackPattern == 3 and (SH.I1 % 20 == 0 and SH.I1 <= 180) then
				local speed = 7
				local tearCount = 20
				local angleStep = 360 / tearCount
				for i = 0, tearCount - 1 do
					local angle = i * angleStep + 9 * (SH.I1 / 20 - 1)
					local velocity = Vector(speed * math.cos(math.rad(angle)), speed * math.sin(math.rad(angle)))
					local proj = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, ProjectileVariant.PROJECTILE_HUSH, 0, SH.Position, velocity, SH):ToProjectile()
					proj:ClearProjectileFlags(ProjectileFlags.HIT_ENEMIES)
					if SH:GetData().CBASHTearAttackFlags & ProjectileFlags.ORBIT_CW ~= 0 then
						SH:GetData().CBASHTearAttackFlags = SH:GetData().CBASHTearAttackFlags ~ ProjectileFlags.ORBIT_CW
						proj:GetData().IsCBAOrbitCircleProj = {math.random(2), SH.Position, 2}
					end
					proj:AddProjectileFlags(SH:GetData().CBASHTearAttackFlags)
					proj.FallingAccel = -0.1
					proj.Color = Color(1, 0.25, 0.25, 1)
				end
				if SH.I1 % 60 == 0 then
					local velocity = (Isaac.GetPlayer().Position - SH.Position):Normalized() * 15
					local proj = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, 0, 0, SH.Position, velocity, SH):ToProjectile()
					proj:ClearProjectileFlags(ProjectileFlags.HIT_ENEMIES)
					proj:AddProjectileFlags(ProjectileFlags.SIDEWAVE)
					proj:GetSprite():Load("gfx/002.037_brimstone balloon tear.anm2", true)
					proj.Scale = 3
					proj.FallingAccel = -0.1
					proj:GetData().IsCBAHaemolBrimProj = true
				end
				if SH.I1 == 180 then
					SH:GetSprite():Play("AttackEnd", true)
				end
			elseif SH:GetData().CBASHTearAttackPattern == 4 then 
				if SH.I1 == 10 then
					local dir = cba.GetAngle(Isaac.GetPlayer().Position - SH.Position)
					for i = -1, 0 do
						if i == 0 then i = 1 end
						local laser = Isaac.Spawn(EntityType.ENTITY_LASER, LaserVariant.THICK_RED, 0, SH.Position, Vector(0,0), SH):ToLaser()
						laser.AngleDegrees = dir + 45 * i
						laser.Parent = SH
						laser.Timeout = 150
						laser:SetActiveRotation(20, dir + 15 * i, 0.25 * i * -1, false)
					end
				elseif SH.I1 % 20 == 0 and SH.I1 <= 120 then
					local speed = 7
					local tearCount = 30
					local angleStep = 360 / tearCount
					for i = 0, tearCount - 1 do
						local angle = i * angleStep + 6 * (SH.I1 / 20 - 1)
						local velocity = Vector(speed * math.cos(math.rad(angle)), speed * math.sin(math.rad(angle)))
						local proj = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, ProjectileVariant.PROJECTILE_HUSH, 0, SH.Position, velocity, SH):ToProjectile()
						proj:ClearProjectileFlags(ProjectileFlags.HIT_ENEMIES)
						if SH:GetData().CBASHTearAttackFlags & ProjectileFlags.ORBIT_CW ~= 0 then
							SH:GetData().CBASHTearAttackFlags = 0
							proj:GetData().IsCBAOrbitCircleProj = {math.random(2), SH.Position, 2}
						end
						proj:AddProjectileFlags(SH:GetData().CBASHTearAttackFlags)
						proj.FallingAccel = -0.1
						proj.Color = Color(2, 1, 1, 1)
					end
				end
				if SH.I1 == 120 then
					SH:GetSprite():Play("AttackEnd", true)
				end
			end
		elseif SH:GetSprite():GetAnimation() == "AttackEnd" then
			if SH:GetSprite():IsFinished() == true then
				SH:GetSprite():Play("Idle", true)
			end
		end
		if SH.I1 == 180 then
			SH.I1 = 0
			SH.State = 3
		end
	end
	SH.I1 = SH.I1 + 1
end

cba:AddCallback(ModCallbacks.MC_NPC_UPDATE, cba.SkinlessHushLogic, EntityType.ENTITY_HUSH_SKINLESS)

function cba:SHProjUpdate(Proj)
	if Proj:GetData().IsCBATimerDieProj then
		if Proj.FrameCount == Proj:GetData().IsCBATimerDieProj then
			Proj.Height = -4
		end
	end
	if Proj:GetData().IsCBASHContinuumProj then
		Proj:GetSprite().Color = Color(Proj:GetSprite().Color.R, 0, 0, Proj:GetSprite().Color.A)
	end
end

cba:AddCallback(ModCallbacks.MC_POST_PROJECTILE_UPDATE, cba.SHProjUpdate)

function cba:HaemolBrimProjDeath(Proj)
	if Proj:GetData().IsCBAHaemolBrimProj then
		local dir = cba.GetAngle(Proj.Velocity:Rotated(180))
		for i = -1, 0 do
			if i == 0 then i = 1 end
			local laser = Isaac.Spawn(EntityType.ENTITY_LASER, LaserVariant.THICK_RED, 0, Proj.Position, Vector(0,0), Proj.SpawnerEntity):ToLaser()
			laser.AngleDegrees = dir + 30 * i
			laser.Timeout = 30
			laser:SetDisableFollowParent(true)
		end
	end
end

cba:AddCallback(ModCallbacks.MC_POST_PROJECTILE_DEATH, cba.HaemolBrimProjDeath)