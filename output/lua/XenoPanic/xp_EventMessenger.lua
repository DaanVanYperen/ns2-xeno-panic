
kEventMessageTypes = enum({ 
    'SuddenlyAlien',
    'MarineStartGame',
    'AlienStartGame',
 })

local kEventMessages = { }

// This function will generate the string to display based on a clientIndex.
local actorStringGen = function(clientIndex, messageString) 

    // Unknown person.
    local name = "Someone "
    
    name = Scoreboard_GetPlayerName(clientIndex) or name
    
    // Keyword self as 'you'
    local localPlayer = Client.GetLocalPlayer()
    if localPlayer ~= nil and clientIndex == localPlayer:GetClientIndex() then
        name = "You"
    end
    
    return string.format(Locale.ResolveString(messageString), name) 
end

kEventMessages[kEventMessageTypes.SuddenlyAlien] = { text = function(data) return actorStringGen(data, "SUDDENLY_ALIEN") end }
kEventMessages[kEventMessageTypes.MarineStartGame] = { text = function(data) return Locale.ResolveString("MARINE_START_GAME") end }
kEventMessages[kEventMessageTypes.AlienStartGame] = { text = function(data) return Locale.ResolveString("ALIEN_START_GAME") end }

// Silly name but it fits the convention.
local kEventMessageMessage =
{
    type = "enum kEventMessageTypes",
    data = "integer"
}

Shared.RegisterNetworkMessage("EventMessage", kEventMessageMessage)

if Server then

    /**
     * Sends every team the passed in message for display.
     */
    function SendGlobalMessage(messageType, optionalData)
    
        if GetGamerules():GetGameStarted() then
        
            local teams = GetGamerules():GetTeams()
            for t = 1, #teams do
                SendEventMessage(teams[t], messageType, optionalData)
            end
            
        end
        
    end
    
    /**
     * Sends every player on the passed in team the passed in message for display.
     */
    function SendEventMessage(team, messageType, optionalData)
    
        local function SendToPlayer(player)
            Server.SendNetworkMessage(player, "EventMessage", { type = messageType, data = optionalData or 0 }, true)
        end
        
        team:ForEachPlayer(SendToPlayer)
        
    end
    
    /**
     * Sends the passed in message to the players passed in.
     */
    function SendPlayersMessage(playerList, messageType, optionalData)
    
        if GetGamerules():GetGameStarted() then
        
            for p = 1, #playerList do
                Server.SendNetworkMessage(playerList[p], "EventMessage", { type = messageType, data = optionalData or 0 }, true)
            end
            
        end
        
    end
    
    local function TestEventMessage(client)
    
        local player = client:GetControllingPlayer()
        if player then
            SendPlayersMessage({ player }, kEventMessageTypes.EnemyTookOurGorge)
        end
        
    end
    
    Event.Hook("Console_tem", TestEventMessage)
    
end

if Client then

    local function SetEventMessage(messageType, messageData)
    
        local player = Client.GetLocalPlayer()
        if player and HasMixin(player, "EventMessage") then
        
                local displayText = kEventMessages[messageType].text
                
                if displayText then
                
                    if type(displayText) == "function" then
                        displayText = displayText(messageData)
                    else
                        displayText = Locale.ResolveString(displayText)
                    end
                    
                    assert(type(displayText) == "string")
                    player:SetEventMessage(string.upper(displayText))
                    
                end
            
        end
        
    end
    
    function OnCommandEventMessage(message)
        SetEventMessage(message.type, message.data)
    end
    
    Client.HookNetworkMessage("EventMessage", OnCommandEventMessage)
    
end