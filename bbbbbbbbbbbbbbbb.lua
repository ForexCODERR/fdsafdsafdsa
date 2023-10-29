local workspace = game:GetService("Workspace")
local players = game:GetService("Players")
local startergui = game:GetService("StarterGui")

local player = players.LocalPlayer
local char = player.Character
if not char then
    char = player.CharacterAdded:Wait()
end
local rootpart = char:WaitForChild("HumanoidRootPart")

local b1
local b2
local b2touched = false
local lasttgt = ""
local lasttouchtime = 0
local lastclicktype = ""
local lastclicktimestamp = 0
local lastclicktgt = nil
local hitbox = Instance.new("Part")

hitbox.Shape = Enum.PartType.Ball
hitbox.Size = Vector3.new(30, 30, 30)
hitbox.Anchored = true
hitbox.CanCollide = false
hitbox.Transparency = 0
hitbox.CastShadow = false
hitbox.Parent = workspace
hitbox.Material = Enum.Material.ForceField

local maxdistquickfar = 20
local maxdistquickclose = 10
local maxdistnormal = 15
local mintimebetweenclicks = 0.5
local minvelocitynormal = 50
local minvelocityquick = 100
local players

local function updateballrefs()
    local foundb1 = false
    local foundb2 = false

    for _, ball in ipairs(workspace.Balls:GetChildren()) do
        if not foundb1 and ball.Transparency == 0 then
            b1 = ball
            foundb1 = true
        elseif not foundb2 and ball.Transparency == 1 then
            b2 = ball
            foundb2 = true
        end

        if foundb1 and foundb2 then
            break
        end
    end
end

local function ontouch(hit)
    if b2 and hit == b2 then
        b2touched = true
        lasttouchtime = tick()
    end
end

hitbox.Touched:Connect(ontouch)

local lastvel = 0
local lastupdatetime = tick()
local lastdisttoplayer = math.huge
local lastdisttotgt = math.huge

local function checkplayerdist()
    players = players:GetPlayers()
    local currenttime = tick()

    for _, otherplayer in ipairs(players) do
        if otherplayer ~= players.LocalPlayer and otherplayer.Character then
            local otherrootpart = otherplayer.Character:FindFirstChild("HumanoidRootPart")
            if otherrootpart then
                local disttoplayer = (otherrootpart.Position - rootpart.Position).Magnitude
                local currenttgt = b2 and b2:GetAttribute("target") or ""

                if disttoplayer < lastdisttoplayer then
                    lastdisttoplayer = disttoplayer
                else
                    lastdisttoplayer = disttoplayer
                end

                if currenttgt ~= lasttgt then
                    startergui:SetCore("SendNotification", {
                        Title = "New Target",
                        Text = "Ball2 has a new target: " .. currenttgt,
                        Duration = 5
                    })

                    lasttgt = currenttgt
                    lastclicktgt = nil
                end

                if lastdisttoplayer <= maxdistnormal and currenttgt == otherplayer.Name and b2 and b2:FindFirstChild("zoomies") then
                    local currentvel = math.abs(b2.zoomies.VectorVelocity.Magnitude)
                    local clicktype = "none"

                    if currenttime - lastclicktimestamp >= mintimebetweenclicks then
                        if currentvel >= minvelocitynormal then
                            if lastclicktgt ~= otherplayer.Name then
                                clicktype = "normal"
                            end
                            if disttoplayer <= maxdistnormal then
                                clicktype = "normal"
                            end
                            if disttoplayer <= maxdistquickclose then
                                clicktype = "quick"
                            elseif disttoplayer <= maxdistquickfar then
                                clicktype = "quick_multi"
                            end
                        end
                    end

                    if clicktype ~= lastclicktype and clicktype ~= "none" then
                        startergui:SetCore("SendNotification", {
                            Title = "Click Type",
                            Text = "Click Type: " .. clicktype,
                            Duration = 3
                        })

                        if clicktype == "quick" then
                            startergui:SetCore("SendNotification", {
                                Title = "Quick Click",
                                Text = "Quick Click Activated!",
                                Duration = 3
                            })

                            game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.F, false, game)
                            wait(0.03)
                            game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.F, false, game)
                        elseif clicktype == "quick_multi" then
                            startergui:SetCore("SendNotification", {
                                Title = "Quick Multi Click",
                                Text = "Quick Multi Click Activated!",
                                Duration = 3
                            })

                            game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.F, false, game)
                            wait(0.03)
                            game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.F, false, game)
                        elseif clicktype == "normal" then
                            startergui:SetCore("SendNotification", {
                                Title = "Normal Click",
                                Text = "Normal Click Activated!",
                                Duration = 3
                            })

                            game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.F, false, game)
                            wait(0.1)
                            game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.F, false, game)
                        end

                        lastclicktype = clicktype
                        lastclicktimestamp = currenttime
                        lastclicktgt = otherplayer.Name
                    end
                end
            end
        end
    end
end

game:GetService("RunService").Heartbeat:Connect(function()
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        hitbox.CFrame = player.Character.HumanoidRootPart.CFrame

        updateballrefs()
        checkplayerdist()

        if b2touched then
            if b1 and b1.BrickColor == BrickColor.new("Really red") then
                game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.F, false, game)
                wait(0.1)
                game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.F, false, game)
            end
        end

        if b2 and b2:FindFirstChild("zoomies") and b2.zoomies then
            local currenttime = tick()
            local deltatime = currenttime - lastupdatetime
            local currentvel = math.abs(b2.zoomies.VectorVelocity.Magnitude)

            if deltatime > 0 then
                local acceleration = (currentvel - lastvel) / deltatime
                if acceleration < 10 then
                    local size = currentvel - 25
                    size = math.clamp(size, 30, 140)
                    hitbox.Size = Vector3.new(size, size, size)

                    local b2pos = b2.Position
                    local hitboxpos = hitbox.Position
                    local distance = (b2pos - hitboxpos).Magnitude

                    if distance <= hitbox.Size.Magnitude / 2 and b1 and b1.BrickColor == BrickColor.new("Really red") then
                        game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.F, false, game)
                        wait(0.1)
                        game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.F, false, game)
                    end
                end
            end

            lastvel = currentvel
            lastupdatetime = currenttime
        else
            hitbox.Size = Vector3.new(30, 30, 30)
        end
    end
end)

workspace.Balls.ChildAdded:Connect(updateballrefs)
workspace.Balls.ChildRemoved:Connect(updateballrefs)
