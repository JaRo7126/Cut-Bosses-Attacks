local cba = CutBossesAttacks

local function AddBoolSetting(setting, category, text, info)
	local tab = "General"
	if category == "Witness" then
		tab = "Witness"
	end
	ModConfigMenu.AddSetting(
		"CBA",
		tab,
		{
			Type = ModConfigMenu.OptionType.BOOLEAN,
			CurrentSetting = function()
				return cba.Save.Config[category][setting]
			end,
			Display = function()
				local onOff = "False"
				if cba.Save.Config[category][setting] then
					onOff = "True"
				end
				return text .. ": " .. onOff
			end,
			OnChange = function(currentBool)
				cba.Save.Config[category][setting] = currentBool
			end,
			Info = info
		}
	)
end

local function AddNumSetting(setting, category, minimum, maximum, text, info)
	local tab = "General"
	if category == "Witness" then
		tab = "Witness"
	end
	ModConfigMenu.AddSetting(
		"CBA",
		tab,
		{
			Type = ModConfigMenu.OptionType.NUMBER,
			CurrentSetting = function()
				return cba.Save.Config[category][setting]
			end,
			Minimum = minimum,
			Maximum = maximum,
			ModifyBy = 1,
			Display = function()
				return text .. ": " .. cba.Save.Config[category][setting]
			end,
			OnChange = function(currentNum)
				cba.Save.Config[category][setting] = currentNum
			end,
			Info = info
		}
	)
end

ModConfigMenu.AddSetting(
	"CBA",
	"General",
	{
		Type = ModConfigMenu.OptionType.BOOLEAN,
		CurrentSetting = function()
			return true
		end,
		Display = function()
			return "<<RESET SETTINGS TO DEFAULT>>"
		end,
		OnChange = function(currentBool)
			for k, v in pairs(cba.Save.DefaultConfig) do
				for k2, v2 in pairs(cba.Save.DefaultConfig[k]) do
					cba.Save.Config[k][k2] = cba.Save.DefaultConfig[k][k2]
				end
			end
		end,
		Info = "Press Left or Right to reset settings",
		Color = {0.25, 0, 0}
	}
)

ModConfigMenu.AddSetting(
	"CBA",
	"General",
	{
		Type = ModConfigMenu.OptionType.BOOLEAN,
		CurrentSetting = function()
			return true
		end,
		Display = function()
			return "<<FIX WITNESS CRASH ZOOM ISSUE>>"
		end,
		OnChange = function(currentBool)
			Options.MaxScale = 99
			Options.Fullscreen = not Options.Fullscreen
			Options.Fullscreen = not Options.Fullscreen
		end,
		Info = "Press Left or Right to fix (don't press if there are no issue)",
		Color = {0.25, 0, 0}
	}
)


ModConfigMenu.AddTitle("CBA", "General", "Changes")
ModConfigMenu.AddText("CBA", "General", "Reap Creep")
AddBoolSetting("ReapCreepRestore", "General", "Reap Creep Restore", "Changes behaivor of Reap Creep")
ModConfigMenu.AddText("CBA", "General", "Visage")
AddBoolSetting("VisageRestore", "General", "Visage Restore", "Changes behaivor of Visage")
ModConfigMenu.AddText("CBA", "General", "Siren")
AddBoolSetting("SirenRestore", "General", "Siren Restore", "Adds unused attack to Siren")
AddBoolSetting("NotesAttack", "Siren", "Note Attack", "If true, then unused Note Attack will replace Scream and Summon attacks")
AddNumSetting("NotesChance", "Siren", 0, 100, "Note Attack Chance", "Chance of replacing Scream and Summon attacks")
AddBoolSetting("ScreamAttack", "Siren", "Scream Attack Overwrite", "Restores old Scream attack pattern from Antibirth")
ModConfigMenu.AddText("CBA", "General", "Mausoleum Mom")
AddBoolSetting("MomRestore", "General", "Mom Restore", "Changes behaivor of Mausoleum Mom")
AddNumSetting("ArmEyeChance", "Mom", 0, 100, "Arm Attack Chance (Eye)", "Chance of Arm attack to replace Brimstone Eye attack")
AddNumSetting("ArmSpawnChance", "Mom", 0, 100, "Arm Attack Chance (Summon)", "Chance of Arm attack to replace Summoning attack(Not recommended to increase this value to more than 20)")
ModConfigMenu.AddText("CBA", "General", "Mausoleum Mom's Heart")
AddBoolSetting("HeartRestore", "General", "Mom's Heart Restore", "Re-adds ability to spawn enemies to Mausoleum Mom's Heart")
ModConfigMenu.AddText("CBA", "General", "Witness(Mother)")
AddBoolSetting("WitnessRestore", "General", "Witness Restore", "Completely changes Mother's behavior, transforming her to The Witness")
ModConfigMenu.AddText("CBA", "General", "Mega Satan 2'nd Phase")
AddBoolSetting("MegaSatanRestore", "General", "Mega Satan 2 Hands Restore", "Readds Mega Satan's hands in 2'nd phase and adds new attacks to them")
AddNumSetting("AttackChance", "MS2", 0, 100, "Hand Attack Chance", "Chance of Mega Satan's hand to attack in 2'nd phase")
AddNumSetting("HandsHP", "MS2", 500, 1000, "Hands HP", "Defines what number of HP will Mega Satan 2'nd phase hands have")
ModConfigMenu.AddText("CBA", "General", "Dogma")
AddBoolSetting("DogmaRestore", "General", "Dogma Restore", "Readds cut Blackhole attack and adds dogma babies summoning")
AddBoolSetting("BlackHole", "Dogma", "Blackhole Attack", "Readds cut Blackhole attack")
AddNumSetting("BlackHoleChance1", "Dogma", 0, 100, "Blackhole Attack Chance in 1'st phase", "Chance of Blackhole attack to replace other attacks in 1'st phase")
AddNumSetting("BlackHoleChance", "Dogma", 0, 100, "Blackhole Attack Chance in 2'nd phase", "Chance of Blackhole attack to replace Spin attack in 2'nd phase")
AddBoolSetting("BlackHoleCap", "Dogma", "Blackhole Bullets' speed cap", "Fix for Blackhole bullets being too fast")
AddBoolSetting("AngelSummon", "Dogma", "Dogma Babies", "During Spin attack Dogma babies will appear")

--Witness settings--
ModConfigMenu.AddTitle("CBA", "Witness", "--HP--")
AddBoolSetting("WitnessIncreasedHP", "Witness", "Phase 1 HP Increase", "If true, then HP of Witness first phase will be increased to 2500")
AddBoolSetting("Witness2IncreasedHP", "Witness", "Phase 2 HP Increase", "If true, then HP of Witness second phase will be increased to 2500")
ModConfigMenu.AddTitle("CBA", "Witness", "--Phase 1 Attacks--")
ModConfigMenu.AddText("CBA", "Witness", "Laser Attack")
AddBoolSetting("LaserAttack", "Witness", "Laser Attack", "If true, then Witness will do Laser Attack from Antibirth combined with Dead Isaacs Attack")
AddBoolSetting("OldLaserAttack", "Witness", "Antibirth Laser Attack", "If true, then Laser Attack from Antibirth will not be combined with Dead Isaacs Attack")
ModConfigMenu.AddText("CBA", "Witness", "Wrist Attack")
AddBoolSetting("WormsAttack", "Witness", "Wrist Attack Owerwrite", "If true, then Witness will throw 2 big chargers (or corpse eaters if you have Restored Monsters Pack mod) at the player direction during Wrist Attack")
ModConfigMenu.AddText("CBA", "Witness", "Fist Attack")
AddBoolSetting("FistAttack", "Witness", "Fist Attack Overwrite", "If true, then Witness will do Fist Attack from Antibirth instead of Repentance")
ModConfigMenu.AddText("CBA", "Witness", "Knife Attack Replace")
AddNumSetting("KnifeReplaceChance", "Witness", 0, 100, "Replace Chance", "Chance of other attack to replace Knife Attack(I made this setting for balance)")
ModConfigMenu.AddText("CBA", "Witness", "Burst Attack")
AddBoolSetting("BurstAttack", "Witness", "Burst Attack", "If true, then Witness will do Burst Attack from Antibirth instead of Ball Attack with 50% chance")
AddNumSetting("BurstChance", "Witness", 0, 100, "Burst Attack Chance", "Chance of Burst Attack to replace Ball Attack")
ModConfigMenu.AddText("CBA", "Witness", "Ball Attack")
AddBoolSetting("BallAttack", "Witness", "Ball Attack Overwrite", "If true, then Witness will do Ball Attack in Antibirth-like style instead of Repentance")
AddBoolSetting("BallHoming", "Witness", "Homing", "If true, then ball will rotate to direction of the player like he did in Antibirth")
AddBoolSetting("BallSpeedScale", "Witness", "Rotation Speed Scale", "If true, then ball's rotation speed would be scaling with player speed(works if homing is enabled)")
ModConfigMenu.AddText("CBA", "Witness", "Double Fist Attack")
AddBoolSetting("DoubleFistAttack", "Witness", "Double Fist Attack", "If true, then Witness will do Double Fist Attack from Antibirth if her HP is smaller than half")
AddNumSetting("DoubleFistChance", "Witness", 0, 100, "Double Fist Attack Chance", "Chance of Double Fist Attack to replace regular Fist Attack")
ModConfigMenu.AddText("CBA", "Witness", "Shoot Attack")
AddBoolSetting("ShootAttack", "Witness", "Shoot Attack", "If true, then Witness will shoot 3 homing rows of tears in Antibirth-like style instead of Wrist Attack")
AddNumSetting("ShootAttackChance", "Witness", 0, 100, "Shoot Attack Chance", "Chance of Shoot Attack to replace Wrist Attack")
ModConfigMenu.AddTitle("CBA", "Witness", "--Phase 2 Attacks--")
ModConfigMenu.AddText("CBA", "Witness", "Spin Attack")
AddBoolSetting("SpinAttack", "Witness", "Spin Attack Overwrite", "If true, then Witness will do different pattern of Spin Attack from Antibirth")
AddNumSetting("SpinAttackChance", "Witness", 0, 100, "Spin Attack Chance", "Chance of Antibirth Spin Attack pattern to replace the Repentance one")
ModConfigMenu.AddText("CBA", "Witness", "Worms Attack")
AddBoolSetting("TearsAttack", "Witness", "Worms Attack Overwrite", "If true, then Witness will do Tears Attack from Antibirth instead of Worms Attack")
AddBoolSetting("TearsAttackLines", "Witness", "Lines in Worms Attack", "If true, then on tears spots will be lines that warn you where tears will be shooted")
ModConfigMenu.AddText("CBA", "Witness", "Charge Attack")
AddBoolSetting("ChargeAttack", "Witness", "Charge Attack Overwrite", "If true, then Witness will do Charge Attack with some improvements from Antibirth")
AddBoolSetting("ChargeSpeedScale", "Witness", "Charge Speed Scale", "If true, Witness Charge Attack speed would be scaling with player speed")
ModConfigMenu.AddText("CBA", "Witness", "Brimstone Attack")
AddBoolSetting("BrimstoneAttack", "Witness", "Brimstone Attack", "If true, then Witness will do Brimstone Attack from Antibirth instead of 'Suck in' Attack")
AddNumSetting("BrimAttackChance", "Witness", 0, 100, "Brimstone Attack Chance", "Chance of Brimstone Attack to replace the 'Suck in' Attack")
AddBoolSetting("OldBrimBallGfx", "Witness", "Old GFX", "Restores old Brimstone Ball GFX from Antibirth")
ModConfigMenu.AddTitle("CBA", "Witness", "Extra")
ModConfigMenu.AddText("CBA", "Witness", "Camera")
AddBoolSetting("ZoomOut", "Witness", "Zoom Out", "You can disable zooming out in Witness boss room if you want or if you are a masochist")
AddNumSetting("ZoomType", "Witness", 1, 2, "Zoom Type", "1 - standart(vanilla), 2 - REPENTOGON(may be bugged)")
AddBoolSetting("CameraLock", "Witness", "Camera Lock", "If true, then camera will be locked to room center in Witness fight")
AddNumSetting("ZoomSize", "Witness", 1, 5, "Zoom Size", "You can configure the zoom size in Witness boss room(on values 3-5 recommended to disable camera lock)")
ModConfigMenu.AddText("CBA", "Witness", "Appearence")
AddBoolSetting("OldTheme", "Witness", "Old Theme", "If true, you will hear Antibirth Witness theme instead of Repentance")
ModConfigMenu.AddText("CBA", "Witness", "Attacks")
AddBoolSetting("HomingKnives", "Witness", "Homing Knives", "I thought that would be funny to make Witness throw knives to the direction of the player. Well, I made it")
AddBoolSetting("OldChargeAttack", "Witness", "New Charge Attack", "I made this attack in early development and didn't want to delete its code in order to use it somewhere")
AddNumSetting("OldChargeChance", "Witness", 0, 100, "New Charge Attack Chance", "Chance of New Charge Attack to replace the old one if both is enabled")
