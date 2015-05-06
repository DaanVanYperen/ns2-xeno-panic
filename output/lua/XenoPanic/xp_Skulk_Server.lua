function Skulk:OnInitialized()

    Alien.OnInitialized(self)
    
    // Note: This needs to be initialized BEFORE calling SetModel() below
    // as SetModel() will call GetHeadAngles() through SetPlayerPoseParameters()
    // which will cause a script error if the Skulk is wall walking BEFORE
    // the Skulk is initialized on the client.
    self.currentWallWalkingAngles = Angles(0.0, 0.0, 0.0)
    
    self:SetModel(self:GetVariantModel(), kSkulkAnimationGraph)
    
    self.wallWalking = false
    self.wallWalkingNormalGoal = Vector.yAxis
    
    if Server then
        if GetGamerules():GetWhitey() == nil then
            -- Whitey uses shadow art
            self:SetVariant(kSkulkVariant.shadow)
            Shared.Message("Spawning as Whitey")
        else
            Shared.Message("Spawning as Normal")
        end
    end   

    self:SetHatched()
    self:TriggerEffects("egg_death")
 
    if Client then    
        self.currentCameraRoll = 0
        self.goalCameraRoll = 0        
    end
    
    self.leaping = false
    
    self.timeLastWallJump = 0
    
    InitMixin(self, IdleMixin)
    
end
