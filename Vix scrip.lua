-- Vix Hub com Fluent UI - Versão Limpa
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Vix brainrot",
    SubTitle = "criado por Vix scripter",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- Notificação inicial
Fluent:Notify({
    Title = "Hub carregado!",
    Content = "Todas as funcionalidades foram carregadas com sucesso!",
    Duration = 3
})

-- Combat Tab
local CombatTab = Window:AddTab({ 
    Title = "Combat", 
    Icon = "sword"
})

-- Variáveis globais
local godmodeConnection = nil
local originalHealth = nil

-- Godmode Toggle
local GodmodeToggle = CombatTab:AddToggle("Godmode", {
    Title = "Godmode",
    Description = "Torna você invencível",
    Default = false,
    Callback = function(Value)
        local player = game.Players.LocalPlayer
        local character = player.Character
        
        if not character then 
            Fluent:Notify({
                Title = "Erro",
                Content = "Personagem não encontrado!",
                Duration = 2
            })
            return 
        end
        
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid then return end
        
        if Value then
            -- Salvar vida original
            originalHealth = humanoid.MaxHealth
            
            -- Ativar godmode
            humanoid.MaxHealth = math.huge
            humanoid.Health = math.huge
            
            -- Conexão para manter vida infinita
            godmodeConnection = humanoid.HealthChanged:Connect(function()
                if humanoid.Health < math.huge then
                    humanoid.Health = math.huge
                end
            end)
            
            Fluent:Notify({
                Title = "Godmode",
                Content = "Ativado com sucesso!",
                Duration = 2
            })
        else
            -- Desativar godmode
            if godmodeConnection then
                godmodeConnection:Disconnect()
                godmodeConnection = nil
            end
            
            -- Restaurar vida normal
            local restoreHealth = originalHealth or 100
            humanoid.MaxHealth = restoreHealth
            humanoid.Health = restoreHealth
            
            Fluent:Notify({
                Title = "Godmode",
                Content = "Desativado!",
                Duration = 2
            })
        end
    end,
})

-- Movimentação Tab
local MovementTab = Window:AddTab({
    Title = "Movimentação",
    Icon = "zap"
})

-- Variáveis de movimento
local jumpConnection = nil
local speedConnection = nil
local currentSpeed = 16
local speedActive = false

-- Pulos Infinitos
local InfiniteJumpToggle = MovementTab:AddToggle("InfiniteJump", {
    Title = "Pulos Infinitos",
    Description = "Permite pular infinitamente no ar",
    Default = false,
    Callback = function(Value)
        if Value then
            jumpConnection = game:GetService("UserInputService").JumpRequest:Connect(function()
                local player = game.Players.LocalPlayer
                if player.Character and player.Character:FindFirstChild("Humanoid") then
                    local humanoid = player.Character.Humanoid
                    if humanoid:GetState() ~= Enum.HumanoidStateType.Seated then
                        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                    end
                end
            end)
            
            Fluent:Notify({
                Title = "Pulos Infinitos",
                Content = "Ativado!",
                Duration = 2
            })
        else
            if jumpConnection then
                jumpConnection:Disconnect()
                jumpConnection = nil
            end
            
            Fluent:Notify({
                Title = "Pulos Infinitos",
                Content = "Desativado!",
                Duration = 2
            })
        end
    end
})

-- Toggle Speed
local SpeedToggle = MovementTab:AddToggle("Speed", {
    Title = "Speed Personalizado",
    Description = "Ativa velocidade personalizada",
    Default = false,
    Callback = function(Value)
        speedActive = Value
        local player = game.Players.LocalPlayer
        
        if Value then
            local function applySpeed()
                local character = player.Character
                if character then
                    local humanoid = character:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        humanoid.WalkSpeed = currentSpeed
                    end
                end
            end
            
            applySpeed()
            
            speedConnection = game:GetService("RunService").Heartbeat:Connect(function()
                if speedActive then
                    applySpeed()
                end
            end)
            
            Fluent:Notify({
                Title = "Speed",
                Content = "Ativado! Velocidade: " .. currentSpeed,
                Duration = 2
            })
        else
            if speedConnection then
                speedConnection:Disconnect()
                speedConnection = nil
            end
            
            local character = player.Character
            if character then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.WalkSpeed = 16
                end
            end
            
            Fluent:Notify({
                Title = "Speed",
                Content = "Desativado!",
                Duration = 2
            })
        end
    end
})

-- Slider de Velocidade
local SpeedSlider = MovementTab:AddSlider("SpeedValue", {
    Title = "Velocidade",
    Description = "Ajusta a velocidade de caminhada",
    Default = 16,
    Min = 16,
    Max = 200,
    Rounding = 1,
    Callback = function(Value)
        currentSpeed = Value
        
        if speedActive then
            local player = game.Players.LocalPlayer
            local character = player.Character
            if character then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.WalkSpeed = currentSpeed
                end
            end
        end
    end
})

-- Botão Fly
local FlyButton = MovementTab:AddButton({
    Title = "Fly Temporário",
    Description = "Voa por 3 segundos na direção da câmera",
    Callback = function()
        local player = game.Players.LocalPlayer
        local character = player.Character
        
        if not character or not character:FindFirstChild("HumanoidRootPart") then
            Fluent:Notify({
                Title = "Erro",
                Content = "Personagem não encontrado!",
                Duration = 2
            })
            return
        end
        
        local hrp = character.HumanoidRootPart
        local cam = workspace.CurrentCamera
        
        local bv = Instance.new("BodyVelocity")
        local bg = Instance.new("BodyGyro")
        
        bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
        bv.Velocity = Vector3.new(0, 0, 0)
        bv.Parent = hrp
        
        bg.MaxTorque = Vector3.new(4e5, 4e5, 4e5)
        bg.CFrame = cam.CFrame
        bg.Parent = hrp
        
        local flying = true
        local startTime = tick()
        
        spawn(function()
            while flying do
                bv.Velocity = cam.CFrame.LookVector * 50
                bg.CFrame = cam.CFrame
                if tick() - startTime > 3 then
                    flying = false
                end
                wait(0.1)
            end
            
            if bv then bv:Destroy() end
            if bg then bg:Destroy() end
        end)
        
        Fluent:Notify({
            Title = "Fly",
            Content = "Voando por 3 segundos!",
            Duration = 2
        })
    end,
})

-- Habilidades Tab
local UtilityTab = Window:AddTab({
    Title = "Habilidades",
    Icon = "settings"
})

-- Variáveis da plataforma
local platform = nil
local platformHeight = 6
local platformFollowRun = nil
local platformSpawned = false

-- Toggle Plataforma
local PlatformToggle = UtilityTab:AddToggle("Platform", {
    Title = "Plataforma Móvel",
    Description = "Cria uma plataforma que te segue",
    Default = false,
    Callback = function(Value)
        local player = game.Players.LocalPlayer
        local character = player.Character
        
        if Value and not platformSpawned then
            platformSpawned = true
            
            if not platform or not platform.Parent then
                -- Criar plataforma
                platform = Instance.new("Part")
                platform.Size = Vector3.new(12, 1.5, 12)
                platform.Name = "VixPlatform"
                platform.Anchored = true
                platform.CanCollide = true
                platform.Material = Enum.Material.ForceField
                platform.BrickColor = BrickColor.new("Cyan")
                platform.Shape = Enum.PartType.Block
                platform.TopSurface = Enum.SurfaceType.Smooth
                platform.BottomSurface = Enum.SurfaceType.Smooth
                
                -- Efeito neon
                local neonPart = Instance.new("Part")
                neonPart.Size = Vector3.new(12.2, 1.7, 12.2)
                neonPart.Material = Enum.Material.Neon
                neonPart.BrickColor = BrickColor.new("Electric blue")
                neonPart.Shape = Enum.PartType.Block
                neonPart.Anchored = true
                neonPart.CanCollide = false
                neonPart.Name = "NeonGlow"
                neonPart.Parent = platform
                
                if character and character:FindFirstChild("HumanoidRootPart") then
                    local hrp = character.HumanoidRootPart
                    local pos = hrp.Position
                    local offsetY = (hrp.Size.Y/2) + (platform.Size.Y/2) + platformHeight
                    platform.Position = Vector3.new(pos.X, pos.Y - offsetY, pos.Z)
                    neonPart.Position = platform.Position
                    platform.Parent = workspace
                    
                    -- Sistema de seguir com animações avançadas
                    platformFollowRun = game:GetService("RunService").Heartbeat:Connect(function()
                        if character and character.Parent and platform and platform.Parent then
                            local hrpPos = hrp.Position
                            local targetPos = Vector3.new(hrpPos.X, platform.Position.Y, hrpPos.Z)
                            
                            -- Movimento suave
                            platform.Position = platform.Position:lerp(targetPos, 0.1)
                            neonPart.Position = platform.Position
                            
                            -- Rotações complexas para efeito visual
                            platform.Rotation = Vector3.new(
                                math.sin(tick() * 2) * 5, -- Balanço suave no X
                                platform.Rotation.Y + 1, -- Rotação constante no Y
                                math.cos(tick() * 1.5) * 3 -- Balanço suave no Z
                            )
                            
                            neonPart.Rotation = Vector3.new(
                                -math.sin(tick() * 1.5) * 3,
                                neonPart.Rotation.Y - 0.7,
                                math.cos(tick() * 2) * 2
                            )
                            
                            -- Animação de pulsação no brilho
                            local pulseValue = (math.sin(tick() * 3) + 1) * 0.5 -- 0 a 1
                            pointLight.Brightness = 3 + (pulseValue * 3) -- 3 a 6
                            
                            -- Mudança de cor cíclica
                            local hue = (tick() * 0.5) % 1
                            local color = Color3.fromHSV(hue, 0.8, 1)
                            neonPart.Color = color
                            pointLight.Color = color
                            
                            -- Animação de escala sutil
                            local scaleVariation = 1 + (math.sin(tick() * 2) * 0.05) -- Variação de 5%
                            neonPart.Size = Vector3.new(12.2 * scaleVariation, 1.7, 12.2 * scaleVariation)
                        end
                    end)
                end
            end
            
            Fluent:Notify({
                Title = "Plataforma",
                Content = "Plataforma criada!",
                Duration = 2
            })
        else
            platformSpawned = false
            
            if platform and platform.Parent then
                local tween = game:GetService("TweenService"):Create(
                    platform,
                    TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                    {Transparency = 1, Size = Vector3.new(0.1, 0.1, 0.1)}
                )
                tween:Play()
                
                tween.Completed:Connect(function()
                    platform:Destroy()
                    platform = nil
                end)
            end
            
            if platformFollowRun then
                platformFollowRun:Disconnect()
                platformFollowRun = nil
            end
            
            Fluent:Notify({
                Title = "Plataforma",
                Content = "Plataforma removida!",
                Duration = 2
            })
        end
    end,
})

-- Botões da plataforma
local PlatformUpButton = UtilityTab:AddButton({
    Title = "⬆️ Subir Plataforma",
    Description = "Move a plataforma para cima",
    Callback = function()
        if platform and platform.Parent then
            platformHeight = platformHeight - 1
            if platformHeight < 1 then platformHeight = 1 end
            
            local player = game.Players.LocalPlayer
            local character = player.Character
            
            if character and character:FindFirstChild("HumanoidRootPart") then
                local hrp = character.HumanoidRootPart
                local pos = hrp.Position
                local offsetY = (hrp.Size.Y/2) + (platform.Size.Y/2) + platformHeight
                local targetY = pos.Y - offsetY
                
                local tween = game:GetService("TweenService"):Create(
                    platform,
                    TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                    {Position = Vector3.new(platform.Position.X, targetY, platform.Position.Z)}
                )
                tween:Play()
                
                local neonPart = platform:FindFirstChild("NeonGlow")
                if neonPart then
                    local neonTween = game:GetService("TweenService"):Create(
                        neonPart,
                        TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                        {Position = Vector3.new(neonPart.Position.X, targetY, neonPart.Position.Z)}
                    )
                    neonTween:Play()
                end
            end
        end
    end,
})

local PlatformDownButton = UtilityTab:AddButton({
    Title = "⬇️ Descer Plataforma", 
    Description = "Move a plataforma para baixo",
    Callback = function()
        if platform and platform.Parent then
            platformHeight = platformHeight + 1
            
            local player = game.Players.LocalPlayer
            local character = player.Character
            
            if character and character:FindFirstChild("HumanoidRootPart") then
                local hrp = character.HumanoidRootPart
                local pos = hrp.Position
                local offsetY = (hrp.Size.Y/2) + (platform.Size.Y/2) + platformHeight
                local targetY = pos.Y - offsetY
                
                local tween = game:GetService("TweenService"):Create(
                    platform,
                    TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                    {Position = Vector3.new(platform.Position.X, targetY, platform.Position.Z)}
                )
                tween:Play()
                
                local neonPart = platform:FindFirstChild("NeonGlow")
                if neonPart then
                    local neonTween = game:GetService("TweenService"):Create(
                        neonPart,
                        TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                        {Position = Vector3.new(neonPart.Position.X, targetY, neonPart.Position.Z)}
                    )
                    neonTween:Play()
                end
            end
        end
    end,
})

-- Anti-AFK
local AntiAFKToggle = UtilityTab:AddToggle("AntiAFK", {
    Title = "Anti-AFK",
    Description = "Evita ser kickado por inatividade",
    Default = false,
    Callback = function(Value)
        local player = game.Players.LocalPlayer
        local connection
        
        if Value then
            connection = player.Idled:Connect(function()
                local vu = game:GetService("VirtualUser")
                vu:Button2Down(Vector2.new(0,0))
                wait(1)
                vu:Button2Up(Vector2.new(0,0))
                
                Fluent:Notify({
                    Title = "Anti-AFK",
                    Content = "Atividade simulada!",
                    Duration = 1
                })
            end)
        else
            if connection then
                connection:Disconnect()
                connection = nil
            end
        end
    end,
})

-- Teleporte Tab
local TeleportTab = Window:AddTab({
    Title = "Teleportes",
    Icon = "map-pin"
})

-- Sistema de teleporte seguro
local function safeTeleport(targetPosition)
    local player = game.Players.LocalPlayer
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        return false
    end
    
    local hrp = character.HumanoidRootPart
    hrp.CFrame = CFrame.new(targetPosition)
    return true
end

-- Variáveis de coordenadas
local xInput, yInput, zInput = 0, 0, 0

-- Inputs de coordenadas
local XInput = TeleportTab:AddInput("CoordX", {
    Title = "Coordenada X",
    Description = "Digite a coordenada X",
    Default = "0",
    Placeholder = "Ex: 100",
    Numeric = true,
    Callback = function(Value)
        xInput = tonumber(Value) or 0
    end
})

local YInput = TeleportTab:AddInput("CoordY", {
    Title = "Coordenada Y",
    Description = "Digite a coordenada Y", 
    Default = "0",
    Placeholder = "Ex: 50",
    Numeric = true,
    Callback = function(Value)
        yInput = tonumber(Value) or 0
    end
})

local ZInput = TeleportTab:AddInput("CoordZ", {
    Title = "Coordenada Z",
    Description = "Digite a coordenada Z",
    Default = "0", 
    Placeholder = "Ex: -200",
    Numeric = true,
    Callback = function(Value)
        zInput = tonumber(Value) or 0
    end
})

-- Botão teleporte por coordenadas
local TeleportButton = TeleportTab:AddButton({
    Title = "🚀 Teleportar",
    Description = "Teleporta para as coordenadas inseridas",
    Callback = function()
        local targetPos = Vector3.new(xInput, yInput, zInput)
        if safeTeleport(targetPos) then
            Fluent:Notify({
                Title = "Teleporte",
                Content = "Teleportado para: " .. tostring(targetPos),
                Duration = 2
            })
        else
            Fluent:Notify({
                Title = "Erro",
                Content = "Falha no teleporte!",
                Duration = 2
            })
        end
    end,
})

-- Teleporte para spawn
local SpawnButton = TeleportTab:AddButton({
    Title = "🏠 Ir para Spawn",
    Description = "Teleporta para o spawn do jogo",
    Callback = function()
        local spawnLocation = workspace:FindFirstChild("SpawnLocation")
        local targetPos = Vector3.new(0, 50, 0)
        
        if spawnLocation then
            targetPos = spawnLocation.Position + Vector3.new(0, 5, 0)
        end
        
        if safeTeleport(targetPos) then
            Fluent:Notify({
                Title = "Teleporte",
                Content = "Teleportado para o spawn!",
                Duration = 2
            })
        end
    end,
})

-- Inicializar interface
Window:SelectTab(1)

print("🎯 Vix Hub carregado com sucesso!")
print("🔧 Versão: Fluent UI Clean")
print("⚡ Todas as funcionalidades ativas!")
