local cba = CutBossesAttacks

local json = require("json")

function cba.GetAngle(vector) --Special func for getting direction angle (Vector with y = 0 and x > 0 is 0 degrees)
	local angleBetween = math.deg(math.acos(vector.X / (math.sqrt(vector.X ^ 2 + vector.Y ^ 2))))
	if vector.Y < 0 then
        angleBetween = 360 - angleBetween
    end
	return angleBetween
end

cba.EntData = {} --entities' data table

function cba.GetData(ent) --func for getting entities' data
	local entHash = GetPtrHash(ent)
	local data = cba.EntData[entHash]
	if not data then
		local newData = {}
		cba.EntData[entHash] = newData
		data = newData
	end
	return data
end

cba:AddPriorityCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, CallbackPriority.LATE, function(_, ent)
	cba.EntData[GetPtrHash(ent)] = nil
end)

--Save Utils--

function cba:LoadConfig()
	if cba:HasData() then
		local save = json.decode(Isaac.LoadModData(cba))
		for key, value in pairs(cba.Save.Config) do
			if save[key] ~= nil then
				for key2, value2 in pairs(cba.Save.Config[key]) do
					if save[key][key2] ~= nil then
						cba.Save.Config[key][key2] = save[key][key2]
					end
				end
			end
		end
	end
end

function cba:SaveConfig()
	cba.SaveData(cba, json.encode(cba.Save.Config))
end

cba:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, cba.LoadConfig)
cba:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, cba.SaveConfig)