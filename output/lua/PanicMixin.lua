kSfxPanic = PrecacheAsset("sound/xp.fev/common/panic")

PanicMixin = CreateMixin(PanicMixin)
PanicMixin.type = "Panic"

PanicMixin.kDefaultDuration = 60

PanicMixin.networkVars = {
    isPanicked = "boolean"
}

function PanicMixin:__initmixin()

    if Server then
        self.isPanicked = false
        self.timeUntilPanicEnd = 0
    end
    
end

function PanicMixin:GetIsPanicked()
    return self.isPanicked
end

function PanicMixin:GetCanCatalyst()
    return ( HasMixin(self, "Maturity") and not self:GetIsMature() ) or self:isa("Embryo")
end

local function SharedUpdate(self, deltaTime)

    if self.isPanicked then
        if Server then
            self.timeUntilPanicEnd = math.max(self.timeUntilPanicEnd - deltaTime, 0)
            if self.timeUntilPanicEnd == 0 then
                self.isPanicked = false
            end
        end
    end

end

function PanicMixin:OnProcessMove(input)
    SharedUpdate(self, input.time)
end

function PanicMixin:OnUpdate(deltaTime)
    SharedUpdate(self, deltaTime)
end


function PanicMixin:PanicDropAllWeapons()

    local weaponSpawnCoords = self:GetAttachPointCoords(Weapon.kHumanAttachPoint)
    local weaponList = self:GetHUDOrderedWeaponList()
    for w = 1, #weaponList do
        local weapon = weaponList[w]
        self:Drop(weapon, true, true)
    end
    
end

local function PlaySound( self, soundEffect )
    Shared.PlaySound(self, soundEffect)
end

function PanicMixin:TriggerPanic()

    local duration = 30

    if Server and self.isPanicked == false then
        self.timeUntilPanicEnd = ConditionalValue(duration ~= nil, duration, PanicMixin.kDefaultDuration)
        self.isPanicked = true
        
        -- cannot pickup weapons while under panic effects.
        self.timeOfLastPickUpWeapon = Shared.GetTime() + CatalystMixin.kDefaultDuration

        self:PanicDropAllWeapons()
        StartSoundEffectAtOrigin(CatPack.kPickupSound, self:GetOrigin())
        self:ApplyCatPack()
        
        StartSoundEffectAtOrigin(kSfxPanic, self:GetOrigin())
    end
    
end

function PanicMixin:CopyPlayerDataFrom(player)

    if player.isPanicked then
        self.isPanicked = player.isPanicked
    end
    
    if player.timeUntilPanicEnd then
        self.timeUntilPanicEnd = player.timeUntilPanicEnd
    end

end