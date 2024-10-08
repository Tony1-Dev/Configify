-- Configify
-- Tony1
-- October 7, 2024

--[[
    A non invasive, plug-and-play constant/config variable editor during runtime, 
    meant to help debug and find the perfect values for your games.

    Github repo: https://github.com/Tony1-Dev/Configify

    DevForum discussion: https://devforum.roblox.com/t/configify-a-runtime-constantconfig-editor/3186154

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

local KEYBIND = script:GetAttribute("ToggleKeybind") or "RightAlt"

local cas = game:GetService("ContextActionService")
local runservice = game:GetService("RunService")
local players = game:GetService("Players")

local configify = {}
configify.__index = configify

local tab_cache = nil
local is_client = runservice:IsClient()

if is_client then
    tab_cache = {}
end
type att_type = string | boolean | number | UDim | UDim2 | BrickColor | Color3 | Vector2 | Vector3 | CFrame | NumberSequence | ColorSequence | NumberRange | Rect | Font

local function get_tab_name() -- get name of script this is being called in
    local path = string.split(debug.info(3, "s"), ".")
    return path[#path]
end

local function get_module(depth)
    local path = string.split(debug.info(depth, "s"), ".")
    local module = game[path[1]]

    for i = 2, #path do
        module = module[path[i]]
    end

    return module
end

function configify.new()
    local self = setmetatable({}, configify)

    if is_client then
        self._UI = nil
        self.UI_Changed = nil

        if script:FindFirstChild("Comm") then
            self._comm = script.Comm
            self:_ListenForComm()
        else
            local c 
            c = script.ChildAdded:Connect(function(child)
                if not (child.Name == "Comm") then
                    return
                end

                c:Disconnect()
                c = nil

                self._comm = child
                self:_ListenForComm()
            end)
        end
    else
        self._comm = Instance.new("RemoteEvent")
        self._comm.Name = "Comm"
        self._comm.Parent = script
        self:_ListenForComm()
    end

    self._config = {}
    self:_Init()

    return self
end

function configify:_CreateUI()
    self._UI = require(script.UI).new()

    self._UI.UIChanged:Connect(function(att_name, att_value, module)
        module:SetAttribute(att_name, att_value)

        self._config[att_name].value = att_value
    end)

    local function toggle(action_name, input_state, input_obj)
        if input_state == Enum.UserInputState.Cancel or input_state == Enum.UserInputState.End then
            return
        end

        self._UI:Toggle()
    end

    cas:BindAction("ToggleConfigify", toggle, false, Enum.KeyCode[KEYBIND])

    script:GetAttributeChangedSignal("ToggleKeybind"):Connect(function()
        cas:UnbindAction("ToggleConfigify")
        cas:BindAction("ToggleConfigify", toggle, false, Enum.KeyCode[script:GetAttribute("ToggleKeybind")])
    end)
end

function configify:_Init()
    if is_client then
        self:_CreateUI()
    else
        local function initialize_existing_config(player)
            self._comm:FireClient(player, self._config)
        end
        
        for i, v in players:GetPlayers() do
            initialize_existing_config(v)
        end

        players.PlayerAdded:Connect(function(player)
            initialize_existing_config(player)    
        end)
    end

    _G.Configify = self
    _G.Cfg = self -- Alias
end

function configify:Set(att_name: string, initial: att_type, min: att_type, max: att_type): () -> att_type
    local module = get_module(3)
    local initial_type = type(initial)

    if is_client then
        if tab_cache[module.Name] == nil then
            self._UI:AddTab(module, "Client")
            tab_cache[module.Name] = true
        end

        self._UI:AddConfig(att_name, initial, min, max, module)
    else
        --TODO: Change this to fire specific clients based on a whitelist/group rank
        self._comm:FireAllClients(att_name, initial, min, max, module)
    end

    module:SetAttribute(att_name, initial)
    module:GetAttributeChangedSignal(att_name):Connect(function()
        local v = module:GetAttribute(att_name)
        self._config[att_name].value = v
    end)

    self._config[att_name] = {
        ["value"] = initial,
        ["min"] = min,
        ["max"] = max,
        ["parent_script"] = module
    }

    return function()
        if initial_type == "number" then
            return tonumber(self._config[att_name].value)
        else
            return self._config[att_name].value
        end
    end
end

function configify:_ListenForComm()
    if is_client then
        self._comm.OnClientEvent:Connect(function(new_configs)
            for att_name, info in new_configs do
                local module_name = info["parent_script"]

                -- if a tab doesn't exist for this script yet..
                if not tab_cache[module_name] then
                    self._UI:AddTab(module_name, "Server")
                    tab_cache[module_name] = true
                end

                self._UI:AddConfig(
                    att_name,
                    info["value"],
                    info["min"],
                    info["max"],
                    module_name
                )

                self._config[att_name] = {
                    ["value"] = info["value"],
                    ["min"] = info["min"],
                    ["max"] = info["max"],
                    ["parent_script"] = module_name
                }
            end
        end)
    else
        self._comm.OnServerEvent:Connect(function()
            print("Server received!")
        end)
    end
end

if _G.Configify then
    return _G.Configify
else
    return configify.new()
end
