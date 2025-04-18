local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
    Name = "Powerby : CodeX HUB : Arise_Crossover",
    Icon = 0, -- Icon in Topbar. Can use Lucide Icons (string) or Roblox Image (number). 0 to use no icon (default).
    LoadingTitle = "CodeX HUB",
    LoadingSubtitle = "by CodeX",
    Theme = "Default", -- Check https://docs.sirius.menu/rayfield/configuration/themes
 
    DisableRayfieldPrompts = false,
    DisableBuildWarnings = false, -- Prevents Rayfield from warning when the script has a version mismatch with the interface
 
    ConfigurationSaving = {
       Enabled = true,
       FolderName = nil, -- Create a custom folder for your hub/game
       FileName = "Big Hub"
    },
 
    Discord = {
       Enabled = false, -- Prompt the user to join your Discord server if their executor supports it
       Invite = "noinvitelink", -- The Discord invite code, do not include discord.gg/. E.g. discord.gg/ ABCD would be ABCD
       RememberJoins = true -- Set this to false to make them join the discord every time they load it up
    },
 
    KeySystem = false, -- Set this to true to use our key system
    KeySettings = {
       Title = "Untitled",
       Subtitle = "Key System",
       Note = "No method of obtaining the key is provided", -- Use this to tell the user how to get a key
       FileName = "Key", -- It is recommended to use something unique as other scripts using Rayfield may overwrite your key file
       SaveKey = true, -- The user's key will be saved, but if you change the key, they will be unable to use your script
       GrabKeyFromSite = false, -- If this is true, set Key below to the RAW site you would like Rayfield to get the key from
       Key = {"Hello"} -- List of keys that will be accepted by the system, can be RAW file links (pastebin, github etc) or simple strings ("hello","key22")
    }
 })
 local RankMapping = {
    E = 1,
    D = 2,
    C = 3,
    B = 4,
    A = 5,
    S = 6,
    SS = 7,
    G = 8,
    N = 9
}
local autoArise = false -- default
local attackRunningDungen = false  -- ตัวแปรติดตามสถานะการทำงานของ attackLoop
local attackRunning = false  -- ตัวแปรติดตามสถานะการทำงานของ attackLoop
local autoDestroy = false
local Setspaawnp = false
local Setspaawnp2 = false
local Setspaawnp3 = false
local Setspaawnp4 = false
local Setspaawnp5 = false
local Setspaawnp6 = false
local Setspaawnp7 = false
local autosellexe = false
local equipBestPetsex = false
local Punch = false
local autoinf = false
local autoDungeon = false
local walkSpeed = 16
local loopEnabled = false
local SelectRank = RankMapping["E"] -- กำหนดค่าเริ่มต้น
local TP_RANGE = 350  -- กำหนดระยะ TP (หน่วย: Studs)
local highestHP = 1000
local STEP_DISTANCE = 100 -- ระยะที่ TP ทีละก้าว

local ProfileTab = Window:CreateTab("👼Profile👼", nil) -- Title, Image
local MainSection = ProfileTab:CreateSection("Profile Player👼")

local player = game:GetService("Players").LocalPlayer
local players = game:GetService("Players")
local serverStats = game:GetService("Stats") -- สำหรับการตรวจสอบข้อมูลเซิร์ฟเวอร์
local dataPing = serverStats:FindFirstChild("Data Ping") and serverStats["Data Ping"]:GetValueString() or "N/A" -- ตรวจสอบและดึงค่า Ping

local leaderstats = player:FindFirstChild("leaderstats")

local coins = leaderstats and leaderstats:FindFirstChild("Cash") and leaderstats.Cash.Value or "N/A"
local rank = leaderstats and leaderstats:FindFirstChild("Rank") and leaderstats.Rank.Value or "N/A"

local playerCount = #players:GetPlayers()
local maxPlayers = players.MaxPlayers
local pingValue = (dataPing ~= "N/A" and tonumber(dataPing:match("(%d+)"))) or "N/A" -- แปลง Ping เป็นตัวเลข

--local player = Players.LocalPlayer
local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
local worldFolder = workspace:WaitForChild("__Main"):WaitForChild("__World")
local currentRoomNumber = 2

-- ฟังก์ชันสร้าง Section บนโปรไฟล์
ProfileTab:CreateSection("👥 User Name: " .. player.Name)
-- ตรวจสอบว่ามีค่า Rank และ Coins หรือไม่
if coins and rank then
    ProfileTab:CreateSection("🏆 Rank: " .. rank)
    ProfileTab:CreateSection("💰 Coins: " .. coins)
end
ProfileTab:CreateSection("🕹️ Players in Server: " .. playerCount .. " / " .. maxPlayers)

if pingValue ~= "N/A" then
    ProfileTab:CreateSection("📡 Network Info: " .. pingValue .. " ms") -- แสดง Ping หากมีข้อมูล
else
    ProfileTab:CreateSection("📡 Network Info: Unable to fetch Ping") -- แสดงข้อความเมื่อดึง Ping ไม่สำเร็จ
end

-- ลิงก์ Discord
ProfileTab:CreateSection("🖥️ Discord Link: https://discord.gg/HHwaZxBXUd")

-- ปุ่มคัดลอกลิงก์ Discord
local Button = ProfileTab:CreateButton({
    Name = "Copy Link Discord",
    Callback = function()
        setclipboard("https://discord.gg/HHwaZxBXUd") -- คัดลอกลิงก์ไปยังคลิปบอร์ด
        print("Discord link copied to clipboard!") -- แสดงข้อความในคอนโซล
    end,
})

local Tab = Window:CreateTab("🛎️Main🛎️", nil) -- Title, Image
local MainSection = Tab:CreateSection("Main🛎️")


-- สไลเดอร์สำหรับตั้งค่า WalkSpeed
local Slider = Tab:CreateSlider({
    Name = "Walk Speed",
    Range = {16, 300},
    Increment = 1,
    Suffix = "Bananas",
    CurrentValue = 16,
    Flag = "Slider1", 
    Callback = function(Value)
        walkSpeed = Value -- เก็บค่าไว้เพื่อนำไปใช้ใน loop      
    end,
})

-- Toggle สำหรับเปิด/ปิด loop
local Toggle = Tab:CreateToggle({
    Name = "Auto WalkSpeed Loop",
    CurrentValue = false,
    Flag = "Toggle1",
    Callback = function(Value)
        loopEnabled = Value
        if loopEnabled then
            -- เริ่ม loop
            task.spawn(function()
                while loopEnabled do
                    local play = game.Players.LocalPlayer.character       
                    play.Humanoid.WalkSpeed = (walkSpeed)
                    task.wait(0.2) -- ความถี่ในการ loop (0.1 วินาที)
                end
            end)
        end
    end,
})
 local Slider = Tab:CreateSlider({
    Name = "JumpPower",
    Range = {50, 300},
    Increment = 1,
    Suffix = "Bananas",
    CurrentValue = 16,
    Flag = "Slider2", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps   
    Callback = function(Value)
        local play = game.Players.LocalPlayer.character       
        play.Humanoid.JumpPower = (Value)
    -- The function that takes place when the slider changes
    -- The variable (Value) is a number which correlates to the value the slider is currently at
    end,
 })
 local Slider = Tab:CreateSlider({
    Name = "CameraMaxZoomDistance",
    Range = {36, 300},
    Increment = 1,
    Suffix = "Bananas",
    CurrentValue = 36,
    Flag = "Slider3", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps   
    Callback = function(Value)
        game:GetService("Players").LocalPlayer.CameraMaxZoomDistance = (Value)
    end,
 })

 local Slider = Tab:CreateSlider({
    Name = "Gravity",
    Range = {1, 170},
    Increment = 1,
    Suffix = "Bananas",
    CurrentValue = 170,
    Flag = "Slider3", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps   
    Callback = function(Value)
        game.Workspace.Gravity = (Value)
    end,
 })
 local Slider = Tab:CreateSlider({
    Name = "HipHeight",
    Range = {0, 300},
    Increment = 1,
    Suffix = "Bananas",
    CurrentValue = 1,
    Flag = "Slider3", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps   
    Callback = function(Value)
        game.Players.LocalPlayer.Character.Humanoid.HipHeight = Value
    end,
 })
 local LocalPlayer = game:GetService("Players").LocalPlayer
 local Noclip = false
 local NoclipConnection = nil
 
 function NoclipConnectionx()
     local RunService = game:GetService("RunService")
     local LocalCharacter = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait() -- รองรับการเปลี่ยน Character
     
     -- ยกเลิกการเชื่อมต่อก่อนถ้ามีการเชื่อมต่อก่อนหน้านี้
     if NoclipConnection then
         NoclipConnection:Disconnect()
     end
 
     -- เริ่มการเชื่อมต่อใหม่
     NoclipConnection = RunService.Stepped:Connect(function()
         if Noclip and LocalCharacter then
             for _, v in pairs(LocalCharacter:GetDescendants()) do
                 if v:IsA("BasePart") and v.CanCollide == true then
                     v.CanCollide = false
                 end
             end
         end
     end)
 end
 
 -- ฟังก์ชันสำหรับเปิด/ปิด Noclip
 function ToggleNoclip(state)
     Noclip = state
     if Noclip then
         print("Noclip Enabled")
         NoclipConnectionx()
     else
         print("Noclip Disabled")
         if NoclipConnection then
             NoclipConnection:Disconnect()
             NoclipConnection = nil
         end
     end
 end

 local Toggle = Tab:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Flag = "Toggle1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
    Callback = function(Value)
        ToggleNoclip(Value)
        Noclip = Value
            
    end,
 })
 local MainSection = Tab:CreateSection("Setting Auto Farm")
 local Input = Tab:CreateInput({
    Name = "RANGE",
    CurrentValue = TP_RANGE,
    PlaceholderText = "Rang",
    RemoveTextAfterFocusLost = false,
    Flag = "Input1",
    Callback = function(Text)
        TP_RANGE = Text
    -- The function that takes place when the input is changed
    -- The variable (Text) is a string for the value in the text box
    end,
 })
 local Input = Tab:CreateInput({
    Name = "MIN HP",
    CurrentValue = highestHP,
    PlaceholderText = "highest_HP",
    RemoveTextAfterFocusLost = false,
    Flag = "Input1",
    Callback = function(Text)
        highestHP = Text
    -- The function that takes place when the input is changed
    -- The variable (Text) is a string for the value in the text box
    end,
 })
local MainSection = Tab:CreateSection("Setting Auto Farm")
local Toggle = Tab:CreateToggle({
    Name = "Auto Arise",
    CurrentValue = false,
    Flag = "AttackLoopFlag", -- Flag สำหรับการเก็บค่าคอนฟิก
    Callback = function(Value)
        -- ฟังก์ชันที่ทำงานเมื่อกด Toggle
        if Value then
            autoArise = Value  -- ตั้งสถานะการทำงานของ attackLoop
            

        else
            autoArise = Value  -- หยุด attackLoop เมื่อ Toggle ปิด
        end
    end,
})
local Toggle = Tab:CreateToggle({
    Name = "Auto Destroy",
    CurrentValue = false,
    Flag = "AttackLoopFlag", -- Flag สำหรับการเก็บค่าคอนฟิก
    Callback = function(Value)
        -- ฟังก์ชันที่ทำงานเมื่อกด Toggle
        if Value then
            autoDestroy = Value  -- ตั้งสถานะการทำงานของ attackLoop
            

        else
            autoDestroy = Value  -- หยุด attackLoop เมื่อ Toggle ปิด
        end
    end,
})
local Toggle = Tab:CreateToggle({
    Name = "Auto infinit",
    CurrentValue = false,
    Flag = "AttackLoopFlag", -- Flag สำหรับการเก็บค่าคอนฟิก
    Callback = function(Value)
        -- ฟังก์ชันที่ทำงานเมื่อกด Toggle
        if Value then    
            autoinf = Value 
        else
            autoinf = Value
        end
    end,
})
local Toggle = Tab:CreateToggle({
    Name = "Auto Dungeon Islans",
    CurrentValue = false,
    Flag = "AttackLoopFlag", -- Flag สำหรับการเก็บค่าคอนฟิก
    Callback = function(Value)
        -- ฟังก์ชันที่ทำงานเมื่อกด Toggle
        if Value then    
            autoDungeon = Value          
        else
            autoDungeon = Value
        end
    end,
})
local Button = Tab:CreateButton({
    Name = "Auto Dungeon",
    Callback = function()
        autoCreateAndStartDungeonex()
    end,
 })
local MainSection = Tab:CreateSection("Auto Farm")
local Toggle = Tab:CreateToggle({
    Name = "Auto Farm",
    CurrentValue = false,
    Flag = "AttackLoopFlag", -- Flag สำหรับการเก็บค่าคอนฟิก
    Callback = function(Value)
        -- ฟังก์ชันที่ทำงานเมื่อกด Toggle
        if Value then
            attackRunningDungen = Value  -- ตั้งสถานะการทำงานของ attackLoop
            attackLoopDungen()  -- เริ่ม attackLoop เมื่อ Toggle เปิด         

        else
            attackRunningDungen = Value  -- หยุด attackLoop เมื่อ Toggle ปิด
        end
    end,
})
local Toggle = Tab:CreateToggle({
    Name = "Anti AFK",
    CurrentValue = false,
    Flag = "AttackLoopFlag", -- Flag สำหรับการเก็บค่าคอนฟิก
    Callback = function(Value)
        -- ฟังก์ชันที่ทำงานเมื่อกด Toggle
        if Value then
            
            connection = game:GetService("Players").LocalPlayer.Idled:Connect(function()
            game:GetService("VirtualUser"):CaptureController()
            game:GetService("VirtualUser"):ClickButton2(Vector2.new())
            end)
                
           

        else
            if connection then
                connection:Disconnect()
                connection = nil
            end
        end
    end,
})


local MainSection = Tab:CreateSection("Auto Equip")
local Toggle = Tab:CreateToggle({
    Name = "Auto EquipBest",
    CurrentValue = false,
    Flag = "AttackLoopFlag", -- Flag สำหรับการเก็บค่าคอนฟิก
    Callback = function(Value)
        -- ฟังก์ชันที่ทำงานเมื่อกด Toggle
        if Value then    
            equipBestPetsex = Value
            equipBestPets()
        else
            equipBestPetsex = Value
        end
    end,
})
local Toggle = Tab:CreateToggle({
    Name = "Auto Punch",
    CurrentValue = false,
    Flag = "AttackLoopFlag", -- Flag สำหรับการเก็บค่าคอนฟิก
    Callback = function(Value)
        -- ฟังก์ชันที่ทำงานเมื่อกด Toggle       
        Punch = Value
        if Punch then
            spawn(function()
                PunchATT(Enemye)
            end)
        end
    end,
})

local MainSection = Tab:CreateSection("Auto SELL")
local Dropdown = Tab:CreateDropdown({
    Name = "Select Rank",
    Options = {"E", "D", "C", "B", "A", "S", "SS", "G", "N"},
    CurrentOption = {"E"},
    MultipleOptions = false,
    Flag = "Dropdown1",
    Callback = function(Option)
        local selected = typeof(Option) == "table" and Option[1] or Option
        print("เลือก Rank:", selected)
        SelectRank = RankMapping[selected]
        print("SelectRank:", SelectRank)
    end,
    
})
local Toggle = Tab:CreateToggle({
    Name = "Auto SELL",
    CurrentValue = false,
    Flag = "AttackLoopFlag", -- Flag สำหรับการเก็บค่าคอนฟิก
    Callback = function(Value)
        -- ฟังก์ชันที่ทำงานเมื่อกด Toggle
        if Value then    
            autosellexe = Value
            autosellex()
        else
            autosellexe = Value
        end
    end,
})

local Tab2 = Window:CreateTab("🏠TP & Spawn🏠", nil) -- Title, Image
local Section = Tab2:CreateSection("HOME🏠")
local Button = Tab2:CreateButton({
    Name = "Auto Set Spawn Solo World",
    Callback = function()
        Setspaawnp = true  -- ตั้งสถานะการทำงานของ attackLoop
        SetSpawn()  -- เริ่ม attackLoop เมื่อ Toggle เปิด         

    end,
 })
local Button = Tab2:CreateButton({
    Name = "Auto Set Spawn NarutoWorld",
    Callback = function()
        Setspaawnp2 = true  -- ตั้งสถานะการทำงานของ attackLoop
        SetSpawn()  -- เริ่ม attackLoop เมื่อ Toggle เปิด         

    end,
 })
local Button = Tab2:CreateButton({
    Name = "Auto Set Spawn OPWorld",
    Callback = function()
        Setspaawnp3 = true  -- ตั้งสถานะการทำงานของ attackLoop
        SetSpawn()  -- เริ่ม attackLoop เมื่อ Toggle เปิด         

    end,
 })
 local Button = Tab2:CreateButton({
    Name = "Auto Set Spawn BleachWorld",
    Callback = function()
        Setspaawnp4 = true  -- ตั้งสถานะการทำงานของ attackLoop
        SetSpawn()  -- เริ่ม attackLoop เมื่อ Toggle เปิด         

    end,
 })
 local Button = Tab2:CreateButton({
    Name = "Auto Set Spawn BCWorld",
    Callback = function()
        Setspaawnp5 = true  -- ตั้งสถานะการทำงานของ attackLoop
        SetSpawn()  -- เริ่ม attackLoop เมื่อ Toggle เปิด         

    end,
 })
 local Button = Tab2:CreateButton({
    Name = "Auto Set Spawn ChainsawWorld",
    Callback = function()
        Setspaawnp6 = true  -- ตั้งสถานะการทำงานของ attackLoop
        SetSpawn()  -- เริ่ม attackLoop เมื่อ Toggle เปิด         

    end,
 })
 local Button = Tab2:CreateButton({
    Name = "Auto Set Spawn JojoWorld",
    Callback = function()
        Setspaawnp7 = true  -- ตั้งสถานะการทำงานของ attackLoop
        SetSpawn()  -- เริ่ม attackLoop เมื่อ Toggle เปิด         

    end,
 })
local MainSection = Tab2:CreateSection("Reset")
local Button = Tab2:CreateButton({
    Name = "Reset Player",
    Callback = function()
        local player = game.Players.LocalPlayer
        if player and player.Character then
            -- ลบตัวละครเดิม
            player.Character:BreakJoints()
    
            -- รอจนกว่าตัวละครใหม่จะถูกสร้าง
            player.CharacterAdded:Wait()
            
            --//Script Roblox Arise_Crossover by : Code X HUB
            loadstring(game:HttpGet("https://raw.githubusercontent.com/Uncharron/CodeX.lua/refs/heads/main/codex.lua", true))()

        end
    end,
 })
 

local MainSection = Tab2:CreateSection("Teleport")
local Button = Tab2:CreateButton({
    Name = "TP To Upgrader",
    Callback = function()
        local Players = game:GetService("Players")
        --game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(593.784912, 28.102459, 189.892761, -0.667140841, 0, 0.744931638, 0, 1, 0, -0.744931638, 0, -0.667140841)
        local player = Players.LocalPlayer
        local targetCFrame = CFrame.new(593.784912, 28.102459, 189.892761, -0.667140841, 0, 0.744931638, 0, 1, 0, -0.744931638, 0, -0.667140841)
          -- รอให้ character โหลดก่อน
        local character = player.Character or player.CharacterAdded:Wait()
        local hrp = character:WaitForChild("HumanoidRootPart")
          
        -- Loop จนไปถึงตำแหน่ง
        while (hrp.Position - targetCFrame.Position).magnitude > 1 do
            hrp.CFrame = targetCFrame
            task.wait(0.1)
        end
    end,
})
local Button = Tab2:CreateButton({
    Name = "TP To Enchanter",
    Callback = function()
        local Players = game:GetService("Players")
        --game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(593.784912, 28.102459, 189.892761, -0.667140841, 0, 0.744931638, 0, 1, 0, -0.744931638, 0, -0.667140841)
        local player = Players.LocalPlayer
        local targetCFrame = CFrame.new(612.509766, 28.0839901, 226.756882, 0.744507194, 0, 0.66761446, 0, 1, 0, -0.66761446, 0, 0.744507194)
          -- รอให้ character โหลดก่อน
        local character = player.Character or player.CharacterAdded:Wait()
        local hrp = character:WaitForChild("HumanoidRootPart")
          
        -- Loop จนไปถึงตำแหน่ง
        while (hrp.Position - targetCFrame.Position).magnitude > 1 do
            hrp.CFrame = targetCFrame
            task.wait(0.1)
        end
    end,
})
local Button = Tab2:CreateButton({
    Name = "TP To Ant lans",
    Callback = function()
        local Players = game:GetService("Players")
        --game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(593.784912, 28.102459, 189.892761, -0.667140841, 0, 0.744931638, 0, 1, 0, -0.744931638, 0, -0.667140841)
        local player = Players.LocalPlayer
        local targetCFrame = CFrame.new(3834.31274, 60.1047897, 3051.87012, 0.887708068, 1.10925555e-07, 0.46040675, -2.5959551e-07, 1, 2.59595396e-07, -0.46040675, -3.49964438e-07, 0.887708068)
          -- รอให้ character โหลดก่อน
        local character = player.Character or player.CharacterAdded:Wait()
        local hrp = character:WaitForChild("HumanoidRootPart")
          
        -- Loop จนไปถึงตำแหน่ง
        while (hrp.Position - targetCFrame.Position).magnitude > 1 do
            hrp.CFrame = targetCFrame
            task.wait(0.1)
        end
    end,
})

 local ServerTab = Window:CreateTab("🌃 Server 🌃", nil) -- Title, Image
 local MainSection = ServerTab:CreateSection("Server 🌃")
 
 function getServerID()
     return game.JobId
 end
 local Section = ServerTab:CreateSection("Server ID: " .. getServerID())
 
 local Button = ServerTab:CreateButton({
     Name = "Copy Server ID",
     Callback = function()
         setclipboard(tostring(getServerID()))
         bigGreenItalicText("Copied Server ID to clipboard!")
     end,
  })
 
 
 local Section = ServerTab:CreateSection("Teleport Jobid Server")
 getgenv().hyperlibblock = false
 
 -- ตัวแปรสำหรับเก็บ JobId จาก Input
 local targetJobId = ""
 
 -- PlaceId ของเกมปัจจุบัน
 local placeId = game.PlaceId
 
 -- สร้าง Input ให้ผู้เล่นป้อน JobId
 local Input = ServerTab:CreateInput({
    Name = "Enter Server JobId",
    CurrentValue = "",
    PlaceholderText = "Input JobId here",
    RemoveTextAfterFocusLost = false,
    Flag = "JobIdInput",
    Callback = function(Text)
        targetJobId = Text -- เก็บค่าที่ป้อนในตัวแปร targetJobId
    end,
 })
 
 -- สร้างปุ่มสำหรับยืนยันการเทเลพอร์ต
 local Button = ServerTab:CreateButton({
    Name = "Teleport to Server",
    Callback = function()
        if targetJobId ~= "" then
            local success, err = pcall(function()
                game:GetService("TeleportService"):TeleportToPlaceInstance(placeId, targetJobId, game.Players.LocalPlayer)
            end)
 
            if not success then
                warn("Teleport failed: " .. tostring(err))
            else
                print("Teleporting to server with JobId: " .. targetJobId)
            end
        else
            warn("Please enter a valid JobId!")
        end
    end,
 })
 
 local Section = ServerTab:CreateSection("Hop Server")
 
 local Button = ServerTab:CreateButton({
     Name = "Auto Rejoin",
     Callback = function()
         getgenv().hyperlibblock = false
          game:GetService("TeleportService"):Teleport(game.PlaceId, game.Players.LocalPlayer)
     end,
  })
 
  local Button = ServerTab:CreateButton({
     Name = "Hop Server Low",
     Callback = function()
         local PlaceID = game.PlaceId
         local AllIDs = {}
         local foundAnything = ""
         local actualHour = os.date("!*t").hour
         
         -- ฟังก์ชันหลักสำหรับการค้นหาเซิร์ฟเวอร์
         function TPReturner()
             local sortOrder = math.random(1, 2) == 1 and "Asc" or "Desc"
             local Site
             if foundAnything == "" then
                 Site = game.HttpService:JSONDecode(
                     game:HttpGet('https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=' ..
                     sortOrder .. '&limit=100&excludeFullGames=true'))
             else
                 Site = game.HttpService:JSONDecode(
                     game:HttpGet('https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=' ..
                     sortOrder .. '&limit=100&cursor=' .. foundAnything .. '&excludeFullGames=true'))
             end
         
             if Site.nextPageCursor and Site.nextPageCursor ~= "null" then
                 foundAnything = Site.nextPageCursor
             else
                 foundAnything = ""
             end
         
             local serverList = {}
             for _, v in pairs(Site.data) do
                 if tonumber(v.maxPlayers) > tonumber(v.playing) then
                     table.insert(serverList, tostring(v.id))
                 end
             end
         
             if #serverList > 0 then
                 local randomIndex = math.random(1, #serverList)
                 local randomServerID = serverList[randomIndex]
                 table.insert(AllIDs, randomServerID)
         
                 pcall(function()
                     print("Teleporting to server ID: " .. randomServerID)
                     game:GetService("TeleportService"):TeleportToPlaceInstance(PlaceID, randomServerID, game.Players.LocalPlayer)
                 end)
             else
                 if foundAnything ~= "" then
                     TPReturner()
                 else
                     print("No available servers found!")
                 end
             end
         end
         
         -- ฟังก์ชันสำหรับการเริ่มกระโดดเซิร์ฟเวอร์
         function Teleport()
             while wait() do
                 pcall(function()
                     TPReturner()
                 end)
             end
         end
         
         -- UI/ข้อความแจ้งสถานะ (สามารถปรับแต่งให้ใช้งานใน GUI ได้)
         spawn(function()
             while true do
                 wait(0.1)
                 print("Teleporting")
                 wait(0.1)
                 print("Teleporting.")
                 wait(0.1)
                 print("Teleporting..")
                 wait(0.1)
                 print("Teleporting...")
             end
         end)
         
         -- เริ่มการกระโดดเซิร์ฟเวอร์
         print("Starting server hopper...")
         Teleport()
 
 
 
     end,
  })
  local Button = ServerTab:CreateButton({
     Name = "Hop Server Full",
     Callback = function()
         local PlaceID = game.PlaceId
         local AllIDs = {}
         local foundAnything = ""
         local maxRetries = 5 -- จำกัดจำนวนครั้งในการค้นหาเซิร์ฟเวอร์ใหม่
         
         function TPReturner()
             local Site
             if foundAnything == "" then
                 Site = game.HttpService:JSONDecode(
                     game:HttpGet('https://games.roblox.com/v1/games/' ..
                     PlaceID .. '/servers/Public?sortOrder=Desc&limit=100&excludeFullGames=true'))
             else
                 Site = game.HttpService:JSONDecode(
                     game:HttpGet('https://games.roblox.com/v1/games/' ..
                     PlaceID .. '/servers/Public?sortOrder=Desc&limit=100&cursor=' .. foundAnything .. '&excludeFullGames=true'))
             end
         
             if Site.nextPageCursor and Site.nextPageCursor ~= "null" then
                 foundAnything = Site.nextPageCursor
             else
                 foundAnything = ""
             end
         
             local serverList = Site.data
             if #serverList > 0 then
                 for _, v in pairs(serverList) do
                     if tonumber(v.maxPlayers) > tonumber(v.playing) then
                         local serverID = tostring(v.id)
                         table.insert(AllIDs, serverID)
         
                         pcall(function()
                             print("Teleporting to server ID: " .. serverID)
                             game:GetService("TeleportService"):TeleportToPlaceInstance(PlaceID, serverID, game.Players.LocalPlayer)
                         end)
                         return
                     end
                 end
             else
                 print("No servers found on this page.")
                 if foundAnything ~= "" then
                     TPReturner()
                 end
             end
         end
         
         function Teleport()
             local retries = 0
             while retries < maxRetries do
                 pcall(function()
                     TPReturner()
                 end)
                 retries = retries + 1
                 wait(1)
             end
             print("No suitable servers found after " .. maxRetries .. " attempts.")
         end
         
         -- UI/สถานะแจ้งเตือน
         spawn(function()
             while true do
                 getgenv().serverhopperhigher:UpdateButton("Teleporting")
                 wait(0.1)
                 getgenv().serverhopperhigher:UpdateButton("Teleporting.")
                 wait(0.1)
                 getgenv().serverhopperhigher:UpdateButton("Teleporting..")
                 wait(0.1)
                 getgenv().serverhopperhigher:UpdateButton("Teleporting...")
                 wait(0.1)
             end
         end)
         
         -- เริ่มการกระโดดเซิร์ฟเวอร์
         print("Starting server hopper...")
         Teleport()
 
 
    
     end,
  })
  local Button = ServerTab:CreateButton({
     Name = "Hop Server Private",
     Callback = function()
         local PlaceID = game.PlaceId
         local AllIDs = {}
         local foundAnything = ""
         local actualHour = os.date("!*t").hour
         
         function TPReturner()
             local sortOrder = math.random(1, 2) == 1 and "Asc" or "Desc"
             local Site
             if foundAnything == "" then
                 Site = game.HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' ..
                 PlaceID .. '/servers/Public?sortOrder=' .. sortOrder .. '&limit=100&excludeFullGames=true'))
             else
                 Site = game.HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' ..
                 PlaceID .. '/servers/Public?sortOrder=' .. sortOrder .. '&limit=100&cursor=' .. foundAnything .. '&excludeFullGames=true'))
             end
             if Site.nextPageCursor and Site.nextPageCursor ~= "null" and Site.nextPageCursor ~= nil then
                 foundAnything = Site.nextPageCursor
             end
         
             local serverList = {}
             for _, v in pairs(Site.data) do
                 if tonumber(v.maxPlayers) > tonumber(v.playing) then
                     table.insert(serverList, tostring(v.id))
                 end
             end
         
             if #serverList > 0 then
                 local randomIndex = math.random(1, #serverList) 
                 local randomServerID = serverList[randomIndex]
                 table.insert(AllIDs, randomServerID)
         
                 pcall(function()
                     bigGreenItalicText("Teleporting to a random server now!")
                     game:GetService("TeleportService"):TeleportToPlaceInstance(PlaceID, randomServerID, game.Players.LocalPlayer)
                 end)
             else
                 if foundAnything ~= "" then
                     TPReturner()
                 end
             end
         end
         
         function Teleport()
             while wait() do
                 pcall(function()
                     TPReturner()
                 end)
             end
         end
         
         spawn(function()
             while true do
                 getgenv().serverhopper:UpdateButton("Teleporting")
                 wait(0.1)
                 getgenv().serverhopper:UpdateButton("Teleporting.")
                 wait(0.1)
                 getgenv().serverhopper:UpdateButton("Teleporting..")
                 wait(0.1)
                 getgenv().serverhopper:UpdateButton("Teleporting...")
                 wait(0.1)
             end
         end)
         
         bigGreenItalicText("Teleporting to a random server...")
         Teleport()
 
 
     
     end,
  })
  local WebhookTab = Window:CreateTab("📝 Webhook 📝", nil) -- Title, Image
local MainSection = WebhookTab:CreateSection("Webhook 📝")

--// Config
getgenv().whscript = "Code X HUB" -- ชื่อสคริปต์
getgenv().webhookexecUrl = "" -- เริ่มต้นว่างเปล่า
local webhookEnabled = false -- สถานะ Webhook (เปิด/ปิด)

--// บริการที่เกี่ยวข้อง
local player = game:GetService("Players").LocalPlayer
local httpService = game:GetService("HttpService")

-- ฟังก์ชันดึงชื่อเกม
local gameName = "Unknown Game"
pcall(function()
    gameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
end)

-- ฟังก์ชันส่งข้อมูล Webhook
local function sendWebhook()
    if not webhookEnabled then
        print("Webhook is currently disabled.")
        return
    end

    if getgenv().webhookexecUrl == "" then
        print("Webhook URL is not set!")
        return
    end

    -- ดึงข้อมูลล่าสุด
    local completeTime = os.date("%Y-%m-%d %H:%M:%S")

    local character = player.Character or workspace.__Main.__Players:FindFirstChild(player.Name)
    local humanoid = character and character:FindFirstChild("Humanoid")
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")

    local health = humanoid and humanoid.Health or "N/A"
    local maxHealth = humanoid and humanoid.MaxHealth or "N/A"
    local position = rootPart and rootPart.Position or "N/A"

    -- ตรวจสอบ leaderstats ก่อนดึงค่า
    local leaderstats = player:FindFirstChild("leaderstats")
    local coins = leaderstats and leaderstats:FindFirstChild("Cash") and leaderstats.Cash.Value or "N/A"
    local rank = leaderstats and leaderstats:FindFirstChild("Rank") and leaderstats.Rank.Value or "N/A"

    local data = {
        ["content"] = "@everyone",
        ["embeds"] = {
            {
                ["title"] = "🚀 ** Code X HUB LOG | Fish **",
                ["type"] = "rich",
                ["color"] = tonumber(0x34DB98),
                ["fields"] = {
                    {
                        ["name"] = "🔍 **Info**",
                        ["value"] = "```💻 Script Name: " .. getgenv().whscript .. "\n🆔 Game Name: " .. gameName .. "\n⏰ Executed At: " .. completeTime .. "```",
                        ["inline"] = false
                    },
                    {
                        ["name"] = "👤 **Player Info**",
                        ["value"] = "```🧸 Username: " .. player.Name .. "\n📝 Display Name: " .. player.DisplayName .. "\n🆔 UserID: " .. player.UserId .. "\n❤️ Health: " .. health .. " / " .. maxHealth .. "\n🏆 Rank: " .. rank .. "\n💰 Coins: " .. coins .. "```",
                        ["inline"] = false
                    },
                    {
                        ["name"] = "📍 **Position**",
                        ["value"] = "```📍 Position: " .. tostring(position) .. "```",
                        ["inline"] = true
                    }
                },
                ["footer"] = {
                    ["text"] = "Ⓤ  Code X HUB Log | " .. os.date("%Y-%m-%d %H:%M:%S"),
                }
            }
        }
    }

    local requestData = httpService:JSONEncode(data)
    local headers = {["content-type"] = "application/json"}

    local request = http_request or request or (syn and syn.request) or (fluxus and fluxus.request) or (http and http.request)
    if request then
        request({Url = getgenv().webhookexecUrl, Body = requestData, Method = "POST", Headers = headers})
    else
        warn("HTTP request function not found! Unable to send webhook.")
    end
end

 
 -- UI สำหรับใส่ URL ของ Webhook
 local Input = WebhookTab:CreateInput({
     Name = "Webhook URL",
     CurrentValue = "",
     PlaceholderText = "Enter your Webhook URL",
     RemoveTextAfterFocusLost = false,
     Flag = "WebhookInput",
     Callback = function(Text)
         getgenv().webhookexecUrl = Text
         print("Webhook URL set to:", Text)
     end,
 })
 -- สร้างปุ่มทดสอบ Webhook
 local Button = WebhookTab:CreateButton({
     Name = "Test Webhook",
     Callback = function()
         -- ฟังก์ชันที่ทำงานเมื่อปุ่มถูกกด
         local data = {
             ["content"] = "@everyone",
             ["embeds"] = {
                 {
                     ["title"] = "🚀 **Test Webhook Code X HUB**",
                     --//["description"] = "This is a test message sent via the webhook.",
                     ["type"] = "rich",
                     ["color"] = tonumber(0x34DB98), -- สีเขียว
                     ["fields"] = {
                         {
                             ["name"] = "Info",
                             ["value"] = "```Webhook test was triggered manually```",
                             ["inline"] = false
                         }
                     },
                     ["footer"] = {
                         ["text"] = "Ⓤ  Code X HUB Log | " .. os.date("%Y-%m-%d %H:%M:%S"),
                     }
                 }
             }
         }
 
         -- เช็คว่า URL ของ Webhook ถูกตั้งค่าหรือไม่
         if getgenv().webhookexecUrl == "" then
             print("Webhook URL is not set!")
             return
         end
 
         -- ส่งข้อมูล Webhook
         local requestData = game:GetService("HttpService"):JSONEncode(data)
         local headers = {["content-type"] = "application/json"}
 
         local request = http_request or request or (syn and syn.request) or (fluxus and fluxus.request) or (http and http.request)
         if request then
             request({Url = getgenv().webhookexecUrl, Body = requestData, Method = "POST", Headers = headers})
             print("Test Webhook sent!")
         else
             warn("HTTP request function not found! Unable to send webhook.")
         end
     end,
 })
 local SliderWebhook = 2
 local Slider = WebhookTab:CreateSlider({
     Name = "Send Messages every ? seconds",
     Range = {2, 2000},
     Increment = 1,
     Suffix = "seconds",
     CurrentValue = 2,
     Flag = "Slider1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
     Callback = function(Value)
         SliderWebhook = Value
     -- The function that takes place when the slider changes
     -- The variable (Value) is a number which correlates to the value the slider is currently at
     end,
  })
 -- Toggle สำหรับเปิด/ปิด Webhook
 local Toggle = WebhookTab:CreateToggle({
     Name = "Enable Webhook",
     CurrentValue = false,
     Flag = "WebhookToggle",
     Callback = function(Value)
         webhookEnabled = Value
         if Value then
             print("Webhook is enabled!")
             -- ลูปส่งข้อมูลเมื่อเปิด Webhook
             spawn(function()
                 while webhookEnabled do
                     sendWebhook()
                     task.wait(SliderWebhook) -- ตั้งเวลาส่งข้อมูลทุก 10 วินาที
                 end
             end)
         else
             print("Webhook is disabled!")
         end
     end,
 })
-------------------------**ฟังก์ชัน**----------------------
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()


local function teleportToDungeon()
    local dungeonFolder = workspace:FindFirstChild("__Main"):FindFirstChild("__Dungeon")
    if dungeonFolder then
        for _, dungeon in ipairs(dungeonFolder:GetChildren()) do
            if dungeon:IsA("Part") and dungeon:FindFirstChild("Dungeon") then
                local player = game.Players.LocalPlayer
                if player and player.Character and player.Character.PrimaryPart then
                    player.Character:SetPrimaryPartCFrame(dungeon.PrimaryPart.CFrame)
                    return
                end
            end
        end
    end
end
          
-- ฟังก์ชันค้นหามอนที่ใกล้ที่สุด
function findClosestEnemies()
    local enemies = workspace.__Main.__Enemies.Client:GetChildren()
    local closestEnemy, nextClosestEnemy = nil, nil
    local shortestDistance, nextShortestDistance = math.huge, math.huge

    for _, enemy in pairs(enemies) do
        if enemy:FindFirstChild("HumanoidRootPart") then
            local distance = (character.PrimaryPart.Position - enemy.HumanoidRootPart.Position).Magnitude
            if distance < shortestDistance then
                nextClosestEnemy, nextShortestDistance = closestEnemy, shortestDistance
                closestEnemy, shortestDistance = enemy, distance
            elseif distance < nextShortestDistance then
                nextClosestEnemy, nextShortestDistance = enemy, distance
            end
        end
    end
    return closestEnemy, nextClosestEnemy
end

function SetSpawn()
    if  Setspaawnp then
        local args = {
            [1] = {
                [1] = {
                    ["Event"] = "ChangeSpawn",
                    ["Spawn"] = "SoloWorld"
                },
                [2] = "\n"
            }
        } 
        game:GetService("ReplicatedStorage").BridgeNet2.dataRemoteEvent:FireServer(unpack(args))       
    end   
    if  Setspaawnp2 then
        local args = {
            [1] = {
                [1] = {
                    ["Event"] = "ChangeSpawn",
                    ["Spawn"] = "NarutoWorld"
                },
                [2] = "\n"
            }
        } 
        game:GetService("ReplicatedStorage").BridgeNet2.dataRemoteEvent:FireServer(unpack(args))       
    end
    if  Setspaawnp3 then
        local args = {
            [1] = {
                [1] = {
                    ["Event"] = "ChangeSpawn",
                    ["Spawn"] = "OPWorld"
                },
                [2] = "\n"
            }
        } 
        game:GetService("ReplicatedStorage").BridgeNet2.dataRemoteEvent:FireServer(unpack(args))       
    end
    if  Setspaawnp4 then
        local args = {
            [1] = {
                [1] = {
                    ["Event"] = "ChangeSpawn",
                    ["Spawn"] = "BleachWorld"
                },
                [2] = "\n"
            }
        } 
        game:GetService("ReplicatedStorage").BridgeNet2.dataRemoteEvent:FireServer(unpack(args))       
    end
    if  Setspaawnp5 then
        local args = {
            [1] = {
                [1] = {
                    ["Event"] = "ChangeSpawn",
                    ["Spawn"] = "BCWorld"
                },
                [2] = "\n"
            }
        } 
        game:GetService("ReplicatedStorage").BridgeNet2.dataRemoteEvent:FireServer(unpack(args))       
    end
    if  Setspaawnp6 then
        local args = {
            [1] = {
                [1] = {
                    ["Event"] = "ChangeSpawn",
                    ["Spawn"] = "ChainsawWorld"
                },
                [2] = "\n"
            }
        } 
        game:GetService("ReplicatedStorage").BridgeNet2.dataRemoteEvent:FireServer(unpack(args))       
    end
    if  Setspaawnp7 then
        local args = {
            [1] = {
                [1] = {
                    ["Event"] = "ChangeSpawn",
                    ["Spawn"] = "JojoWorld"
                },
                [2] = "\n"
            }
        } 
        game:GetService("ReplicatedStorage").BridgeNet2.dataRemoteEvent:FireServer(unpack(args))       
    end
end

-- ฟังก์ชันจับมอนสเตอร์
function getEnemyCapture(enemyName)
    local args

    if autoArise then
        args = {
            [1] = {
                [1] = {
                    ["Event"] = "EnemyCapture",
                    ["Enemy"] = enemyName
                },
                [2] = "\4"
            }
        }
    elseif autoDestroy then
        args = {
            [1] = {
                [1] = {
                    ["Event"] = "EnemyDestroy",
                    ["Enemy"] = enemyName
                },
                [2] = "\4"
            }
        }
    end

    -- ถ้ามี args ถึงจะส่งคำสั่ง
    if args then
        for _ = 1, 3 do
            game:GetService("ReplicatedStorage").BridgeNet2.dataRemoteEvent:FireServer(unpack(args))
            wait(0.3)
        end
    else
        warn("⚠ ไม่มีเงื่อนไขที่เลือกไว้ (autoArise หรือ autoDestroy)")
    end
end


local function getEnemyHP(enemy)
    local success, result = pcall(function()
        local enemyData = nil

        -- Loop through every folder in Server
        for _, folder in ipairs(workspace.__Main.__Enemies.Server:GetChildren()) do
            if folder:FindFirstChild(enemy.Name) then
                enemyData = folder[enemy.Name]
                break
            end
        end

        if not enemyData then return 0 end

        local hp = enemyData:GetAttribute("HP")
        return hp or 0
    end)

    return success and result or 0
end

function isEnemyAlive(enemy)
    return enemy and getEnemyHP(enemy) > 0
end


local function getEnemyHPX2(enemy)
    local success, result = pcall(function()
        local enemyData = nil

        -- สแกนทุก Part ที่อยู่ใน workspace.__Main.__Enemies.Server
        local server = workspace:FindFirstChild("__Main")
        if not server then return 0 end

        server = server:FindFirstChild("__Enemies")
        if not server then return 0 end

        server = server:FindFirstChild("Server")
        if not server then return 0 end

        -- ใช้ GetDescendants แทน GetChildren เพื่อให้ครอบคลุมทุกชั้น
        for _, obj in ipairs(server:GetDescendants()) do
            -- หาชื่อ Part ที่ตรงกับชื่อ enemy ที่ส่งเข้ามา
            if obj:IsA("Instance") and obj.Name == enemy.Name then
                enemyData = obj
                break
            end
        end

        if not enemyData then return 0 end

        local hp = enemyData:GetAttribute("HP")
        return hp or 0
    end)

    return success and result or 0
end

function isEnemyAliveX2(enemy)
    return enemy and getEnemyHPX2(enemy) > 0
end

-- ฟังก์ชันค้นหาศัตรูที่อยู่ในระยะ
local function getClosestEnemyWithinRange(TP_RANGE)
    local enemiesFolder = workspace:FindFirstChild("__Main"):FindFirstChild("__Enemies"):FindFirstChild("Client")
    if not enemiesFolder then
        warn("❌ Enemies folder not found!")
        return nil
    end

    local player = game.Players.LocalPlayer
    if not player or not player.Character or not player.Character.PrimaryPart then
        return nil
    end

    local playerPosition = player.Character.PrimaryPart.Position
    local validEnemies = {}

    -- สแกนหาศัตรูที่มี HP มากกว่า 0 และอยู่ในระยะที่กำหนด
    for _, enemy in ipairs(enemiesFolder:GetChildren()) do
        if enemy:IsA("Model") and enemy.PrimaryPart and getEnemyHPX2(enemy) > 0 then
            local distance = (enemy.PrimaryPart.Position - playerPosition).Magnitude
            if distance <= TP_RANGE then
                table.insert(validEnemies, {enemy = enemy, distance = distance})
            end
        end
    end

    if #validEnemies == 0 then
        warn("❌ No valid enemies found within range!")
        return nil
    end

    -- เรียงลำดับศัตรูจากใกล้สุดไปไกลสุด
    table.sort(validEnemies, function(a, b) return a.distance < b.distance end)
    return validEnemies[1].enemy
end

-- หา Room_X ที่มีเลขสูงสุด
local function GetHighestRoomModel()
    local worldFolder = workspace:WaitForChild("__Main"):WaitForChild("__World")
    local highestNumber = 0
    local highestRoom = nil

    for _, obj in pairs(worldFolder:GetChildren()) do
        if obj:IsA("Model") and obj.Name:match("^Room_(%d+)$") then
            local num = tonumber(obj.Name:match("%d+"))
            if num > highestNumber then
                highestNumber = num
                highestRoom = obj
            end
        end
    end

    return highestRoom
end

-- ฟังก์ชัน teleport ทีละ 100 studs ไปหาจุดหมาย
local function TeleportGraduallyToTarget(targetPos, stepSize)
    local Players = game:GetService("Players")
    local player = Players.LocalPlayer
    local hrp = player.Character and player.Character:WaitForChild("HumanoidRootPart")
    stepSize = stepSize or 100

    while hrp and (hrp.Position - targetPos).Magnitude > stepSize do
        local direction = (targetPos - hrp.Position).Unit
        local nextPos = hrp.Position + direction * stepSize
        hrp.CFrame = CFrame.new(nextPos)
        task.wait(0.1)
    end

    -- เทเลพอร์ตตำแหน่งสุดท้ายแบบเป๊ะ
    hrp.CFrame = CFrame.new(targetPos + Vector3.new(0, 5, 0)) -- เผื่อยกขึ้นจากพื้น
end

-- เริ่มกระบวนการ
local function TeleportToLatestRoomStepByStep()
    local room = GetHighestRoomModel()
    if not room then
        warn("ไม่พบ Room_ ใด ๆ")
        return
    end

    print("กำลังวาร์ปแบบทีละ 100m ไปยัง:", room.Name)

    local spawn = room:FindFirstChild("PlayersSpawns", true)
    local targetPos

    if spawn and spawn:IsA("BasePart") then
        targetPos = spawn.Position
    else
        targetPos = room:GetPivot().Position
    end

    TeleportGraduallyToTarget(targetPos, 100)
    print("ถึงที่หมายแล้ว:", room.Name)
end

function tpToFirstEnemyPartStep()
    local enemyFolder = workspace.__Main.__Enemies.Server
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local hrp = character:WaitForChild("HumanoidRootPart")

    for _, enemy in pairs(enemyFolder:GetChildren()) do
        local targetCFrame = nil

        if enemy:IsA("Model") and enemy:FindFirstChild("HumanoidRootPart") then
            targetCFrame = enemy.HumanoidRootPart.CFrame
        elseif enemy:IsA("BasePart") then
            targetCFrame = enemy.CFrame
        end

        if targetCFrame then
            local currentPos = hrp.Position
            local targetPos = targetCFrame.Position + Vector3.new(0, 5, 0)
            local distance = (targetPos - currentPos).Magnitude
            local stepSize = 100

            print("เริ่มเทเลพอร์ตทีละ 100 หน่วย ไปยัง:", enemy.Name)

            while distance > stepSize do
                local direction = (targetPos - currentPos).Unit
                currentPos = currentPos + direction * stepSize
                hrp.CFrame = CFrame.new(currentPos)
                wait(0.05) -- รอเล็กน้อยก่อนขยับครั้งต่อไป
                distance = (targetPos - currentPos).Magnitude
            end

            -- วาร์ปสุดท้ายไปยังจุดเป้าหมาย
            hrp.CFrame = CFrame.new(targetPos)
            print("ถึงเป้าหมาย:", enemy.Name)
            return
        end
    end

    warn("ไม่พบศัตรูใน workspace.__Main.__Enemies.Server")
end
local function getClosestEnemyWithinRangeEx(TP_RANGE)
    local enemiesFolder = workspace:FindFirstChild("__Main"):FindFirstChild("__Enemies"):FindFirstChild("Client")
    if not enemiesFolder then
        warn("Enemies folder not found!")
        return nil
    end
    
    local player = game.Players.LocalPlayer
    if not player or not player.Character or not player.Character.PrimaryPart then
        return nil
    end

    local playerPosition = player.Character.PrimaryPart.Position
    local validEnemies = {}
    
    for _, enemy in ipairs(enemiesFolder:GetChildren()) do
        if enemy:IsA("Model") and enemy.PrimaryPart and getEnemyHPX2(enemy) > 0 then
            local distance = (enemy.PrimaryPart.Position - playerPosition).Magnitude
            if distance <= TP_RANGE then
                table.insert(validEnemies, {enemy = enemy, distance = distance})
            end
        end
    end
    
    if #validEnemies == 0 then

        if  autoinf then
            -- เรียกใช้เลย
            TeleportToLatestRoomStepByStep()                     
        end 
        if  autoDungeon then
            -- เรียกใช้เลย
            tpToFirstEnemyPartStep()                     
        end 
        warn("No valid enemies found within range!")
        return nil
    end
    
    table.sort(validEnemies, function(a, b) return a.distance < b.distance end)
    return validEnemies[1].enemy
end
-- ฟังก์ชันโจมตี
function attack(enemy)
    local enemyPosition = enemy.HumanoidRootPart.Position
    local adjustedPosition = Vector3.new(enemyPosition.X + 1, enemyPosition.Y , enemyPosition.Z)
    local petNames = {}

    for _, folder in ipairs(workspace.__Main.__Pets:GetChildren()) do
        if folder:FindFirstChild(enemy.Name) then
            enemyData = folder[enemy.Name]
            table.insert(petNames, enemyData)
            break
        end
    end

    -- for _, pet in pairs(workspace.__Main.__Pets["3080585905"]:GetChildren()) do
     --   table.insert(petNames, pet.Name)
   -- end

    local petPosArgs = {}
    for _, petName in pairs(petNames) do
        petPosArgs[petName] = adjustedPosition
    end

    local args = {
        [1] = {
            [1] = {
                ["PetPos"] = petPosArgs,
                ["AttackType"] = "All",
                ["Event"] = "Attack",
                ["Enemy"] = enemy.Name
            },
            [2] = "\5"
        }
    }
    character:SetPrimaryPartCFrame(CFrame.new(adjustedPosition))
    wait(0.2)
    game:GetService("ReplicatedStorage").BridgeNet2.dataRemoteEvent:FireServer(unpack(args))
end
function equipBestPets()
    local player = game:GetService("Players").LocalPlayer
    local inventory = player:FindFirstChild("leaderstats") and player.leaderstats:FindFirstChild("Inventory")

    if inventory and inventory:FindFirstChild("Pets") then
        local petsFolder = inventory.Pets
        local maxRank = 0
        local bestPets = {} -- เก็บรายชื่อสัตว์เลี้ยงที่ดีที่สุด
        -- ค้นหาสัตว์เลี้ยงที่มี Rank สูงสุด
        for _, pet in ipairs(petsFolder:GetChildren()) do
            if pet:IsA("Folder") or pet:IsA("Model") then
                local attributes = pet:GetAttributes() -- ดึง Attributes ทั้งหมด
                if attributes and attributes.Rank then
                    local petRank = tonumber(attributes.Rank)
                    if petRank then
                        if petRank > maxRank then
                            maxRank = petRank
                            bestPets = {pet.Name} -- เริ่มเก็บสัตว์เลี้ยงที่มี Rank สูงสุด
                        elseif petRank == maxRank then
                            table.insert(bestPets, pet.Name) -- เพิ่มสัตว์เลี้ยงที่มี Rank เท่ากับสูงสุด
                        end
                    end
                else
                    print("Pet has no Rank attribute:", pet.Name)
                end
            end
        end
        -- ส่งคำสั่งไปยังเซิร์ฟเวอร์เพื่อ Equip สัตว์เลี้ยงที่ดีที่สุด
        if #bestPets > 0 then
            local args = {
                [1] = {
                    [1] = {
                        ["Event"] = "EquipBest",
                        ["Pets"] = bestPets
                    },
                    [2] = "\t"
                }
            }
            game:GetService("ReplicatedStorage").BridgeNet2.dataRemoteEvent:FireServer(unpack(args))
            print("Equipped Best Pets:", table.concat(bestPets, ", "))
        else
            print("No pets found with a valid Rank.")
        end
    else
        print("No Pets Inventory Found!")
    end
end
local VirtualInputManager = game:GetService("VirtualInputManager")
function Button1Down()
    local x, y = workspace.CurrentCamera.ViewportSize.X / 2, workspace.CurrentCamera.ViewportSize.Y / 2
    VirtualInputManager:SendMouseButtonEvent(x - 200, y, 0, true, game, 0)
    wait(0.05)
    VirtualInputManager:SendMouseButtonEvent(x - 200, y, 0, false, game, 0)
end   
function PunchATT(Enemye)
       
    while Punch do
        local args = {
            [1] = {
                [1] = {
                    ["Event"] = "PunchAttack",
                    ["Enemy"] = Enemye
                },
                [2] = "\5"
            }
        }
        Button1Down()
        game:GetService("ReplicatedStorage").BridgeNet2.dataRemoteEvent:FireServer(unpack(args))
        wait(0.15) -- เพิ่ม wait เพื่อลดภาระการทำงาน
    end
end
function autoCreateAndStartDungeonex()
    local args = {
        [1] = {
            [1] = {
                ["Type"] = "Gems",
                ["Event"] = "DungeonAction",
                ["Action"] = "BuyTicket"
            },
            [2] = "\n"
        }
    }  
    game:GetService("ReplicatedStorage").BridgeNet2.dataRemoteEvent:FireServer(unpack(args))
    -- รอเล็กน้อยเพื่อความชัวร์ก่อน Start
    task.wait(0.15)
    -- เรียกใช้งาน Create
    local argsCreate = {
        [1] = {
            [1] = {
                ["Event"] = "DungeonAction",
                ["Action"] = "Create"
            },
            [2] = "\n"
        }
    }
    game:GetService("ReplicatedStorage").BridgeNet2.dataRemoteEvent:FireServer(unpack(argsCreate))

    -- รอเล็กน้อยเพื่อความชัวร์ก่อน Start
    task.wait(0.25)

    -- เรียกใช้งาน Start
    local argsStart = {
        [1] = {
            [1] = {
                ["Dungeon"] = doubleID,
                ["Event"] = "DungeonAction",
                ["Action"] = "Start"
            },
            [2] = "\n"
        }
    }
    game:GetService("ReplicatedStorage").BridgeNet2.dataRemoteEvent:FireServer(unpack(argsStart))
end
local function autoCreateAndStartDungeon()
    local dungeonFolder = workspace:FindFirstChild("__Main")
    if not dungeonFolder then
        warn("ไม่พบ __Main ใน workspace")
        return
    end

    dungeonFolder = dungeonFolder:FindFirstChild("__Dungeon")
    if not dungeonFolder then
        warn("ไม่พบ __Dungeon ใน __Main")
        return
    end

   -- print("=== สแกน Dungeon เพื่อ Auto Start ===")
    for _, obj in ipairs(dungeonFolder:GetDescendants()) do
        if (obj:IsA("Model") or obj:IsA("BasePart")) and obj.Name == "Dungeon" then
            local doubleID = obj:GetAttribute("DoubleID")
            local doubleRank = obj:GetAttribute("DoubleRank")

            if doubleID then
                print("- Dungeon:", obj:GetFullName())
                print("  DoubleID:", doubleID)
                print("  DoubleRank:", doubleRank)
                local args = {
                    [1] = {
                        [1] = {
                            ["Type"] = "Gems",
                            ["Event"] = "DungeonAction",
                            ["Action"] = "BuyTicket"
                        },
                        [2] = "\n"
                    }
                }
                
                game:GetService("ReplicatedStorage").BridgeNet2.dataRemoteEvent:FireServer(unpack(args))
                task.wait(0.15)
                -- เรียกใช้งาน Create
                local argsCreate = {
                    [1] = {
                        [1] = {
                            ["Event"] = "DungeonAction",
                            ["Action"] = "Create"
                        },
                        [2] = "\n"
                    }
                }
                game:GetService("ReplicatedStorage").BridgeNet2.dataRemoteEvent:FireServer(unpack(argsCreate))

                -- รอเล็กน้อยเพื่อความชัวร์ก่อน Start
                task.wait(0.25)

                -- เรียกใช้งาน Start
                local argsStart = {
                    [1] = {
                        [1] = {
                            ["Dungeon"] = doubleID,
                            ["Event"] = "DungeonAction",
                            ["Action"] = "Start"
                        },
                        [2] = "\n"
                    }
                }
                game:GetService("ReplicatedStorage").BridgeNet2.dataRemoteEvent:FireServer(unpack(argsStart))

                print("✅ สร้างและเริ่ม Dungeon สำเร็จ")
                break -- หยุดหลังเจออันแรก
            end
        end
    end
end
function Autoinfex()

    local args = {
        [1] = {
            [1] = {
                ["Event"] = "JoinCastle"
            },
            [2] = "\n"
        }
    }
    game:GetService("ReplicatedStorage").BridgeNet2.dataRemoteEvent:FireServer(unpack(args)) 
end
-- ====== เทเลพอร์ตไปหามอนทีละ 100m ======
function tpToEnemy(enemy)
    local enemyPosition = enemy.HumanoidRootPart.Position
    local characterPosition = character.PrimaryPart.Position
    local direction = (enemyPosition - characterPosition).Unit
    local stepDistance = 80
    local minDistance = 150

    while true do
        local distance = (characterPosition - enemyPosition).Magnitude
        if distance <= minDistance then break end

        local moveDistance = math.min(stepDistance, distance)
        local nextPosition = characterPosition + direction * moveDistance
        character:SetPrimaryPartCFrame(CFrame.new(nextPosition))

        characterPosition = nextPosition
        task.wait(0.2)
    end

    -- ไปยืนข้าง ๆ มอน
    local adjustedPosition = enemyPosition + Vector3.new(1, 0, 0)
    character:SetPrimaryPartCFrame(CFrame.new(adjustedPosition))
end
   
function attackLoopDungen()  
    while attackRunningDungen do  -- ใช้ attackRunning เพื่อตรวจสอบการเปิดใช้งาน
        local closestEnemy = getClosestEnemyWithinRangeEx(TP_RANGE)
        --local closestEnemy, nextClosestEnemy = findClosestEnemies()
        if not closestEnemy then
            warn("No enemy found!")
            break
        end  

        -- เทเลพอร์ตไปหามอน
        --tpToEnemyss(closestEnemy)      
        -- เมื่อเจอศัตรูที่อยู่ในระยะ
        if autoDungeon then
           autoCreateAndStartDungeon()  -- สร้างและเริ่มดันเจี้ยนใหม่
        end
        if autoinf then           
            Autoinfex()  -- สร้างและเริ่มดันเจี้ยนใหม่  
            
        end

        if equipBestPetsex then
            equipBestPets()  -- สวมใส่สัตว์เลี้ยงที่ดีที่สุด
        end

        -- โจมตีศัตรูที่ใกล้ที่สุด
        attack(closestEnemy)
        wait(0.2)

        attack(closestEnemy)
        --if  Punch then
        --    PunchATT(closestEnemy.Name)          
        --end
        
        local hp = getEnemyHPX2(closestEnemy)
        -- ตรวจสอบว่า HP หมดหรือไม่
        if hp <= 0 then
            repeat
            --wait(0.2)
            until getEnemyHPX2(closestEnemy) <= 0
            getEnemyCapture(closestEnemy.Name)           
        end
        -- ค้นหามอนใหม่ที่ HP > 0 และอยู่ในระยะ TP
        repeat
            wait(0.1)
            closestEnemy = getClosestEnemyWithinRangeEx(TP_RANGE)
        until closestEnemy and getEnemyHPX2(closestEnemy) > 0  
        tpToEnemy(closestEnemy)
        if closestEnemy then
            closestEnemy = getClosestEnemyWithinRangeEx(TP_RANGE)
            tpToEnemy(closestEnemy)
        end
        wait(0.1)

    end
    attackRunningDungen = false  -- เปลี่ยนสถานะเมื่อเลิกทำงาน
end
----**Auto Sell**----
function autosell()
    local player = game:GetService("Players").LocalPlayer
    local inventory = player:FindFirstChild("leaderstats") and player.leaderstats:FindFirstChild("Inventory")

    if inventory and inventory:FindFirstChild("Pets") then
        local petsFolder = inventory.Pets
        local petsToSell = {} -- เก็บรายชื่อสัตว์เลี้ยงที่จะขาย

        for _, pet in ipairs(petsFolder:GetChildren()) do
            if pet:IsA("Folder") or pet:IsA("Model") then
                local attributes = pet:GetAttributes() -- ดึง Attributes ทั้งหมด
                if attributes and attributes.Rank then
                    local petRank = tonumber(attributes.Rank)
                    if petRank and petRank == SelectRank then
                        --print("Selling Pet with Rank 1:", pet.Name)
                        table.insert(petsToSell, pet.Name) -- เพิ่มชื่อสัตว์เลี้ยงเข้าไปในตาราง
                    end
                else
                    --print("Pet has no Rank attribute:", pet.Name)
                end
            end
        end

        -- ถ้ามีสัตว์เลี้ยงที่ตรงกับ Rank ที่ต้องการขาย
        if #petsToSell > 0 then
            for _, petName in ipairs(petsToSell) do
                local args = {
                    [1] = {
                        [1] = {
                            ["Event"] = "SellPet",
                            ["Pets"] = {
                                [1] = petName
                            }
                        },
                        [2] = "\5"
                    }
                }
                game:GetService("ReplicatedStorage").BridgeNet2.dataRemoteEvent:FireServer(unpack(args))
                --print("Sold Pet:", petName)
                wait(0.1) -- ป้องกันการยิงคำสั่งเร็วเกินไป
            end
        else
           -- print("No pets with Rank 1 found to sell.")
        end
    else
       -- print("No Pets Inventory Found!")
    end
end
function autosellex()
while autosellexe do
    autosell()
    wait(10) -- รอ 5 วินาทีก่อนตรวจสอบและขายอีกครั้ง
end
end
