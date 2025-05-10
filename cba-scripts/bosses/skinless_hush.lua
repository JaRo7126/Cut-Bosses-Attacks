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
	SH.State = NpcState.STATE_APPEAR
	SH:GetSprite():Play("Appear", true)
	SH.MaxHitPoints = 6666
	SH.HitPoints = 6666
	SH:SetShieldStrength(100)
	cba.GetData(SH).SH_frames_without_attack = 0
end


cba:AddCallback(ModCallbacks.MC_POST_NPC_INIT, cba.SHInit, EntityType.ENTITY_HUSH_SKINLESS)


function cba:SHUpdate(SH)
	local data = cba.GetData(SH)
	local target = SH:GetPlayerTarget()
	local state = SH.State
	local sprite = SH:GetSprite()
	local anim = sprite:GetAnimation()
	local frame = sprite:GetFrame()
	local healthPercent = SH.HitPoints / SH.MaxHitPoints
	
	if state = NpcState.STATE_APPEAR and anim == "Appear" then
	
		if sprite:IsFinished() then
			state = NpcState.STATE_IDLE
			sprite:Play("Idle")
		end
		
	elseif state = NpcState.STATE_IDLE then
		data.SH_frames_without_attack = data.SH_frames_without_attack + 1
		
		if data.SH_frames_without_attack >= math.floor(600 - 420 * healthPercent) then
		
			state = math.random(NpcState.STATE_ATTACK, NpcState.STATE_ATTACK4)
			
			data.SH_frames_without_attack = 0
		end
	end
	
end
