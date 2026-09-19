local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = game:GetService("Players").LocalPlayer
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")

local deviceType = not (UserInputService.KeyboardEnabled and UserInputService.MouseEnabled) and "Mobile" or "PC"
local behaviorFolder = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Survivors"):WaitForChild("Veeronica"):WaitForChild("Behavior")
local getDescendantsFunc = behaviorFolder.GetDescendants

local function getSprintButton()
    return LocalPlayer.PlayerGui:WaitForChild("MainUI"):WaitForChild("SprintingButton")
end

local activeHighlights = {}

local function setupHighlight(highlightObj)
    if not highlightObj or activeHighlights[highlightObj] then
        return
    end

    local connectionsList = {}

    local function cleanupHighlight()
        for _, connection in ipairs(connectionsList) do
            if connection and connection.Connected then
                connection:Disconnect()
            end
        end
        activeHighlights[highlightObj] = nil
    end

    local function processHighlight()
        -- ถ้าสคริปต์ถูกปิดการทำงานแล้ว ให้หยุดทำงานทันที
        if getgenv().VeeronicaAutoTrickStopped then
            return
        end

        if not highlightObj.Parent then
            cleanupHighlight()
            return
        end

        local adorneeTarget = highlightObj.Adornee
        local character = LocalPlayer.Character

        if not (not adorneeTarget or not character) and (adorneeTarget == character or adorneeTarget:IsDescendantOf(character)) and true then
            if deviceType == "Mobile" then
                local success, sprintBtn = pcall(getSprintButton)

                if success and sprintBtn then
                    for _, conn in pairs(getconnections(sprintBtn.MouseButton1Down)) do
                        local currentConn = conn

                        pcall(function()
                            currentConn:Fire()
                        end)
                        pcall(function()
                            if currentConn.Function then
                                currentConn:Function()
                            end
                        end)
                    end

                    return
                end
            elseif deviceType == "PC" then
                pcall(function()
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
                    task.wait()
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
                end)
            end
        end
    end

    table.insert(connectionsList, highlightObj:GetPropertyChangedSignal("Adornee"):Connect(processHighlight))
    table.insert(connectionsList, highlightObj.AncestryChanged:Connect(function(_, parent)
        if not parent then
            cleanupHighlight()
            return
        end
        processHighlight()
    end))
    table.insert(connectionsList, LocalPlayer.CharacterAdded:Connect(processHighlight))
    activeHighlights[highlightObj] = cleanupHighlight
    task.spawn(processHighlight)
end

-- เริ่มต้นการทำงานของ Auto Trick
getgenv().VeeronicaAutoTrickStopped = false

for _, v in ipairs(getDescendantsFunc(behaviorFolder)) do
    if v:IsA("Highlight") then
        setupHighlight(v)
    end
end

if not getgenv().VeeronicaDescendantConn then
    getgenv().VeeronicaDescendantConn = behaviorFolder.DescendantAdded:Connect(function(descendant)
        if not getgenv().VeeronicaAutoTrickStopped and descendant:IsA("Highlight") then
            setupHighlight(descendant)
        end
    end)
end

-- ฟังก์ชันเคลียร์ค่าเมื่อปิดการใช้งาน (ผูกกับตอนกดปิดปุ่ม Topbar ได้)
getgenv().StopVeeronicaScript = function()
    getgenv().VeeronicaAutoTrickStopped = true

    if getgenv().VeeronicaDescendantConn then
        getgenv().VeeronicaDescendantConn:Disconnect()
        getgenv().VeeronicaDescendantConn = nil
    end

    for _, cleanupFunc in pairs(activeHighlights) do
        cleanupFunc()
    end

    table.clear(activeHighlights)
end
