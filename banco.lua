
local function getNilRemote() 
    for _, v in next, getnilinstances() do 
        if v:IsA("RemoteEvent") and (v.Name == "RemoteEvent" or v.Name == "ClientBanker") then return v end 
    end 
    return game:GetService("ReplicatedStorage"):FindFirstChild("ClientBanker", true)
end

local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local MainFrame = Instance.new("Frame", ScreenGui)
local TitleLabel = Instance.new("TextLabel", MainFrame)
local UIList = Instance.new("UIListLayout", MainFrame)
local AddBtn = Instance.new("TextButton", MainFrame)
local RemoveBtn = Instance.new("TextButton", MainFrame)

MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
MainFrame.Size = UDim2.new(0, 180, 0, 110)
MainFrame.Active = true
MainFrame.Draggable = true

UIList.Padding = UDim.new(0, 5)
UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIList.VerticalAlignment = Enum.VerticalAlignment.Center

local function styleBtn(btn, text)
    btn.Size = UDim2.new(0.9, 0, 0, 45)
    btn.Text = text
    btn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 14
end

styleBtn(AddBtn, "AUTO-AÑADIR: OFF")
styleBtn(RemoveBtn, "AUTO-SACAR: OFF")

_G.AutoAdd = false
_G.AutoRemove = false

local function runAutoAdd()
    print("Iniciando")
    while _G.AutoAdd do
        local player = game.Players.LocalPlayer
        local char = player.Character
        local pGui = player.PlayerGui

        local tool = (char and char:FindFirstChildOfClass("Tool")) or player.Backpack:FindFirstChildOfClass("Tool")
        
        if tool then
            local options = pGui:FindFirstChild("NPCDialogue") and pGui.NPCDialogue.BG.Options
            if options then
                local depositBtn = options:GetChildren()[3]
                if depositBtn and depositBtn:IsA("GuiButton") then
                    pcall(function()
                        for _, c in pairs(getconnections(depositBtn.MouseButton1Click)) do c:Fire() end
                    end)
                end
            end
            
            if tool.Parent ~= char then
                tool.Parent = char
                task.wait(0.3)
            end

            local remote = getNilRemote()
            if remote then
                print("Añadiendo al banco: " .. tool.Name)
                remote:FireServer(Instance.new("TextButton", nil))
            end
        end
        task.wait(0.8)
    end
end


local function runAutoRemove()
    local player = game.Players.LocalPlayer
    local clientBanker = game:GetService("ReplicatedStorage").Remotes.West.ClientBanker
    
    print("Bucle de Retiro Activado")
    while _G.AutoRemove do
        local bankFrame = player.PlayerGui:FindFirstChild("NewBankUI") and player.PlayerGui.NewBankUI.Background.BankFrame.Frame
        
        if bankFrame then
            local items = bankFrame:GetChildren()
            local found = false
            
            for _, itemUI in pairs(items) do
                if not _G.AutoRemove then break end
                if itemUI:IsA("GuiObject") and itemUI.Name ~= "UIListLayout" then
                    found = true
                    local itemName = itemUI.Name
                    if itemUI:FindFirstChild("ItemName") then itemName = itemUI.ItemName.Text end
                    
                    print("Sacando: " .. itemName)
                    clientBanker:FireServer("RemoveItem", {["itemPos"] = 1, ["itemName"] = itemName})
                    task.wait(0.5)
                end
            end
            if not found then task.wait(1) end
        end
        task.wait(0.5)
    end
end

AddBtn.MouseButton1Click:Connect(function()
    _G.AutoAdd = not _G.AutoAdd
    AddBtn.Text = _G.AutoAdd and "AUTO-AÑADIR: ON" or "AUTO-AÑADIR: OFF"
    AddBtn.BackgroundColor3 = _G.AutoAdd and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
    if _G.AutoAdd then task.spawn(runAutoAdd) end
end)

RemoveBtn.MouseButton1Click:Connect(function()
    _G.AutoRemove = not _G.AutoRemove
    RemoveBtn.Text = _G.AutoRemove and "AUTO-SACAR: ON" or "AUTO-SACAR: OFF"
    RemoveBtn.BackgroundColor3 = _G.AutoRemove and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
    if _G.AutoRemove then task.spawn(runAutoRemove) end
end)
