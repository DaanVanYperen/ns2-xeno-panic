
/*
function AlienTeam:ReplaceRespawnPlayer(player, origin, angles, mapName)

    Shared:ShotgunMessage("SPAWNING ALIEN V!")       

    local spawnMapName = self.respawnEntity
    
    if mapName ~= nil then
        spawnMapName = mapName
    end
    
    local newPlayer = player:Replace(spawnMapName, self:GetTeamNumber(), false, origin)
    
    // If we fail to find a place to respawn this player, put them in the Team's
    // respawn queue.
    if not self:RespawnPlayer(newPlayer, origin, angles) then
   
         newPlayer = newPlayer:Replace(newPlayer:GetDeathMapName())
         if newPlayer:GetTeamNumber() == kTeam1Index then
             TeamSwap(newPlayer, "skulk", kTeam2Index)
         else
            self:PutPlayerInRespawnQueue(newPlayer)
         end
        // Marines turn skulk upon death.
    end
    
    if newPlayer ~= nil then
        Shared:ShotgunMessage("SPAWNING ALIEN")       
    end
        
    newPlayer:ClearGameEffects()
    if HasMixin(newPlayer, "Upgradable") then
        newPlayer:ClearUpgrades()
    end
    
    return (newPlayer ~= nil), newPlayer
    
end*/