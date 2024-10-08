require(script.Parent.Configify)

local Test1 = _G.Cfg:Set("Test1", 500, 0, 1000)
local Test2 = _G.Cfg:Set("Test2", true)

local runservice = game:GetService("RunService")

local ui = require(script.UI)

runservice.RenderStepped:Connect(function(deltaTime)
    local s = ui.ScrollingFrame

    s.NumberTest.Text = Test1()
    s.BooleanTest.Text = "Test2 value: " .. tostring(Test2())
end)