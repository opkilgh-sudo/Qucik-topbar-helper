local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = game:GetService("Players").LocalPlayer
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")

-- ตัวแปรเก็บสถานะการเปิด/ปิด (เปลี่ยนค่าเป็น true เพื่อเปิด หรือ false เพื่อปิด)
getgenv().AutoTrickEnabled = false

local u90 = not (UserInputService.KeyboardEnabled and UserInputService.MouseEnabled) and "Mobile" or "PC"
local Behavior = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Survivors"):WaitForChild("Veeronica"):WaitForChild("Behavior")
local GetDescendants = Behavior.GetDescendants

local function v93()
    return LocalPlayer.PlayerGui:WaitForChild("MainUI"):WaitForChild("SprintingButton")
end

local t2 = {}

local function v95(p11)
    if not p11 or t2[p11] then
        return
    end

    local t3 = {}

    local function v260()
        for _, v in ipairs(t3) do
            if v and v.Connected then
                v:Disconnect()
            end
        end
        t2[p11] = nil
    end

    local function v261()
        -- เช็คก่อนว่าฟังก์ชันถูกเปิดใช้งานอยู่หรือไม่
        if not getgenv().AutoTrickEnabled then
            return
        end

        if not p11.Parent then
            v260()
            return
        end

        local p11Adornee = p11.Adornee
        local Character = LocalPlayer.Character

        if not (not p11Adornee or not Character) and (p11Adornee == Character or p11Adornee:IsDescendantOf(Character)) and true then
            if u90 == "Mobile" then
                local ok, result = pcall(v93)

                if ok and result then
                    for _, v in pairs(getconnections(result.MouseButton1Down)) do
                        local v367 = v

                        pcall(function()
                            v367:Fire()
                        end)
                        pcall(function()
                            if v367.Function then
                                v367:Function()
                            end
                        end)
                    end

                    return
                end
            elseif u90 == "PC" then
                pcall(function()
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
                    task.wait()
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
                end)
            end
        end
    end

    table.insert(t3, p11:GetPropertyChangedSignal("Adornee"):Connect(v261))
    table.insert(t3, p11.AncestryChanged:Connect(function(_, parent)
        if not parent then
            v260()
            return
        end
        v261()
    end))
    table.insert(t3, LocalPlayer.CharacterAdded:Connect(v261))
    t2[p11] = v260
    task.spawn(v261)
end

-- ฟังก์ชันสำหรับสั่งเปิดการทำงาน
local function StartAutoTrick()
    getgenv().AutoTrickEnabled = true

    for _, v in ipairs(GetDescendants(Behavior)) do
        if v:IsA("Highlight") then
            v95(v)
        end
    end

    if not getgenv().AutoTrickConnection then
        getgenv().AutoTrickConnection = Behavior.DescendantAdded:Connect(function(descendant)
            if getgenv().AutoTrickEnabled and descendant:IsA("Highlight") then
                v95(descendant)
            end
        end)
    end
end

-- ฟังก์ชันสำหรับสั่งปิดการทำงานและเคลียร์ระบบ
local function StopAutoTrick()
    getgenv().AutoTrickEnabled = false

    if getgenv().AutoTrickConnection then
        getgenv().AutoTrickConnection:Disconnect()
        getgenv().AutoTrickConnection = nil
    end

    for _, v in pairs(t2) do
        v()
    end

    table.clear(t2)
end

-- วิธีใช้งาน:
-- เปิดใช้งาน: StartAutoTrick()
-- ปิดใช้งาน: StopAutoTrick()
  
