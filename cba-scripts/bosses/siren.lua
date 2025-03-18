local cba = CutBossesAttacks

local cfg = cba.Save.Config
local noteanm = "gfx/cba/bosses/siren/siren_note.anm2"
local notegfx = "gfx/cba/bosses/siren/siren_note1.png"
local dnotegfx = "gfx/cba/bosses/siren/siren_note2.png"

local effect = Sprite()
effect:Load("gfx/cba/effects/siren_charm.anm2", true)
effect:Play("Idle", true)
effect.Scale = Vector(0.75, 0.75)


function cba:SirenAttacks(Siren)
	if cfg["General"]["SirenRestore"] == true 
	and cfg["Siren"]["ScreamAttack"] == true 
	and Siren.Variant == 0 then
		local anim = Siren:GetSprite():GetAnimation()
		local data = cba.GetData(Siren)
			
		if Siren.State == 9 then
		
			if anim == "Attack2Start" and Siren:GetSprite():GetFrame() == 8 then
			
				SFXManager():Play(SoundEffect.SOUND_SIREN_SING, Options.Volume) --play some sound cuz silence is boring
			end
			
			for _, tear in ipairs(Isaac.FindInRadius(Siren.Position, 40, EntityPartition.BULLET)) do
				local tdata = cba.GetData(tear)
			
				if tear.SpawnerType == EntityType.ENTITY_SIREN 
				and Siren.Variant == 0
				and not tdata.SN_noteproj then
				
					local note = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, ProjectileVariant.PROJECTILE_HUSH, 0, tear.Position, tear.Velocity, tear.SpawnerEntity):ToProjectile()
					
					note:GetSprite().Color = tear:GetSprite().Color
					note:AddProjectileFlags(tear:ToProjectile().ProjectileFlags)
					note:GetSprite():Load(noteanm, true)
					
					local gfx = math.random(2) == 2 and dnotegfx or notegfx --random gfx
					note:GetSprite():ReplaceSpritesheet(0, gfx, true)
					
					cba.GetData(note).SN_noteproj = true --marking
					
					note.FallingAccel = -0.1 --note can't fall
					tear:Remove() --remove tear
				end
			end
		
		elseif Siren.State == 8 then
			
			if not data.chance_calc then
				local chance = math.random(100)
				
				if chance <= cfg["Siren"]["NotesChance"] then
					Siren.State = 9
				end
				
				data.chance_calc = true
			end
			
			for _, tear in ipairs(Isaac.FindInRadius(Siren.Position, 40, EntityPartition.BULLET)) do --for each proj in radius of 1 grid tile (I think)
				local tdata = cba.GetData(tear)
				
				if tear.SpawnerType == EntityType.ENTITY_SIREN 
				and Siren.Variant == 0 
				and not tdata.SN_screamproj then
				
					tear:ToProjectile():ClearProjectileFlags(ProjectileFlags.SINE_VELOCITY) --remove wavy movement
					tear.Velocity = tear.Velocity:Normalized() * 6 --reduce speed
					
					tear:GetSprite().Color.R = 3 --MAKE IT RED
					
					tdata.SN_screamproj = true --mark it
				end
			end
		elseif Siren.State == 12 then
			
			if not data.chance_calc then
				local chance = math.random(100)
				
				if chance <= cfg["Siren"]["NotesChance"] then
					Siren.State = 9
				end
				
				data.chance_calc = true
			end
		elseif Siren.State == 3 and data.chance_calc then
			data.chance_calc = nil
		end
	end
end

cba:AddCallback(ModCallbacks.MC_NPC_UPDATE, cba.SirenAttacks, EntityType.ENTITY_SIREN)

function cba:SirenScreamTearUpdate(Tear)
	if cba.GetData(Tear).SN_screamproj then
	
		if Tear.FrameCount == 35 then
			Tear:Remove() --despawn tear
			
			--spawn 2 projs with 45 degrees angle--
			Isaac.Spawn(EntityType.ENTITY_PROJECTILE, 0, 0, Tear.Position, Tear.Velocity:Rotated(-45), Tear):ToProjectile().FallingAccel = -0.1
			Isaac.Spawn(EntityType.ENTITY_PROJECTILE, 0, 0, Tear.Position, Tear.Velocity:Rotated(45), Tear):ToProjectile().FallingAccel = -0.1
		end
	end
end

cba:AddCallback(ModCallbacks.MC_POST_PROJECTILE_UPDATE, cba.SirenScreamTearUpdate, 0)

function cba:NoteEffectAdd(player, dmg, flags, source) --siren charm effect setup
	if source.Entity and cba.GetData(source.Entity) and cba.GetData(source.Entity).SN_noteproj then
	
		cba.GetData(player).SN_charmed_frames = 180
		
		player:GetSprite().Color:SetOffset(0.35, 0, 0.5, 1)
	end
end

cba:AddCallback(ModCallbacks.MC_PRE_PLAYER_TAKE_DMG, cba.NoteEffectAdd)

function cba:SirenCharmEffect(player, hook, button) --charm effect logic (also thanks Nato Potato for CAASI mod, where did I get this func from)
	if hook == InputHook.GET_ACTION_VALUE and player 
	and player.Type == EntityType.ENTITY_PLAYER and button < 8 then
	
		if cba.GetData(player).SN_charmed_frames and cba.GetData(player).SN_charmed_frames > 0 then
		
			if player:GetSprite().Color:GetOffset().R ~= 0.35 then
				player:GetSprite().Color:SetOffset(0.35, 0, 0.5, 1) --set purple color
			end
			
			return -Input.GetActionValue(button, player:ToPlayer().ControllerIndex) --invert controls
		end
	end
end

cba:AddCallback(ModCallbacks.MC_INPUT_ACTION, cba.SirenCharmEffect)

function cba:SirenPlayerUpdate(player) --remove mark on effect end
	local data = cba.GetData(player)

	if data.SN_charmed_frames then
	
		data.SN_charmed_frames = data.SN_charmed_frames - 1
		
		if data.SN_charmed_frames <= 0 then
		
			data.SN_charmed_frames = nil
			
			player.Color = Color(1, 1, 1, 1)
		end
	end
end

cba:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, cba.SirenPlayerUpdate)

function cba:SirenPlayerRender(player)
	local data = cba.GetData(player)
	
	if data.SN_charmed_frames and data.SN_charmed_frames > 0 then
		local pos = Isaac.WorldToScreen(player.Position - Vector(0, 55))
		
		effect.Color = Color(0.8, 0, 1.5, 1)
		
		effect:Update()
		
		effect:Render(pos)
	end
end

cba:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, cba.SirenPlayerRender)