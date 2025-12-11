while not game:GetService("Players").LocalPlayer or not workspace do
    task.wait()
end

local UILibPath = _G.UILib or "C:/matcha/workspace/x11-colorpicker.lua"
local cfgPath = _G.cfg or "C:/matcha/workspace/bwespconfig.lua"

local success, UILib = pcall(require, UILibPath)
if not success or not UILib then
    local camera = workspace.CurrentCamera
    local viewport = camera and camera.ViewportSize or Vector2.new(1920,1080)
    local warning = Drawing.new("Text")
    warning.Text = "UILib file not found, please download the x11-colorpicker.lua file and put it in the matcha workspace, you may adjust paths by using _G.UILib if needed"
    warning.Color = Color3.fromRGB(255, 0, 0)
    warning.Center = true
    warning.Outline = true
    warning.Position = Vector2.new(viewport.X/2, viewport.Y/2)
    warning.Size = Vector2.new(800, 50)
    warning.Visible = true
    setrobloxinput(true)
    return
end

local gui = UILib.new('BW HUB', Vector2.new(320, 380))
local tab = gui:Tab('Visuals')
local sec = gui:Section(tab, 'ESP Options')
local settingsTab, settingsSec = gui:CreateSettingsTab("ESP Settings")

local espTypes = {"None", "Eldertree", "Metal", "Star", "DeathAdder"}
local current = "None"
local running = true
local tracked = {}

local boxConfig = {
    Color = Color3.fromRGB(180,180,180),
    Thickness = 1,
    Filled = false
}

local cfg
local successCfg, loaded = pcall(require, cfgPath)
if successCfg and loaded and loaded.boxCfg then
    cfg = loaded
    if cfg.boxCfg.color then boxConfig.Color = cfg.boxCfg.color end
    if cfg.boxCfg.thickness then boxConfig.Thickness = cfg.boxCfg.thickness end
    if cfg.boxCfg.filled ~= nil then boxConfig.Filled = cfg.boxCfg.filled end
end

local function clearAll()
    for _, v in pairs(tracked) do
        if v.text then v.text:Remove() end
        if v.box then v.box:Remove() end
    end
    tracked = {}
end

local function scan(name)
    local valid = {}
    for _, m in pairs(workspace:GetChildren()) do
        local p, lbl
        if name == "Metal" and m:FindFirstChild("hidden-metal-prompt") then
            p = m:FindFirstChild("Part")
            lbl = "Metal"
        elseif name == "DeathAdder" and m:FindFirstChild("alchemy_crystal_ProximityPrompt") then
            p = m:FindFirstChild("2")
            lbl = "Alchemy Crystal"
        elseif name == "Eldertree" and m:FindFirstChild("treeOrb") then
            p = m:FindFirstChild("Spirit")
            lbl = "Spirit"
        elseif name == "Star" and m:FindFirstChild("stars_ProximityPrompt") then
            p = m:FindFirstChild("RootPart")
            lbl = p and (p.Parent and p.Parent.Name or "Star")
        end
        if p then
            local addr = tostring(p.Address)
            valid[addr] = true
            if not tracked[addr] then
                local t = Drawing.new("Text")
                t.Text = lbl
                t.Center = true
                t.Outline = true
                t.Color = boxConfig.Color
                t.Visible = false
                local b = Drawing.new("Square")
                b.Thickness = boxConfig.Thickness
                b.Filled = boxConfig.Filled
                b.Color = boxConfig.Color
                b.Visible = false
                tracked[addr] = {root=p, text=t, box=b}
            end
        end
    end
    for addr, v in pairs(tracked) do
        if not valid[addr] then
            if v.text then v.text:Remove() end
            if v.box then v.box:Remove() end
            tracked[addr] = nil
        end
    end
end

local function upd()
    for _, v in pairs(tracked) do
        local r, t, b = v.root, v.text, v.box
        if r and r.Position then
            local h, on1 = WorldToScreen(r.Position + Vector3.new(0,2,0))
            local l, on2 = WorldToScreen(r.Position - Vector3.new(0,2,0))
            if on1 and on2 then
                local ht = math.abs(h.Y-l.Y)
                local w = ht/1.5
                local x = h.X-w/2
                local y = h.Y
                b.Position = Vector2.new(x,y)
                b.Size = Vector2.new(w,ht)
                b.Visible = true
                b.Color = boxConfig.Color
                b.Thickness = boxConfig.Thickness
                b.Filled = boxConfig.Filled
                t.Position = Vector2.new(h.X,y-16)
                t.Visible = true
                t.Color = boxConfig.Color
            else
                b.Visible = false
                t.Visible = false
            end
        else
            b.Visible = false
            t.Visible = false
        end
    end
end

gui:Choice(tab, sec, "Choose ESP", {"None"}, function(v)
    current = v[1]
    clearAll()
end, espTypes, false)

gui:Colorpicker(settingsTab, settingsSec, "Box Color", boxConfig.Color, function(c)
    boxConfig.Color = c
end)

gui:Slider(settingsTab, settingsSec, "Box Thickness", boxConfig.Thickness, function(v)
    boxConfig.Thickness = v
end, 1, 5, 1, "")

gui:Checkbox(settingsTab, settingsSec, "Filled Box", boxConfig.Filled, function(v)
    boxConfig.Filled = v
end)

gui:Checkbox(settingsTab, settingsSec, "Uninject", false, function(v)
    if v then
        running = false
        clearAll()
        gui:Destroy()
    end
end)

while running do
    if current ~= "None" then
        scan(current)
        upd()
    else
        clearAll()
    end
    gui:Step()
    task.wait(0.015)
end

clearAll()
gui:Destroy()
