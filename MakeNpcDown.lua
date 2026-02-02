_G.Radius = 19

local p = game.Players.LocalPlayer
local RS = game:GetService("RunService")

-- 1. FIX LAG: MATIIN LOOP LAMA KALO LU RE-EXECUTE
if _G.RebahConnection then
    _G.RebahConnection:Disconnect()
end

local function Aura()
    local c = p.Character or p.CharacterAdded:Wait()
    local hrp = c:WaitForChild("HumanoidRootPart")

    -- 2. SIMPEN KE VARIABEL GLOBAL BIAR BISA DI-CLEANUP
    _G.RebahConnection = RS.Heartbeat:Connect(function()
        if not c or not c.Parent then return end
        
        -- Noclip (Ringan)
        for _, v in pairs(c:GetChildren()) do
            if v:IsA("BasePart") and v.CanCollide then v.CanCollide = false end
        end

        p.SimulationRadius = math.huge
        
        -- 3. OPTIMASI: INI BAGIAN YANG BIKIN GAK LAG (Pake task.wait biar RAM 2GB nafas)
        for _, v in pairs(workspace:GetDescendants()) do
            -- Biar gak nge-freeze pas scan ribuan objek
            if _ % 100 == 0 then task.wait() end 

            if v:IsA("Humanoid") and not v.Parent:IsAncestorOf(c) and not game.Players:GetPlayerFromCharacter(v.Parent) then
                local mHRP = v.Parent:FindFirstChild("HumanoidRootPart") or v.Parent:FindFirstChild("Torso")
                if mHRP then
                    local dist = (hrp.Position - mHRP.Position).Magnitude
                    if dist < _G.Radius then
                        v.PlatformStand = true
                        if not mHRP:FindFirstChild("RebahGyro") then
                            local bg = Instance.new("BodyGyro", mHRP)
                            bg.Name = "RebahGyro"
                            bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                            bg.P = 3000
                            bg.CFrame = mHRP.CFrame * CFrame.Angles(math.rad(-90), 0, 0)
                            
                            local bv = Instance.new("BodyVelocity", mHRP)
                            bv.Name = "RebahVel"
                            bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                            bv.Velocity = Vector3.new(0, -5, 0)
                        end
                    else
                        if mHRP:FindFirstChild("RebahGyro") then
                            mHRP.RebahGyro:Destroy()
                            mHRP.RebahVel:Destroy()
                            v.PlatformStand = false
                        end
                    end
                end
            end
        end
    end)
end

-- 4. AUTO EXECUTE: JALAN PAS RESPOND / PINDAH MAP
p.CharacterAdded:Connect(Aura)
task.spawn(Aura)

print("Aura Rebah Aktif & Anti-Lag Ready.")
