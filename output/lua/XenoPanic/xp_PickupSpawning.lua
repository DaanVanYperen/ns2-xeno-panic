if Server then


local function SpawnWeapons(self, techPoint)
    
    local weaponTypes = { 
            Pistol.kMapName, 
            Pistol.kMapName, 
            Pistol.kMapName, 
            Pistol.kMapName, 
            Pistol.kMapName, 
            Pistol.kMapName, 
            Axe.kMapName, 
            Axe.kMapName, 
            Axe.kMapName, 
            Axe.kMapName, 
            Axe.kMapName, 
            Axe.kMapName, 
            Rifle.kMapName, 
            Rifle.kMapName, 
            Rifle.kMapName, 
            Builder.kMapName,
            Flamethrower.kMapName,
            GrenadeLauncher.kMapName,
            LayMines.kMapName,
            ClusterGrenadeThrower.kMapName,
            PulseGrenadeThrower.kMapName,
            GasGrenadeThrower.kMapName
    }
    
    for index, current in ientitylist(Shared.GetEntitiesWithClassname("ResourcePoint")) do
         // place some random weapons.
        for i = 1, 40 do        
            local spawnOrigin = current:GetOrigin() + Vector(math.random() * 4 - 2, 0.5, math.random() * 4 - 2)         
            local randomWeapon = weaponTypes[math.random(#weaponTypes)]
            newEnt = CreateEntity( randomWeapon, spawnOrigin, self:GetTeamNumber() )
        end
    end
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
    
    // Spawn weapons for marine team.
    if ( self:GetTeamNumber() == kTeam1Index ) then
        SpawnWeapons(self, techPoint)
    end

    // Spawn hive/command station at team location.
    local commandStructure = SpawnCommandStructure(techPoint, self:GetTeamNumber())
    
    return tower, commandStructure
    
end

end