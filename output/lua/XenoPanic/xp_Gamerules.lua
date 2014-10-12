// We override NS2Gamerules to avoid having to override the NS2 gameserver.
// @todo port this all to our own gamerules class.

if (Server) then            

    local kGameEndCheckInterval = 0.75
    local kXenoPanicTimeLimit = 60*20

    function NS2Gamerules:GetCanJoinTeamNumber(teamNumber)
       return true; // (teamNumber == self.team2:GetTeamNumber())
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
    
    function NS2Gamerules:CheckGameStart()
    
        if (self:GetGameState() == kGameState.NotStarted) or (self:GetGameState() == kGameState.PreGame) then
        
            // Start game when we have /any/ players in the game.
            local playerCount = self.team1:GetNumPlayers() + self.team2:GetNumPlayers()
            
            if  (playerCount >= 3) then
                if self:GetGameState() == kGameState.NotStarted then
                    self:SetGameState(kGameState.PreGame)
                    self.score = 0
                    Shared:ShotgunMessage("Game started!")
                end
            else
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
    
        if self:GetGameStarted() and self.timeGameEnded == nil and not self.preventGameEnd then
                
            // no marines remain.
            local noMarinesRemain = (GetNumAlivePlayers(self.team1) < 1) 
            if noMarinesRemain then
                Shared:ShotgunMessage("Aliens win!")
                self:EndGame(self.team2)
            end
            
            // game is taking too long.
            if self.timeLastGameEndCheck == nil or (Shared.GetTime() > self.timeLastGameEndCheck + kGameEndCheckInterval) then
            
                if (self.timeSinceGameStateChanged >= kXenoPanicTimeLimit) then
                    Shared:ShotgunMessage("Marines survived!")
                    self:EndGame(self.team1)
                end

                self.timeLastGameEndCheck = Shared.GetTime()                
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
        
        /*
        // fall back on resource points as spawns if none exist for the shadow team.
        if table.maxn(Server.shadowSpawnList) <= 0 then
            Shared:ShotgunWarning("Map lacks shadow_spawn entities on the map! Falling back on ResourcePoints.")        
            for index, entity in ientitylist(Shared.GetEntitiesWithClassname("ResourcePoint")) do
                local spawn = ShadowSpawn()
                spawn:OnCreate()
                spawn:SetAngles(entity:GetAngles())
                spawn:SetOrigin(entity:GetOrigin())
                table.insert(Server.shadowSpawnList, spawn)
            end     
        end
        
        // fall back on resource points as spawns if none exist for the vanilla team.
        if table.maxn(Server.vanillaSpawnList) <= 0 then
            Shared:ShotgunWarning("Map lacks vanilla_spawn entitities on the map! Falling back on ResourcePoints.")
            for index, entity in ientitylist(Shared.GetEntitiesWithClassname("ResourcePoint")) do
                local spawn = VanillaSpawn()
                spawn:OnCreate()
                spawn:SetAngles(entity:GetAngles())
                spawn:SetOrigin(entity:GetOrigin())
                table.insert(Server.vanillaSpawnList, spawn)
            end     
        end */
   end

    // disable these methods in OnUpdate, we don't want them to trigger.
    local function DisabledUpdateAutoTeamBalance(self, dt) end
    local function DisabledCheckForNoCommander(self, onTeam, commanderType) end
    local function DisabledKillEnemiesNearCommandStructureInPreGame(self, timePassed) end
    
    ReplaceLocals( NS2Gamerules.OnUpdate, { UpdateAutoTeamBalance = DisabledUpdateAutoTeamBalance } )
    ReplaceLocals( NS2Gamerules.OnUpdate, { CheckForNoCommander = DisabledCheckForNoCommander } )
    ReplaceLocals( NS2Gamerules.OnUpdate, { KillEnemiesNearCommandStructureInPreGame = DisabledKillEnemiesNearCommandStructureInPreGame } )

end