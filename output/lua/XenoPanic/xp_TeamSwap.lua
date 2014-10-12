local function TeamSwap(className, teamNumber, extraValues)

    return function(client)
    
        local player = client:GetControllingPlayer()
        
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
    
end