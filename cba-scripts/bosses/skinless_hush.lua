local cba = CutBossesAttacks
----!!!WIP!!!----
cba.Save.Config["SkinlessHush"] = {
	["IsSkinlessWomb"] = false
}

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
