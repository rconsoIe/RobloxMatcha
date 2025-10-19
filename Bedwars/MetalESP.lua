if _G.executed then
    for _, info in pairs(_G.trackedESP or {}) do
        if info.text then info.text:Remove() end
        if info.box then info.box:Remove() end
    end
end

_G.executed = true

local config = {
    box = true,
    name = true,
    color = Color3.fromRGB(180, 180, 180)
}

local trackedESP = _G.trackedESP or {}
_G.trackedESP = trackedESP
local workspace = workspace or game and game.Workspace or nil
if not workspace then return end

local function scan_workspace()
    local valid = {}
    for _, model in pairs(workspace:GetChildren()) do
        local prompt = model:FindFirstChild("hidden-metal-prompt")
        if prompt then
            local part = model:FindFirstChild("Part")
            if part then
                local addr = tostring(part)
                valid[addr] = true
                if not trackedESP[addr] then
                    local text
                    local box
                    if config.name then
                        text = Drawing.new("Text")
                        text.Text = "Metal"
                        text.Center = true
                        text.Outline = true
                        text.Color = config.color
                        text.Visible = true
                    end
                    if config.box then
                        box = Drawing.new("Square")
                        box.Thickness = 1
                        box.Filled = false
                        box.Color = config.color
                        box.Visible = true
                    end

                    trackedESP[addr] = {
                        root = part,
                        text = text,
                        box = box
                    }
                end
            end
        end
    end

    for addr, info in pairs(trackedESP) do
        if not valid[addr] then
            if info.text then info.text:Remove() end
            if info.box then info.box:Remove() end
            trackedESP[addr] = nil
        end
    end
end

local function update_esp()
    for _, info in pairs(trackedESP) do
        local root = info.root
        local text = info.text
        local box = info.box

        if root and root.Position then
            local head_pos, on_screen1 = WorldToScreen(root.Position + Vector3.new(0, 2, 0))
            local leg_pos, on_screen2 = WorldToScreen(root.Position - Vector3.new(0, 2, 0))

            if on_screen1 and on_screen2 then
                local h = math.abs(head_pos.Y - leg_pos.Y)
                local w = h / 1.5
                local x = head_pos.X - w / 2
                local y = head_pos.Y

                if box then
                    box.Position = Vector2.new(x, y)
                    box.Size = Vector2.new(w, h)
                    box.Visible = config.box
                end

                if text then
                    text.Position = Vector2.new(head_pos.X, y - 16)
                    text.Visible = config.name
                end
            else
                if box then box.Visible = false end
                if text then text.Visible = false end
            end
        else
            if box then box.Visible = false end
            if text then text.Visible = false end
        end
    end
end

scan_workspace()

while true do
    scan_workspace()
    update_esp()
    task.wait(0.03)
end
