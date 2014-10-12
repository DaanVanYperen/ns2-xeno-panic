
function Marine:InitWeapons()

    Player.InitWeapons(self)
    
    /* players spawn with zero weapons.
    self:GiveItem(Rifle.kMapName)
    self:GiveItem(Pistol.kMapName)
    self:GiveItem(Axe.kMapName)
    self:GiveItem(Builder.kMapName)
    
    self:SetQuickSwitchTarget(Pistol.kMapName)
    self:SetActiveWeapon(Rifle.kMapName)  */

end


local function TeamSwap(player, className, teamNumber, extraValues)
        
        // Don't allow to use these commands if you're in the RR
        if player:GetTeamNumber() == kTeam1Index or player:GetTeamNumber() == kTeam2Index then
        
            // Switch teams if necessary
            if player:GetTeamNumber() ~= teamNumber then
                    // Remember position and team for calling player for debugging
                    local playerOrigin = player:GetOrigin()
                    local playerViewAngles = player:GetViewAngles()
                    
                    local newTeamNumber = kTeam1Index
                    if player:GetTeamNumber() == kTeam1Index then
                        newTeamNumber = kTeam2Index
                    end
                    
                    local success, newPlayer = GetGamerules():JoinTeam(player, kTeamReadyRoom)
                    success, newPlayer = GetGamerules():JoinTeam(newPlayer, newTeamNumber)
                    
                    newPlayer:SetOrigin(playerOrigin)
                    newPlayer:SetViewAngles(playerViewAngles)
                    
                    player = client:GetControllingPlayer()
            end
            
         // Respawn shenanigans
            local newPlayer = player:Replace(className, player:GetTeamNumber(), nil, nil, extraValues)
            // Always disable 3rd person
            newPlayer:SetDesiredCameraDistance(0)
            
       end
end


function Marine:OnKill(attacker, doer, point, direction)

    // @TODO STRIP OUT VANILLA CODE START >  
    local lastWeaponList = self:GetHUDOrderedWeaponList()
    self.lastWeaponList = { }
    for _, weapon in pairs(lastWeaponList) do
        table.insert(self.lastWeaponList, weapon:GetMapName())
        // If cheats are enabled, destroy the weapons so they don't drop
        if Shared.GetCheatsEnabled() and weapon:GetIsDroppable() and LookupTechData(weapon:GetTechId(), kTechDataCostKey, 0) > 0 then
            DestroyEntity(weapon)
        end
    end

    // Drop all weapons which cost resources
    self:DropAllWeapons()
    
    // Destroy remaining weapons
    self:DestroyWeapons()
    
    //Player.OnKill(self, attacker, doer, point, direction)
    
    // Don't play alert if we suicide
    if attacker ~= self then
        self:GetTeam():TriggerAlert(kTechId.MarineAlertSoldierLost, self)
    end
    
    // Note: Flashlight is powered by Marine's beating heart. Eco friendly.
    self:SetFlashlightOn(false)
    self.originOnDeath = self:GetOrigin()
    // @TODO STRIP OUT VANILLA CODE END
    
    // Marines turn skulk upon death.
    TeamSwap(self, "skulk", kTeam2Index)
end
