local addonName, addon = ...

local Utils = addon.Utils

addon.Core = {}
local Core = addon.Core

local function InitDB()
    if not LookAtMyHorseDB then
        LookAtMyHorseDB = {
            FlyMounts = {},
            GroundMounts = {}
        }
    end
end

local function MakeMacrosMount(fly)
    
    if not LookAtMyHorseDB then return end

    local targetMount = Utils:GetRandomMount(LookAtMyHorseDB.GroundMounts)

    if fly then
        targetMount = Utils:GetRandomMount(LookAtMyHorseDB.FlyMounts)
    end
    local macroBody = "/look-at-my-horse"
    
    if targetMount then
        macroBody = "/cast "..targetMount
    end

    local macroName = "LookAtMyHorse"

    local index = GetMacroIndexByName(macroName)

    if index == 0 then
        CreateMacro(macroName, 1, macroBody, 0)
        print("LookAtMyHorse макрос створено.")
    else
        EditMacro(index, macroName, 1, macroBody)
    end

end

local function IsFlyableZone(zoneID)

    local canFly = false

    if zoneID == 502 then
        if not (Utils:HasAura(37795) or Utils:HasAura(33280) or Utils:HasAura(55629)) then
            canFly = IsFlyableArea()  
        end
    else
        canFly = IsFlyableArea()
    end

    return canFly

end

local lastZone = false
local lastZoneFly = false
local lastInCombat = false
local lastInDoors = false

function Core:CheckMountUpdate(force) 

    local inCombat = UnitAffectingCombat("player")
    if not inCombat then

        local zoneID = GetCurrentMapAreaID()
        local fly = IsFlyableZone(zoneID)
        local inDoors = IsIndoors()

        if force then
            MakeMacrosMount(fly)
        elseif lastInDoors == 1 and not inDoors then
            MakeMacrosMount(fly)
        elseif lastInCombat == 1 and not inCombat then
            MakeMacrosMount(fly)
        elseif lastZone ~= zoneID then
            MakeMacrosMount(fly)
        elseif lastZoneFly ~= fly then
            MakeMacrosMount(fly)      
        end

        lastInDoors = inDoors
        lastZone = zoneID
        lastZoneFly = fly

    end

    lastInCombat = inCombat

end

local f = CreateFrame("Frame")

local timer = 0

f:SetScript("OnUpdate", function(self, elapsed)
    timer = timer + elapsed
    if timer >= 0.35 then
        timer = 0
        Core:CheckMountUpdate()
    end
end)

f:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LOGIN" then
        InitDB()
    end
end)
