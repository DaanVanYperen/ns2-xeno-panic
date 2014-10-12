
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
