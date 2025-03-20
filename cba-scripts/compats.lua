local cba = CutBossesAttacks

--EBB--
if HPBars then
	HPBars.BossDefinitions[EntityType.ENTITY_MEGA_SATAN_2..".1"] = {sprite = "gfx/cba/ui/EBB/mega_satan_2_righthand.png", barStyle = "Mega Satan Phase 2"}
	HPBars.BossDefinitions[EntityType.ENTITY_MEGA_SATAN_2..".2"] = {sprite = "gfx/cba/ui/EBB/mega_satan_2_lefthand.png", barStyle = "Mega Satan Phase 2"}
end

--HP Bars For Enemies--

if HPBarForEnemies then
	HPBarForEnemies:AddEnemyName(EntityType.ENTITY_MOTHER, 9, "Blood Cluster")
	HPBarForEnemies:AddIgnoreParentEnemy(EntityType.ENTITY_MEGA_SATAN_2, 1)
	HPBarForEnemies:AddIgnoreParentEnemy(EntityType.ENTITY_MEGA_SATAN_2, 2)
end
