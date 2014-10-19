kCustomLocaleMessages = {
    

    MARINE_START_GAME = 'Objective: Find weapons and ammo, survive for 10 minutes!',
    MARINE_VICTORY = "Marines Survived!",
    MARINE_DEFEAT = "Team Marine loses",

    ALIEN_START_GAME = 'Objective: Infect all marines!',
    ALIEN_VICTORY = "Team Xeno Wins!",
    ALIEN_DEFEAT = "Team Xeno loses",    

    // %s=Playername
    SUDDENLY_ALIEN = "A skulk bursts from %s's chest!",    
}

if Locale then
    local OldResolveString = Locale.ResolveString
    
    local function ResolveString(input)
    
        local result = nil
        
        if kCustomLocaleMessages[input] ~= nil then
            result = kCustomLocaleMessages[input]
        end
        
        if result == nil then
            result = OldResolveString(input)
        end
        
        return result
    
    end
    
    Locale.ResolveString = ResolveString
end
