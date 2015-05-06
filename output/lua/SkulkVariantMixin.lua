// ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =====
//
// lua\SkulkVariantMixin.lua
//
// ==============================================================================================

Script.Load("lua/Globals.lua")

SkulkVariantMixin = CreateMixin(SkulkVariantMixin)
SkulkVariantMixin.type = "SkulkVariant"

SkulkVariantMixin.kModelNames = {}

for variant, data in pairs(kSkulkVariantData) do
    SkulkVariantMixin.kModelNames[variant] = PrecacheAsset("models/alien/skulk/skulk" .. data.modelFilePart .. ".model" )
end

SkulkVariantMixin.kDefaultModelName = SkulkVariantMixin.kModelNames[kDefaultSkulkVariant]
local kSkulkAnimationGraph = PrecacheAsset("models/alien/skulk/skulk.animation_graph")

SkulkVariantMixin.networkVars =
{
    variant = "enum kSkulkVariant",
}

function SkulkVariantMixin:__initmixin()
    -- Normal skulks are normal!
    self.variant = kSkulkVariant.normal
end

function SkulkVariantMixin:GetVariant()
    return self.variant
end

function SkulkVariantMixin:IsWhitey()
    return self.variant == kSkulkVariant.shadow
end

function SkulkVariantMixin:SetVariant(variant)
    self.variant = variant
    self:SetModel(self:GetVariantModel(), kSkulkAnimationGraph)
end

function SkulkVariantMixin:GetVariantModel()
    return SkulkVariantMixin.kModelNames[ self.variant ]
end
