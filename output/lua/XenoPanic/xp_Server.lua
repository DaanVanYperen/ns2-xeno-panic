
Script.Load("lua/XenoPanic/xp_Marine_Server.lua")
Script.Load("lua/XenoPanic/xp_Skulk_Server.lua")

// Misc
/*Script.Load("lua/SkulksWithShotguns/sws_NS2ConsoleCommands_Server.lua") */
Script.Load("lua/XenoPanic/xp_ItemSpawn.lua") 
Script.Load("lua/XenoPanic/xp_PlayingTeam.lua")

// Custom entity prepping for our mod.

local OriginalGetCreateEntityOnStart = GetCreateEntityOnStart
function GetCreateEntityOnStart(mapName, groupName, values)

    return mapName ~= ItemSpawn.kMapName
       and OriginalGetCreateEntityOnStart(mapName, groupName, values)

end

Server.itemSpawnList = table.array(5000)

// Custom entity loading for our mod.
local OriginalLoadSpecial = GetLoadSpecial
function GetLoadSpecial(mapName, groupName, values)

    local success = false
    
    if mapName == ItemSpawn.kMapName then
        local entity = ItemSpawn()
        entity:OnCreate()
        LoadEntityFromValues(entity, values)
        table.insert(Server.itemSpawnList, entity)
        success = true
    else
        return OriginalLoadSpecial(mapName, groupName, values)
    end
    
    return success
    
end