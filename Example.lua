--[[
    Contoh Penggunaan AstroHubV3 GUI Library
    
    Cara menggunakan:
    1. Load library dengan loadstring
    2. Buat window
    3. Buat tab
    4. Tambahkan komponen UI
]]

-- Load AstroHubV3 Library
local AstroHubV3 = loadstring(game:HttpGet("https://raw.githubusercontent.com/hailazra/Loader/refs/heads/main/AstroHubV3.lua"))()

-- Buat Window
local Window = AstroHubV3:CreateWindow({
    Name = "AstroHubV3 - Example Script",
    Theme = "Space" -- atau "Manga"
})

-- Buat Tab Home
local HomeTab = Window:CreateTab({
    Name = "Home",
    Icon = "🏠"
})

-- Tambahkan Section
HomeTab:CreateSection({
    Name = "Welcome to AstroHubV3"
})

-- Tambahkan Toggle
local AutoFarmToggle = HomeTab:CreateToggle({
    Name = "Auto Farm",
    Description = "Automatically farm resources",
    Default = false,
    Callback = function(value)
        print("Auto Farm:", value)
        -- Implementasi auto farm di sini
    end
})

-- Tambahkan Button
HomeTab:CreateButton({
    Name = "Teleport to Spawn",
    Description = "Instantly teleport to spawn point",
    Callback = function()
        local player = game.Players.LocalPlayer
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = CFrame.new(0, 50, 0)
        end
        print("Teleported to spawn!")
    end
})

-- Tambahkan Slider
local WalkSpeedSlider = HomeTab:CreateSlider({
    Name = "Walk Speed",
    Description = "Change your walking speed",
    Min = 16,
    Max = 100,
    Default = 16,
    Increment = 1,
    Callback = function(value)
        local player = game.Players.LocalPlayer
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.WalkSpeed = value
        end
        print("Walk Speed set to:", value)
    end
})

-- Buat Tab Settings
local SettingsTab = Window:CreateTab({
    Name = "Settings",
    Icon = "⚙️"
})

-- Tambahkan Textbox
local PlayerNameTextbox = SettingsTab:CreateTextbox({
    Name = "Player Name",
    Description = "Enter a player name to target",
    Default = "",
    PlaceholderText = "Enter player name...",
    Callback = function(text)
        print("Target player:", text)
    end
})

-- Tambahkan Dropdown
local ThemeDropdown = SettingsTab:CreateDropdown({
    Name = "Theme",
    Description = "Select GUI theme",
    Options = {"Manga", "Space"},
    Default = "Space",
    Callback = function(option)
        Window:SetTheme(option)
        print("Theme changed to:", option)
    end
})

-- Tambahkan Keybind
local ToggleGUIKeybind = SettingsTab:CreateKeybind({
    Name = "Toggle GUI",
    Description = "Keybind to show/hide GUI",
    Default = Enum.KeyCode.RightControl,
    Callback = function()
        Window.IsMinimized = not Window.IsMinimized
        if Window.IsMinimized then
            Window.MainFrame:TweenSize(UDim2.new(0, 200, 0, 35), "Out", "Quad", 0.3, true)
        else
            Window.MainFrame:TweenSize(UDim2.new(0, 500, 0, 250), "Out", "Quad", 0.3, true)
        end
    end
})

-- Tambahkan ColorPicker
local ESPColorPicker = SettingsTab:CreateColorPicker({
    Name = "ESP Color",
    Description = "Color for ESP features",
    Default = Color3.fromRGB(255, 0, 0),
    Callback = function(color)
        print("ESP Color:", color)
        -- Implementasi ESP color di sini
    end
})

-- Buat Tab Misc
local MiscTab = Window:CreateTab({
    Name = "Misc",
    Icon = "🔧"
})

MiscTab:CreateSection({
    Name = "Utility Functions"
})

-- Tambahkan Button untuk save config
MiscTab:CreateButton({
    Name = "Save Config",
    Description = "Save current settings",
    Callback = function()
        Window:SaveConfig("MyConfig")
    end
})

-- Tambahkan Button untuk load config
MiscTab:CreateButton({
    Name = "Load Config",
    Description = "Load saved settings",
    Callback = function()
        Window:LoadConfig("MyConfig")
    end
})

-- Tambahkan Button untuk notification test
MiscTab:CreateButton({
    Name = "Test Notification",
    Description = "Show a test notification",
    Callback = function()
        AstroHubV3:CreateNotification({
            Title = "Test Notification",
            Content = "This is a test notification from AstroHubV3!",
            Duration = 3
        })
    end
})

-- Contoh penggunaan advanced
spawn(function()
    wait(2)
    AstroHubV3:CreateNotification({
        Title = "AstroHubV3 Loaded",
        Content = "GUI Library loaded successfully! Welcome to AstroHubV3.",
        Duration = 4
    })
end)

print("AstroHubV3 Example Script Loaded!")
print("Press Right Control to toggle GUI visibility")

