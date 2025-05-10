local cba = CutBossesAttacks

function cba:IsSkinlessWombRoom()
	local data = Game():GetLevel():GetCurrentRoomDesc().Data
	
	return (Game():GetLevel():GetStage() == LevelStage.STAGE4_3 
	or 
	(data 
	and data.Type == RoomType.ROOM_DEFAULT 
	and data.Variant == 1 
	and data.Subtype == 1 
	and data.StageID == 13)
	) 
	and cba.Save.Config["SkinlessHush"]["IsSkinlessWomb"] == true
end

function cba:SWInit(knife)
	local data = Game():GetLevel():GetCurrentRoomDesc().Data
	
	if data 
	and data.Type == RoomType.ROOM_DEFAULT 
	and data.Variant == 1 
	and data.Subtype == 1 
	and data.StageID == 13 
	and cba.Save.Config["SkinlessHush"]["IsSkinlessWomb"] == false then
	
		if tostring(knife.Position) ~= "320 280" then
			knife.Position = Vector(320, 280)
		end
		
		if knife:GetSprite():GetAnimation()~= "SWOpen" then
			knife:GetSprite():Load("gfx/cba/bosses/skinless_hush/full_knife_SH_anim.anm2", true)
			knife:GetSprite():Play("SWOpen", true)
			
		elseif knife:GetSprite():GetFrame() > 15 
		and knife:GetSprite():GetFrame() < 33 
		and knife:GetSprite():GetFrame() % 2 == 0 then
			SFXManager():Play(SoundEffect.SOUND_DEATH_BURST_LARGE)
		
		elseif knife:GetSprite():GetFrame() == 33 then
			Game():GetRoom():SetBackdropType(Isaac.GetBackdropIdByName("SkinlessWombCBA"), 1)
			
			Game():SetColorModifier(ColorModifier(1, 0, 0, 0.5, 0.01, 1), false, 0)
			
			for i = 0, Game():GetRoom():GetGridSize() do
				local grid = Game():GetRoom():GetGridEntity(i)
				
				if grid then 
					if ((grid:GetType() >= GridEntityType.GRID_ROCK and grid:GetType() <= GridEntityType.GRID_ROCK) 
					or grid:GetType() == GridEntityType.GRID_ROCK_SS 
					or (grid:GetType() >= GridEntityType.GRID_ROCK_SPIKED and grid:GetType() <= GridEntityType.GRID_ROCK_GOLD)) then
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
		
		elseif knife:GetSprite():IsFinished() == true then
			knife:Remove()
			
			if knife.Player then
				knife.Player:RemoveCollectible(CollectibleType.COLLECTIBLE_KNIFE_PIECE_1)
				knife.Player:RemoveCollectible(CollectibleType.COLLECTIBLE_KNIFE_PIECE_2)
			end
			
			cba.Save.Config["SkinlessHush"]["IsSkinlessWomb"] = true
		end
		return true
	end
end


cba:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_UPDATE, cba.SWInit, FamiliarVariant.KNIFE_FULL)


function cba:SWRoomGfx()
	local data = Game():GetLevel():GetCurrentRoomDesc().Data
	
	if cba.IsSkinlessWombRoom()
	and Game():GetRoom():GetBackdropType() ~= Isaac.GetBackdropIdByName("SkinlessWombCBA") then
		Game():GetRoom():SetBackdropType(Isaac.GetBackdropIdByName("SkinlessWombCBA"), 1)
		
		for i = 0, Game():GetRoom():GetGridSize() do
			local grid = Game():GetRoom():GetGridEntity(i)
			
			if grid then 
				if ((grid:GetType() >= GridEntityType.GRID_ROCK and grid:GetType() <= GridEntityType.GRID_ROCK) 
				or grid:GetType() == GridEntityType.GRID_ROCK_SS 
				or (grid:GetType() >= GridEntityType.GRID_ROCK_SPIKED and grid:GetType() <= GridEntityType.GRID_ROCK_GOLD)) then
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
		
		if Game():GetLevel():GetStage() == LevelStage.STAGE4_3 then
		
			if Game():GetLevel():GetCurrentRoomDesc().GridIndex == 84 then
				
				for i = 0, 4 do
					Game():GetRoom():GetDoor(DoorSlot.UP0):GetSprite():ReplaceSpritesheet(i, "gfx/cba/grid/skinlesshush_door.png", true)
				end
			
			elseif Game():GetLevel():GetCurrentRoomDesc().GridIndex == 58 then
				
				for i = 0, 4 do
					Game():GetRoom():GetDoor(DoorSlot.DOWN0):GetSprite():ReplaceSpritesheet(i, "gfx/cba/grid/skinlesshush_door.png", true)
				end
				
				if Game():GetRoom():GetDoor(DoorSlot.UP1) then
					for i = 0, 4 do
						Game():GetRoom():GetDoor(DoorSlot.UP1):GetSprite():ReplaceSpritesheet(i, "gfx/cba/grid/skinlesshush_door.png", true)
					end
				end
			
			elseif Game():GetLevel():GetCurrentRoomDesc().GridIndex == -9 then
				
				for i = 0, 4 do
					Game():GetRoom():GetDoor(DoorSlot.DOWN0):GetSprite():ReplaceSpritesheet(i, "gfx/cba/grid/skinlesshush_door.png", true)
				end
			end
		else
			for _, slot in ipairs({DoorSlot.UP0, DoorSlot.LEFT0, DoorSlot.RIGHT0, DoorSlot.DOWN0}) do
				
				if Game():GetRoom():GetDoor(slot) then
					
					for i = 0, 5 do
						Game():GetRoom():GetDoor(slot):GetSprite():ReplaceSpritesheet(i, "gfx/grid/door_29_doortobluewomb.png", true)
					end
				end
			end
		end
	end
end


cba:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, cba.SWRoomGfx)


function cba:SWOnRender()
	if cba.IsSkinlessWombRoom() then
		if Game():GetCurrentColorModifier().R ~= 1
		or Game():GetCurrentColorModifier().G ~= 0
		or Game():GetCurrentColorModifier().B ~= 0
		or Game():GetCurrentColorModifier().A ~= 0.5
		or Game():GetCurrentColorModifier().Brightness ~= 0.01
		or Game():GetCurrentColorModifier().Contrast ~= 1 then
			Game():SetColorModifier(ColorModifier(1, 0, 0, 0.5, 0.01, 1), false, 0)
		end
	end

	if Game():GetLevel():GetStage() == LevelStage.STAGE4_3 
	and cba.Save.Config["SkinlessHush"]["IsSkinlessWomb"] == true 
	and Game():GetRoom():GetBossID() == 63 
	and RoomTransition.IsRenderingBossIntro() == true then
		local sprite = RoomTransition.GetVersusScreenSprite()
		
		sprite:ReplaceSpritesheet(0, "gfx/cba/ui/boss/ground_skinlesshush.png", true)
		sprite:ReplaceSpritesheet(2, "gfx/cba/ui/boss/bossspot_skinlesshush.png", true)
		sprite:ReplaceSpritesheet(3, "gfx/cba/ui/boss/playerspot_skinlesswomb.png", true)
		sprite:ReplaceSpritesheet(4, "gfx/cba/ui/boss/portrait_408.0_skinlesshush.png", true)
		sprite:ReplaceSpritesheet(7, "gfx/cba/ui/boss/bossname_408.0_skinlesshush.png", true)
	end
end


cba:AddCallback(ModCallbacks.MC_POST_RENDER, cba.SWOnRender)


function cba.SWFloorInit()
	if Game():GetLevel():GetStage() == LevelStage.STAGE4_3 
	and cba.Save.Config["SkinlessHush"]["IsSkinlessWomb"] == true then
		
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
	
	elseif Game():GetLevel():GetStage() ~= LevelStage.STAGE4_3 
	and Game():GetLevel():GetStage() ~= LevelStage.STAGE4_2 
	and cba.Save.Config["SkinlessHush"]["IsSkinlessWomb"] == true then
		cba.Save.Config["SkinlessHush"]["IsSkinlessWomb"] = false
	end
end


cba:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, cba.SWFloorInit)


function cba:SWMusic(id)
	if Game():GetLevel():GetStage() == LevelStage.STAGE4_3 
	and cba.Save.Config["SkinlessHush"]["IsSkinlessWomb"] == true then
		
		if (Game():GetRoom():GetType() == RoomType.ROOM_DEFAULT 
		or Game():GetRoom():GetType() == RoomType.ROOM_TREASURE 
		or Game():GetRoom():GetType() == RoomType.ROOM_SHOP)
		and id ~= Isaac.GetMusicIdByName("Skinless Womb") 
		and id ~= Music.MUSIC_JINGLE_NIGHTMARE then
		
			return Isaac.GetMusicIdByName("Skinless Womb")
		
		elseif Game():GetRoom():GetType() == RoomType.ROOM_BOSS 
		and not Game():GetRoom():IsClear() 
		and id ~= Isaac.GetMusicIdByName("Skinless Hush") 
		and id ~= Music.MUSIC_JINGLE_BOSS 
		and RoomTransition.IsRenderingBossIntro() == false then
			
			return Isaac.GetMusicIdByName("Skinless Hush")
		end
	end
end


cba:AddCallback(ModCallbacks.MC_PRE_MUSIC_PLAY, cba.SWMusic)


function cba:SWCurse(id, _, player)
	if id == CollectibleType.COLLECTIBLE_RED_KEY
	and cba.IsSkinlessWombRoom() then
		player:AnimateSad()
		SFXManager():Play(SoundEffect.SOUND_DEATH_CARD)
		SFXManager():Play(SoundEffect.SOUND_BEAST_SPIT)
		return true
	end
end


cba:AddCallback(ModCallbacks.MC_PRE_USE_ITEM, cba.SWCurse)