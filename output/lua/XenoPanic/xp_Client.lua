decoda_name = "Client"
Script.Load("lua/PreLoadMod.lua")
Shared.Message('Xeno Panic [ALPHA/WIP] V0.0.5')

-- disable alien buy menu.
function Alien:Buy()
end

Script.Load("lua/PostLoadMod.lua") 