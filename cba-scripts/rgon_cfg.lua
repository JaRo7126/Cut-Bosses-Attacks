local cba = CutBossesAttacks

ImGui.CreateMenu("CutBossesAttacks", "\u{f043} CBA")
ImGui.AddElement("CutBossesAttacks", "CBASettingsButton", ImGuiElement.MenuItem, "\u{f085} Settings")
ImGui.CreateWindow("CBASettingsWindow", "Settings")
ImGui.LinkWindowToElement("CBASettingsWindow", "CBASettingsButton")
ImGui.AddTabBar("CBASettingsWindow", "CBASettingsTabBar")
ImGui.AddTab("CBASettingsTabBar", "CBASettingsGeneralTab", "General")
ImGui.AddTab("CBASettingsTabBar", "CBASettingsWitnessTab", "Witness")

local function AddBoolSetting(setting, category, name, info)
	local id = "CBASettings" .. setting
	local tab = "General"
	if category == "Witness" then
		tab = "Witness"
	end
	ImGui.AddElement("CBASettings" .. tab .. "Tab", "", ImGuiElement.Separator)
	ImGui.AddCheckbox("CBASettings" .. tab .. "Tab", id, "", nil, true)
	ImGui.AddElement("CBASettings" .. tab .. "Tab", "", ImGuiElement.SameLine)
	ImGui.AddElement("CBASettings" .. tab .. "Tab", "CBASettings" .. name .. "Text", ImGuiElement.TextWrapped, name)
	ImGui.SetHelpmarker("CBASettings" .. name .. "Text", info)
	ImGui.AddCallback(id, ImGuiCallback.Render, function()
		ImGui.UpdateData(id, ImGuiData.Value, cba.Save.Config[category][setting])
	end)
	ImGui.AddCallback(id, ImGuiCallback.Edited, function(value)
		 cba.Save.Config[category][setting] = value
	end)
end

local function AddNumSetting(setting, category, minv, maxv, name, info)
	local id = "CBASettings" .. setting
	local tab = "General"
	if category == "Witness" then
		tab = "Witness"
	end
	ImGui.AddElement("CBASettings" .. tab .. "Tab", "", ImGuiElement.Separator)
	ImGui.AddSliderInteger("CBASettings" .. tab .. "Tab", id, "", nil, cba.Save.Config[category][setting], minv, maxv)
	ImGui.AddElement("CBASettings" .. tab .. "Tab", "", ImGuiElement.SameLine)
	ImGui.AddElement("CBASettings" .. tab .. "Tab", "CBASettings" .. name .. "Text", ImGuiElement.TextWrapped, name)
	ImGui.SetHelpmarker("CBASettings" .. name .. "Text", info)
	ImGui.AddCallback(id, ImGuiCallback.Render, function()
		ImGui.UpdateData(id, ImGuiData.Value, cba.Save.Config[category][setting])
	end)
	ImGui.AddCallback(id, ImGuiCallback.Edited, function(value)
		 cba.Save.Config[category][setting] = value
	end)
end

ImGui.AddButton("CBASettingsGeneralTab", "CBAResetSettingsButton", "Reset Settings",
    function()
        for k, v in pairs(cba.Save.DefaultConfig) do
			for k2, v2 in pairs(cba.Save.DefaultConfig[k]) do
				cba.Save.Config[k][k2] = cba.Save.DefaultConfig[k][k2]
			end
		end
end, false)

ImGui.AddButton("CBASettingsGeneralTab", "CBAFixZoomButton", "Fix Zoom",
    function()
        Options.MaxScale = 99
		Options.Fullscreen = not Options.Fullscreen
		Options.Fullscreen = not Options.Fullscreen
end, false)
ImGui.SetHelpmarker("CBASettingsGeneralTab", "Fix issue with zoom remaining small after crash in Witness room")

ImGui.AddElement("CBASettingsGeneralTab", "", ImGuiElement.SeparatorText, "Reap Creep")
AddBoolSetting("ReapCreepRestore", "General", "Reap Creep Restore", "Changes behaivor of Reap Creep")
ImGui.AddElement("CBASettingsGeneralTab", "", ImGuiElement.SeparatorText, "Visage")
AddBoolSetting("VisageRestore", "General", "Visage Restore", "Changes behaivor of Visage")
ImGui.AddElement("CBASettingsGeneralTab", "", ImGuiElement.SeparatorText, "Siren")
AddBoolSetting("SirenRestore", "General", "Siren Restore", "Adds unused attack to Siren")
AddBoolSetting("NotesAttack", "Siren", "Note Attack", "If true, then unused Note Attack will replace Scream and Summon attacks")
AddNumSetting("NotesChance", "Siren", 0, 100, "Note Attack Chance", "Chance of replacing Scream and Summon attacks")
AddBoolSetting("ScreamAttack", "Siren", "Scream Attack Overwrite", "Restores old Scream attack pattern from Antibirth")
ImGui.AddElement("CBASettingsGeneralTab", "", ImGuiElement.SeparatorText, "Mausoleum Mom")
AddBoolSetting("MomRestore", "General", "Mom Restore", "Changes behaivor of Mausoleum Mom")
AddNumSetting("ArmEyeChance", "Mom", 0, 100, "Arm Attack Chance (Eye)", "Chance of Arm attack to replace Brimstone Eye attack")
AddNumSetting("ArmSpawnChance", "Mom", 0, 100, "Arm Attack Chance (Summon)", "Chance of Arm attack to replace Summoning attack(Not recommended to increase this value to more than 20)")
ImGui.AddElement("CBASettingsGeneralTab", "", ImGuiElement.SeparatorText, "Mausoleum Mom's Heart")
AddBoolSetting("HeartRestore", "General", "Mom's Heart Restore", "Re-adds ability to spawn enemies to Mausoleum Mom's Heart")
ImGui.AddElement("CBASettingsGeneralTab", "", ImGuiElement.SeparatorText, "Witness(Mother)")
AddBoolSetting("WitnessRestore", "General", "Witness Restore", "Completely changes Mother's behavior, transforming her to The Witness")
ImGui.AddElement("CBASettingsGeneralTab", "", ImGuiElement.SeparatorText, "Mega Satan 2'nd Phase")
AddBoolSetting("MegaSatanRestore", "General", "Mega Satan 2 Hands Restore", "Readds Mega Satan's hands in 2'nd phase and adds new attacks to them")
AddNumSetting("AttackChance", "MS2", 0, 100, "Hand Attack Chance", "Chance of Mega Satan's hand to attack in 2'nd phase")
AddNumSetting("HandsHP", "MS2", 500, 1000, "Hands HP", "Defines what number of HP will Mega Satan 2'nd phase hands have")
ImGui.AddElement("CBASettingsGeneralTab", "", ImGuiElement.SeparatorText, "Dogma")
AddBoolSetting("DogmaRestore", "General", "Dogma Restore", "Readds cut Blackhole attack and adds dogma babies summoning")
AddBoolSetting("BlackHole", "Dogma", "Blackhole Attack", "Readds cut Blackhole attack")
AddNumSetting("BlackHoleChance1", "Dogma", 0, 100, "Blackhole Attack Chance in 1'st phase", "Chance of Blackhole attack to replace other attacks in 1'st phase")
AddNumSetting("BlackHoleChance", "Dogma", 0, 100, "Blackhole Attack Chance in 2'nd phase", "Chance of Blackhole attack to replace Spin attack in 2'nd phase")
AddBoolSetting("BlackHoleCap", "Dogma", "Blackhole Bullets' speed cap", "Fix for Blackhole bullets being too fast")
AddBoolSetting("AngelSummon", "Dogma", "Dogma Babies", "During Spin attack Dogma babies will appear")

--Witness settings--
ImGui.AddElement("CBASettingsWitnessTab", "", ImGuiElement.SeparatorText, "HP")
AddBoolSetting("WitnessIncreasedHP", "Witness", "Phase 1 HP Increase", "If true, then HP of Witness first phase will be increased to 2500")
AddBoolSetting("Witness2IncreasedHP", "Witness", "Phase 2 HP Increase", "If true, then HP of Witness second phase will be increased to 2500")
ImGui.AddElement("CBASettingsWitnessTab", "", ImGuiElement.SeparatorText, "PHASE 1 ATTACKS")
ImGui.AddElement("CBASettingsWitnessTab", "", ImGuiElement.TextWrapped, "Laser Attack")
AddBoolSetting("LaserAttack", "Witness", "Laser Attack", "If true, then Witness will do Laser Attack from Antibirth combined with Dead Isaacs Attack")
AddBoolSetting("OldLaserAttack", "Witness", "Antibirth Laser Attack", "If true, then Laser Attack from Antibirth will not be combined with Dead Isaacs Attack")
ImGui.AddElement("CBASettingsWitnessTab", "", ImGuiElement.TextWrapped, "Wrist Attack")
AddBoolSetting("WormsAttack", "Witness", "Wrist Attack Owerwrite", "If true, then Witness will throw 2 big chargers (or corpse eaters if you have Restored Monsters Pack mod) at the player direction during Wrist Attack")
ImGui.AddElement("CBASettingsWitnessTab", "", ImGuiElement.TextWrapped, "Fist Attack")
AddBoolSetting("FistAttack", "Witness", "Fist Attack Overwrite", "If true, then Witness will do Fist Attack from Antibirth instead of Repentance")
ImGui.AddElement("CBASettingsWitnessTab", "", ImGuiElement.TextWrapped, "Knife Attack Replace")
AddNumSetting("KnifeReplaceChance", "Witness", 0, 100, "Replace Chance", "Chance of other attack to replace Knife Attack(I made this setting for balance)")
ImGui.AddElement("CBASettingsWitnessTab", "", ImGuiElement.TextWrapped, "Burst Attack")
AddBoolSetting("BurstAttack", "Witness", "Burst Attack", "If true, then Witness will do Burst Attack from Antibirth instead of Ball Attack with 50% chance")
AddNumSetting("BurstChance", "Witness", 0, 100, "Burst Attack Chance", "Chance of Burst Attack to replace Ball Attack")
ImGui.AddElement("CBASettingsWitnessTab", "", ImGuiElement.TextWrapped, "Ball Attack")
AddBoolSetting("BallAttack", "Witness", "Ball Attack Overwrite", "If true, then Witness will do Ball Attack in Antibirth-like style instead of Repentance")
AddBoolSetting("BallHoming", "Witness", "Homing", "If true, then ball will rotate to direction of the player like he did in Antibirth")
AddBoolSetting("BallSpeedScale", "Witness", "Rotation Speed Scale", "If true, then ball's rotation speed would be scaling with player speed(works if homing is enabled)")
ImGui.AddElement("CBASettingsWitnessTab", "", ImGuiElement.TextWrapped, "Double Fist Attack")
AddBoolSetting("DoubleFistAttack", "Witness", "Double Fist Attack", "If true, then Witness will do Double Fist Attack from Antibirth if her HP is smaller than half")
AddNumSetting("DoubleFistChance", "Witness", 0, 100, "Double Fist Attack Chance", "Chance of Double Fist Attack to replace regular Fist Attack")
ImGui.AddElement("CBASettingsWitnessTab", "", ImGuiElement.TextWrapped, "Shoot Attack")
AddBoolSetting("ShootAttack", "Witness", "Shoot Attack", "If true, then Witness will shoot 3 homing rows of tears in Antibirth-like style instead of Wrist Attack")
AddNumSetting("ShootAttackChance", "Witness", 0, 100, "Shoot Attack Chance", "Chance of Shoot Attack to replace Wrist Attack")
ImGui.AddElement("CBASettingsWitnessTab", "", ImGuiElement.SeparatorText, "PHASE 2 ATTACKS")
ImGui.AddElement("CBASettingsWitnessTab", "", ImGuiElement.TextWrapped, "Spin Attack")
AddBoolSetting("SpinAttack", "Witness", "Spin Attack Overwrite", "If true, then Witness will do different pattern of Spin Attack from Antibirth")
AddNumSetting("SpinAttackChance", "Witness", 0, 100, "Spin Attack Chance", "Chance of Antibirth Spin Attack pattern to replace the Repentance one")
ImGui.AddElement("CBASettingsWitnessTab", "", ImGuiElement.TextWrapped, "Worms Attack")
AddBoolSetting("TearsAttack", "Witness", "Worms Attack Overwrite", "If true, then Witness will do Tears Attack from Antibirth instead of Worms Attack")
AddBoolSetting("TearsAttackLines", "Witness", "Lines in Worms Attack", "If true, then on tears spots will be lines that warn you where tears will be shooted")
ImGui.AddElement("CBASettingsWitnessTab", "", ImGuiElement.TextWrapped, "Charge Attack")
AddBoolSetting("ChargeAttack", "Witness", "Charge Attack Overwrite", "If true, then Witness will do Charge Attack with some improvements from Antibirth")
AddBoolSetting("ChargeSpeedScale", "Witness", "Charge Speed Scale", "If true, Witness Charge Attack speed would be scaling with player speed")
ImGui.AddElement("CBASettingsWitnessTab", "", ImGuiElement.TextWrapped, "Brimstone Attack")
AddBoolSetting("BrimstoneAttack", "Witness", "Brimstone Attack", "If true, then Witness will do Brimstone Attack from Antibirth instead of 'Suck in' Attack")
AddNumSetting("BrimAttackChance", "Witness", 0, 100, "Brimstone Attack Chance", "Chance of Brimstone Attack to replace the 'Suck in' Attack")
ImGui.AddElement("CBASettingsWitnessTab", "", ImGuiElement.SeparatorText, "EXTRA")
ImGui.AddElement("CBASettingsWitnessTab", "", ImGuiElement.TextWrapped, "Camera")
AddBoolSetting("ZoomOut", "Witness", "Zoom Out", "You can disable zooming out in Witness boss room if you want or if you are a masochist")
AddNumSetting("ZoomType", "Witness", 1, 2, "Zoom Type", "1 - standart(vanilla), 2 - REPENTOGON(may be bugged)")
AddBoolSetting("CameraLock", "Witness", "Camera Lock", "If true, then camera will be locked to room center in Witness fight")
AddNumSetting("ZoomSize", "Witness", 1, 5, "Zoom Size", "You can configure the zoom size in Witness boss room(on values 3-5 recommended to disable camera lock)")
ImGui.AddElement("CBASettingsWitnessTab", "", ImGuiElement.TextWrapped, "Appearence")
AddBoolSetting("OldTheme", "Witness", "Old Theme", "If true, you will hear Antibirth Witness theme instead of Repentance")
ImGui.AddElement("CBASettingsWitnessTab", "", ImGuiElement.TextWrapped, "Attacks")
AddBoolSetting("HomingKnives", "Witness", "Homing Knives", "I thought that would be funny to make Witness throw knives to the direction of the player. Well, I made it")
AddBoolSetting("OldChargeAttack", "Witness", "New Charge Attack", "I made this attack in early development and didn't want to delete its code in order to use it somewhere")
AddNumSetting("OldChargeChance", "Witness", 0, 100, "New Charge Attack Chance", "Chance of New Charge Attack to replace the old one if both is enabled")

--Debugging--

ImGui.AddElement("CutBossesAttacks", "CBADebuggingButton", ImGuiElement.MenuItem, "\u{f552} Debugging")
ImGui.CreateWindow("CBADebuggingWindow", "Debugging")
ImGui.LinkWindowToElement("CBADebuggingWindow", "CBADebuggingButton")

ImGui.AddButton("CBADebuggingWindow", "CBADebuggingToWitnessButton", "TP to Witness",
    function()
        Isaac.ExecuteCommand("stage 8c")
		if Game():GetDebugFlags() & DebugFlag.INFINITE_HP == 0 then
			Isaac.ExecuteCommand("debug 3")
		end
		Isaac.ExecuteCommand("g c118")
		Isaac.ExecuteCommand("g soy milk")
		Isaac.GetPlayer().Damage = 1000
		Isaac.GetPlayer():UseCard(Card.CARD_EMPEROR)
		ImGui.Hide()
end, false)

ImGui.AddButton("CBADebuggingWindow", "CBADebuggingToMortisWitnessButton", "TP to Mortis Witness",
    function()
		if LastJudgement and StageAPI then
			Isaac.ExecuteCommand("cstage Mortis 2")
			if Game():GetDebugFlags() & DebugFlag.INFINITE_HP == 0 then
				Isaac.ExecuteCommand("debug 3")
			end
			Isaac.ExecuteCommand("g c118")
			Isaac.ExecuteCommand("g soy milk")
			Isaac.GetPlayer().Damage = 1000
			Isaac.GetPlayer():UseCard(Card.CARD_EMPEROR)
			ImGui.Hide()
		else
			ImGui.PushNotification("YOU STUPID", ImGuiNotificationType.ERROR)
			SFXManager():Play(SoundEffect.SOUND_FART_MEGA)
		end
end, false)

ImGui.AddButton("CBADebuggingWindow", "CBADebuggingToDogmaButton", "TP to Dogma",
    function()
        Isaac.ExecuteCommand("stage 13a")
		if Game():GetDebugFlags() & DebugFlag.INFINITE_HP == 0 then
			Isaac.ExecuteCommand("debug 3")
		end
		Isaac.ExecuteCommand("g c118")
		Isaac.ExecuteCommand("g soy milk")
		Isaac.GetPlayer().Damage = 1000
		Game():ChangeRoom(109, 0)
		ImGui.Hide()
end, false)

ImGui.AddButton("CBADebuggingWindow", "CBADebuggingToMegaSatanButton", "TP to Mega Satan",
    function()
        Isaac.ExecuteCommand("stage 11")
		if Game():GetDebugFlags() & DebugFlag.INFINITE_HP == 0 then
			Isaac.ExecuteCommand("debug 3")
		end
		Isaac.ExecuteCommand("g c118")
		Isaac.ExecuteCommand("g soy milk")
		Game():ChangeRoom(-7, 0)
		Isaac.GetPlayer().Damage = 1000
		ImGui.Hide()
end, false)

ImGui.AddButton("CBADebuggingWindow", "CBADebuggingToSkinlessHushButton", "TP to Skinless Hush",
    function()
        cba.Save.Config["SkinlessHush"]["IsSkinlessWomb"] = true
		Isaac.ExecuteCommand("stage 9")
		if Game():GetDebugFlags() & DebugFlag.INFINITE_HP == 0 then
			Isaac.ExecuteCommand("debug 3")
		end
		Isaac.ExecuteCommand("g c118")
		Isaac.ExecuteCommand("g soy milk")
		Isaac.GetPlayer().Damage = 1000
		ImGui.Hide()
end, false)

ImGui.AddCheckbox("CBADebuggingWindow", "CBADebugSkinlessWombCheck", "", nil, true)
ImGui.AddElement("CBADebuggingWindow", "", ImGuiElement.SameLine)
ImGui.AddElement("CBADebuggingWindow", "CBADebugSkinlessWombText", ImGuiElement.TextWrapped, "Force to Skinless Womb")
ImGui.SetHelpmarker("CBADebugSkinlessWombText", "Defines where you go entering Blue Womb trapdoor: to Blue or Skinless Womb")
ImGui.AddCallback("CBADebugSkinlessWombCheck", ImGuiCallback.Render, function()
	ImGui.UpdateData("CBADebugSkinlessWombCheck", ImGuiData.Value, cba.Save.Config["SkinlessHush"]["IsSkinlessWomb"])
end)
ImGui.AddCallback("CBADebugSkinlessWombCheck", ImGuiCallback.Edited, function(value)
	 cba.Save.Config["SkinlessHush"]["IsSkinlessWomb"] = value
end)