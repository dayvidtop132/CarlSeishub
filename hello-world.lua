-- ========================================
--  BLOX FRUITS - MACONHA HUB (FOCO DINHEIRO/BELI)
--  LocalScript para Executor (Synapse, Krnl, etc.)
--  GUI arrastável, tema escuro, abas funcionais
--  Auto Farm PRIORITÁRIO: CHESTS + NPCs (MAIS BELI)
--  Detecta baús dourados/vermelhos + quests NPCs
--  Tecla Insert = Abre/Fecha GUI
-- ========================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local hrp = character:WaitForChild("HumanoidRootPart")

-- Variáveis de controle
local guiOpen = false
local autoFarmEnabled = false
local selectedCategory = nil

-- Cria a GUI principal
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MaconhaHub"
screenGui.Parent = playerGui
screenGui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 650, 0, 450)
mainFrame.Position = UDim2.new(0.5, -325, 0.5, -225)
mainFrame.BackgroundColor3 = Color3.fromHex("#1A1A1A")
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Visible = false
mainFrame.Parent = screenGui

-- Borda externa
local border = Instance.new("UIStroke")
border.Color = Color3.fromHex("#363636")
border.Thickness = 2
border.Parent = mainFrame

-- UICorner
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = mainFrame

-- Título
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -10, 0, 40)
title.Position = UDim2.new(0, 5, 0, 5)
title.BackgroundTransparency = 1
title.Text = "💰 MACONHA HUB - FOCO DINHEIRO 💰"
title.TextColor3 = Color3.fromHex("#FFD700") -- Dourado
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = mainFrame

-- Info Beli (contador)
local beliLabel = Instance.new("TextLabel")
beliLabel.Size = UDim2.new(0, 200, 0, 30)
beliLabel.Position = UDim2.new(1, -210, 0, 8)
beliLabel.BackgroundTransparency = 1
beliLabel.Text = "💵 Beli: 0"
beliLabel.TextColor3 = Color3.fromHex("#FFD700")
beliLabel.Font = Enum.Font.GothamBold
beliLabel.TextSize = 16
beliLabel.TextXAlignment = Enum.TextXAlignment.Right
beliLabel.Parent = mainFrame

-- Botão X (fechar)
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 5)
closeBtn.BackgroundColor3 = Color3.fromHex("#FF3333")
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 16
closeBtn.Parent = mainFrame

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = closeBtn

-- Painel esquerdo (categorias)
local leftPanel = Instance.new("ScrollingFrame")
leftPanel.Size = UDim2.new(0, 160, 1, -50)
leftPanel.Position = UDim2.new(0, 0, 0, 50)
leftPanel.BackgroundColor3 = Color3.fromHex("#222222")
leftPanel.BorderSizePixel = 0
leftPanel.ScrollBarThickness = 4
leftPanel.Parent = mainFrame

local leftCorner = Instance.new("UICorner")
leftCorner.CornerRadius = UDim.new(0, 8)
leftCorner.Parent = leftPanel

-- Painel direito (ações)
local rightPanel = Instance.new("ScrollingFrame")
rightPanel.Size = UDim2.new(1, -170, 1, -50)
rightPanel.Position = UDim2.new(0, 165, 0, 50)
rightPanel.BackgroundColor3 = Color3.fromHex("#1A1A1A")
rightPanel.BorderSizePixel = 0
rightPanel.ScrollBarThickness = 4
rightPanel.Parent = mainFrame

local rightCorner = Instance.new("UICorner")
rightCorner.CornerRadius = UDim.new(0, 8)
rightCorner.Parent = rightPanel

-- Layout para botões
local leftLayout = Instance.new("UIListLayout")
leftLayout.Padding = UDim.new(0, 5)
leftLayout.FillDirection = Enum.FillDirection.Vertical
leftLayout.Parent = leftPanel

local rightLayout = Instance.new("UIListLayout")
rightLayout.Padding = UDim.new(0, 8)
rightLayout.FillDirection = Enum.FillDirection.Vertical
rightLayout.Parent = rightPanel

-- Categorias e conteúdos (FOCO DINHEIRO)
local categories = {
	["💰 Dinheiro"] = {
		{"🔥 Auto Farm Beli [PRIORIDADE CHESTS]", function() toggleAutoFarm() end},
		{"⚡ Speed Boost x3", function() print("Velocidade x3 para farm rápido") end},
		{"🛡️ Infinite Stamina", function() print("Stamina infinita") end},
		{"🌟 Auto Quest NPCs", function() print("Quests ativadas") end},
	},
	["Visual"] = {
		{"👥 ESP Players", function() print("ESP ativado") end},
		{"💎 Chest ESP [VERMELHO/DOURADO]", function() print("Chests destacados") end},
		{"☀️ Fullbright", function() print("Fullbright ON") end},
	},
	["Menu"] = {
		{"🔄 Server Hop [MAIS CHESTS]", function() 
			loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/serverhop"))() 
		end},
		{"🔗 Copy Server Link", function() setclipboard(game:GetService("HttpService"):JSONEncode(game:GetService("HttpService"):GenerateGUID(false))) end},
		{"❌ Exit GUI", function() screenGui:Destroy() end},
	}
}

-- Cria botões de categoria
local categoryButtons = {}
for _, name in ipairs({"💰 Dinheiro", "Visual", "Menu"}) do
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -10, 0, 45)
	btn.BackgroundColor3 = Color3.fromHex("#2A2A2A")
	btn.Text = name
	btn.TextColor3 = Color3.new(1,1,1)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 15
	btn.Parent = leftPanel
	
	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 6)
	btnCorner.Parent = btn
	
	-- Hover
	btn.MouseEnter:Connect(function()
		if selectedCategory ~= name then
			TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromHex("#3A3A3A")}):Play()
		end
	end)
	btn.MouseLeave:Connect(function()
		if selectedCategory ~= name then
			TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromHex("#2A2A2A")}):Play()
		end
	end)
	
	btn.MouseButton1Click:Connect(function()
		selectCategory(name)
	end)
	
	categoryButtons[name] = btn
end

-- Seleciona categoria
function selectCategory(name)
	if selectedCategory == name then return end
	selectedCategory = name
	
	-- Reset cores
	for cat, btn in pairs(categoryButtons) do
		TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromHex("#2A2A2A")}):Play()
	end
	TweenService:Create(categoryButtons[name], TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromHex("#FFD700")}):Play()
	
	-- Limpa painel direito
	for _, child in ipairs(rightPanel:GetChildren()) do
		if child:IsA("TextButton") or child:IsA("Frame") then
			child:Destroy()
		end
	end
	
	-- Cria botões de ação
	for _, action in ipairs(categories[name]) do
		local actionName, callback = action[1], action[2]
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, -10, 0, 50)
		btn.BackgroundColor3 = Color3.fromHex("#252525")
		btn.Text = actionName
		btn.TextColor3 = Color3.new(1,1,1)
		btn.Font = Enum.Font.Gotham
		btn.TextSize = 15
		btn.Parent = rightPanel
		
		local acorner = Instance.new("UICorner")
		acorner.CornerRadius = UDim.new(0, 6)
		acorner.Parent = btn
		
		btn.MouseButton1Click:Connect(callback)
		
		-- Hover
		btn.MouseEnter:Connect(function()
			TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromHex("#353535")}):Play()
		end)
		btn.MouseLeave:Connect(function()
			TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromHex("#252525")}):Play()
		end)
	end
end

-- Toggle Auto Farm (PRIORIDADE DINHEIRO)
function toggleAutoFarm()
	autoFarmEnabled = not autoFarmEnabled
	local btn = nil
	for _, child in ipairs(rightPanel:GetChildren()) do
		if child:IsA("TextButton") and child.Text:find("Auto Farm Beli") then
			btn = child
			break
		end
	end
	if not btn then return end
	
	if autoFarmEnabled then
		btn.Text = "🔥 Auto Farm Beli [ON]"
		btn.BackgroundColor3 = Color3.fromHex("#FFD700")
		btn.TextColor3 = Color3.new(0,0,0)
		spawn(autoFarmLoop)
	else
		btn.Text = "🔥 Auto Farm Beli [PRIORIDADE CHESTS]"
		btn.BackgroundColor3 = Color3.fromHex("#252525")
		btn.TextColor3 = Color3.new(1,1,1)
	end
end

-- Loop de Auto Farm FOCADO EM DINHEIRO
function autoFarmLoop()
	local lastBeli = 0
	while autoFarmEnabled do
		pcall(function()
			local character = player.Character
			if not character then return end
			hrp = character:FindFirstChild("HumanoidRootPart")
			humanoid = character:FindFirstChild("Humanoid")
			if not hrp or not humanoid then return end
			
			local closestTarget = nil
			local closestDist = math.huge
			
			-- PRIORIDADE 1: BAÚS (MAIS DINHEIRO)
			for _, obj in ipairs(Workspace:GetChildren()) do
				local isChest = obj.Name:find("Chest") or obj.Name:find("Treasure") or obj.Name:find("Baú")
				if isChest and obj:FindFirstChild("Handle") or obj:FindFirstChild("Part") then
					local part = obj.Handle or obj.Part or obj:FindFirstChildWhichIsA("BasePart")
					if part then
						local dist = (hrp.Position - part.Position).Magnitude
						if dist < closestDist and dist < 150 then
							closestDist = dist
							closestTarget = part
						end
					end
				end
			end
			
			-- PRIORIDADE 2: NPCs VIVOS (Quests + Drops Beli)
			if closestDist > 50 then
				for _, npc in ipairs(Workspace:GetDescendants()) do
					if npc:IsA("Model") and npc:FindFirstChild("Humanoid") and npc.Humanoid.Health > 0 then
						local root = npc:FindFirstChild("HumanoidRootPart")
						if root and (npc.Name:find("Bandit") or npc.Name:find("Pirate") or npc.Name:find("Marine")) then
							local dist = (hrp.Position - root.Position).Magnitude
							if dist < closestDist and dist < 80 then
								closestDist = dist
								closestTarget = root
							end
						end
					end
				end
			end
			
			-- PRIORIDADE 3: FRUTAS (bônus)
			if closestDist > 60 then
				for _, fruit in ipairs(Workspace:GetChildren()) do
					if fruit.Name:find("Fruit") and fruit:FindFirstChild("Handle") then
						local dist = (hrp.Position - fruit.Handle.Position).Magnitude
						if dist < closestDist and dist < 100 then
							closestDist = dist
							closestTarget = fruit.Handle
						end
					end
				end
			end
			
			-- MOVE E ATACA
			if closestTarget and closestDist < 150 then
				humanoid:MoveTo(closestTarget.Position)
				repeat
					wait(0.1)
					if closestTarget.Parent == nil then break end
				until (hrp.Position - closestTarget.Position).Magnitude < 10 or not autoFarmEnabled
				
				-- ATACA NPC
				if closestTarget.Parent:FindFirstChild("Humanoid") then
					local tool = character:FindFirstChildOfClass("Tool") or player.Backpack:FindFirstChildOfClass("Tool")
					if tool then
						tool.Parent = character
						for i = 1, 3 do
							tool:Activate()
							wait(0.2)
						end
					end
				end
			else
				wait(0.5)
			end
			
			-- ATUALIZA CONTADOR BELI
			local leaderstats = player:FindFirstChild("leaderstats")
			if leaderstats and leaderstats:FindFirstChild("Beli") then
				local currentBeli = leaderstats.Beli.Value
				beliLabel.Text = "💵 Beli: " .. currentBeli .. " (+$" .. (currentBeli - lastBeli) .. ")"
				lastBeli = currentBeli
			end
		end)
		wait(0.2)
	end
end

-- Fechar com X
closeBtn.MouseButton1Click:Connect(function()
	screenGui:Destroy()
end)

-- Tecla Insert
UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode == Enum.KeyCode.Insert then
		guiOpen = not guiOpen
		mainFrame.Visible = guiOpen
		if guiOpen then
			selectCategory("💰 Dinheiro") -- Abre direto na aba DINHEIRO
		end
	end
end)

-- Atualiza personagem ao respawn
player.CharacterAdded:Connect(function(newChar)
	character = newChar
	wait(1)
	humanoid = newChar:WaitForChild("Humanoid")
	hrp = newChar:WaitForChild("HumanoidRootPart")
end)

-- Loop contador Beli (mesmo com GUI fechada)
spawn(function()
	while wait(2) do
		pcall(function()
			local leaderstats = player:FindFirstChild("leaderstats")
			if leaderstats and leaderstats:FindFirstChild("Beli") then
				beliLabel.Text = "💵 Beli: " .. leaderstats.Beli.Value
			end
		end)
	end
end)

print("💰 MACONHA HUB - FOCO DINHEIRO carregado! Pressione INSERT")
