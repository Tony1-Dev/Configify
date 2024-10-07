-- Configify
-- Tony1
-- October 7, 2024

--[[
    A non invasive, plug-and-play constant/config variable editor during runtime, 
    meant to help debug and find the perfect values for your games.

    Github repo: 

    DevForum discussion: 

    Functions:

        Configify.new() -> Configify Object (injects into client environment)


    Methods:

        Configify:Set(config_name, initial_value, min_value, max_value): () -> current config value
            config_name   [string] -- name that will be stored for your value
            initial_value [any attribute value] -- initial value for your config, some attribute types not yet supported
            min_value     [same type as initial_value] -- min value if your config is a number (for slider)
            max_value     [same type as initial_value] -- max value if your config is a number (for slider)


    USAGE:
        -- Some main client script
        require(path.to.configify) -- Will automatically initialize into client env

        -- Your script
        local CONSTANT = _G.Cfg:Set("MY_CONSTANT", 50, 0, 100) -- initialize MY_CONSTANT to 50, min is 0 and max is 100

        some_event:Connect(function()
            print(CONSTANT()) -- Prints the current value of MY_CONSTANT
        end)
]]

local cas = game:GetService("ContextActionService")
local runservice = game:GetService("RunService")

local configify = {}
configify.__index = configify

local tab_cache = {}
local is_client = runservice:IsClient()
type att_type = string | boolean | number | UDim | UDim2 | BrickColor | Color3 | Vector2 | Vector3 | CFrame | NumberSequence | ColorSequence | NumberRange | Rect | Font

local function get_tab_name() -- get name of script this is being called in
    local path = string.split(debug.info(3, "s"), ".")
    return path[#path]
end

local function get_module(depth)
    print(debug.info(depth, "s"))
    local path = string.split(debug.info(depth, "s"), ".")
    local module = game[path[1]]

    for i = 2, #path do
        module = module[path[i]]
    end

    return module
end

function configify.new()
    local self = setmetatable({}, configify)

    if _G.Configify then
        warn("Configify already exists!")
        return
    end

    if not is_client then
        warn("Only client use of Configify is currently supported, please use on client")
        return
    end

    self._UI = nil
    self.UI_Changed = nil
    self:_Init()

    return self
end

function configify:_Init()
    self._UI = require(script.UI).new()

    self._UI.UIChanged:Connect(function(att_name, att_value, module)
        module:SetAttribute(att_name, att_value)
        self[att_name] = att_value
    end)

    local function toggle(action_name, input_state, input_obj)
        if input_state == Enum.UserInputState.Cancel or input_state == Enum.UserInputState.End then
            return
        end

        self._UI:Toggle()
    end

    cas:BindAction("ToggleConfigify", toggle, false, Enum.KeyCode[script:GetAttribute("ToggleKeybind")])

    script:GetAttributeChangedSignal("ToggleKeybind"):Connect(function()
        cas:UnbindAction("ToggleConfigify")
        cas:BindAction("ToggleConfigify", toggle, false, Enum.KeyCode[script:GetAttribute("ToggleKeybind")])
    end)

    _G.Configify = self
    _G.Cfg = self -- Alias
end

function configify:Set(att_name: string, initial: att_type, min: att_type, max: att_type): () -> att_type
    local module = get_module(3)
    local initial_type = type(initial)

    if tab_cache[module] == nil then
        self._UI:AddTab(module)
        tab_cache[module] = true
    end

    self._UI:AddConfig(att_name, initial, min, max, module)

    module:SetAttribute(att_name, initial)
    module:GetAttributeChangedSignal(att_name):Connect(function()
        local v = module:GetAttribute(att_name)
        self[att_name] = v
    end)

    self[att_name] = initial

    return function()
        if initial_type == "number" then
            return tonumber(self[att_name])
        else
            return self[att_name]
        end
    end
end

if _G.Configify then
    return _G.Configify
else
    return configify.new()
end