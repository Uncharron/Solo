local httpService = game:GetService("HttpService")
local UIS = game:GetService("UserInputService")
local InterfaceManager = {} do
    InterfaceManager.Folder = "FluentSettings"
    InterfaceManager.Settings = {
        Theme = "Dark",
        Acrylic = true,
        Transparency = true,
        MenuKeybind = "LeftControl"
    }

    -- สร้างฟังก์ชันสำหรับเพิ่มปุ่มเปิด/ปิดเมนู
    function InterfaceManager:AddMenuButton()
        local button = Instance.new("ImageButton")
        button.Size = UDim2.new(0, 40, 0, 40)
        button.Position = UDim2.new(0, 10, 0, 10) -- ตั้งตำแหน่งของปุ่ม
        button.Image = "rbxassetid://1234567890"  -- เปลี่ยนเป็น asset ID ของไอคอนที่ต้องการ
        button.Parent = game.Players.LocalPlayer.PlayerGui:WaitForChild("ScreenGui")

        -- เพิ่มการคลิกเพื่อเปิด-ปิดเมนู
        button.MouseButton1Click:Connect(function()
            InterfaceManager:ToggleMenu()
        end)
    end

    -- สร้างฟังก์ชัน Toggle เมนู
    function InterfaceManager:ToggleMenu()
        local menu = game.Players.LocalPlayer.PlayerGui:FindFirstChild("Menu")
        if menu then
            menu.Visible = not menu.Visible  -- สลับการแสดงหรือซ่อนเมนู
        end
    end

    -- ฟังก์ชันสร้างและจัดการโครงสร้างการตั้งค่า
    function InterfaceManager:SetFolder(folder)
        self.Folder = folder
        self:BuildFolderTree()
    end

    function InterfaceManager:SetLibrary(library)
        self.Library = library
    end

    function InterfaceManager:BuildFolderTree()
        local paths = {}

        local parts = self.Folder:split("/")
        for idx = 1, #parts do
            paths[#paths + 1] = table.concat(parts, "/", 1, idx)
        end

        table.insert(paths, self.Folder)
        table.insert(paths, self.Folder .. "/settings")

        for i = 1, #paths do
            local str = paths[i]
            if not isfolder(str) then
                makefolder(str)
            end
        end
    end

    function InterfaceManager:SaveSettings()
        writefile(self.Folder .. "/options.json", httpService:JSONEncode(InterfaceManager.Settings))
    end

    function InterfaceManager:LoadSettings()
        local path = self.Folder .. "/options.json"
        if isfile(path) then
            local data = readfile(path)
            local success, decoded = pcall(httpService.JSONDecode, httpService, data)

            if success then
                for i, v in next, decoded do
                    InterfaceManager.Settings[i] = v
                end
            end
        end
    end

    function InterfaceManager:BuildInterfaceSection(tab)
        assert(self.Library, "Must set InterfaceManager.Library")
        local Library = self.Library
        local Settings = InterfaceManager.Settings

        InterfaceManager:LoadSettings()

        local section = tab:AddSection("Interface")

        local InterfaceTheme = section:AddDropdown("InterfaceTheme", {
            Title = "Theme",
            Description = "Changes the interface theme.",
            Values = Library.Themes,
            Default = Settings.Theme,
            Callback = function(Value)
                Library:SetTheme(Value)
                Settings.Theme = Value
                InterfaceManager:SaveSettings()
            end
        })

        InterfaceTheme:SetValue(Settings.Theme)
    
        if Library.UseAcrylic then
            section:AddToggle("AcrylicToggle", {
                Title = "Acrylic",
                Description = "The blurred background requires graphic quality 8+",
                Default = Settings.Acrylic,
                Callback = function(Value)
                    Library:ToggleAcrylic(Value)
                    Settings.Acrylic = Value
                    InterfaceManager:SaveSettings()
                end
            })
        end
    
        section:AddToggle("TransparentToggle", {
            Title = "Transparency",
            Description = "Makes the interface transparent.",
            Default = Settings.Transparency,
            Callback = function(Value)
                Library:ToggleTransparency(Value)
                Settings.Transparency = Value
                InterfaceManager:SaveSettings()
            end
        })
    
        local MenuKeybind = section:AddKeybind("MenuKeybind", { Title = "Minimize Bind", Default = Settings.MenuKeybind })
        MenuKeybind:OnChanged(function()
            Settings.MenuKeybind = MenuKeybind.Value
            InterfaceManager:SaveSettings()
        end)
        Library.MinimizeKeybind = MenuKeybind
    end
end

return InterfaceManager
