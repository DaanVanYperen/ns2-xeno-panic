
function Marine:InitWeapons()

    Player.InitWeapons(self)

    self:GiveItem(Axe.kMapName)
    self:SetQuickSwitchTarget(Axe.kMapName)
    self:SetActiveWeapon(Axe.kMapName) 
    
    /* players spawn with zero weapons.
    self:GiveItem(Rifle.kMapName)
    self:GiveItem(Pistol.kMapName)
    self:GiveItem(Builder.kMapName)
    
    self:SetQuickSwitchTarget(Pistol.kMapName)
    self:SetActiveWeapon(Rifle.kMapName)  */

end

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
        end
    end   
 
    if Client then
    
        self.currentCameraRoll = 0
        self.goalCameraRoll = 0
        
        self:AddHelpWidget("GUIEvolveHelp", 2)
        self:AddHelpWidget("GUISkulkParasiteHelp", 1)
        self:AddHelpWidget("GUISkulkLeapHelp", 2)
        self:AddHelpWidget("GUIMapHelp", 1)
        self:AddHelpWidget("GUITunnelEntranceHelp", 1)
        
    end
    
    self.leaping = false
    
    self.timeLastWallJump = 0
    
    InitMixin(self, IdleMixin)
    
end
