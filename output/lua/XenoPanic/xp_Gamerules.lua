// We override NS2Gamerules to avoid having to override the NS2 gameserver.
// @todo port this all to our own gamerules class.

if (Server) then            

    local kEnoughAlienCheckInterval = 5
    local kGameEndCheckInterval = 0.75
    local kXenoPanicTimeLimit = 60*20
    
    function NS2Gamerules:GetWhitey()
        for playerIndex, player in ipairs(self.team2:GetPlayers()) do
            if HasMixin(player, "Live") and player:GetCanDie() and player:GetVariant() ==  kSkulkVariant.shadow then
                return player
            end
        end
        return nil
    end
          
    function NS2Gamerules:GetCanJoinTeamNumber(teamNumber)
        if self:GetGameStarted() then
            // after game started you can only join aliens.
            return (teamNumber == self.team2:GetTeamNumber())
        else
            // during pre-game you can only join marines.
            return (teamNumber == self.team1:GetTeamNumber())
        end
    end
       
    local kPauseToSocializeBeforeMapcycle = 30
    function NS2Gamerules:SetGameState(state)
    
        if state ~= self.gameState then
        
            self.gameState = state
            self.gameInfo:SetState(state)
            self.timeGameStateChanged = Shared.GetTime()
            self.timeSinceGameStateChanged = 0
            
            local frozenState = (state == kGameState.Countdown) and (not Shared.GetDevMode())
            self.team1:SetFrozenState(frozenState)
            self.team2:SetFrozenState(frozenState)
            
            if self.gameState == kGameState.Started then
            
                PostGameViz("Game started")
                self.gameStartTime = Shared.GetTime()
                
                self.gameInfo:SetStartTime(self.gameStartTime)
                
                SendEventMessage(self.team1, kEventMessageTypes.MarineStartGame)
                SendEventMessage(self.team2, kEventMessageTypes.AlienStartGame)
                
                // Reset disconnected player resources when a game starts to prevent shenanigans.
                self.disconnectedPlayerResources = { }
                
            end
            
            // On end game, check for map switch conditions
            if state == kGameState.Team1Won or state == kGameState.Team2Won then
            
                if MapCycle_TestCycleMap() then
                    self.timeToCycleMap = Shared.GetTime() + kPauseToSocializeBeforeMapcycle
                else
                    self.timeToCycleMap = nil
                end
                
            end
            
        end
        
    end    
    

function NS2Gamerules:TeamSwap(player, className, teamNumber, extraValues)
        
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
            end
            
         // Respawn shenanigans
            local newPlayer = player:Replace(className, player:GetTeamNumber(), nil, nil, extraValues)
            
            // Always disable 3rd person
            newPlayer:SetDesiredCameraDistance(0)
            
       end
end    
    
    function NS2Gamerules:RandomlyConvertMarine()
    
        local convertables = {}

        for playerIndex, player in ipairs(self.team1:GetPlayers()) do
            if HasMixin(player, "Live") and player:GetCanDie() then
                table.insert(convertables, player)
            end
        end
    
        -- swap random player to enemy team.
        if (#convertables > 0) then
            self:TeamSwap(convertables[math.random(#convertables)], "skulk", kTeam2Index)
        end
         
    end
        
    function NS2Gamerules:EnsureEnoughAliens()

         local marineCount = self.team1:GetNumPlayers()
         local alienCount = self.team2:GetNumPlayers()
         
         local minimumAlienCount = (marineCount >= 8) and 2 or 1          
         if ( alienCount < minimumAlienCount ) then
             self:RandomlyConvertMarine()
         end
         
    end
    
    -- Force join everyone to the game.
    function NS2Gamerules:AutojoinEveryone()
        Shared.Message("Attempting Auto joining" )
        for index, player in ientitylist(Shared.GetEntitiesWithClassname("Player")) do
            Server.ClientCommand(player, "jointeamone") 
        end
    end
    
    function NS2Gamerules:BreakPowernodes()
        for index, powerPoint in ientitylist(Shared.GetEntitiesWithClassname("PowerPoint")) do            
           if powerPoint:GetPowerState() == PowerPoint.kPowerState.unsocketed then
                powerPoint:SocketPowerNode()
                powerPoint:SetConstructionComplete()
           end
           if ( math.random(100) <= 66 ) then
                powerPoint:Kill()
           end
        end
    end
    
    
    function NS2Gamerules:CheckGameStart()
    
        if (self:GetGameState() == kGameState.NotStarted) or (self:GetGameState() == kGameState.PreGame) then

            // Start game when we have /any/ players in the game.
            local playerCount = self.team1:GetNumPlayers() + self.team2:GetNumPlayers()
            
            if (playerCount >= 3) then
            
                if self:GetGameState() == kGameState.NotStarted then
                
                    -- 15 second cooldown.
                    if ( self.timeUntilStart == nil ) then
                    
                      -- auto join all players
                      self:BreakPowernodes()
                      Shared:ShotgunMessage("Game will start in 15 seconds! Join up quickly!")
                      Shared:ShotgunMessage("One of you is infected! Trust no one...")
                      self.timeUntilStart = Shared.GetTime() + 15 
                    end 
            
                    -- ready to begin!
                    if ( Shared.GetTime() >= self.timeUntilStart ) then
                        self:AutojoinEveryone()
                        self.timeUntilStart = nil
                        self:SetGameState(kGameState.PreGame)
                        self.score = 0
                        Shared:ShotgunMessage("Game started!")
                        Shared:ShotgunMessage("Marines: Find weapons and ammo, survive!")
                        Shared:ShotgunMessage("Aliens: Turn all marines.. by eating them!")                        
                    end
                end
            else
                self.timeUntilStart = nil
                if (self:GetGameState() == kGameState.PreGame) then
                    self:SetGameState(kGameState.NotStarted)
                    Shared:ShotgunMessage("Round aborted!")
                end
            end
            
        end
        
    end
    
    function NS2Gamerules:OnClientConnect(client)        
        Gamerules.OnClientConnect(self, client)
        
        local player = client:GetControllingPlayer()
        
        // warn players they are not getting a typical match. 
        // Wouldn't want to confuse the greens.
        player:ShotgunMessage("You are playing custom mod: Xeno Panic!")
        player:ShotgunMessage("This is not Vanilla NS2! Have fun!")
    end
    
    function NS2Gamerules:GetPregameLength()
        // we have no need for a pre-game.
        return 0
    end

    local function ResetPlayerScores()
        for _, player in ientitylist(Shared.GetEntitiesWithClassname("Player")) do            
            if player.ResetScores then
                player:ResetScores()
            end            
        end
    
    end

    function NS2Gamerules:UpdatePregame(timePassed)

        if self:GetGameState() == kGameState.PreGame then
                ResetPlayerScores()
                self:SetGameState(kGameState.Started)
                self.sponitor:OnStartMatch()
                self.playerRanking:StartGame()
                
                -- XP we want this to run immediately
                self.timeLastEnoughAliensCheck = nil 
        end
        
    end
    
    // returns number of living players on team.
    local function GetNumAlivePlayers(self)
        local numPlayers = 0
    
        for index, playerId in ipairs(self.playerIds) do
            local player = Shared.GetEntity(playerId)
            if player ~= nil and player:GetId() ~= Entity.invalidId and player:GetIsAlive() == true then
                numPlayers = numPlayers + 1
            end 
        end
    
        return numPlayers
    end
   
    function NS2Gamerules:CheckGameEnd()
    
        // respawn dead marines as skulks.
        if self:GetGameStarted() then
            local playerToSwap = self.team1:GetOldestQueuedPlayer();
            if playerToSwap ~= nil then 
                  self:TeamSwap(playerToSwap, "skulk", kTeam2Index)
            end
        end 
    
        if self:GetGameStarted() and self.timeGameEnded == nil and not self.preventGameEnd then
                
            // no marines remain.
            local noMarinesRemain = (GetNumAlivePlayers(self.team1) < 1) 
            if noMarinesRemain then
                Shared:ShotgunMessage("Aliens win!")
                self:EndGame(self.team2)
            end
            
            // game is taking too long.
            if self.timeLastGameEndCheck == nil or (Shared.GetTime() > self.timeLastGameEndCheck + kGameEndCheckInterval) then
            
                -- lost by lack of hive.
                local team2Lost = self.team2:GetNumAliveCommandStructures() == 0
            
                if (self.timeSinceGameStateChanged >= kXenoPanicTimeLimit) or team2Lost then
                    Shared:ShotgunMessage("Marines survived!")
                    self:EndGame(self.team1)
                end

                self.timeLastGameEndCheck = Shared.GetTime()                
            end
            
            // spawn some aliens if needed.
            if self.timeLastEnoughAliensCheck == nil or (Shared.GetTime() > self.timeLastEnoughAliensCheck + kEnoughAlienCheckInterval) then
                self:EnsureEnoughAliens()
                self.timeLastEnoughAliensCheck = Shared.GetTime()   
            end
            
        end
        
    end
    
    
    function NS2Gamerules:OnMapPostLoad()

        Gamerules.OnMapPostLoad(self)
        
        // Now allow script actors to hook post load
        local allScriptActors = Shared.GetEntitiesWithClassname("ScriptActor")
        for index, scriptActor in ientitylist(allScriptActors) do
            scriptActor:OnMapPostLoad()
        end
        
        // fall back on resource points as spawns if none exist for the shadow team.
        if table.maxn(Server.itemSpawnList) <= 0 then
            Shared:ShotgunWarning("Map lacks item_spawn entities on the map! Falling back on ResourcePoints.")        
            for index, entity in ientitylist(Shared.GetEntitiesWithClassname("ResourcePoint")) do
                local spawn = ItemSpawn()
                spawn:OnCreate()
                spawn:SetAngles(entity:GetAngles())
                spawn:SetOrigin(entity:GetOrigin())
                table.insert(Server.itemSpawnList, spawn)
            end     
        end
        
   end

    // disable these methods in OnUpdate, we don't want them to trigger.
    local function DisabledUpdateAutoTeamBalance(self, dt) end
    local function DisabledCheckForNoCommander(self, onTeam, commanderType) end
    local function DisabledKillEnemiesNearCommandStructureInPreGame(self, timePassed) end
    
    ReplaceLocals( NS2Gamerules.OnUpdate, { UpdateAutoTeamBalance = DisabledUpdateAutoTeamBalance } )
    ReplaceLocals( NS2Gamerules.OnUpdate, { CheckForNoCommander = DisabledCheckForNoCommander } )
    ReplaceLocals( NS2Gamerules.OnUpdate, { KillEnemiesNearCommandStructureInPreGame = DisabledKillEnemiesNearCommandStructureInPreGame } )

end