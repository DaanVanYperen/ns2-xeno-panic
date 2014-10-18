if Server then

local function SpawnWeapons(self, techPoint)
    
    local weaponTypes = { 
            GrenadeLauncherAmmo.kMapName,
            FlamethrowerAmmo.kMapName,
            RifleAmmo.kMapName,
            RifleAmmo.kMapName,
            ShotgunAmmo.kMapName,
            ShotgunAmmo.kMapName,
            Pistol.kMapName, 
            Pistol.kMapName, 
            Pistol.kMapName, 
            Pistol.kMapName, 
            Pistol.kMapName, 
            Pistol.kMapName, 
            Rifle.kMapName, 
            Rifle.kMapName, 
            Rifle.kMapName, 
            Rifle.kMapName, 
            Shotgun.kMapName,
            Shotgun.kMapName,
            Shotgun.kMapName,
            Welder.kMapName,
            Welder.kMapName,
            Welder.kMapName,
            Flamethrower.kMapName,
            GrenadeLauncher.kMapName,
            LayMines.kMapName,
            ClusterGrenadeThrower.kMapName,
            PulseGrenadeThrower.kMapName,
            GasGrenadeThrower.kMapName
    }
    
    for i = 1, #Server.itemSpawnList do
         local current = Server.itemSpawnList[i]
         // place some random weapons.
         local spawnOrigin = current:GetOrigin() + Vector(0, .2, 0)
         local randomWeapon = weaponTypes[math.random(#weaponTypes)]
         newEnt = CreateEntity( randomWeapon, spawnOrigin, self:GetTeamNumber() )
            
         if newEnt ~= nil then 
            -- give weapons a physics model so they can plop down.
            if not newEnt.physicsModel then
                newEnt.physicsModel = Shared.CreatePhysicsModel(newEnt.physicsModelIndex, true, newEnt:GetCoords(), newEnt)
            end
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

function MarineTeam:SpawnInitialStructures(techPoint)
    local tower, commandStation = PlayingTeam.SpawnInitialStructures(self, techPoint)
    return tower, commandStation
end

end