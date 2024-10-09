local DEBUG = script.Parent:GetAttribute("Debug") or false

local COLOR_A = script.Parent:GetAttribute("COLOR_A") or Color3.fromRGB(45, 45, 45)
local COLOR_B = script.Parent:GetAttribute("COLOR_B") or Color3.fromRGB(25, 25, 25)
local COLOR_C = script.Parent:GetAttribute("COLOR_C") or Color3.fromRGB(18, 18, 18)
local COLOR_D = script.Parent:GetAttribute("COLOR_D") or Color3.fromRGB(60, 60, 60)
local COLOR_E = script.Parent:GetAttribute("COLOR_E") or Color3.fromRGB(255, 255, 255)
local COLOR_TRUE = script.Parent:GetAttribute("COLOR_TRUE") or Color3.fromRGB(109, 223, 99)

local MIN_SIZE_X = 180 -- pixels

local DRAG_LERP_ALPHA = 0.25
local RESIZE_LERP_ALPHA = 1
local RESIZING_SPEED = 1

local players = game:GetService("Players")
local runservice = game:GetService("RunService")
local uis = game:GetService("UserInputService")

local player = players.LocalPlayer
local mouse = player:GetMouse()
local player_gui = player:WaitForChild("PlayerGui")

local signal = require(script.Parent.Dependencies.Signal)

local configify_ui = {}
configify_ui.__index = configify_ui

local function set_visible(parent, bool, type)
    for i, v in parent:GetChildren() do
        if not v:IsA(type) then
            continue
        end

        v.Visible = bool
    end
end

local function get_env_from_config_element(self, ui_object: TextButton)
    local tab_container = self._ScreenGui.Container.TabContainer
    local tab_name = ui_object.Parent.Name
    
    local client_search = tab_container.Client:FindFirstChild(tab_name)
    local server_search = tab_container.Server:FindFirstChild(tab_name)

    if client_search and server_search then
        error(`You have scripts called the exact same thing ({tab_name}) in the server and client, this isn't supported by Configify!`)
    end

    if client_search then
        return "Client"
    elseif server_search then
        return "Server"
    end
end

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

function configify_ui.new()
    local self = setmetatable({}, configify_ui)

    self._current_env = nil
    self._current_tab = nil
    self._ScreenGui = nil
    self.UIChanged = signal.new()

    self:_Init()
    
    return self
end

function configify_ui:_Init()
    local ui = create(
        "ScreenGui", {
            ["Name"] = "Configify",
            ["Enabled"] = DEBUG and true or false,
            ["IgnoreGuiInset"] = true,
            ["ResetOnSpawn"] = false,
            ["ZIndexBehavior"] = Enum.ZIndexBehavior.Global,
            ["DisplayOrder"] = 100,
            ["Parent"] = player_gui
        },

        create(
            "Frame", {
                ["Name"] = "Container",
                ["Position"] = UDim2.fromScale(0.5, 0.5),
                ["Size"] = UDim2.fromOffset(200, 0),
                ["BackgroundColor3"] = COLOR_A,
                ["AutomaticSize"] = Enum.AutomaticSize.Y,
                ["BorderSizePixel"] = 0,
            },

            create(
                "ImageButton", {
                    ["Name"] = "Resize",
                    ["Position"] = UDim2.new(1, 0, 1, 0),
                    ["AnchorPoint"] = Vector2.new(1, 1),
                    ["Size"] = UDim2.fromOffset(15, 15),
                    ["BorderSizePixel"] = 0,
                    ["AutoButtonColor"] = false,
                    ["BackgroundTransparency"] = 1,
                    ["ImageTransparency"] = 0,
                    ["Image"] = "rbxassetid://81689986742785"
                }
            ),

            create(
                "TextButton", {
                    ["Name"] = "Drag",
                    ["Text"] = "",
                    ["BackgroundColor3"] = COLOR_C,
                    ["Size"] = UDim2.new(1, 0, 0, 6),
                    ["Position"] = UDim2.new(0, 0, 0, -60),
                    ["AnchorPoint"] = Vector2.new(0, 1),
                    ["AutoButtonColor"] = false
                }
            ),

            create(
                "Frame", {
                    ["Name"] = "EnvContainer",
                    ["AnchorPoint"] = Vector2.new(0, 1),
                    ["Position"] = UDim2.new(0, 0, 0, -30),
                    ["Size"] = UDim2.new(1, 0, 0, 25),
                    ["BackgroundColor3"] = COLOR_C,
                },

                create(
                    "UIPadding", {
                        ["PaddingTop"] = UDim.new(0, 6),
                        ["PaddingBottom"] = UDim.new(0, 5),
                        ["PaddingLeft"] = UDim.new(0, 5),
                        ["PaddingRight"] = UDim.new(0, 5),
                    }
                ),

                create(
                    "TextButton", {
                        ["Name"] = "ClientBtn",
                        ["BackgroundTransparency"] = 1,
                        ["Size"] = UDim2.new(0.5, 0, 1, 0),
                        ["Text"] = "Client",
                        ["TextColor3"] = COLOR_E,
                        ["TextScaled"] = true,
                    },

                    create(
                        "UIStroke", {
                            ["Color"] = COLOR_D,
                            ["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border
                        }
                    )
                ),

                create(
                    "TextButton", {
                        ["Name"] = "ServerBtn",
                        ["AnchorPoint"] = Vector2.new(1, 0),
                        ["Position"] = UDim2.fromScale(1, 0),
                        ["BackgroundTransparency"] = 1,
                        ["Size"] = UDim2.new(0.5, 0, 1, 0),
                        ["Text"] = "Server",
                        ["TextColor3"] = COLOR_E,
                        ["TextScaled"] = true,
                    },

                    create(
                        "UIStroke", {
                            ["Color"] = COLOR_D,
                            ["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border
                        }
                    )
                )
            ),

            create(
                "ScrollingFrame", {
                    ["Name"] = "TabContainer",
                    ["AnchorPoint"] = Vector2.new(0, 1),
                    ["BackgroundColor3"] = COLOR_B,
                    ["Size"] = UDim2.new(1, 0, 0, 30),
                    ["AutomaticCanvasSize"] = Enum.AutomaticSize.X,
                    ["CanvasSize"] = UDim2.fromScale(0, 0),
                    ["ScrollBarThickness"] = 2,
                    ["ScrollBarImageColor3"] = Color3.fromRGB(0, 0, 0),
                    ["HorizontalScrollBarInset"] = Enum.ScrollBarInset.ScrollBar,
                },

                create(
                    "Folder", {
                        ["Name"] = "Client",
                    },

                    create(
                        "UIListLayout", {
                            ["FillDirection"] = Enum.FillDirection.Horizontal,
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
                    )
                ),

                create(
                    "Folder", {
                        ["Name"] = "Server",
                    },

                    create(
                        "UIListLayout", {
                            ["FillDirection"] = Enum.FillDirection.Horizontal,
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
                    )
                ),

                create(
                    "UIListLayout", {
                        ["FillDirection"] = Enum.FillDirection.Horizontal,
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
                )
            ),

            create(
                "ScrollingFrame", {
                    ["AutomaticCanvasSize"] = Enum.AutomaticSize.Y,
                    ["ScrollingDirection"] = Enum.ScrollingDirection.Y,
                    ["AutomaticSize"] = Enum.AutomaticSize.Y,
                    ["Size"] = UDim2.fromScale(1, 0),
                    ["BackgroundTransparency"] = 1,
                    ["ClipsDescendants"] = false,
                    ["CanvasSize"] = UDim2.fromScale(0, 0),
                    ["ScrollBarThickness"] = 4,
                    ["ScrollBarImageColor3"] = Color3.fromRGB(0, 0, 0),
                    ["VerticalScrollBarInset"] = Enum.ScrollBarInset.ScrollBar
                },
        
                create(
                    "UIPadding", {
                        ["PaddingBottom"] = UDim.new(0, 5),
                        ["PaddingTop"] = UDim.new(0, 5),
                        ["PaddingLeft"] = UDim.new(0, 5),
                        ["PaddingRight"] = UDim.new(0, 5),
                    }
                )
            )
        )
    )

    self._ScreenGui = ui

    local env_container = ui.Container.EnvContainer
    local tab_container = ui.Container.TabContainer
    local drag_btn: TextButton = ui.Container.Drag
    local resize_btn: ImageButton = ui.Container.Resize

    -- dragging/minimize logic
    drag_btn.MouseButton1Down:Connect(function(x, y)
        local click_or_hold = nil

        local thread = task.delay(0.1, function()
            if click_or_hold and click_or_hold.Connected then
                click_or_hold:Disconnect()
                click_or_hold = nil
            end

            local offset = ui.Container.AbsolutePosition - Vector2.new(mouse.X, mouse.Y)
    
            runservice:BindToRenderStep("Configify_DragStart", Enum.RenderPriority.Last.Value + 10, function(dt)
                local goal = UDim2.fromOffset(
                    mouse.X + offset.X, 
                    mouse.Y + offset.Y + env_container.Size.Y.Offset + tab_container.Size.Y.Offset
                )
                ui.Container.Position = ui.Container.Position:Lerp(goal, DRAG_LERP_ALPHA)
            end)

            local c
            c = uis.InputEnded:Connect(function(input)
                if not (input.UserInputType == Enum.UserInputType.MouseButton1) then
                    return
                end

                runservice:UnbindFromRenderStep("Configify_DragStart")
                c:Disconnect()
                c = nil
            end)
        end)

        click_or_hold = uis.InputEnded:Connect(function(input)
            if not (input.UserInputType == Enum.UserInputType.MouseButton1) then
                return
            end

            task.cancel(thread)
            click_or_hold:Disconnect()
            click_or_hold = nil

            -- Click behavior
            env_container.Visible = not env_container.Visible
            ui.Container.ScrollingFrame.Visible = not ui.Container.ScrollingFrame.Visible
            tab_container.Visible = not tab_container.Visible
            resize_btn.Visible = not resize_btn.Visible

            ui.Container.Size = UDim2.fromOffset(ui.Container.Size.X.Offset, 0)
        end)
    end)

    -- resizing logic
    resize_btn.MouseButton1Down:Connect(function(x, y)
        local mouse_delta = Vector2.zero
        local mouse_pos = Vector2.new(mouse.X, mouse.Y)
        ui.Container.Size = UDim2.fromOffset(ui.Container.Size.X.Offset, math.max(0, ui.Container.Size.Y.Offset))

        runservice:BindToRenderStep("Configify_ResizeStart", Enum.RenderPriority.Last.Value + 10, function(dt)
            local goal = UDim2.fromOffset(
                math.max(ui.Container.Size.X.Offset - (mouse_delta.X * RESIZING_SPEED), MIN_SIZE_X),
                ui.Container.Size.Y.Offset - (mouse_delta.Y * RESIZING_SPEED)
            )

            ui.Container.Size = ui.Container.Size:Lerp(goal, RESIZE_LERP_ALPHA)

            local new_pos = Vector2.new(mouse.X, mouse.Y)
            mouse_delta = mouse_pos - new_pos
            
            mouse_pos = new_pos
        end)

        local c
        c = uis.InputEnded:Connect(function(input)
            if not (input.UserInputType == Enum.UserInputType.MouseButton1) then
                return
            end

            runservice:UnbindFromRenderStep("Configify_ResizeStart")
            c:Disconnect()
            c = nil
        end)
    end)

    local function setup_hover(ui_obj: Frame)
        ui_obj.MouseEnter:Connect(function(x, y)
            self:_HoverStart(ui_obj)
        end)

        ui_obj.MouseLeave:Connect(function(x, y)
            self:_HoverStop(ui_obj)
        end)
    end

    setup_hover(env_container.ClientBtn)
    setup_hover(env_container.ServerBtn)

    env_container.ClientBtn.MouseButton1Click:Connect(function()
        self:_SelectEnvironment("Client")
    end)

    env_container.ServerBtn.MouseButton1Click:Connect(function()
        self:_SelectEnvironment("Server")
    end)

    --Init
    self:_SelectEnvironment("Client")
end

function configify_ui:AddTab(module_name, env_type: "Client" | "Server")
    -- Make folder for any config for this tab
    local tab_folder = create(
        "Folder", {
            ["Name"] = module_name,
            ["Parent"] = self._ScreenGui.Container.ScrollingFrame
        },

        create(
            "UIListLayout", {
                ["HorizontalAlignment"] = Enum.HorizontalAlignment.Center,
                ["Padding"] = UDim.new(0, 5)
            }
        ),

        create(
            "UIPadding", {
                ["PaddingBottom"] = UDim.new(0, 10),
                ["PaddingTop"] = UDim.new(0, 10),
                ["PaddingLeft"] = UDim.new(0, 10),
                ["PaddingRight"] = UDim.new(0, 10),
            }
        )
    )

    -- Make tab button
    local tab: TextButton = create(
        "TextButton", {
            ["Name"] = module_name,
            ["BackgroundColor3"] = COLOR_C,
            ["Font"] = Enum.Font.SourceSans,
            ["Text"] = module_name,
            ["TextColor3"] = Color3.fromRGB(255, 255, 255),
            ["TextScaled"] = true,
            ["Size"] = UDim2.new(0, 80, 1, 0),
            ["AutoButtonColor"] = false
        },

        create(
            "UIStroke", {
                ["Color"] = COLOR_D,
                ["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border
            }
        )
    )

    if not self._current_env or self._current_env ~= env_type then
        tab.Visible = false
    end

    tab.Parent = self._ScreenGui.Container.TabContainer[env_type]

    if not self._current_tab then
        self:_SelectTab(module_name)
    end

    tab.MouseEnter:Connect(function()
        self:_HoverStart(tab)
    end)

    tab.MouseLeave:Connect(function()
        self:_HoverStop(tab)
    end)

    tab.MouseButton1Click:Connect(function()
        self:_SelectTab(module_name)
    end)
end

function configify_ui:_SelectEnvironment(env_name)
    local container = self._ScreenGui.Container
    local scrolling_frame = container.ScrollingFrame

    if self._current_env then
        if self._current_env == env_name then
            return
        end

        set_visible(container.TabContainer[self._current_env], false, "TextButton")
        set_visible(scrolling_frame[self._current_tab], false, "TextButton")
    end

    self._current_env = env_name

    set_visible(container.TabContainer[self._current_env], true, "TextButton")
end

function configify_ui:_SelectTab(tab_name)
    local tab_inst = self._ScreenGui.Container.TabContainer:FindFirstChild(tab_name)
    local scrolling_frame = self._ScreenGui.Container.ScrollingFrame

    if self._current_tab then
        set_visible(scrolling_frame[self._current_tab], false, "TextButton")
    end
    
    self._current_tab = tab_name

    set_visible(scrolling_frame[tab_name], true, "TextButton")
end

function configify_ui:AddConfig(att_name, initial, min, max, module_name)
    local initial_type = type(initial)
    local config = nil

    if initial_type == "number" then
        config = self:_CreateSliderConfig(att_name, initial, min, max)
    elseif initial_type == "boolean" then
        config = self:_CreateToggleConfig(att_name, initial, min, max)
    else
        warn("This type isn't implemented yet")
        return
    end

    config.Parent = self._ScreenGui.Container.ScrollingFrame:FindFirstChild(module_name)
end

function configify_ui:_CreateSliderConfig(att_name, initial, min, max)
    local config: TextButton = create(
        "TextButton", {
            ["Name"] = att_name,
            ["Size"] = UDim2.new(1, 0, 0, 30),
            ["BackgroundColor3"] = COLOR_C,
            ["Text"] = "",
            ["AutoButtonColor"] = false,
            ["Visible"] = false
        },

        create(
            "UIStroke", {
                ["Color"] = COLOR_D,
                ["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border
            }
        ),

        create(
            "TextLabel", {
                ["Name"] = att_name,
                ["BackgroundTransparency"] = 1,
                ["Size"] = UDim2.new(1, 0, 0, 15),
                ["Font"] = Enum.Font.SourceSans,
                ["Text"] = att_name,
                ["TextColor3"] = Color3.fromRGB(255, 255, 255),
                ["TextScaled"] = true,
            }
        ),

        create(
            "TextLabel", {
                ["Name"] = "Amount",
                ["Position"] = UDim2.new(0, 0, 0, 12),
                ["Size"] = UDim2.new(1, 0, 0, 20),
                ["ZIndex"] = 2,
                ["BackgroundTransparency"] = 1,
                ["Font"] = Enum.Font.SourceSans,
                ["Text"] = initial,
                ["TextColor3"] = Color3.fromRGB(255, 255, 255),
                ["TextScaled"] = true,
                ["TextStrokeTransparency"] = 0.2,
            }
        ),

        create(
            "Frame", {
                ["Name"] = "SliderContainer",
                ["BackgroundTransparency"] = 1,
                ["Position"] = UDim2.fromOffset(0, 15),
                ["Size"] = UDim2.new(1, 0, 0, 15),
            },

            create(
                "UIPadding", {
                    ["PaddingBottom"] = UDim.new(0, 4),
                    ["PaddingTop"] = UDim.new(0, 4),
                    ["PaddingLeft"] = UDim.new(0, 5),
                    ["PaddingRight"] = UDim.new(0, 5),
                }
            ),

            create(
                "Frame", {
                    ["Name"] = "SliderBG",
                    ["BackgroundColor3"] = COLOR_B,
                    ["Size"] = UDim2.fromScale(1, 1),
                },

                create(
                    "UICorner", {
                        ["CornerRadius"] = UDim.new(1, 0)
                    }
                ),

                create(
                    "UIStroke", {
                        ["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border,
                        ["Color"] = COLOR_D,
                        ["LineJoinMode"] = Enum.LineJoinMode.Round,
                        ["Thickness"] = 1,
                        ["Transparency"] = 0.4,
                    }
                ),

                create(
                    "Frame", {
                        ["Name"] = "Slider",
                        ["BackgroundColor3"] = COLOR_A,
                        ["Size"] = UDim2.fromScale(0.5, 1),
                    },

                    create(
                        "UICorner", {
                            ["CornerRadius"] = UDim.new(1, 0)
                        }
                    )
                )
            )
        )
    )

    --Initialize slider size based off initial
    local slider_container = config.SliderContainer
    local slider_bg = slider_container.SliderBG
    local slider = slider_bg.Slider
    local percent = (initial - min) / (max - min)
    slider.Size = UDim2.fromScale(percent, 1)

    config.MouseEnter:Connect(function(x, y)
        self:_HoverStart(config)
    end)

    config.MouseLeave:Connect(function(x, y)
        self:_HoverStop(config)
    end)

    config.MouseButton1Down:Connect(function()
        self:_SliderStart(config, min, max)
    end)

    return config
end

function configify_ui:_CreateToggleConfig(att_name, initial, min, max)
    local config: TextButton = create(
        "TextButton", {
            ["Name"] = att_name,
            ["Size"] = UDim2.new(1, 0, 0, 20),
            ["BackgroundColor3"] = COLOR_C,
            ["Text"] = "",
            ["AutoButtonColor"] = false,
            ["Visible"] = false
        },

        create(
            "UIStroke", {
                ["Color"] = COLOR_D,
                ["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border
            }
        ),

        create(
            "TextLabel", {
                ["Name"] = att_name,
                ["AnchorPoint"] = Vector2.new(0, 0.5),
                ["Position"] = UDim2.new(0, 3, 0.5, 0),
                ["BackgroundTransparency"] = 1,
                ["Size"] = UDim2.new(1, -23, 0, 16),
                ["Font"] = Enum.Font.SourceSans,
                ["Text"] = att_name,
                ["TextColor3"] = Color3.fromRGB(255, 255, 255),
                ["TextScaled"] = true,
                ["TextXAlignment"] = Enum.TextXAlignment.Left,
            }
        ),

        create(
            "ImageButton", {
                ["Name"] = "ToggleBtn",
                ["ImageTransparency"] = 1,
                ["BackgroundTransparency"] = 1,
                ["BackgroundColor3"] = COLOR_TRUE,
                ["Size"] = UDim2.fromOffset(11, 11),
                ["AnchorPoint"] = Vector2.new(1, 0.5),
                ["Position"] = UDim2.new(1, -5, 0.5, 0),
            },

            create(
                "UIStroke", {
                    ["Color"] = COLOR_D
                }
            )
        )
    )

    if initial == true then
        config:SetAttribute("Active", true)
        config.ToggleBtn.BackgroundTransparency = 0 
    else
        config:SetAttribute("Active", false)
        config.ToggleBtn.BackgroundTransparency = 1
    end
    
    config.MouseEnter:Connect(function(x, y)
        self:_HoverStart(config)
    end)

    config.MouseLeave:Connect(function(x, y)
        self:_HoverStop(config)
    end)

    config.MouseButton1Click:Connect(function()
        self:_ConfigToggleClick(config)
    end)

    return config
end

function configify_ui:_HoverStart(ui_object)
    for i, v in ui_object:GetDescendants() do
        if v:IsA("UIStroke") then
            v.Color = COLOR_E
        end
    end
end

function configify_ui:_HoverStop(ui_object)
    for i, v in ui_object:GetDescendants() do
        if v:IsA("UIStroke") then
            v.Color = COLOR_D
        end
    end
end

function configify_ui:_ConfigToggleClick(ui_object)
    local Active = ui_object:GetAttribute("Active")

    if Active then
        ui_object:SetAttribute("Active", false)
        ui_object.ToggleBtn.BackgroundTransparency = 1
    else
        ui_object:SetAttribute("Active", true)
        ui_object.ToggleBtn.BackgroundTransparency = 0
    end

    local env = get_env_from_config_element(self, ui_object)
    
    self.UIChanged:Fire(ui_object.Name, ui_object:GetAttribute("Active"), env)
end

function configify_ui:_SliderStart(ui_object, min, max)
    local slider_container = ui_object.SliderContainer
    local slider_bg = slider_container.SliderBG
    local slider = slider_bg.Slider

    slider.BackgroundColor3 = COLOR_D

    runservice:BindToRenderStep("Configify_SliderStart", Enum.RenderPriority.Last.Value + 10, function(dt)
        local diff = mouse.X - slider_bg.AbsolutePosition.X
        local percent = math.clamp(diff / slider_bg.AbsoluteSize.X, 0, 1)
        local n = min + (max - min) * percent

        slider.Size = UDim2.fromScale(percent, 1)
        ui_object.Amount.Text = string.format("%.2f", n)
    end)

    local c1
    local c2

    c1 = uis.WindowFocusReleased:Connect(function()
        c1:Disconnect()
        c2:Disconnect()
        c1 = nil
        c2 = nil
        
        self:_SliderStop(ui_object)
    end)

    c2 = uis.InputEnded:Connect(function(input, gpe)
        if not (input.UserInputType == Enum.UserInputType.MouseButton1) then
            return
        end

        c1:Disconnect()
        c2:Disconnect()
        c1 = nil
        c2 = nil

        self:_SliderStop(ui_object)
    end)
end

function configify_ui:_SliderStop(ui_object)
    local slider_container = ui_object.SliderContainer
    local slider_bg = slider_container.SliderBG
    local slider = slider_bg.Slider

    slider.BackgroundColor3 = COLOR_A

    runservice:UnbindFromRenderStep("Configify_SliderStart")

    local env = get_env_from_config_element(self, ui_object)

    self.UIChanged:Fire(ui_object.Name, ui_object.Amount.Text, env)
end

function configify_ui:Toggle()
    if not self._ScreenGui then
        return
    end

    self._ScreenGui.Enabled = not self._ScreenGui.Enabled
end

return configify_ui