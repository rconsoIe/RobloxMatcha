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

    if point.X == 0 and point.Y == 0 then
        print("[AimHelper] Screen point is (0,0), skipping")
        return false
    end

    local success, err = pcall(function()
        mousemoveabs(point.X, point.Y)
    end)

    if success then
        print(string.format("[AimHelper] Aimed at %s (%.1f, %.1f)", part.Name, point.X, point.Y))
        return true
    else
        print("[AimHelper] mousemoveabs failed:", err)
        return false
    end
end

return _G.AimHelper
