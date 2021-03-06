if Server then

local function SpawnWeapons(self, techPoint)
    
    local weaponTypes = { 
            MedPack.kMapName,
            MedPack.kMapName,
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
            
            if HasMixin(newEnt,"RifleVariant") then
            
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
    
    -- Instance armslab. We need it!
    local origin = commandStation:GetOrigin()
    local right = commandStation:GetCoords().xAxis
    local forward = commandStation:GetCoords().zAxis
    local armslab = CreateEntity( ArmsLab.kMapName, origin+right*3.5+forward*1.5, kMarineTeamType)
    armslab:SetConstructionComplete()

    return tower, commandStation
end

end



function DropPack:OnInitialized()

    ScriptActor.OnInitialized(self)

    if Server then
        -- XP START
        -- Disable default timeout for medpacks and the like.
        self.pickupRange = 1
        -- XP END
         self:SetAngles(Angles(0, math.random() * math.pi * 2, 0))
       
        self:OnUpdate(0)
    
    end

end



function Weapon:Dropped(prevOwner)
    
    if prevOwner ~= nil then
    local slot = self:GetHUDSlot()

    self.prevOwnerId = prevOwner:GetId()
    
    -- XP START 
    -- prevent weapons from despawning
    self:SetWeaponWorldState(true,true)
    -- XP END
    
    // when dropped weapons always need a physic model
    if not self.physicsModel then
        self.physicsModel = Shared.CreatePhysicsModel(self.physicsModelIndex, true, self:GetCoords(), self)
    end
    
    if self.physicsModel then
    
        local viewCoords = prevOwner:GetViewCoords()
        local impulse = 0.075
        if slot == 2 then
            impulse = 0.0075
        elseif slot == 3 then
            impulse = 0.005
        end
        self.physicsModel:AddImpulse(self:GetOrigin(), (viewCoords.zAxis * impulse))
        self.physicsModel:SetAngularVelocity(Vector(5,0,0))
        
    end
    end
    
end
