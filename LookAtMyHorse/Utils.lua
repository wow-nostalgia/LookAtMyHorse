local addonName, addon = ...

addon.Utils = {}
local Utils = addon.Utils

-- Utils
function Utils:GetRandomMount(mountList)
    if not mountList or #mountList == 0 then
        return nil
    end
    local index = math.random(1, #mountList)
    return mountList[index]
end


function Utils:HasAura(spellID)
    local unit = "player"
    local name = GetSpellInfo(spellID)
    if not name then return false end

    for i = 1, 40 do
        local buff = UnitBuff(unit, i)
        if not buff then break end
        if buff == name then
            return true
        end
    end

    return false
end
