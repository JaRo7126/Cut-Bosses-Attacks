local cba = CutBossesAttacks

local cfg = cba.Save.Config

----------------------------
---------Fight Init---------
----------------------------

function cba:IsWitnessBossRoom() --check for Witness room
	local rtype = Game():GetLevel():GetCurrentRoom():GetType()
	local rvar = Game():GetLevel():GetCurrentRoomDesc().Data.Variant
	
	return cfg["General"]["WitnessRestore"] == true 
	and rtype == RoomType.ROOM_BOSS 
	and rvar == 912
end

function cba:IsMortisFloor() --check for Mortis floor
	return cfg["General"]["WitnessRestore"] == true 
	and LastJudgement 
	and StageAPI
	and StageAPI.InOverriddenStage() 
	and (StageAPI.GetCurrentStage().Name == "Mortis 2" or StageAPI.GetCurrentStage().Name == "Mortis XL")
end


cba:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, function() --change Mother room to Witness room
	local stage = Game():GetLevel():GetStage()
	local stype = Game():GetLevel():GetStageType()
	local level = Game():GetLevel()
	
	if cfg["General"]["WitnessRestore"] == true 
	and (
			(
				(stage == LevelStage.STAGE4_2
				or (stage == LevelStage.STAGE4_1 and level:GetCurses() & LevelCurse.CURSE_OF_LABYRINTH ~= 0)
				) and stype == StageType.STAGETYPE_REPENTANCE
			)
			or cba.IsMortisFloor()
		) 
	and level:GetRoomByIdx(-10, 0).Data then --Mother room's grid index is -10
		level:GetRoomByIdx(-10, 0).Data = RoomConfigHolder.GetRoomByStageTypeAndVariant(StbType.CORPSE, RoomType.ROOM_BOSS, 912)
	end
end)


cba:AddCallback(ModCallbacks.MC_POST_RENDER, function() --camera focus
	if cba.IsWitnessBossRoom() then
		local camera = Game():GetRoom():GetCamera()
	
		if cfg["Witness"]["CameraLock"] == true then
			camera:SetFocusPosition(Game():GetRoom():GetCenterPos()) --focus in room center
		else
			camera:SetFocusPosition(Isaac.GetPlayer().Position) --follow player
		end
	end
end)


local IsZoomed

cba:AddCallback(ModCallbacks.MC_POST_UPDATE, function()

	if cba.IsWitnessBossRoom() then 
	
		if cfg["Witness"]["ZoomOut"] == true 
		and not IsZoomed 
		and RoomTransition.IsRenderingBossIntro() == false then --on Witness room enter
		
			Options.MaxScale = cfg["Witness"]["ZoomSize"] --change zoom setting
			
			if cfg["Witness"]["ZoomType"] == 2 then
				Isaac.TriggerWindowResize() --RGON method(bugged)
			else
				Options.Fullscreen = not Options.Fullscreen --"vanilla" method
				Options.Fullscreen = not Options.Fullscreen
			end
			
			IsZoomed = true
		elseif cfg["Witness"]["CameraLock"] == false 
		and Options.CameraStyle == 1 then --change camera type for smoother movement
		
			Options.CameraStyle = 2
		end
	end
end)


function cba.WSZoomBack() --change zoom back to normal
	Options.MaxScale = cba.Save.ZoomSetting
		
	if cfg["Witness"]["ZoomType"] == 2 then
		Isaac.TriggerWindowResize()
	else
		Options.Fullscreen = not Options.Fullscreen
		Options.Fullscreen = not Options.Fullscreen
	end
end


cba:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()

	if Options.MaxScale ~= cba.Save.ZoomSetting then
		cba.WSZoomBack()
	end
	
	if cba.Save.CameraSetting 
	and Options.CameraStyle ~= cba.Save.CameraSetting then --change camera setting back
		Options.CameraStyle = cba.Save.CameraSetting
	end
	
	if cfg["Witness"]["OldTheme"] == true then --update music table
		cba.WSMusic = {Isaac.GetMusicIdByName("Witness Boss"), Isaac.GetMusicIdByName("Witness Boss Over")}
	else
		cba.WSMusic = {Music.MUSIC_MOTHER_BOSS, Music.MUSIC_JINGLE_MOTHER_OVER}
	end
	
	--reset values--
	IsZoomed = false 
	
	if cba.IsMortisLoadedVSScreen then
		cba.IsMortisLoadedVSScreen = nil
	end
end)


cba:AddCallback(ModCallbacks.MC_PRE_LEVEL_SELECT, function()

	if Options.MaxScale ~= cba.Save.ZoomSetting then
		cba.WSZoomBack()
	end
end)


cba:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, function()

	if Options.MaxScale ~= cba.Save.ZoomSetting then 
		cba.WSZoomBack()
	end
end)


function cba:WitnessWallDelete() --remove corpse wall in lower left corner of the room
	if cba.IsWitnessBossRoom() then
	
		for _, Wall in ipairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.BACKDROP_DECORATION)) do
			local sprite = Wall:GetSprite()
			
			sprite:ReplaceSpritesheet(0, "", true)
			sprite:ReplaceSpritesheet(1, "", true)
			sprite:ReplaceSpritesheet(2, "", true)
			sprite:ReplaceSpritesheet(3, "", true)
		end
	end
end

cba:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, cba.WitnessWallDelete)


--Music change func's--

local function WitnessTheme()
	if cba.IsWitnessBossRoom() and cfg["Witness"]["OldTheme"] then
		return cba.WSMusic[1]
	end
end

local function WitnessOver()
	if cba.IsWitnessBossRoom() and cfg["Witness"]["OldTheme"] then
		return cba.WSMusic[2]
	end
end

cba:AddCallback(ModCallbacks.MC_PRE_MUSIC_PLAY, WitnessTheme, Music.MUSIC_JINGLE_BOSS)
cba:AddCallback(ModCallbacks.MC_PRE_MUSIC_PLAY, WitnessTheme, Music.MUSIC_MOTHER_BOSS)
cba:AddCallback(ModCallbacks.MC_PRE_MUSIC_PLAY, WitnessOver, Music.MUSIC_JINGLE_BOSS_OVER3)
cba:AddCallback(ModCallbacks.MC_PRE_MUSIC_PLAY, WitnessOver, Music.MUSIC_JINGLE_MOTHER_OVER)


----------------------------
-------Compatibiities-------
----------------------------

if LastJudgement then
	
	cba:AddCallback(ModCallbacks.MC_POST_RENDER, function() --load Mortis vs screen
	
		if cba.IsWitnessBossRoom() 
		and RoomTransition.IsRenderingBossIntro() == true 
		and cba.IsMortisFloor() 
		and not cba.IsMortisLoadedVSScreen then
			
			LastJudgement:LoadMotherVsScreen() --I prefer to use LJ function
			cba.IsMortisLoadedVSScreen = true
		end
	end)
	
	
	function cba:MortisChestFix() --spawn gold chest on room clear
	
		if cba.IsWitnessBossRoom() 
		and cba.IsMortisFloor() then
		
			Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_BIGCHEST, 0, 
			Game():GetRoom():GetCenterPos(), Vector(0,0), nil)
		end
	end
	
	cba:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, cba.MortisChestFix)
	
	
	function cba:MortisChestEnding(Chest, Collider, Low) --mother ending on chest collision
		if Collider.Type == EntityType.ENTITY_PLAYER 
		and cba.IsWitnessBossRoom() 
		and cba.IsMortisFloor() then 
		
			Game():End(13)
		end
	end

	cba:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, cba.MortisChestEnding, PickupVariant.PICKUP_BIGCHEST)
	
	
	function cba:MortisUnlocks(Witness) --give unlocks on witness death
	
		if Witness.Variant == 10 
		and cba.IsWitnessBossRoom() 
		and cba.IsMortisFloor() then
			local ptype = Isaac.GetPlayer():GetPlayerType()
		
			Isaac.SetCompletionMark(ptype, CompletionType.MOTHER, Game().Difficulty + 1) --give completion mark
			
			if cba.WitnessAchievements[ptype] then --if player is non-modded character
				Isaac.GetPersistentGameData():TryUnlock(cba.WitnessAchievements[ptype], false) --give achievement
			end
		end
	end
	
	cba:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, cba.MortisUnlocks, EntityType.ENTITY_MOTHER)
	
	
	StageAPI.AddCallback("The Repentance Witness", "POST_SELECT_BOSS_MUSIC", 1, function(_, ID) --music change func
		
		if cba.IsWitnessBossRoom() and cba.IsMortisFloor() then
		
			if ID == Music.MUSIC_BOSS3 then
				return cba.WSMusic[1]
			elseif ID == Music.MUSIC_JINGLE_BOSS_OVER3 then
				return cba.WSMusic[2]
			end
		end
	end
	)
	
end




---------------------------
--------Color Stuff--------
---------------------------

local function ColorColorize(color, colorize) --func for color colorizing for shortening
	local c = color
	
	c:SetColorize(colorize[1], colorize[2], colorize[3], colorize[4])
	
	return c
end


local colors = {["Worm"] = {}, ["Fist"] = {}, ["GreenBall"] = {}} --proj's colors

colors["Worm"].Normal = {ColorColorize(Color(1, 1, 1, 1), {4, 3.5, 3.2, 1})}
colors["Fist"].Normal = {Color(1, 1, 1, 1)}
colors["GreenBall"].Normal = {ColorColorize(Color(1, 1, 1, 1), {0.62, 0.85, 0.31, 1}), ColorColorize(Color(4, 4, 4, 1), {0.62, 0.85, 0.31, 1})}

if LastJudgement then
	colors["Worm"].Mortis = {LastJudgement.Colors.VirusBlue}
	colors["Fist"].Mortis = {LastJudgement.Colors.MortisBloodProj}
	colors["GreenBall"].Mortis = {LastJudgement.Colors.OrganBlue, LastJudgement.Colors.OrganYellow, LastJudgement.Colors.OrganPurple}
end


local function CheckColor(Color, name, variant) --color comparison
	local cs --comparable color
	
	if variant == "n" then
		cs = colors[name].Normal
	else 
		cs = colors[name].Mortis
	end
	
	for _, c in ipairs(cs) do --if all values approximately equal
		if (Color.R >= c.R and Color.R < c.R + 0.01) 
		and (Color.B >= c.B and Color.B < c.B + 0.01)
		and (Color.G >= c.G and Color.G < c.G + 0.01)
		and (Color.A >= c.A and Color.A < c.A + 0.01)
		and (Color:GetColorize().R >= c:GetColorize().R and Color:GetColorize().R < c:GetColorize().R + 0.01) 
		and (Color:GetColorize().B >= c:GetColorize().B and Color:GetColorize().B < c:GetColorize().B + 0.01) 
		and (Color:GetColorize().G >= c:GetColorize().G and Color:GetColorize().G < c:GetColorize().G + 0.01) 
		and (Color:GetColorize().A >= c:GetColorize().A and Color:GetColorize().A < c:GetColorize().A + 0.01) then
			return true --colors are equal
		end
	end
end

---------------------------
--------Rocks Stuff--------
---------------------------

local mortisRocks, mortisPits

if LastJudgement then --get Mortis rocks' and pits' sprites
	mortisRocks, _, _ = LastJudgement.GetMortisRocks()
	
	local pit1, pit2, _, _, _ = LastJudgement.GetMortisPits()
	
	mortisPits = {pit1, pit2}
end


local GetAngle = cba.GetAngle --another variable cuz I'm lazy


local function CheckForGrid(pos, gridType) --func for checking for grid type in 3x3 radius
	local room = Game():GetRoom()
	local gridPos = room:GetGridPosition(room:GetGridIndex(pos))
	local grids = {room:GetGridEntityFromPos(gridPos),
	room:GetGridEntityFromPos(gridPos - Vector(40, 0)),
	room:GetGridEntityFromPos(gridPos + Vector(40, 0)),
	room:GetGridEntityFromPos(gridPos - Vector(0, 40)),
	room:GetGridEntityFromPos(gridPos + Vector(0, 40)),
	room:GetGridEntityFromPos(gridPos - Vector(40, 40)),
	room:GetGridEntityFromPos(gridPos + Vector(40, 40)),
	room:GetGridEntityFromPos(gridPos + Vector(-40, 40)),
	room:GetGridEntityFromPos(gridPos + Vector(40, -40))
	}
	
	for _, grid in ipairs(grids) do
		if grid and grid:GetType() == gridType then
			return true
		end
	end
	
	return false
end

--small rocks' positions
local RockEffectsPos = {116, 117, 144, 145, 172, 173, 174, 200, 201, 202, 203, 229, 230, 231, 232, 233, 257, 258, 259, 260, 261, 262, 263, 288, 289, 290, 291, 135, 161, 162, 163, 189, 190, 191, 194, 217, 218, 219, 222, 247, 216, 243, 244, 245, 246, 270, 271, 272, 273, 274, 298, 299, 300, 292,293,294,295,296, 297,316,317,318,319,320,321,322,323,324,325,326,327,328, 346, 347,349,350,351,352, 353}


--------------------------
---------Behavior---------
--------------------------


cba.PitsPos = {29,30,31,32,33,34,35,36,37,38,45,46,47,48,49,50,51,52,53,54,57,58,59,60,61,62,77,78,79,80,81,82,85,86,109,110,113,138}


function cba:WitnessMortisPitsFix() --spawn pits in Mortis
	if cba.IsMortisFloor() 
	and cba.IsWitnessBossRoom() then
		local room = Game():GetRoom()
		
		if not room:IsClear() then
			local pitSprite = mortisPits[math.random(2)]
		
			for _, Idx in ipairs(cba.PitsPos) do
				local pit = Isaac.GridSpawn(GridEntityType.GRID_PIT, 0, room:GetGridPosition(Idx), true)
				pit:GetSprite():ReplaceSpritesheet(0, pitSprite, true)
			end
		else
		
			for _, Idx in ipairs(cba.PitsPos) do
				local pit = room:GetGridEntity(Idx):ToPit()
				
				if pit then
				
					pit:MakeBridge(pit)
					
					Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, room:GetGridPosition(Idx), Vector(0,0), nil)
					
					SFXManager():Play(SoundEffect.SOUND_ROCK_CRUMBLE)
				end
			end
		end
	end
end

cba:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, cba.WitnessMortisPitsFix)

cba:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, function()
	if cba.IsWitnessBossRoom() then
		local room = Game():GetRoom()
		
		for _, Idx in ipairs(cba.PitsPos) do
			local pit = room:GetGridEntity(Idx):ToPit()
			
			if pit then
			
				pit:MakeBridge(pit)
				
				Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, room:GetGridPosition(Idx), Vector(0,0), nil)
				
				SFXManager():Play(SoundEffect.SOUND_ROCK_CRUMBLE)
			end
		end
	end
end)

cba.LaserAttackRocksPos = {{116,117,144,145,172,173,174}, --rocks' positions on laser attack
	{203,229,230,231,232,233,260,261,262,263}, 
	{135,161,162,163,189,190,191,219},
	{216,243,244,245,246,270,271,272},
	{292,293,294,295,296,316,317,318,319,320,321,322,323,324,325,326,327,346,349,350,351,352}
}

local worm = { --this needs for ce/charger gfx change if in mortis
	Type = EntityType.ENTITY_CHARGER_L2,
	Variant = 0,
	Spritesheet = {
		normal = {"gfx/monsters/repentance/lv2_charger.png"},
		mortis = {"gfx/cba/bosses/witness/mortis_charger.png"}
	}
}

if RestoredMonsterPack then

	--add witness and it's enemies to ce blacklist--

	for i = 0, 3 do
		RestoredMonsterPack:AMLblacklistentry("Corpse Eater", EntityType.ENTITY_MOTHER, 0, i, "add")
	end
	
	RestoredMonsterPack:AMLblacklistentry("Corpse Eater", EntityType.ENTITY_MOTHER, 9, 0, "add") --don't seem to work
	RestoredMonsterPack:AMLblacklistentry("Corpse Eater", EntityType.ENTITY_MOTHER, 20, 0, "add") --this too
	
	--change type and gfx to ce's
	
	worm.Type = EntityType.ENTITY_GRUB
	worm.Variant = Isaac.GetEntityVariantByName("​Corpse Eater")
	
	worm.Spritesheet = {
		normal = {"gfx/monsters/repentance/239.100_corpse_eater_corpse.png",
			"gfx/monsters/repentance/239.100_corpse_eater_body_corpse.png"},
		mortis = {"gfx/monsters/repentance/239.100_corpse_eater.png",
			"gfx/monsters/repentance/239.100_corpse_eater_body.png"}
	}
end


function cba:NPCInit(NPC)

	if cba.IsWitnessBossRoom() then
		local data = cba.GetData(NPC)

		--Witness 1'st phase--

		if NPC.Type == EntityType.ENTITY_MOTHER then
		
			if NPC.Variant == 0 then
				local room = Game():GetRoom()
			
				if cfg.Witness["WitnessIncreasedHP"] == true then --changing HP
					NPC.MaxHitPoints = 2500
					NPC.HitPoints = 2500
				end
				
				if cba.IsMortisFloor() then --replace gfx if in Mortis
					NPC:GetData().MortisSkin = true
					NPC:GetSprite():ReplaceSpritesheet(0, "gfx/enemies/reskins/mother/witness_head_mortis.png", true) 
					NPC:GetSprite():ReplaceSpritesheet(1, "gfx/enemies/reskins/mother/witness_head_mortis.png", true) 
					NPC:GetSprite():ReplaceSpritesheet(2, "gfx/enemies/reskins/mother/witness_arm_mortis.png", true) 
					NPC:GetSprite():ReplaceSpritesheet(3, "gfx/enemies/reskins/mother/witness_arm_mortis.png", true)
				end
				
				if NPC.SubType == 2 or NPC.SubType == 3 then --set arms' depth offset to 100
					NPC.DepthOffset = 100
				end
				
				--remove rocks--
				for i = 1, 4 do
					for _, pos in ipairs(cba.LaserAttackRocksPos[i]) do
						room:RemoveGridEntityImmediate(pos, 0, false)
						room:RemoveGridEntityImmediate(pos + 28, 0, false)
					end
				end
				
				for _, pos1 in ipairs(cba.LaserAttackRocksPos[5]) do
					room:RemoveGridEntityImmediate(pos1, 0, false)
					room:RemoveGridEntityImmediate(pos1 + 1, 0, false)
				end
				
				--remove small rocks
				for _, rock in ipairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.ROCK_PARTICLE)) do
				
					for _, pos2 in ipairs(RockEffectsPos) do
					
						if room:GetGridIndex(rock.Position) == pos2 then
							rock:Remove()
						end
					end
				end
				
				--spawn small rocks(yep, again)
				for _, pos3 in ipairs(RockEffectsPos) do
					Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.ROCK_PARTICLE, 0, 
					room:GetGridPosition(pos3), Vector(0, 0), nil)
				end
				
			--Burst Cluster Init--
			
			elseif NPC.Variant == 9 then
			
				NPC:GetSprite():Play("Idle", true)
			
				data.WS_burst_cluster_frames = 0
		
			--Dead Isaac Init--
			
			elseif NPC.Variant == 20 and cfg.Witness["LaserAttack"] == true then
				
				if cfg.Witness["OldLaserAttack"] then
					NPC:Remove()
					
				else
					local chance = math.random(1, 5)
					
					if chance == 5 then
					
						NPC:Remove()
					else
					
						NPC.MaxHitPoints = 6
						NPC.HitPoints = 6
					end
				end
		
			--Fistula Ball Init--
			
			elseif cfg.Witness["BallAttack"] == true and NPC.Variant == 100 then
				
				cba.GetData(NPC.SpawnerEntity).WS_ball = NPC
				
				data.WS_ball_projcount = 14
				data.WS_ball_dir = "toplayer"
				
				NPC:GetSprite():ReplaceSpritesheet(0, "gfx/cba/bosses/witness/fistula_small_corpse.png", true)
				NPC:GetSprite().Scale = Vector(0.5, 0.5)
				
				NPC.Size = NPC.Size * 0.25
			end
		end
	end
end

cba:AddCallback(ModCallbacks.MC_POST_NPC_INIT, cba.NPCInit)

local function ClearStatusEffects(Witness)
	if Witness:HasEntityFlags(EntityFlag.FLAG_SLOW) then
		Witness:ClearEntityFlags(EntityFlag.FLAG_SLOW)
	end
	
	if Witness:HasEntityFlags(EntityFlag.FLAG_MIDAS_FREEZE) then
		Witness:ClearEntityFlags(EntityFlag.FLAG_MIDAS_FREEZE)
	end
	
	if Witness:HasEntityFlags(EntityFlag.FLAG_FREEZE) then
		Witness:ClearEntityFlags(EntityFlag.FLAG_FREEZE)
	end

	if Witness:HasEntityFlags(EntityFlag.FLAG_ICE) then
		Witness:ClearEntityFlags(EntityFlag.FLAG_ICE)
	end
end


function cba:WitnessUpdate(Witness) --big ass func for witness behavior
	if cba.IsWitnessBossRoom() then
		local data = cba.GetData(Witness)
		local sprite = Witness:GetSprite()
		local anim = Witness:GetSprite():GetAnimation()
		local frame = Witness:GetSprite():GetFrame()
		local state = Witness:ToNPC().State
		
		------------------------------------------------
		------------------------------------------------
		-------------------1'st PHASE-------------------
		------------------------------------------------
		------------------------------------------------
		
		
		if Witness.Variant == 0 then
		
			if state ~= 3 then 
				ClearStatusEffects(Witness)
			end
		
			-----------------------------------------------
			---------1'st to 2'nd phase transition---------
			-----------------------------------------------
			
			if state == 16 and frame == 1 and Witness.SubType == 0 then
				
				--remove all unwanted projs and effects--
				
				for _, tear in ipairs(Isaac.FindByType(EntityType.ENTITY_PROJECTILE)) do
					tear:ToProjectile().Height = 0
				end
				
				for _, laser in ipairs(Isaac.FindByType(EntityType.ENTITY_LASER, LaserVariant.THIN_RED)) do
					if cba.GetData(laser).WS_laser_degrees then
						laser:Kill()
					end
				end
				
				for i = 1, 4 do
					for pos = 1, #cba.LaserAttackRocksPos[i] do
						Game():GetRoom():DestroyGrid(cba.LaserAttackRocksPos[i][pos])
						Game():GetRoom():DestroyGrid(cba.LaserAttackRocksPos[i][pos] + 28)
					end
				end
				
				for pos = 1, #cba.LaserAttackRocksPos[5] do
					Game():GetRoom():DestroyGrid(cba.LaserAttackRocksPos[5][pos])
					Game():GetRoom():DestroyGrid(cba.LaserAttackRocksPos[5][pos] + 1)
				end
			end
			
			-----------------------------------------------
			--------------------ATTACKS--------------------
			-----------------------------------------------
			
			----------------------------------------------
			-------------Corpse Eaters Attack-------------
			----------------------------------------------
			
			if cfg.Witness["WormsAttack"] 
			and (anim == "WristAttackLeft" or anim == "WristAttackRight")
			and frame == 47 then --spawn chargers/corpse eaters
			
				local playerAngle = (Isaac.GetPlayer().Position - Witness.Position):Normalized()
				local pos = anim == "WristAttackLeft" and Vector(380, 250) or Vector(730, 250)
				local sprite = cba.IsMortisFloor() and worm.Spritesheet.mortis or worm.Spritesheet.normal
				
				for i = 0, 1 do
					local vel = playerAngle:Rotated(22.5):Rotated(i * 45 * -1) * 15 --velocity
					local w = Isaac.Spawn(worm.Type, worm.Variant, 0, pos + Vector(50 * i, 0), Vector(0, 0), Witness)
					
					w:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
					
					cba.GetData(w).WS_CE_vel = vel
					cba.GetData(w).WS_CE_dir = "+"
					
					w.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY --don't collide 
					w.SpriteOffset = Vector(0, -5)
					
					for i, v in ipairs(sprite) do
						w:GetSprite():ReplaceSpritesheet(i - 1, v, true)
					end
					
					if worm.Type == EntityType.ENTITY_GRUB then
					
						local wbody = Isaac.Spawn(worm.Type, worm.Variant, 1, pos + Vector(50 * i, 0), Vector(0, 0), nil)
						
						wbody:GetData().headIndex = w.Index
						
						wbody:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
					
						cba.GetData(wbody).WS_CE_vel = vel
						cba.GetData(wbody).WS_CE_dir = "+"
						
						wbody.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY --don't collide 
						wbody.SpriteOffset = Vector(0, -5)
						
						for i, v in ipairs(sprite) do
							wbody:GetSprite():ReplaceSpritesheet(i - 1, v, true)
						end
					end
				end
				
				local tearCount = math.random(10, 15)
				
				for i = 1, tearCount do
					local vel = playerAngle:Rotated(math.random(-20, 20)) * math.random(10, 20)
					
					local proj = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, 0, 0, pos, vel, Witness):ToProjectile()
					
					cba.GetData(proj).WS_mod_proj = true
					
					proj.Scale = math.random(12, 17) * 0.1
					proj.FallingSpeed = math.random(-20,-5)
					proj.FallingAccel = 2
					
					if cba.IsMortisFloor() then 
						proj:GetData().MortisMotherColored = true
						proj:GetSprite().Color = LastJudgement.Colors.MotherBlueProj1
					else
						proj:GetSprite().Color:SetColorize(1.5, 2, 1, 1)
					end
				end
			end
			
			----------------------------------------------
			-----------------Knife Attack-----------------
			----------------------------------------------
			
			if (anim == "ThrowKnife" or anim == "ThrowKnife2") 
			and frame == 1 then --attack variaty fix(replace knife attack with smth different)
				local chance = math.random(100)
				
				if chance <= cfg.Witness["KnifeReplaceChance"] then
					Witness:ToNPC().State = 3
				end
				
			end
			
			----------------------------------------------
			-----------------Laser Attack-----------------
			----------------------------------------------
			
			if cfg.Witness["LaserAttack"] == true then
			
				if anim == "SummonBegin" then 
					sprite:Play("LaserAttack", true)
					
				elseif anim == "LaserAttackEnd" then 
				
					if not data.WS_laser_frames or data.WS_laser_frames ~= 33 then
						sprite:Play("LaserAttackLoop", true)
						
					elseif sprite:IsFinished() == true then
						data.WS_laser_frames = 33
						
					else
						sprite:Update()
					end
					
				elseif anim == "LaserAttack" and frame == 1 then
					data.WS_laser_rockpos = {}
					
					for i = 1, 4 do
						local pos = cba.LaserAttackRocksPos[i][math.random(#cba.LaserAttackRocksPos[i])]
						
						data.WS_laser_rockpos[i] = Game():GetRoom():GetGridPosition(pos) + Vector(0, 20)
						
						if cba.IsMortisFloor() then
							Isaac.GridSpawn(GridEntityType.GRID_ROCK, 0, Game():GetRoom():GetGridPosition(pos), true):GetSprite():ReplaceSpritesheet(0, mortisRocks, true)
							Isaac.GridSpawn(GridEntityType.GRID_ROCK, 0, Game():GetRoom():GetGridPosition(pos) + Vector(0, 40), true):GetSprite():ReplaceSpritesheet(0, mortisRocks, true)
							Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, Game():GetRoom():GetGridPosition(pos), Vector(0,0), nil):GetSprite().Color:SetColorize(0.25, 0, 0.75, 0.5)
							Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, Game():GetRoom():GetGridPosition(pos) + Vector(0, 40), Vector(0,0), nil):GetSprite().Color:SetColorize(0.25, 0, 0.75, 0.5)
						else
							Isaac.GridSpawn(GridEntityType.GRID_ROCK, 0, Game():GetRoom():GetGridPosition(pos), true)
							Isaac.GridSpawn(GridEntityType.GRID_ROCK, 0, Game():GetRoom():GetGridPosition(pos) + Vector(0, 40), true)
							Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, Game():GetRoom():GetGridPosition(pos), Vector(0,0), nil):GetSprite().Color:SetColorize(0.1, 0.5, 0, 0.5)
							Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, Game():GetRoom():GetGridPosition(pos) + Vector(0, 40), Vector(0,0), nil):GetSprite().Color:SetColorize(0.1, 0.5, 0, 0.5)
						end
					end
					
					local pos = cba.LaserAttackRocksPos[5][math.random(#cba.LaserAttackRocksPos[5])]
					data.WS_laser_rockpos[5] = Game():GetRoom():GetGridPosition(pos) + Vector(20, 0)
					
					if cba.IsMortisFloor() then
						Isaac.GridSpawn(GridEntityType.GRID_ROCK, 0, Game():GetRoom():GetGridPosition(pos), true):GetSprite():ReplaceSpritesheet(0, mortisRocks, true)
						Isaac.GridSpawn(GridEntityType.GRID_ROCK, 0, Game():GetRoom():GetGridPosition(pos) + Vector(40, 0), true):GetSprite():ReplaceSpritesheet(0, mortisRocks, true)
						Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, Game():GetRoom():GetGridPosition(pos), Vector(0,0), nil):GetSprite().Color:SetColorize(0.25, 0, 0.75, 0.5)
						Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, Game():GetRoom():GetGridPosition(pos) + Vector(40, 0), Vector(0,0), nil):GetSprite().Color:SetColorize(0.25, 0, 0.75, 0.5)
					else
						Isaac.GridSpawn(GridEntityType.GRID_ROCK, 0, Game():GetRoom():GetGridPosition(pos), true)
						Isaac.GridSpawn(GridEntityType.GRID_ROCK, 0, Game():GetRoom():GetGridPosition(pos) + Vector(40, 0), true)
						Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, Game():GetRoom():GetGridPosition(pos), Vector(0,0), nil):GetSprite().Color:SetColorize(0.1, 0.5, 0, 0.5)
						Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, Game():GetRoom():GetGridPosition(pos) + Vector(40, 0), Vector(0,0), nil):GetSprite().Color:SetColorize(0.1, 0.5, 0, 0.5)
					end
					
				elseif anim == "LaserAttackLoop" then
				
					if frame == 0 and not data.WS_laser_frames then
						data.WS_laser_frames = 0
						data.WS_laser_count = 0
					end
					
					if frame == 9 then
						data.WS_laser_frames = data.WS_laser_frames + 1
					end
					
					if data.WS_laser_frames == 33 then
						sprite:Play("LaserAttackEnd", true)
						
					elseif data.WS_laser_frames == 0 and frame < 6 and data.WS_laser_count < 5 then
					
						for i = 0, 1 do
							local laser = Isaac.Spawn(EntityType.ENTITY_LASER, LaserVariant.THIN_RED, 0, Vector(518, 144), Vector(0, 0), Witness):ToLaser()
							
							laser.Color = Color(data.WS_laser_count == 0 and 5 or 1, 1, 1, data.WS_laser_count == 0 and 5 or (5 - data.WS_laser_count) * 0.25)
							
							if cba.IsMortisFloor() then
								laser:GetSprite().Color:SetColorize(1, 1, 5, 1)
							end
							
							laser.DepthOffset = 1000
							laser.CollisionDamage = 0
							laser.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NOPITS
							
							if i == 0 then
								laser.AngleDegrees = 92
								cba.GetData(laser).WS_laser_degrees = 180
								laser:SetActiveRotation(30, 88, 1, false)
								cba.GetData(laser).WS_laser_dir = "+"
							else
								laser.AngleDegrees = 88
								cba.GetData(laser).WS_laser_degrees = 0
								laser:SetActiveRotation(30, -88, -1, false)
								cba.GetData(laser).WS_laser_dir = "-"
							end
							
						end
						
						data.WS_laser_count = data.WS_laser_count + 1
					end
					
				elseif anim == "GroundPound3" and not data.WS_is2fist_attack then 
				
					if frame == 23 then
						data.WS_laser_frames = nil
						
						for i = 1, 5 do
							local pos = data.WS_laser_rockpos[i].X < 580 and Vector(730, 280) or Vector(430, 280)
							local velocity = (data.WS_laser_rockpos[i] - pos):Normalized() * 20
							
							Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.MOTHER_SHOCKWAVE, 0, pos, velocity, Witness)
						end
					end
				end
			end
			
			
			---------------------------------------------
			-----------------Fist Attack-----------------
			---------------------------------------------
			
			if cfg.Witness["FistAttack"] == true
			and (anim == "GroundPound" or anim == "GroundPound2")
			and frame == 23 then
			
				for _, tear in ipairs(Isaac.FindByType(EntityType.ENTITY_PROJECTILE)) do
					if not cba.GetData(tear).WS_mod_proj 
					and (CheckColor(tear.Color, "Fist", "n") 
						or (cba.IsMortisFloor() and CheckColor(tear.Color, "Fist", "m"))
					) then
						tear:Remove()
					end
				end
				
				local tearCount = 12
				local angleStep = 360 / tearCount
				local pos = anim == "GroundPound" and Vector(730, 250) or Vector(430, 250)
				local speed = 7
				
				for i = 0, tearCount - 1 do
					local angle = i * angleStep
					local velocity = Vector(speed * math.cos(math.rad(angle)), speed * math.sin(math.rad(angle)))
					
					local tear = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, 0, 0, pos, velocity, Witness):ToProjectile()
					
					tear.Parent = Witness
					cba.GetData(tear).WS_mod_proj = true
					cba.GetData(tear).WS_fist_proj = true
					
					if cba.IsMortisFloor() then
						tear:GetSprite().Color = LastJudgement.Colors.MortisBloodProj
					end
					
					tear.Scale = 2.5
					tear.FallingAccel = -0.1
				end
			end
			
			----------------------------------------------
			-----------------Burst Attack-----------------
			----------------------------------------------
			
			
			if cfg.Witness["BurstAttack"] == true and Witness.Variant == 0 and anim == "Shoot1" then 
			
				if frame == 0 then
					local chance = math.random(100)
					
					if chance <= cfg.Witness["BurstChance"] then
						data.WS_burst_attack = true
					end
					
				elseif frame == 19 and data.WS_burst_attack then
				
					for _, Ball in ipairs(Isaac.FindByType(EntityType.ENTITY_MOTHER, 100)) do
						Ball:Remove()
					end
					
					local dir = (Isaac.GetPlayer().Position - Witness.Position):Normalized()
					local veldir = (Isaac.GetPlayer().Position - Witness.Position):Length() / 40
					local colorTable = {n = {colors["GreenBall"].Normal[1], colors["GreenBall"].Normal[2], ColorColorize(Color(1, 1, 1, 1), {3.5, 2.5, 1, 1})},
					m = {LastJudgement.Colors.OrganBlue, LastJudgement.Colors.OrganYellow, LastJudgement.Colors.OrganPurple}}
					
					tearCount = math.random(30, 35)
					
					for i = 0, tearCount do
						local angleOffset = math.random(-20, 20)
						local velocity = dir:Rotated(angleOffset):Resized(veldir)
						
						local var = math.random(1, 4)
						var = var == 4 and ProjectileVariant.PROJECTILE_BONE or 0
						
						local tear = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, var, 0, Witness.Position + Vector(math.random(0, 60), math.random(0, 60)):Rotated(dir:GetAngleDegrees()), velocity, Witness):ToProjectile()
						
						tear:AddProjectileFlags(ProjectileFlags.NO_WALL_COLLIDE)
						
						tear.Parent = Witness
						cba.GetData(tear).WS_mod_proj = true
						
						if var ~= ProjectileVariant.PROJECTILE_BONE then
						
							if cba.IsMortisFloor() then
								tear:GetData().MortisMotherColored = true
								tear:GetSprite().Color = colorTable.m[math.random(1, 3)]
							else
								tear:GetSprite().Color = colorTable.n[math.random(1, 3)]
							end
						end
						
						tear.Scale = math.random(12, 17) * 0.1
						tear.FallingSpeed = math.random(-20, -15)
						tear.FallingAccel = 0.5
					end
					
					local clusterCnt = math.random(2, 3)
					
					for i = 0, clusterCnt - 1 do 
						local angleOffset = math.random(-40, 40)
						local velocity = dir:Rotated(angleOffset):Resized(veldir)
						
						local cluster = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, 0, 0, Witness.Position + Vector(math.random(0, 60), math.random(0, 60)), velocity, Witness):ToProjectile()
						
						cluster:AddProjectileFlags(ProjectileFlags.NO_WALL_COLLIDE)
						
						cluster.Parent = Witness
						cba.GetData(cluster).WS_mod_proj = true
						cba.GetData(cluster).WS_burst_proj = true
						
						if cba.IsMortisFloor() then
							cluster:GetSprite().Color = LastJudgement.Colors.MortisBloodProj
						end
						
						cluster.Scale = 3
						cluster.FallingSpeed = math.random(-25, -20)
						cluster.FallingAccel = 0.5
					end
					
				elseif frame == 20 and data.WS_burst_attack then
					data.WS_burst_attack = nil
				end
			end
			
			
			
			
			---------------------------------------------
			-----------------Ball Attack-----------------
			---------------------------------------------
			
			--Ball and Witness collision--
			
			if cfg.Witness["BallAttack"] == true and Witness.Variant == 0 
			and (anim == "ScrapeAttack" or anim == "ScrapeAttack2") then
			
				if data.WS_ball and data.WS_ball:Exists() and frame == 12 then
				
					cba.GetData(data.WS_ball).WS_ball_dir = "toplayer"
					
					local pos = data.WS_ball.Position
					cba.GetData(data.WS_ball).WS_ball_projcount = cba.GetData(data.WS_ball).WS_ball_projcount + 4

					local directionToPlayer = (Isaac.GetPlayer().Position - Witness.Position):Normalized()
					local speed = 15
					
					for i = 0, 4 do
						local angleOffset = 45 * (i / 4 - 0.5)
						local velocity = directionToPlayer:Rotated(angleOffset) * speed
						
						local tear = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, 0, 0, pos, velocity, Witness):ToProjectile()
						
						tear.Parent = Witness
						cba.GetData(tear).WS_mod_proj = true
						
						if cba.IsMortisFloor() then 
							tear:GetData().MortisMotherColored = true
							tear:GetSprite().Color = LastJudgement.Colors.MotherBlueProj1
						else
							tear:GetSprite().Color:SetColorize(1.5, 2, 1, 1)
						end
					end
					
				elseif data.WS_laser_frames then
					sprite:Play("LaserAttackLoop", true)
				end
			end
			
			
			----------------------------------------------
			--------------Double Fist Attack--------------
			----------------------------------------------
			
			
			if cfg.Witness["DoubleFistAttack"] == true and Witness.Variant == 0 then
				if (anim == "GroundPound" or anim == "GroundPound2") and frame <= 1 then
					local chance = math.random(100)
					
					if chance <= cfg.Witness["DoubleFistChance"] then
						sprite:Play("GroundPoundDouble", true)
					end
					
				elseif anim == "GroundPoundDouble" then
				
					if frame == 17 or frame == 35 then
					
						for _, tear in ipairs(Isaac.FindByType(EntityType.ENTITY_PROJECTILE)) do
							if not cba.GetData(tear).WS_mod_proj 
							and (CheckColor(tear.Color, "Fist", "n") 
								or (cba.IsMortisFloor() and CheckColor(tear.Color, "Fist", "m"))
							) then
							
								tear:Remove()
							end
						end
						
						local center = frame == 17 and Vector(730, 250) or Vector(430, 250)
						local tearCount = 3
						local rowCount = 16
						local angleStep = 360 / rowCount
						local frameCounter = 0
						
						for row = 0, rowCount - 1 do
							local angle = row * angleStep
							
							for i = 0, tearCount - 1 do
								local velocity = Vector(5 * math.cos(math.rad(angle)), 5 * math.sin(math.rad(angle)))
								local position = center + Vector(i * 30 * math.cos(math.rad(angle)), i * 30 * math.sin(math.rad(angle)))
								
								local tear = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, 0, 0, position, velocity, nil):ToProjectile()
								
								tear:AddProjectileFlags(ProjectileFlags.SINE_VELOCITY)
								tear.Parent = Witness
								cba.GetData(tear).WS_mod_proj = true
								cba.GetData(tear).WS_circle_curve_dir = 1
								cba.GetData(tear).WS_circle_center = center
								cba.GetData(tear).WS_circle_curve_speed = 1
								
								
								tear.FallingAccel = -0.1
								tear.Scale = 1.5
								
								if cba.IsMortisFloor() then 
									tear:GetData().MortisMotherColored = true
									tear:GetSprite().Color = LastJudgement.Colors.MotherBlueProj1
								else
									tear:GetSprite().Color:SetColorize(1.5, 2, 1, 1)
								end
							end
						end
						
						for row = 0, rowCount - 1 do
							local angle = row * angleStep
							
							for i = 0, tearCount - 1 do
								local velocity = Vector(5 * math.cos(math.rad(angle)), 5 * math.sin(math.rad(angle)))
								local position = center + Vector(i * 30 * math.cos(math.rad(angle)), i * 30 * math.sin(math.rad(angle)))
								
								local tear = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, 0, 0, position, velocity, nil):ToProjectile()
								
								tear:AddProjectileFlags(ProjectileFlags.SINE_VELOCITY)
								tear.Parent = Witness
								cba.GetData(tear).WS_mod_proj = true
								cba.GetData(tear).WS_circle_curve_dir = -1
								cba.GetData(tear).WS_circle_center = center
								cba.GetData(tear).WS_circle_curve_speed = 1
								
								tear.FallingAccel = -0.1
								tear.Scale = 1.5
								
								if cba.IsMortisFloor() then 
									tear:GetData().MortisMotherColored = true
									tear:GetSprite().Color = LastJudgement.Colors.MotherBlueProj2
								else
									tear:GetSprite().Color:SetColorize(2.7, 3, 2, 1)
								end
							end
						end
						
					elseif frame > 69 and frame < 89 and (frame - 70) % 3 == 0 then
					
						if frame == 70 then 
							SFXManager():Play(SoundEffect.SOUND_HELLBOSS_GROUNDPOUND, Options.Volume)
							Game():ShakeScreen(15)
						end
						
						local tearCount = 12
						local angleStep = 360 / tearCount
						
						for pos = 1, 2 do
							local position = pos == 1 and Vector(730,250) or Vector(430,250)
							
							for i = 0, tearCount - 1 do
								local angle = i * angleStep
								local velocity = Vector(15 * math.cos(math.rad(angle)), 15 * math.sin(math.rad(angle)))
								
								local tear = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, 0, 0, position, velocity, Witness):ToProjectile()
								
								tear.Parent = Witness
								cba.GetData(tear).WS_mod_proj = true
								cba.GetData(tear).WS_2fist_Z_proj = true
								
								tear.FallingAccel = -0.1
								tear.Scale = 1.5
								
								if cba.IsMortisFloor() then
									tear:GetSprite().Color = LastJudgement.Colors.MortisBloodProj
								else 
									tear:GetSprite().Color:SetColorize(3.5, 2.5, 1, 1) 
								end
							end
						end
					end
				end
			end
			
			----------------------------------------------
			-----------------Shoot Attack-----------------
			----------------------------------------------
			
			if cfg.Witness["ShootAttack"] == true then
			
				if (anim == "WristAttackLeft" or anim == "WristAttackRight") and frame == 0 then
					local chance = math.random(100)
					
					if chance <= cfg.Witness["ShootAttackChance"] then
						sprite:Play("Shoot2", true)
						SFXManager():Play(SoundEffect.SOUND_MOTHER_FISTULA, Options.Volume)
					end
					
				elseif anim == "Shoot2" and frame == 13 then
				
					for _, tear in ipairs(Isaac.FindByType(EntityType.ENTITY_PROJECTILE)) do
						if not cba.GetData(tear).WS_mod_proj 
						and (CheckColor(tear.Color, "Worm", "n") 
							or (cba.IsMortisFloor() and CheckColor(tear.Color, "Worm", "m"))
						) then
						
							tear:Remove()
							
						elseif cba.GetData(tear).WS_shoot_velchange_count then
							tear:ToProjectile().Height = -4
						end
					end
					
					for _, effect in ipairs(Isaac.FindByType(EntityType.ENTITY_EFFECT)) do
						if effect.Variant == EffectVariant.BLOOD_EXPLOSION or effect.Variant == EffectVariant.BLOOD_PARTICLE then
							effect:Remove()
						end
					end
					
					local sounds = {SoundEffect.SOUND_MOTHER_HAND_BOIL_START, SoundEffect.SOUND_MOTHER_GRUNT1, SoundEffect.SOUND_MOTHER_GRUNT5, SoundEffect.SOUND_MOTHER_GRUNT6, SoundEffect.SOUND_MOTHER_GRUNT7, SoundEffect.SOUND_MOTHER_WRIST_SWELL, SoundEffect.SOUND_MOTHER_WRIST_EXPLODE}
					for _, sound in ipairs(sounds) do
						SFXManager():Stop(sound)
					end
					
					local directionToPlayer = (Isaac.GetPlayer().Position - Witness.Position):Normalized()
					local speed = 10
					
					data.WS_shoot_parentproj_vel = {}
					data.WS_shoot_frames = 0
					
					for i = 0, 2 do
						local angleOffset = 45 * (i / 2 - 0.5)
						local velocity = directionToPlayer:Rotated(angleOffset) * speed
						
						local tear = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, 0, 0, Witness.Position, velocity, Witness):ToProjectile()
						
						tear.Parent = Witness
						cba.GetData(tear).WS_mod_proj = true
						cba.GetData(tear).WS_shoot_parentproj_num = i + 1
						cba.GetData(tear).WS_shoot_velchange_count = 0
						data.WS_shoot_parentproj_vel[i + 1] = velocity
						
						tear.Scale = 2
						tear.FallingAccel = -0.1
						
						if cba.IsMortisFloor() then 
							tear:GetData().MortisMotherColored = true
							tear:GetSprite().Color = LastJudgement.Colors.OrganYellow
						else
							tear:GetSprite().Color.R = 5
						end
					end
				end
				
				if data.WS_shoot_frames then
					data.WS_shoot_frames = data.WS_shoot_frames + 1
					
					if data.WS_shoot_frames % 2 == 0 then
					
						if data.WS_shoot_frames == 28 then
						
							for i = 0, 2 do
								local velocity = data.WS_shoot_parentproj_vel[i + 1]
								
								local tear = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, 0, 0, Witness.Position, velocity, Witness):ToProjectile()
								
								tear.Parent = Witness
								cba.GetData(tear).WS_mod_proj = true
								cba.GetData(tear).WS_shoot_parentproj_num = i + 4
								data.WS_shoot_parentproj_vel[i + 4] = velocity
								cba.GetData(tear).WS_shoot_childproj_num = i + 1
								cba.GetData(tear).WS_shoot_velchange_count = 0
								
								tear.FallingAccel = -0.1
								
								if cba.IsMortisFloor() then 
									tear:GetData().MortisMotherColored = true
									tear:GetSprite().Color = Color(1, 1, 0.25, 1) 
									tear:GetSprite().Color:SetColorize(5, 4, 1, 1.25)
								else
									tear:GetSprite().Color.R = 5
								end
							end
							
						else
						
							for i = 0, 2 do
								local velocity = data.WS_shoot_parentproj_vel[i + 1]
								if data.WS_shoot_frames > 28 then
									velocity = data.WS_shoot_parentproj_vel[i + 4]
								end
								
								local tear = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, 0, 0, Witness.Position, velocity, Witness):ToProjectile()
								
								tear.Parent = Witness
								cba.GetData(tear).WS_mod_proj = true
								
								if data.WS_shoot_frames < 28 then
									cba.GetData(tear).WS_shoot_childproj_num = i + 1
								elseif data.WS_shoot_frames > 28 then
									cba.GetData(tear).WS_shoot_childproj_num = i + 4
								end
								cba.GetData(tear).WS_shoot_velchange_count = 0
								
								tear.FallingAccel = -0.1
								
								if cba.IsMortisFloor() then 
									tear:GetData().MortisMotherColored = true
									tear:GetSprite().Color = Color(1, 1, 0.25, 1) 
									tear:GetSprite().Color:SetColorize(5, 4, 1, 1.25)
								else
									tear:GetSprite().Color.R = 5
								end
							end
						end
					end
					
					if data.WS_shoot_frames == 42 then
						data.WS_shoot_frames = nil
					end
				end
			end
			
		
			--Dead Isaacs' logic--
			
		elseif Witness.Variant == 20 and cfg.Witness["LaserAttack"] == true then
		
			if Witness.Position.Y <= 340 then
				
				Witness:Kill()
			else
			
				Witness.Velocity = (Isaac.GetPlayer().Position - Witness.Position):Normalized() * 4
			end
			
			
			
		elseif Witness.Variant == 9 then --Burst attack cluster logic
			if anim == "Idle" then
				data.WS_burst_cluster_frames = data.WS_burst_cluster_frames + 1
				
				if data.WS_burst_cluster_frames == 90 then
				
					sprite:Play("Shoot", true)
					
					data.WS_burst_cluster_frames = 0
				end
				
			elseif anim == "Shoot" then
			
				if frame == 5 then
					local tearCount = 6
					local angleStep = 360 / tearCount
					local speed = 10
					
					for i = 0, tearCount - 1 do
						local angle = i * angleStep
						local velocity = Vector(speed * math.cos(math.rad(angle)), speed * math.sin(math.rad(angle)))
						
						local tear = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, 0, 0, Witness.Position, velocity, Witness):ToProjectile()
						
						tear:ClearProjectileFlags(ProjectileFlags.HIT_ENEMIES)
						tear.Parent = Witness
						cba.GetData(tear).WS_mod_proj = true
					end
					
				elseif sprite:IsFinished() then
				
					sprite:Play("Idle", true)
				end
			end
			
			
			
		elseif Witness.Variant == 100 and data.WS_ball_projcount then --Fistula Ball logic
			
			if Witness.FrameCount == 2 then
			
				if cba.IsMortisFloor() then
					sprite:ReplaceSpritesheet(0, "gfx/cba/bosses/witness/fistula_mortis.png", true)
				end
				
				sprite:GetLayer(1):SetSize(Vector(0.75, 0.75))
			end
			
			for _, tear in ipairs(Isaac.FindByType(EntityType.ENTITY_PROJECTILE)) do
				if not cba.GetData(tear).WS_mod_proj then
					tear:Remove()
				end
			end
			
			if Witness.Position.X >= 1080 
			or Witness.Position.X <= 80 
			or Witness.Position.Y >= 680 then
				local pos = Witness.Position
				
				if pos.X >= 1080 then
					pos.X = 1079
				elseif pos.X <= 80 then
					pos.X = 81 
				end
				
				if pos.Y >= 680 then
					pos.Y = 679 
				end
				
				--Ball and Wall collision--
				
				for _, tear in ipairs(Isaac.FindByType(EntityType.ENTITY_PROJECTILE)) do
					if not cba.GetData(tear).WS_mod_proj then
						tear:Remove()
					end
				end
				
				local speed = 10
				local tearCount = data.WS_ball_projcount
				local angleStep = 360 / tearCount
				
				for i = 0, tearCount - 1 do
					local angle = i * angleStep
					local velocity = Vector(speed * math.cos(math.rad(angle)), speed * math.sin(math.rad(angle)))
					
					local tear = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, 0, 0, pos, velocity, Witness):ToProjectile()
					
					tear:ClearProjectileFlags(ProjectileFlags.HIT_ENEMIES)
					tear.Parent = Witness
					cba.GetData(tear).WS_mod_proj = true
					
					if cba.IsMortisFloor() then
						tear:GetData().MortisMotherColored = true
						tear:GetSprite().Color = LastJudgement.Colors.MotherBlueProj1
					else
						tear:GetSprite().Color:SetColorize(1.5, 2, 1, 1)
					end
					
					tear.Height = -50
				end
				
				data.WS_ball_dir = "towitness"
				
				if cfg.Witness["BallHoming"] == true then
					Witness.Velocity = (Witness.SpawnerEntity.Position - Witness.Position):Normalized() * 25
				end
				
				if data.WS_ball_projcount == 30 then
				
					for i = 0, 9 do
						local angle = i * (360 / 9)
						local velocity = Vector(speed * math.cos(math.rad(angle)), speed * math.sin(math.rad(angle)))
						
						for t = 0, 7 do
							local tear = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, 0, 0, pos, velocity + velocity * t * 0.1, Ball):ToProjectile()
							
							tear:ClearProjectileFlags(ProjectileFlags.HIT_ENEMIES)
							tear.Parent = Witness
							tear:AddProjectileFlags(ProjectileFlags.MEGA_WIGGLE)
							cba.GetData(tear).WS_mod_proj = true
							
							if cba.IsMortisFloor() then
								tear:GetData().MortisMotherColored = true
								tear:GetSprite().Color = LastJudgement.Colors.MotherBlueProj1
							else
								tear:GetSprite().Color:SetColorize(1.5, 2, 1, 1)
							end
							
							tear.Height = -50
						end
					end
					
					local splatColor = Color(1, 1, 1, 1)
					
					if cba.IsMortisFloor() then 
						splatColor:SetColorize(1, 1.5, 2, 1)
					else 
						splatColor:SetColorize(1.5, 2, 1, 1) 
					end
					
					Isaac.Spawn(EntityType.ENTITY_EFFECT, 77, 0, Witness.Position, Vector(0, 0), nil):GetSprite().Color = splatColor
					
					Witness:Remove()
					Game():ShakeScreen(10)
					SFXManager():Play(SoundEffect.SOUND_DEATH_BURST_LARGE, Options.Volume)
				else
					SFXManager():Play(SoundEffect.SOUND_DEATH_BURST_SMALL, Options.Volume)
				end
				
				return
			end
			
			--Ball movement--
			
			local velocity = Witness.Velocity:Normalized()
			local rotate
			
			if cfg.Witness["BallHoming"] == true then 
				if data.WS_ball_dir == "toplayer" then
				
					local bdirection = GetAngle(velocity)
					local angle = GetAngle((Isaac.GetPlayer().Position - Witness.Position):Normalized())
					
					if cfg.Witness["BallSpeedScale"] == true then
						rotate = 3 * Isaac.GetPlayer().MoveSpeed 
					else 
						rotate = 4 
					end
					
					if bdirection > angle then
						if bdirection - angle <= 180 then
							if bdirection - angle < rotate then 
								rotate = bdirection - angle
							else 
								rotate = rotate * -1 
							end
						end
						
					elseif bdirection < angle then
						if angle - bdirection <= 180 then
							if angle - bdirection < rotate then 
								rotate = angle - bdirection
							end
						else
							rotate = rotate * -1
						end
					end
					
					velocity = velocity:Rotated(rotate or 0)
					Witness.Velocity = velocity * 25
					
				elseif data.WS_ball_dir == "towitness" then
					Witness.Velocity = (Witness.SpawnerEntity.Position - Witness.Position):Normalized() * 25
				end
			end
			
		------------------------------------------------
		------------------------------------------------
		-------------------2'ND PHASE-------------------
		------------------------------------------------
		------------------------------------------------
			
		elseif Witness.Variant == 10 then
		
			if state ~= 3 then 
				ClearStatusEffects(Witness)
			end
			
			--------------------------------------------
			-------------------HP Set-------------------
			--------------------------------------------
			
			if cfg.Witness["Witness2IncreasedHP"] == true and not data.WS_2phase_init then
			
				Witness.MaxHitPoints = 2500
				Witness.HitPoints = 2500
				data.WS_2phase_init = true
			end
			
			
			---------------------------------------------
			-----------------Spin Attack-----------------
			---------------------------------------------
			
			
			if cfg.Witness["SpinAttack"] == true then 
				if anim == "SpinBegin" then 
				
					if frame == 1 then
						local chance = math.random(100)
						
						if chance <= cfg.Witness["SpinAttackChance"] then
							data.WS_spin_frames = 59
							data.WS_spin_angle = 0
						end
						
					elseif data.WS_spin_frames then
						for _, tear in ipairs(Isaac.FindByType(EntityType.ENTITY_PROJECTILE)) do
							if not cba.GetData(tear).WS_mod_proj then
								tear:Remove()
							end
						end
					end
						
				elseif anim == "SpinLoop" and data.WS_spin_frames then
				
					for _, tear in ipairs(Isaac.FindByType(EntityType.ENTITY_PROJECTILE)) do
						if not cba.GetData(tear).WS_mod_proj then
							tear:Remove()
						end
					end
					
					data.WS_spin_frames = data.WS_spin_frames + 1
					
					if data.WS_spin_frames % 10 == 0 then
						local speed = 5
						local tearCount = 6
						local angleStep = 360 / tearCount
						
						for i = 0, tearCount - 1 do
							local angle = i * angleStep 
							local velocity = Vector(speed * math.cos(math.rad(angle)), speed * math.sin(math.rad(angle))):Rotated(data.WS_spin_angle)
							
							local tear = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, 0, 0, Witness.Position, velocity, Witness):ToProjectile()
							
							tear.Parent = Witness
							cba.GetData(tear).WS_mod_proj = true
							
							tear.FallingAccel = -0.1
							tear.Scale = 2
						end
						
						data.WS_spin_angle = data.WS_spin_angle + 10
						
						if data.WS_spin_angle == 360 then
							data.WS_spin_angle = 0
						end
						
					end
					
					if data.WS_spin_frames % 30 == 0 then
						local speed = 10
						local tearCount = 20
						local angleStep = 360 / tearCount
						
						for i = 0, tearCount - 1 do
							local angle = i * angleStep 
							local velocity = Vector(speed * math.cos(math.rad(angle)), speed * math.sin(math.rad(angle)))
							
							local tear = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, 0, 0, Witness.Position, velocity, Witness):ToProjectile()
							
							tear.Parent = Witness
							cba.GetData(tear).WS_mod_proj = true
							cba.GetData(tear).WS_circle_curve_dir = data.WS_spin_frames == 30 and 1 or -1
							cba.GetData(tear).WS_circle_center = Witness.Position
							cba.GetData(tear).WS_circle_curve_speed = 2.5
							
							if cba.IsMortisFloor() then
								tear:GetData().MortisMotherColored = true
								tear:GetSprite().Color = LastJudgement.Colors.MotherBlueProj2
							else 
								tear:GetSprite().Color:SetColorize(2.7, 3, 2, 1)
							end
							
							tear.Scale = 1.5
							tear.FallingAccel = -0.1
						end
					end
					
					if data.WS_spin_frames == 60 then
						data.WS_spin_frames = 0
					end
					
				elseif anim == "SpinEnd" then
					data.WS_spin_frames = nil
					data.WS_spin_angle = nil
				end
			end
			
			---------------------------------------------
			--------------Old Charge Attack--------------
			---------------------------------------------
			
			--PS: I just left this attack cuz idea is good enough
			
			
			if cfg.Witness["OldChargeAttack"] == true 
			and (anim == "ChargeLoop" or anim == "ChargeUpLoop") 
			and state ~= 16 
			and not data.WS_charge
			and frame % 5 == 0 then
				local tear = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, 0, 0, Witness.Position, Vector(0, 0), Witness):ToProjectile()
				
				cba.GetData(tear).WS_mod_proj = true
				cba.GetData(tear).WS_oldcharge_proj = "-"
				tear.Parent = Witness
				
				if cba.IsMortisFloor() then 
					tear:GetData().MortisMotherColored = true
					tear:GetSprite().Color = LastJudgement.Colors.MotherBlueProj1
				else
					tear:GetSprite().Color:SetColorize(1.5, 2, 1, 1)
				end
				
				tear.Scale = 2
				tear.Height = -15
				
				if frame == 5 then
					local velocity = (Isaac.GetPlayer().Position - Witness.Position):Normalized() * 15
					
					local wormTear = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, 0, 0, Witness.Position, velocity, Witness):ToProjectile()
					
					cba.GetData(wormTear).WS_mod_proj = true
					cba.GetData(wormTear).WS_oldcharge_proj = "+"
					wormTear:ClearProjectileFlags(ProjectileFlags.HIT_ENEMIES)
					
					if cba.IsMortisFloor() then 
						wormdata.MortisMotherColored = true
						wormTear:GetSprite().Color = Color(0.5, 1, 1, 1)
						wormTear:GetSprite().Color:SetColorize(2, 3, 3, 1.25)
					else
						wormTear:GetSprite().Color = Color(4, 4, 4, 1)
						wormTear:GetSprite().Color:SetColorize(0.63, 0.85, 0.32, 1)
					end
					
					wormTear.Scale = 2
					wormTear.Height = -30
				end
			end
			
			---------------------------------------------
			----------------Charge Attack----------------
			---------------------------------------------
			
			
			if cfg.Witness["ChargeAttack"] == true then
				if anim == "JumpUp" and frame == 1 then
					if cfg.Witness["OldChargeAttack"] == true then
						local chance = math.random(100)
						
						if chance > cfg.Witness["OldChargeChance"] then
							data.WS_charge = true
							data.WS_charge_count = 0
							data.WS_charge_collided = nil
							Witness.State = 11
							
							local speed = 45
							if cfg.Witness["ChargeSpeedScale"] == true then
								speed = (30 * Isaac.GetPlayer().MoveSpeed)
							end
							
							local velocity = (Isaac.GetPlayer().Position - Witness.Position):Normalized()
							data.WS_charge_vel = velocity * speed
							
							local dir = GetAngle(velocity)
							if (dir > 45 and dir <= 135) or (dir > 225 and dir <= 315) then
								sprite:Play("ChargeBegin", true)
							elseif dir > 135 and dir <= 225 then 
								sprite:Play("ChargeLeftBegin", true)
							else 
								sprite:Play("ChargeRightBegin", true) 
							end
						end
						
					else
						data.WS_charge = true
						data.WS_charge_count = 0
						data.WS_charge_collided = nil
						Witness.State = 11
						
						local speed = 45
						if cfg.Witness["ChargeSpeedScale"] == true then
							speed = (30 * Isaac.GetPlayer().MoveSpeed)
						end
						
						local velocity = (Isaac.GetPlayer().Position - Witness.Position):Normalized()
						data.WS_charge_vel = velocity * speed
						
						local dir = GetAngle(velocity)
						if (dir > 45 and dir <= 135) or (dir > 225 and dir <= 315) then
							sprite:Play("ChargeBegin", true)
						elseif dir > 135 and dir <= 225 then 
							sprite:Play("ChargeLeftBegin", true)
						else 
							sprite:Play("ChargeRightBegin", true) 
						end
					end
					
				elseif data.WS_charge then
					
					if (anim == "ChargeBegin" 
					or anim == "ChargeLeftBegin" 
					or anim == "ChargeRightBegin")
					and frame == 11 then
					
						data.WS_charge_start = Witness.Position
						if anim == "ChargeBegin" then 
							sprite:Play("ChargeLoop", true)
						elseif anim == "ChargeLeftBegin" then 
							sprite:Play("ChargeLeftLoop", true)
						elseif anim == "ChargeRightBegin" then
							sprite:Play("ChargeRightLoop", true) 
						end
						
						Game():ShakeScreen(10)
						
						local sounds = {SoundEffect.SOUND_MOTHER_CHARGE1, SoundEffect.SOUND_MOTHER_CHARGE2}
						SFXManager():Play(sounds[math.random(2)], Options.Volume)
						SFXManager():Play(SoundEffect.SOUND_GROUND_TREMOR, Options.Volume)
						
					elseif anim == "ChargeLoop" or anim == "ChargeLeftLoop" or anim == "ChargeRightLoop" then
						Witness.Velocity = data.WS_charge_vel
						
						if frame % 5 == 0 then
							local tear = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, 0, 0, Witness.Position, Vector(0, 0), Witness):ToProjectile()
							
							cba.GetData(tear).WS_mod_proj = true
							cba.GetData(tear).WS_charge_split = true
							cba.GetData(tear).WS_charge_dir = Witness.Velocity:Normalized()
							tear.Parent = Witness
							
							if cba.IsMortisFloor() then 
								tear:GetData().MortisMotherColored = true
								tear:GetSprite().Color = LastJudgement.Colors.MotherBlueProj1
							else
								tear:GetSprite().Color:SetColorize(1.5, 2, 1, 1)
							end
							
							tear.Scale = 2
							tear.Height = -15
						end
						
						if data.WS_charge_collided then
						
							data.WS_charge_count = data.WS_charge_count + 1
							
							if anim == "ChargeLoop" then 
								sprite:Play("ChargeEnd", true)
							elseif anim == "ChargeLeftLoop" then 
								sprite:Play("ChargeLeftEnd", true)
							elseif anim == "ChargeRightLoop" then 
								sprite:Play("ChargeRightEnd", true) 
							end
						end
						
					elseif anim == "ChargeEnd" 
					or anim == "ChargeLeftEnd" 
					or anim == "ChargeRightEnd"
					and frame == 8 then
					
						if data.WS_charge_count < 3 then
							data.WS_charge_collided = nil
							
							local speed = 45
							if cfg.Witness["ChargeSpeedScale"] == true then
								speed = (30 * Isaac.GetPlayer().MoveSpeed)
							end
							
							local velocity = (Isaac.GetPlayer().Position - Witness.Position):Normalized()
							data.WS_charge_vel = velocity * speed
							
							local dir = GetAngle(velocity)
							if (dir > 45 and dir <= 135) or (dir > 225 and dir <= 315) then
								sprite:Play("ChargeBegin", true)
							elseif dir > 135 and dir <= 225 then 
								sprite:Play("ChargeLeftBegin", true)
							else 
								sprite:Play("ChargeRightBegin", true) 
							end
							
						else
							data.WS_charge = nil
							data.WS_charge_vel = nil
							Witness.State = 3
							sprite:Play("Idle", true)
						end
					end
				end
			end
			
			----------------------------------------------
			---------------Brim Ball Attack---------------
			----------------------------------------------
			
			
			if cfg.Witness["BrimstoneAttack"] == true then
				if anim == "ShootBegin" and not data.WS_brimball and not data.WS_brimball_chancecalc then
					local chance = math.random(100)
					
					if chance <= cfg.Witness["BrimAttackChance"] then
						data.WS_start_brimball = true
						data.WS_shootbrim_frames = 14
						data.WS_shootbrim_angle = 0
						Witness:ToNPC().State = 11
						
						local dir = GetAngle((Isaac.GetPlayer().Position - Witness.Position):Normalized())
						if (dir > 45 and dir <= 135) or (dir > 225 and dir <= 315) then
							sprite:Play("ShootBegin", true)
						elseif dir > 135 and dir <= 225 then
							sprite:Play("ShootLeftBegin", true)
						else 
							sprite:Play("ShootRightBegin", true) 
						end
					end
					
					data.WS_brimball_chancecalc = true
					
				elseif data.WS_start_brimball then
					
					if anim == "ShootBegin" or anim == "ShootRightBegin" or anim == "ShootLeftBegin" then
					
						for _, tear in ipairs(Isaac.FindByType(EntityType.ENTITY_PROJECTILE)) do
							if not cba.GetData(tear).WS_mod_proj
							and (CheckColor(tear.Color, "GreenBall", "n") 
								or (cba.IsMortisFloor() and CheckColor(tear.Color, "GreenBall", "m"))
							) then
							
								tear:Remove()
							end
						end
						
						if frame == 14 then
							local velocity = (Isaac.GetPlayer().Position - Witness.Position):Normalized() * 15
							
							local BrimTear = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, 0, 0, Witness.Position, velocity, Witness):ToProjectile()
							
							cba.GetData(BrimTear).WS_mod_proj = true
							cba.GetData(BrimTear).WS_brim_proj = true
							cba.GetData(BrimTear).WS_brim_proj_speed = 15
							BrimTear.Parent = Witness
							
							BrimTear.FallingAccel = -0.1
							
							BrimTear:GetSprite():Load("gfx/cba/bosses/witness/witness_brimstone_tear.anm2", true)
							if cba.IsMortisFloor() then
								BrimTear:GetData().MortisMotherColored = true
								BrimTear:GetSprite().Color = LastJudgement.Colors.CyanBlue
							else 
								BrimTear:GetSprite().Color = Color(5, 1, 1, 1)
							end
							
							BrimTear.Scale = 7
							BrimTear:GetSprite().Scale = Vector(1.5, 1.5)
							BrimTear.Size = 20
							
							if anim == "ShootBegin" then 
								sprite:Play("ShootEnd", true)
							elseif anim == "ShootLeftBegin" then 
								sprite:Play("ShootLeftEnd", true)
							elseif anim == "ShootRightBegin" then 
								sprite:Play("ShootRightEnd", true) 
							end
						end
						
					elseif (anim == "ShootEnd" or anim == "ShootRightEnd" or anim == "ShootLeftEnd")
					and frame == 15 then
						sprite:Play("Idle", true)
					end
					
				elseif data.WS_brimball then
					Witness.Velocity = (Isaac.GetPlayer().Position - Witness.Position):Normalized()
					
					if anim == "ShootBegin" then
					
						for _, tear in ipairs(Isaac.FindByType(EntityType.ENTITY_PROJECTILE)) do
							if not cba.GetData(tear).WS_mod_proj 
							and (CheckColor(tear.Color, "GreenBall", "n") 
								or (cba.IsMortisFloor() and CheckColor(tear.Color, "GreenBall", "m"))
							) then
							
								tear:Remove()
							end
						end
						
						for _, effect in ipairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 5)) do
							effect:Remove()
						end
						
						if frame == 23 then
							sprite:Play("ShootLoop", true)
						end
						
					elseif anim == "ShootLoop" then
						data.WS_shootbrim_frames = data.WS_shootbrim_frames + 1
						
						if data.WS_shootbrim_frames % 15 == 0 then
						
							for i = 0, 3 do
								local angle = i * 90 + data.WS_shootbrim_angle
								for tear = 0, 13 do
									local velocity = Vector(0, 5 + tear + math.random(-10, 10) * 0.1):Rotated(angle)
									local position = Witness.Position + Vector(math.random(-10, 10), 0):Rotated(angle)
									
									local tear = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, 0, 0, position, velocity, Witness):ToProjectile()
									
									cba.GetData(tear).WS_mod_proj = true
									
									if cba.IsMortisFloor() then 
										tear:GetData().MortisMotherColored = true
										tear:GetSprite().Color = LastJudgement.Colors.CyanBlue
										tear:GetSprite().Color:SetTint(1, 3, 3, 1)
									else 
										tear:GetSprite().Color.R = 5
									end
								end
							end
							
							data.WS_shootbrim_angle = data.WS_shootbrim_angle + 15
							if data.WS_shootbrim_angle == 90 then
								data.WS_shootbrim_angle = 0
							end
						end
					end
					
				elseif Witness.State == 3 and data.WS_brimball_chancecalc then
					data.WS_brimball_chancecalc = nil
				end
			end
		end
	end
end

cba:AddCallback(ModCallbacks.MC_NPC_UPDATE, cba.WitnessUpdate, EntityType.ENTITY_MOTHER)


function cba:WitnessProjUpdate(Proj)
	local data = cba.GetData(Proj)
	if data.WS_mod_proj then
	
		if Game():GetRoom():GetGridIndex(Proj.Position) == -1 then
			Proj:Remove()
			return
		end
		
		--Fist projectiles split--
	
		if data.WS_fist_proj and Proj.FrameCount >= 25 and Proj.Scale > 1 then
			local position = Proj.Position
			data.WS_fist_proj = nil
			Proj:Remove()
			
			local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BULLET_POOF, 0, position, Vector(0, 0), Proj):ToEffect()
			
			poof.Scale = Proj.Scale
			
			if cba.IsMortisFloor() then 
				poof:GetSprite().Color = LastJudgement.Colors.MortisBloodProj
			end
			
			
			for i = 1, 2 do
				local angle = i == 1 and -45 or 45
				local velocity = Proj.Velocity:Rotated(angle)
				
				local newProj = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, 0, 0, position, velocity, Proj):ToProjectile()
				
				if cba.IsMortisFloor() then 
					newProj:GetSprite().Color = LastJudgement.Colors.MortisBloodProj
				end
				
				newProj.Parent = Proj.Parent
				cba.GetData(newProj).WS_mod_proj = true
				cba.GetData(newProj).WS_fist_proj = true
				
				newProj.FallingAccel = -0.1
				
				newProj.Scale = Proj.Scale - 0.5
				
				if newProj.Scale == 1 then
					newProj:AddProjectileFlags(ProjectileFlags.WIGGLE)
				end
			end
		end
		
		--Double Fist proj's update--
		
		if data.WS_2fist_Z_proj then
		
			if Proj.FrameCount % 7 == 0 then
			
				if Proj.FrameCount % 14 == 0 then
					Proj.Velocity = Proj.Velocity:Rotated(-135)
					
				else
					Proj.Velocity = Proj.Velocity:Rotated(135)
				end
			end
		end
		
		--Double Fist and Spin proj's update
		
		if data.WS_circle_curve_dir then
			posOffset = Vector(2.5, 0):Rotated((Proj.Position - data.WS_circle_center):GetAngleDegrees())
			targetPos = (Proj.Position + posOffset - data.WS_circle_center):Rotated(data.WS_circle_curve_dir * 1) + data.WS_circle_center
			Proj.Velocity = (targetPos - Proj.Position) * data.WS_circle_curve_speed
		end


		--Shoot projectiles update--
		
		if data.WS_shoot_parentproj_num and not data.WS_shoot_childproj_num then
		
			if Proj.FrameCount % 30 == 0 and data.WS_shoot_velchange_count < 5 then
				Proj.Velocity = (Isaac.GetPlayer().Position - Proj.Position):Normalized() * 10
				
				cba.GetData(Proj.SpawnerEntity).WS_shoot_parentproj_vel[data.WS_shoot_parentproj_num] = Proj.Velocity
				
				data.WS_shoot_velchange_count = data.WS_shoot_velchange_count + 1
			end
			
		elseif data.WS_shoot_childproj_num then
			
			if Proj.FrameCount % 30 == 0 and data.WS_shoot_velchange_count < 5 then
				
				if cba.GetData(Proj.SpawnerEntity).WS_shoot_parentproj_vel[data.WS_shoot_childproj_num] ~= nil then
					Proj.Velocity = cba.GetData(Proj.SpawnerEntity).WS_shoot_parentproj_vel[data.WS_shoot_childproj_num]
				end
				
				if data.WS_shoot_parentproj_num then
					cba.GetData(Proj.SpawnerEntity).WS_shoot_parentproj_vel[data.WS_shoot_parentproj_num] = Proj.Velocity
				end
				
				data.WS_shoot_velchange_count = data.WS_shoot_velchange_count + 1
			end
		end
	
		--SUCC projectiles--
		
		if data.WS_suck_proj then
		
			if not Proj:HasProjectileFlags(ProjectileFlags.MEGA_WIGGLE) then
				Proj:AddProjectileFlags(ProjectileFlags.MEGA_WIGGLE)
			end
			
			if Proj:HasProjectileFlags(ProjectileFlags.HIT_ENEMIES) then
				Proj:ClearProjectileFlags(ProjectileFlags.HIT_ENEMIES)
			end
			
			local velocity = Proj.Velocity:Normalized()
			local pdirection = GetAngle(velocity) 
			local angle = GetAngle((Isaac.GetPlayer().Position - Proj.Position):Normalized())
			local rotate = 0.5
			
			if pdirection > angle then
				
				if pdirection - angle <= 180 then
					
					if pdirection - angle < rotate then 
						rotate = pdirection - angle
					
					else 
						rotate = rotate * -1 
					end
				end
			
			elseif pdirection < angle then
				
				if angle - pdirection <= 180 then
					
					if angle - pdirection < rotate then 
						rotate = angle - pdirection
					end
				
				else
					rotate = rotate * -1
				end
			end
			
			Proj.Velocity = velocity:Rotated(rotate or 0) * 15
		end
		
		--Brimstone projectile--
		
		if data.WS_brim_proj_death then
		
			if Proj:GetShadowSize() ~= 0.2 then 
				Proj:SetShadowSize(0.2) 
			end
			
			if Proj:GetSprite():GetFrame() == 23 then 
				Proj.Height = -4 
			end
			
		elseif data.WS_brim_proj then
		
			if Proj:GetShadowSize() ~= 0.2 then 
				Proj:SetShadowSize(0.2) 
			end
			
			local room = Game():GetRoom()
			local velocity = Proj.Velocity:Normalized()
			local pdirection = GetAngle(velocity) 
			local angle = GetAngle((Isaac.GetPlayer().Position - Proj.Position):Normalized())
			local rotate = 1
			
			if pdirection > angle then
				
				if pdirection - angle <= 180 then
					
					if pdirection - angle < rotate then 
						rotate = pdirection - angle
					
					else 
						rotate = rotate * -1 
					end
				end
				
			elseif pdirection < angle then
				
				if angle - pdirection <= 180 then
					
					if angle - pdirection < rotate then 
						rotate = angle - pdirection
					end
				
				else
					rotate = rotate * -1
				end
			end
			
			if not CheckForGrid(Proj.Position, GridEntityType.GRID_PIT) or not CheckForGrid(Proj.Position, GridEntityType.GRID_WALL) then
				data.WS_brim_proj_speed = data.WS_brim_proj_speed - 0.25
				
				for _, npc in ipairs(Isaac.FindInRadius(Proj.Position, 170, EntityPartition.ENEMY)) do
					if npc.Type == EntityType.ENTITY_MOTHER and npc.Variant == 10 and data.WS_brim_proj_speed < 7.5 then
						data.WS_brim_proj_speed = data.WS_brim_proj_speed + 0.5
						break
					end
				end
			end
			
			if Proj.Position.X >= 1060 or Proj.Position.X <= 60 or Proj.Position.Y >= 660 or Proj.Position.Y <= 180 then
				
				if data.WS_brim_proj_speed < 7.5 then
					data.WS_brim_proj_speed = 7.5
					Proj.Velocity = (Isaac.GetPlayer().Position - Proj.Position):Normalized() * 7.5
				
				else
					Proj.Velocity = Proj.Velocity:Normalized():Rotated(180) * data.WS_brim_proj_speed
				end
				
			elseif data.WS_brim_proj_speed == 0 then
				data.WS_brim_proj_death = true
				
				if cba.IsMortisFloor() then 
					Proj:GetSprite():Play("BrimTearMortisDeath", true)
				else 
					Proj:GetSprite():Play("BrimTearDeath", true) 
				end
				
				cba.GetData(Proj.SpawnerEntity).WS_start_brimball = nil
				cba.GetData(Proj.SpawnerEntity).WS_brimball = true
				data.WS_brim_proj = nil
				
				Proj.SpawnerEntity:GetSprite():Play("ShootBegin", true)
				
			else
				Proj.Velocity = velocity:Rotated(rotate or 0) * data.WS_brim_proj_speed
			end
		end
		
		--Worm projectiles--
		
		if data.WS_spot_projdir and Proj.SpawnerEntity then
			
			if Proj.SpawnerEntity:GetSprite():GetAnimation() ~= "Spot" and Proj.Velocity.X == 0 and Proj.Velocity.Y == 0 then
				
				if Proj.SpawnerEntity:GetSprite():GetAnimation() == "MoveRight" then
					Proj.Velocity = Vector(65, 0) 
					Proj:GetSprite().Scale = Vector(1, 0.5)
				
				elseif Proj.SpawnerEntity:GetSprite():GetAnimation() == "MoveLeft" then
					Proj.Velocity = Vector(-65, 0) 
					Proj:GetSprite().Scale = Vector(1, 0.5)
				
				elseif Proj.SpawnerEntity:GetSprite():GetAnimation() == "MoveUp" then
					Proj.Velocity = Vector(0, -65) 
					Proj:GetSprite().Scale = Vector(0.5, 1)
				
				elseif Proj.SpawnerEntity:GetSprite():GetAnimation() == "MoveDown" then
					Proj.Velocity = Vector(0, 65) 
					Proj:GetSprite().Scale = Vector(0.5, 1)
				end
			end
		end
	
	--SUCC projs init--
	
	elseif cfg.Witness["SUCC"] == true and not data.WS_mod_proj
	and (CheckColor(Proj.Color, "GreenBall", "n")
			or (cba.IsMortisFloor() and Proj:GetData().MortisMotherColored and CheckColor(Proj.Color, "GreenBall", "m"))
		) then 
		data.WS_suck_proj = true
		data.WS_mod_proj = true
	end
end

cba:AddCallback(ModCallbacks.MC_POST_PROJECTILE_UPDATE, cba.WitnessProjUpdate)



--This needs for fix bug with Epiphany causing game crash(idk why)

cba:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, CallbackPriority.IMPORTANT, function(_, player, dmg, flags, src, cntdown)
	if Epiphany and src.Entity and src.Entity.Type == EntityType.ENTITY_PROJECTILE then
		local data = cba.GetData(src.Entity)
	
		if data.WS_mod_proj then
		
			player:TakeDamage(dmg, flags, EntityRef(player), cntdown)
			
			return false
		end
	end
end, EntityType.ENTITY_PLAYER)



function cba:WitnessProjDeath(Proj)
	local data = cba.GetData(Proj)
	if data.WS_mod_proj then
	
		--Burst cluster spawn--
		
		if data.WS_burst_proj then
		
			local cluster = Isaac.Spawn(EntityType.ENTITY_MOTHER, 9, 0, Proj.Position, Vector(0, 0), Proj)
			
			if cba.IsMortisFloor() then 
				cluster:GetSprite():ReplaceSpritesheet(0, "gfx/cba/bosses/witness/witness_tear_mortis.png", true)
				cluster:GetSprite():ReplaceSpritesheet(1, "gfx/cba/bosses/witness/witness_tear_ground_mortis.png", true)
			end
			
			for i = 0, 2 do
				local direction = Vector(1, 0):Rotated(math.random(0, 360))
				
				for i = 0, 3 do
					local position = Proj.Position + direction * i * 30
					
					local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, 22, 0, position, Vector(0, 0), cluster):ToEffect()
					
					if cba.IsMortisFloor() then 
						creep:GetSprite().Color = Color(1, 0.6, 0.7, 1)
						creep:GetSprite().Color:SetColorize(2.2, 0.924, 1.31, 1)
					end
					
					creep:SetTimeout(180)
				end
			end
		end
		
		--Shoot projectiles death--
		
		if data.WS_shoot_velchange_count then
			local velocity = Proj.Velocity:Rotated(180):Rotated(math.random(-30, 30))
			
			local newProj = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, 0, 0, Proj.Position, velocity, nil):ToProjectile()
			
			newProj.Parent = Proj.Parent
			cba.GetData(newProj).WS_mod_proj = true
			
			newProj.FallingAccel = -0.1
			
			if cba.IsMortisFloor() then 
				newProj:GetData().MortisMotherColored = true
				newProj:GetSprite().Color = Color(1, 1, 0.25, 1) 
				newProj:GetSprite().Color:SetColorize(5, 4, 1, 1.25)
			else
				newProj:GetSprite().Color.R = 5
			end
			
			if data.WS_shoot_parentproj_num and not data.WS_shoot_childproj_num then
				newProj.Scale = 2
			end
		end
		
		--Old Charge projectiles split--
		
		if data.WS_oldcharge_proj == "-" then
		
			for i = 0, 1 do
				local velocity = Vector(15,0):Rotated(i * 180)
				
				local newProj = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, 0, 0, Proj.Position, velocity, Proj):ToProjectile()
				
				cba.GetData(newProj).WS_mod_proj = true
				newProj.Parent = Proj.Parent
				
				if cba.IsMortisFloor() then 
					newProj:GetData().MortisMotherColored = true
					newProj:GetSprite().Color = LastJudgement.Colors.MotherBlueProj1
				else
					newProj:GetSprite().Color:SetColorize(1.5, 2, 1, 1)
				end
				
				newProj.FallingAccel = -0.1
			end
		elseif data.WS_oldcharge_proj == "+" then
			local randomAngle = math.random(0, 1)
			
			for i = 0, 3 do
				local velocity = Vector(15,0):Rotated(i * 90):Rotated(45 * randomAngle)
				
				local newProj = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, 0, 0, Proj.Position, velocity, Proj):ToProjectile()
				
				cba.GetData(newProj).WS_mod_proj = true
				newProj.Parent = Proj.Parent
				
				if cba.IsMortisFloor() then 
					newProj:GetData().MortisMotherColored = true
					newProj:GetSprite().Color = Color(0.5, 1, 1, 1)
					newProj:GetSprite().Color:SetColorize(2, 3, 3, 1.25)
				else
					newProj:GetSprite().Color = Color(4, 4, 4, 1)
					newProj:GetSprite().Color:SetColorize(0.63, 0.85, 0.32, 1)
				end
			end
		end
		
		--Charge projectiles split--
		
		if data.WS_charge_split then
		
			for i = 0, 1 do
				local angle = i == 0 and 90 or -90
				local velocity = data.WS_charge_dir:Rotated(angle) * 10
				
				local newProj = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, 0, 0, Proj.Position, velocity, Proj):ToProjectile()
				
				cba.GetData(newProj).WS_mod_proj = true
				newProj.Parent = Proj.Parent
				
				if cba.IsMortisFloor() then 
					newProj:GetData().MortisMotherColored = true
					newProj:GetSprite().Color = LastJudgement.Colors.MotherBlueProj1
				else
					newProj:GetSprite().Color:SetColorize(1.5, 2, 1, 1)
				end
				
				newProj.Height = -30
			end
		end
		
		--Brimstone projectile early death--
		
		if data.WS_brim_proj then
			local BrimTear = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, 0, 0, Proj.Position, Proj.Velocity, Proj.SpawnerEntity):ToProjectile()
			
			cba.GetData(BrimTear).WS_mod_proj = true
			cba.GetData(BrimTear).WS_brim_proj = true
			cba.GetData(BrimTear).WS_brim_proj_speed = data.WS_brim_proj_speed
			BrimTear:ClearProjectileFlags(ProjectileFlags.HIT_ENEMIES)
			BrimTear.Parent = Proj.Parent
			
			BrimTear.FallingAccel = -0.1
			
			BrimTear:GetSprite():Load("gfx/cba/bosses/witness/witness_brimstone_tear.anm2", true)
			if cba.IsMortisFloor() then 
				BrimTear:GetData().MortisMotherColored = true
				BrimTear:GetSprite().Color = LastJudgement.Colors.CyanBlue
			else 
				BrimTear:GetSprite().Color = Color(5, 1, 1, 1)
			end
			
			BrimTear.Scale = 7
			BrimTear:GetSprite().Scale = Vector(1.5, 1.5)
			BrimTear.Size = 20
		end
		
		
		--Brimstone projectile death--
		
		if data.WS_brim_proj_death and Proj.SpawnerEntity:Exists() then
		
			for _, effect in ipairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.BULLET_POOF)) do
				if tostring(effect.Position) == tostring(Proj.Position) then 
					effect:Remove()
				end
			end	
			
			local ball = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BRIMSTONE_BALL, 0, Proj.Position, Vector(0, 0), Proj.SpawnerEntity):ToEffect()
			
			if cfg.Witness["OldBrimBallGfx"] then
				ball:GetSprite():Load("gfx/cba/bosses/witness/witness_brimstone_ball.anm2", true)
				ball:GetSprite():Play("Idle", true)
			else
				ball:GetSprite().Color.A = 1.2
			end
			
			cba.GetData(ball).WS_brimeffect = true
			
			ball:SetTimeout(300)
			ball.CollisionDamage = 0
			
			local angle = GetAngle(Isaac.GetPlayer().Position - Proj.Position)
			local laser = Isaac.Spawn(EntityType.ENTITY_LASER, LaserVariant.THICK_RED, 0, Proj.Position, Vector(0, 0), Proj.SpawnerEntity):ToLaser()
			
			laser:GetSprite().Color.A = 1.2
			
			if cba.IsMortisFloor() then 
				laser:GetSprite().Color = LastJudgement.Colors.CyanBlue 
				ball:GetSprite().Color = LastJudgement.Colors.CyanBlue 
			end
			
			laser.AngleDegrees = angle - 180
			laser:SetTimeout(300)
			
			cba.GetData(laser).WS_brimlaser = true
			
			laser.Parent = Proj.SpawnerEntity
			laser:SetDisableFollowParent(true)
			
			cba:WitnessBrimstone(laser)
		end
		
		--Fix for Tears attack--
		
		if data.WS_spot_projdir and Game():GetRoom():GetGridIndex(Proj.Position) ~= -1 then
			local vel, scale
			
			if data.WS_spot_projdir == "r" then 
				vel = Vector(65, 0) 
				scale = Vector(1, 0.5)
			elseif data.WS_spot_projdir == "l" then 
				vel = Vector(-65, 0) 
				scale = Vector(1, 0.5)
			elseif data.WS_spot_projdir == "u" then 
				vel = Vector(0, -65) 
				scale = Vector(0.5, 1)
			elseif data.WS_spot_projdir == "d" then 
				vel = Vector(0, 65) 
				scale = Vector(0.5, 1)
			end
			
			local newProj = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, 0, 0, Proj.Position, vel, Proj.SpawnerEntity):ToProjectile()
			
			newProj.Parent = Proj.Parent
			newProj:AddProjectileFlags(ProjectileFlags.NO_WALL_COLLIDE)
			cba.GetData(newProj).WS_mod_proj = true
			
			newProj.FallingAccel = -0.1
			newProj.Scale = 2
			newProj.DepthOffset = 1000
			
			newProj:GetSprite().Scale = scale
			
			if cba.IsMortisFloor() then 
				newProj:GetData().MortisMotherColored = true
				newProj:GetSprite().Color = LastJudgement.Colors.VirusBlue
			else 
				newProj:GetSprite().Color:SetColorize(3.5, 2.5, 1, 1)
			end
		end
	end
end

cba:AddCallback(ModCallbacks.MC_POST_PROJECTILE_DEATH, cba.WitnessProjDeath)

function cba:WitnessCorpseEaterUpdate(CE)
	local data = cba.GetData(CE)
	
	if CE.Variant == worm.Variant and data.WS_CE_vel then
	
		CE.Velocity = data.WS_CE_vel
	
		if data.WS_CE_dir == "+" then
	
			CE.SpriteOffset = CE.SpriteOffset - Vector(0, 2)
			
			if CE.SpriteOffset.Y == -25 then
			
				data.WS_CE_dir = "-"
			end
			
		elseif data.WS_CE_dir == "-" then
		
			CE.SpriteOffset = CE.SpriteOffset + Vector(0, 2)
			
			if CE.SpriteOffset.Y >= 0 then
			
				CE.SpriteOffset.Y = 0
			
				data.WS_CE_vel = nil
				data.WS_CE_dir = nil
				
				CE.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
			end
		end
	end
end

cba:AddCallback(ModCallbacks.MC_NPC_UPDATE, cba.WitnessCorpseEaterUpdate, worm.Type)



function cba:WitnessKnifeUpdate(Knife)
	if cba.IsWitnessBossRoom() and cfg.Witness["HomingKnives"] == true then
		local data = cba.GetData(Knife)
	
		if Knife.FrameCount == 1 then
			data.WS_knife_angle = GetAngle(Isaac.GetPlayer().Position - Knife.Position) - 90
			
		elseif data.WS_knife_angle then
			Knife.Velocity = Vector(0,20):Rotated(data.WS_knife_angle)
			Knife:GetSprite().Rotation = data.WS_knife_angle
		end
	end
end

cba:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, cba.WitnessKnifeUpdate, EffectVariant.BIG_KNIFE)



function cba:WitnessLaserUpdate(Laser)
	if cba.IsWitnessBossRoom() then
		local data = cba.GetData(Laser)
	
		if data.WS_laser_dir then
		
			if not Laser.SpawnerEntity or cba.GetData(Laser.SpawnerEntity).WS_laser_frames == 33 then
				Laser:Remove()
				return
			end
			
			if Laser.FrameCount % 2 == 0 then
				local splatColor = Color(1, 1, 1, 1)
						
				if cba.IsMortisFloor() then 
					splatColor:SetColorize(1, 1.5, 2, 1)
				else 
					splatColor:SetColorize(1.5, 2, 1, 1) 
				end
				
				Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 3, Laser:GetEndPoint(), Vector(0, 0), Laser):GetSprite().Color = splatColor
			end
			
			if data.WS_laser_dir == "+" then
			
				if not Laser.IsActiveRotating then
				
					data.WS_laser_degrees = data.WS_laser_degrees - 88
					Laser:SetActiveRotation(10, -88, -1, false)
					data.WS_laser_dir = "-"
					
				elseif Laser.IsActiveRotating and Laser.RotationDelay == 0 then
				
					if Laser.AngleDegrees < data.WS_laser_degrees - 44 then
						Laser.RotationSpd = Laser.RotationSpd + 0.5
						
					elseif Laser.AngleDegrees > data.WS_laser_degrees - 44 then
						Laser.RotationSpd = Laser.RotationSpd - 0.5
					end
				end
				
				Game():ShakeScreen(5)
				
			elseif data.WS_laser_dir == "-" then
				if not Laser.IsActiveRotating then
				
					data.WS_laser_degrees = data.WS_laser_degrees + 88
					Laser:SetActiveRotation(10, 88, 1, false)
					data.WS_laser_dir = "+"
					
				elseif Laser.IsActiveRotating and Laser.RotationDelay == 0 then
				
					if Laser.AngleDegrees > data.WS_laser_degrees + 44 then
						Laser.RotationSpd = Laser.RotationSpd - 0.5
						
					elseif Laser.AngleDegrees < data.WS_laser_degrees + 44 then
						Laser.RotationSpd = Laser.RotationSpd + 0.5
					end
				end
				
				Game():ShakeScreen(5)
			end
		end
	end
end

cba:AddCallback(ModCallbacks.MC_POST_LASER_UPDATE, cba.WitnessLaserUpdate, 2)


function cba:DeadIsaacKill(DI)
	if cba.IsWitnessBossRoom() and cfg.Witness["LaserAttack"] and DI.Variant == 20 then
	
		DI:Remove()
		
		local dir = (Isaac.GetPlayer().Position - DI.Position):Normalized()
		local vel = dir:Resized((DI.Position - Isaac.GetPlayer().Position):Length() / 27)
		
		local head = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, ProjectileVariant.PROJECTILE_HEAD, 0, DI.Position, vel, DI):ToProjectile()
		
		cba.GetData(head).WS_mod_proj = true
		cba.GetData(head).WS_DI_head = true
			
		head.FallingSpeed = -42
		head.FallingAccel = 2
		
		Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.ROCK_EXPLOSION, 0, DI.Position, Vector(0, 0), DI)
	
		local tearCount = math.random(10, 15)
		
		for i = 1, tearCount do
			local vel = Vector(1, 0):Rotated(math.random(360)) * 5
			local var = math.random(1, 4)
			var = var == 4 and ProjectileVariant.PROJECTILE_BONE or 0
			
			local proj = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, var, 0, DI.Position, vel, DI):ToProjectile()
			
			cba.GetData(proj).WS_mod_proj = true
			
			proj.Scale = math.random(10, 15) * 0.1
			proj.FallingSpeed = math.random(-20,-5)
			proj.FallingAccel = 2
			
			if var ~= ProjectileVariant.PROJECTILE_BONE then
				if cba.IsMortisFloor() then 
					proj:GetData().MortisMotherColored = true
					proj:GetSprite().Color = LastJudgement.Colors.MotherBlueProj1
				else
					proj:GetSprite().Color:SetColorize(1.5, 2, 1, 1)
				end
			end
		end
	end
end
				
cba:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, cba.DeadIsaacKill, EntityType.ENTITY_MOTHER)


cba:AddCallback(ModCallbacks.MC_POST_PROJECTILE_INIT, function(_, head)
	if cba.IsWitnessBossRoom() and cfg.Witness["LaserAttack"] 
	and cba.GetData(head).WS_mod_proj and cba.GetData(head).WS_DI_head then
		head:Remove()
	end
end, ProjectileVariant.PROJECTILE_HEAD)


function cba:WitnessChargeWallCollide(Witness, Idx, Wall)
	local data = cba.GetData(Witness)
	if Wall 
	and Wall:GetType() == GridEntityType.GRID_WALL 
	and data.WS_charge and not data.WS_charge_collided then
	
		local gridDir = Game():GetRoom():GetGridPosition(Idx) - data.WS_charge_start
		local witnessDir = data.WS_charge_vel
		
		if GetAngle(witnessDir) < 45 or GetAngle(witnessDir) > 315 then
			
			if GetAngle(gridDir) >= GetAngle(witnessDir:Rotated(-45)) 
			or GetAngle(gridDir) <= GetAngle(witnessDir:Rotated(45)) then
				
				data.WS_charge_collided = true
				Game():ShakeScreen(10)
			end
		else
			if GetAngle(gridDir) >= GetAngle(witnessDir:Rotated(-45)) 
			and GetAngle(gridDir) <= GetAngle(witnessDir:Rotated(45)) then
			
				data.WS_charge_collided = true
				Game():ShakeScreen(10)
			end
		end
	end
end

cba:AddCallback(ModCallbacks.MC_PRE_NPC_GRID_COLLISION, cba.WitnessChargeWallCollide, EntityType.ENTITY_MOTHER)


function cba:WitnessBrimstone(Brim)
	if cba.GetData(Brim).WS_brimlaser then
		local angle = GetAngle((Isaac.GetPlayer().Position - Brim.Position):Normalized())
		local speed = 0
		local brimAngle = Brim.AngleDegrees < 0 and Brim.AngleDegrees + 360 or Brim.AngleDegrees
		
		if brimAngle > angle then
		
			if brimAngle - angle <= 180 then
			
				if brimAngle - angle < 2 then
					speed = brimAngle - angle
					
				else
					speed = -2
				end
				
			else
				speed = 2
			end
			
		elseif brimAngle < angle then
		
			if angle - brimAngle <= 180 then
			
				if angle - brimAngle < 2 then
					speed = angle - brimAngle
					
				else
					speed = 2
				end
				
			else
				speed = -2
			end
		end
		
		if not Brim.SpawnerEntity:Exists() then
			Brim:Kill()
			Brim.Parent:Kill()
			return
		elseif Brim.Timeout <= 8 then
			local wdata = cba.GetData(Brim.SpawnerEntity)
			
			if wdata.WS_brimball then
				wdata.WS_brimball = nil
				wdata.WS_shootbrim_frames = nil
				wdata.WS_shootbrim_angle = nil
				
				Brim.SpawnerEntity:ToNPC().State = 3
				
				if Brim.SpawnerEntity:GetSprite():GetAnimation() == "ShootLoop" then
					Brim.SpawnerEntity:GetSprite():Play("ShootEnd", true)
				end
			end
		end
		
		Brim:SetActiveRotation(0, angle, speed, false)
	end
end

cba:AddCallback(ModCallbacks.MC_POST_LASER_UPDATE, cba.WitnessBrimstone)

function cba:BrimBallDeathFix(Ball)
	if cba.GetData(Ball).WS_brimeffect and not Ball.SpawnerEntity:Exists() then
		Ball:Remove()
	end
end

cba:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, cba.BrimBallDeathFix, EffectVariant.BRIMSTONE_BALL)


function cba:WitnessWormsAttack(Spot)
	if cba.IsWitnessBossRoom() and cfg.Witness["TearsAttack"] == true then
		local sprite = Spot:GetSprite()
		local witness = Spot.SpawnerEntity
		if sprite:GetAnimation() == "Spot" and witness:Exists() then
		
			if cfg.Witness["TearsAttackLines"] == false then
				for i = 0, 1 do
					sprite:ReplaceSpritesheet(i, "idk its just blank.png", true)
				end
			end
			
			sprite:ReplaceSpritesheet(2, "idk its just blank.png", true)
			
			if sprite:GetFrame() == 1 then
				local dir
				
				if witness:GetSprite():GetAnimation() == "SwipeRight" then 
					dir = "r" 
					Spot.Position = Spot.Position + Vector(0, math.random(-40, 40))
					
				elseif witness:GetSprite():GetAnimation() == "SwipeLeft" then 
					dir = "l" 
					Spot.Position = Spot.Position + Vector(0, math.random(-40, 40))
					
				elseif witness:GetSprite():GetAnimation() == "SwipeUp" then 
					dir = "u" 
					Spot.Position = Spot.Position + Vector(math.random(-40, 40), 0)
					
				elseif witness:GetSprite():GetAnimation() == "SwipeDown" then 
					dir = "d" 
					Spot.Position = Spot.Position + Vector(math.random(-40, 40), 0)
				end
				
				local proj = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, 0, 0, Spot.Position, Vector(0, 0), Spot):ToProjectile()
				
				proj:ClearProjectileFlags(ProjectileFlags.HIT_ENEMIES)
				proj.Parent = witness
				proj:AddProjectileFlags(ProjectileFlags.NO_WALL_COLLIDE)
				cba.GetData(proj).WS_mod_proj = true
				cba.GetData(proj).WS_spot_projdir = dir
				
				proj.FallingAccel = -0.1
				proj.Scale = 2
				proj.DepthOffset = 1000
				
				if cba.IsMortisFloor() then 
					proj:GetData().MortisMotherColored = true
					proj:GetSprite().Color = LastJudgement.Colors.VirusBlue
				else 
					proj:GetSprite().Color:SetColorize(3.5, 2.5, 1, 1)
				end
			end
		end
	end
end

cba:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, cba.WitnessWormsAttack, EffectVariant.MOTHER_TRACER)
