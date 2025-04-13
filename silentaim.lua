local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local aimPart = game.Workspace:FindFirstChild("AimPart")
local targetsFolder = game.Workspace:FindFirstChild("Targets")


-- Define the FoV circle
local fovCircle = Drawing.new("Circle")
fovCircle.Visible = true
fovCircle.Radius = 100 -- Default FoV radius
fovCircle.Thickness = 2
fovCircle.Color = Color3.new(1, 1, 1) -- White
fovCircle.Position = Vector2.new(workspace.CurrentCamera.ViewportSize.X / 2, workspace.CurrentCamera.ViewportSize.Y / 2)


-- Define aim types
local aimTypes = {
   ClosestInFoV = function(touchPosition)
       local closestTarget = nil
       local shortestDistance = math.huge


       for _, target in pairs(targetsFolder:GetChildren()) do
           if target:IsA("Model") and target:FindFirstChild("Head") then
               local screenPosition, onScreen = workspace.CurrentCamera:WorldToViewportPoint(target.Head.Position)
               if onScreen then
                   local distanceFromCenter = (Vector2.new(screenPosition.X, screenPosition.Y) - fovCircle.Position).Magnitude
                   if distanceFromCenter <= fovCircle.Radius then
                       local distance = (touchPosition - target.Head.Position).Magnitude
                       if distance < shortestDistance then
                           closestTarget = target
                           shortestDistance = distance
                       end
                   end
               end
           end
       end


       return closestTarget
   end
}


-- Current aim type (can be changed dynamically)
local currentAimType = "ClosestInFoV"


-- Function to get the target based on the selected aim type
local function getTarget(touchPosition)
   local aimFunction = aimTypes[currentAimType]
   if aimFunction then
       return aimFunction(touchPosition)
   else
       warn("Invalid aim type: " .. tostring(currentAimType))
       return nil
   end
end


-- Function to handle touch movement
local function onTouchMove(touch)
   if not touch.Position then return end
   local touchPosition = touch.Position
   local target = getTarget(touchPosition)


   if target and aimPart then
       aimPart.CFrame = CFrame.new(target.Head.Position)
   end
end


-- Function to handle touch tap
local function onTouchTap(touch)
   if not touch.Position then return end
   local touchPosition = touch.Position
   local target = getTarget(touchPosition)


   if target and aimPart then
       aimPart.CFrame = CFrame.new(target.Head.Position)
   end
end


-- Connect touch move event
game:GetService("UserInputService").TouchMoved:Connect(function(touch)
   onTouchMove(touch)
end)


-- Connect touch tap event
game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
   if input.UserInputType == Enum.UserInputType.Touch and not gameProcessed then
       onTouchTap(input)
   end
end)


-- Function to update the FoV circle position dynamically
game:GetService("RunService").RenderStepped:Connect(function()
   fovCircle.Position = Vector2.new(workspace.CurrentCamera.ViewportSize.X / 2, workspace.CurrentCamera.ViewportSize.Y / 2)
end)
