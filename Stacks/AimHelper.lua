_G.AimHelper = {}
_G.AimHelper.__index = _G.AimHelper

function _G.AimHelper.new()
    return setmetatable({}, _G.AimHelper)
end

function _G.AimHelper:AimAt(part)
    if not part or not part.Position then
        print("[AimHelper] Invalid part")
        return false
    end

    local point = WorldToScreen(part.Position)
    if not point or not point.X or not point.Y then
        print("[AimHelper] WorldToScreen failed or offscreen")
        return false
    end

    local x, y = math.floor(point.X), math.floor(point.Y)
    if x and y then
        local success, err = pcall(function() mousemoveabs(x, y) end)
        if success then
            print(string.format("[AimHelper] Aimed at %s (%.1f, %.1f)", part.Name, x, y))
            return true
        else
            print("[AimHelper] mousemoveabs failed:", err)
            return false
        end
    end

    print("[AimHelper] Unknown error")
    return false
end

return _G.AimHelper
