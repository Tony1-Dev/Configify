local COLOR_A = script.Parent:GetAttribute("COLOR_A") or Color3.fromRGB(45, 45, 45)
local COLOR_B = script.Parent:GetAttribute("COLOR_B") or Color3.fromRGB(25, 25, 25)
local COLOR_C = script.Parent:GetAttribute("COLOR_C") or Color3.fromRGB(18, 18, 18)
local COLOR_D = script.Parent:GetAttribute("COLOR_D") or Color3.fromRGB(60, 60, 60)
local COLOR_E = script.Parent:GetAttribute("COLOR_E") or Color3.fromRGB(255, 255, 255)
local COLOR_TRUE = script.Parent:GetAttribute("COLOR_TRUE") or Color3.fromRGB(125, 125, 125)

local players = game:GetService("Players")

local player = players.LocalPlayer
local player_gui = player:WaitForChild("PlayerGui")

local function create(inst_type: Instance, config: {}, ...)
    local children = {...}
    local inst = Instance.new(inst_type)

    for prop_name, prop_val in config do
        inst[prop_name] = prop_val
    end

    for _, child in children do
        child["Parent"] = inst
    end

    return inst
end

local ui = create(
    "ScreenGui", {
        ["Name"] = "ConfigifyTest",
        ["Enabled"] = true,
        ["IgnoreGuiInset"] = true,
        ["ResetOnSpawn"] = false,
        ["ZIndexBehavior"] = Enum.ZIndexBehavior.Global,
        ["Parent"] = player_gui
    },

    create(
        "ScrollingFrame", {
            ["AnchorPoint"] = Vector2.new(0.5, 0.5),
            ["BackgroundColor3"] = COLOR_A,
            ["Position"] = UDim2.fromScale(0.5, 0.5),
            ["Size"] = UDim2.fromOffset(300, 100),
            ["AutomaticCanvasSize"] = Enum.AutomaticSize.Y,
            ["CanvasSize"] = UDim2.fromScale(0, 0),
            ["ScrollBarThickness"] = 2,
            ["ScrollBarImageColor3"] = Color3.fromRGB(0, 0, 0),
            ["VerticalScrollBarInset"] = Enum.ScrollBarInset.ScrollBar,
        },

        create(
            "UIListLayout", {
                ["FillDirection"] = Enum.FillDirection.Vertical,
                ["Padding"] = UDim.new(0, 5)
            }
        ),

        create(
            "UIPadding", {
                ["PaddingBottom"] = UDim.new(0, 5),
                ["PaddingTop"] = UDim.new(0, 5),
                ["PaddingLeft"] = UDim.new(0, 5),
                ["PaddingRight"] = UDim.new(0, 5),
            }
        ),

        create(
            "TextLabel", {
                ["Name"] = "NumberTest",
                ["BackgroundColor3"] = COLOR_C,
                ["Size"] = UDim2.new(1, 0, 0, 25),
                ["Text"] = "",
                ["TextColor3"] = COLOR_E
            }
        ),

        create(
            "TextLabel", {
                ["Name"] = "BooleanTest",
                ["BackgroundColor3"] = COLOR_C,
                ["Size"] = UDim2.new(1, 0, 0, 25),
                ["Text"] = "",
                ["TextColor3"] = COLOR_E
            }
        ),

        create(
            "TextLabel", {
                ["Name"] = "StringTest",
                ["BackgroundColor3"] = COLOR_C,
                ["Size"] = UDim2.new(1, 0, 0, 25),
                ["Text"] = "N/A",
                ["TextColor3"] = COLOR_E
            }
        )
    )
)

return ui