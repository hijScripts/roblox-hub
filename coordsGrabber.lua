-- get the GUI element you care about
local targetPart = game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.ActivateButton.KeyTag:FindFirstChild("GamepadButtonIcon")

if targetPart then
    -- get the absolute position of the GUI element
    local screenPosition = targetPart.AbsolutePosition
    
    -- screenPosition is already a Vector2 with X and Y screen coordinates
    local screenPoint = Vector2.new(screenPosition.X, screenPosition.Y)
    print(screenPoint)
else
    print("The GUI element is not found")
end