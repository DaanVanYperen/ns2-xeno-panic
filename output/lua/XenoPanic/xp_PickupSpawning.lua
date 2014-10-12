if Server then

local function SpawnResourceTower(self, techPoint)

    local techPointOrigin = Vector(techPoint:GetOrigin())
    
    local closestPoint = nil
    local closestPointDistance = 0
    
    for index, current in ientitylist(Shared.GetEntitiesWithClassname("ResourcePoint")) do
    
        // The resource point and tech point must be in locations that share the same name.
        local sameLocation = techPoint:GetLocationName() == current:GetLocationName()
        if sameLocation then
        
            local pointOrigin = Vector(current:GetOrigin())
            local distance = (pointOrigin - techPointOrigin):GetLength()
            
            if current:GetAttached() == nil and closestPoint == nil or distance < closestPointDistance then
            
                closestPoint = current
                closestPointDistance = distance
                
            end
            
        end
        
    end
    
    // Now spawn appropriate resource tower there
    if closestPoint ~= nil then
    
        local techId = ConditionalValue(self:GetIsAlienTeam(), kTechId.Harvester, kTechId.Extractor)
        return closestPoint:SpawnResourceTowerForTeam(self, techId)
        
    end
    
    return nil
    
end

/**
 * Spawn hive or command station at nearest empty tech point to specified team location.
 * Does nothing if can't find any.
 */
local function SpawnCommandStructure(techPoint, teamNumber)

    local commandStructure = techPoint:SpawnCommandStructure(teamNumber)
    assert(commandStructure ~= nil)
    commandStructure:SetConstructionComplete()
    
    // Use same align as tech point.
    local techPointCoords = techPoint:GetCoords()
    techPointCoords.origin = commandStructure:GetOrigin()
    commandStructure:SetCoords(techPointCoords)
    
    return commandStructure
    
end

function PlayingTeam:SpawnInitialStructures(techPoint)

    assert(techPoint ~= nil)
    
    // Spawn tower at nearest unoccupied resource point.
    //local tower = SpawnResourceTower(self, techPoint)

    // Spawn hive/command station at team location.
    local commandStructure = SpawnCommandStructure(techPoint, self:GetTeamNumber())
    
    return tower, commandStructure
    
end

end