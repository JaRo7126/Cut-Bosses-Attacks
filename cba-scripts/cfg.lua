local cba = CutBossesAttacks

cba.Save = {} --Save for all variables of the mod that needs to be stored
cba.Save.ZoomSetting = Options.MaxScale --save for zoom
cba.Save.CameraSetting = Options.CameraStyle --save for camera type
cba.WitnessAchievements = {[PlayerType.PLAYER_ISAAC] = 440, --achievement id's for Mortis achievement's fix
	[PlayerType.PLAYER_MAGDALENE] = 442, 
	[PlayerType.PLAYER_CAIN] = 444, 
	[PlayerType.PLAYER_JUDAS] = 446, 
	[PlayerType.PLAYER_BLUEBABY] = 448, 
	[PlayerType.PLAYER_EVE] = 450, 
	[PlayerType.PLAYER_SAMSON] = 452, 
	[PlayerType.PLAYER_AZAZEL] = 454, 
	[PlayerType.PLAYER_LAZARUS] = 456, 
	[PlayerType.PLAYER_EDEN] = 458, 
	[PlayerType.PLAYER_THELOST] = 460, 
	[PlayerType.PLAYER_LAZARUS2] = 456, 
	[PlayerType.PLAYER_BLACKJUDAS] = 446, 
	[PlayerType.PLAYER_LILITH] = 462, 
	[PlayerType.PLAYER_KEEPER] = 464, 
	[PlayerType.PLAYER_APOLLYON] = 466, 
	[PlayerType.PLAYER_THEFORGOTTEN] = 468, 
	[PlayerType.PLAYER_THESOUL] = 468, 
	[PlayerType.PLAYER_BETHANY] = 470, 
	[PlayerType.PLAYER_JACOB] = 472, 
	[PlayerType.PLAYER_ESAU] = 472,
	[PlayerType.PLAYER_ISAAC_B] = 549, 
	[PlayerType.PLAYER_MAGDALENE_B] = 551, 
	[PlayerType.PLAYER_CAIN_B] = 553, 
	[PlayerType.PLAYER_JUDAS_B] = 555, 
	[PlayerType.PLAYER_BLUEBABY_B] = 557, 
	[PlayerType.PLAYER_EVE_B] = 559, 
	[PlayerType.PLAYER_SAMSON_B] = 561, 
	[PlayerType.PLAYER_AZAZEL_B] = 563, 
	[PlayerType.PLAYER_LAZARUS_B] = 565, 
	[PlayerType.PLAYER_EDEN_B] = 567, 
	[PlayerType.PLAYER_THELOST_B] = 569, 
	[PlayerType.PLAYER_LILITH_B] = 571, 
	[PlayerType.PLAYER_KEEPER_B] = 573, 
	[PlayerType.PLAYER_APOLLYON_B] = 575, 
	[PlayerType.PLAYER_THEFORGOTTEN_B] = 577, 
	[PlayerType.PLAYER_BETHANY_B] = 579, 
	[PlayerType.PLAYER_JACOB_B] = 581,
	[PlayerType.PLAYER_THESOUL_B] = 577,
	[PlayerType.PLAYER_LAZARUS2_B] = 565
}

cba.WSMusic = {Music.MUSIC_MOTHER_BOSS, Music.MUSIC_JINGLE_MOTHER_OVER} --music table for music setting

--Config--

cba.Save.Config = {}
cba.Save.Config["General"] = { --General settings
	["WitnessRestore"] = true,
	["VisageRestore"] = true,
	["SirenRestore"] = true,
	["ReapCreepRestore"] = true,
	["MomRestore"] = true,
	["HeartRestore"] = true,
	["DogmaRestore"] = true,
	["MegaSatanRestore"] = true
}

cba.Save.Config["Witness"] = {
	["WitnessIncreasedHP"] = true,
	["Witness2IncreasedHP"] = true,
	["WormsAttack"] = true,
	["LaserAttack"] = true,
	["FistAttack"] = true,
	["BurstAttack"] = true,
	["BurstChance"] = 50,
	["BallAttack"] = true,
	["BallHoming"] = true,
	["BallSpeedScale"] = false,
	["DoubleFistAttack"] = true,
	["DoubleFistChance"] = 30,
	["ShootAttack"] = true,
	["ShootAttackChance"] = 30,
	["SpinAttack"] = true,
	["SpinAttackChance"] = 50,
	["TearsAttack"] = true,
	["TearsAttackLines"] = false,
	["SUCC"] = true, --This is change to "Sucking" Attack
	["ChargeAttack"] = true,
	["BrimstoneAttack"] = true,
	["BrimAttackChance"] = 50,
	["OldChargeAttack"] = false,
	["OldChargeChance"] = 50,
	["HomingKnives"] = false,
	["KnifeReplaceChance"] = 0,
	["ZoomOut"] = true,
	["ZoomType"] = 1,
	["ZoomSize"] = 2,
	["CameraLock"] = true,
	["ChargeSpeedScale"] = false,
	["OldTheme"] = false,
	["OldLaserAttack"] = false
}

cba.Save.Config["Dogma"] = { --Dogma settings
	["BlackHole"] = true,
	["BlackHoleChance"] = 50,
	["BlackHoleCap"] = true,
	["AngelSummon"] = true,
	["BlackHoleChance1"] = 20
}

cba.Save.Config["MS2"] = { --Mega Satan settings
	["AttackChance"] = 33,
	["MSsHP"] = 600
}

cba.Save.Config["Mom"] = {
	["ArmEyeChance"] = 50,
	["ArmSpawnChance"] = 10
}

cba.Save.Config["Siren"] = {
	["NotesAttack"] = true,
	["NotesChance"] = 33,
	["ScreamAttack"] = true
}

--Default Config--

cba.Save.DefaultConfig = {}
cba.Save.DefaultConfig["General"] = {
	["WitnessRestore"] = true,
	["VisageRestore"] = true,
	["SirenRestore"] = true,
	["ReapCreepRestore"] = true,
	["MomRestore"] = true,
	["HeartRestore"] = true,
	["DogmaRestore"] = true,
	["MegaSatanRestore"] = true
}

cba.Save.DefaultConfig["Witness"] = {
	["WitnessIncreasedHP"] = true,
	["Witness2IncreasedHP"] = true,
	["WormsAttack"] = true,
	["LaserAttack"] = true,
	["FistAttack"] = true,
	["BurstAttack"] = true,
	["BurstChance"] = 50,
	["BallAttack"] = true,
	["BallHoming"] = true,
	["BallSpeedScale"] = false,
	["DoubleFistAttack"] = true,
	["DoubleFistChance"] = 30,
	["ShootAttack"] = true,
	["ShootAttackChance"] = 30,
	["SpinAttack"] = true,
	["SpinAttackChance"] = 50,
	["TearsAttack"] = true,
	["TearsAttackLines"] = false,
	["SUCC"] = true, --This is change to "Sucking" Attack
	["ChargeAttack"] = true,
	["BrimstoneAttack"] = true,
	["BrimAttackChance"] = 50,
	["OldChargeAttack"] = false,
	["OldChargeChance"] = 50,
	["HomingKnives"] = false,
	["KnifeReplaceChance"] = 0,
	["ZoomOut"] = true,
	["ZoomType"] = 1,
	["ZoomSize"] = 2,
	["CameraLock"] = true,
	["ChargeSpeedScale"] = false,
	["OldTheme"] = false,
	["OldLaserAttack"] = false
}

cba.Save.DefaultConfig["Dogma"] = { --Dogma settings
	["BlackHole"] = true,
	["BlackHoleChance"] = 50,
	["BlackHoleCap"] = true,
	["AngelSummon"] = true,
	["BlackHoleChance1"] = 20
}

cba.Save.DefaultConfig["MS2"] = { --Mega Satan settings
	["AttackChance"] = 33,
	["MSsHP"] = 600
}

cba.Save.DefaultConfig["Mom"] = {
	["ArmEyeChance"] = 50,
	["ArmSpawnChance"] = 10
}

cba.Save.DefaultConfig["Siren"] = {
	["NotesAttack"] = true,
	["NotesChance"] = 33,
	["ScreamAttack"] = true
}

