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

-- for some reason, debug.info returns nil SOMETIMES in live servers, pcall to try helping?
local function get_module(depth)
    local num_attempts = 10

    local module = nil
    local path = nil

    for i = 1, num_attempts do
        local succ, err = pcall(function()
            path = string.split(debug.info(depth + 2, "s"), ".") -- +2 because of added scope from loop and pcall
            module = game[path[1]]
        
            for i = 2, #path do
                module = module[path[i]]
            end
        end)

        if succ then
            break
        else
            warn(err)
        end
        
        task.wait()
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

    self._UI.UIChanged:Connect(function(att_name, att_value, env)
        self._config[att_name].value = att_value

        -- if the config belongs to a server script
        if env == "Server" then
            self._comm:FireServer(att_name, att_value)
        end
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
    local module_name = get_module(3).Name
    local initial_type = type(initial)

    if is_client then
        if tab_cache[module_name] == nil then
            self._UI:AddTab(module_name, "Client")
            tab_cache[module_name] = true
        end

        self._UI:AddConfig(att_name, initial, min, max, module_name)
    else
        --TODO: Change this to fire specific clients based on a whitelist/group rank
        self._comm:FireAllClients(att_name, initial, min, max, module_name)
    end

    self._config[att_name] = {
        ["value"] = initial,
        ["parent_script"] = module_name
    }

    if min and max then
        self._config[att_name]["min"] = min
        self._config[att_name]["max"] = max
    end

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

                if not self._config[att_name] then
                    self._UI:AddConfig(
                        att_name,
                        info["value"],
                        info["min"],
                        info["max"],
                        module_name
                    )
                end

                self._config[att_name] = {
                    ["value"] = info["value"],
                    ["min"] = info["min"],
                    ["max"] = info["max"],
                    ["parent_script"] = module_name
                }
            end
        end)
    else
        self._comm.OnServerEvent:Connect(function(player, att_name, att_value)
            self._config[att_name].value = att_value

            for _, p in players:GetPlayers() do
                if p == player then
                    continue
                end

                self._comm:FireClient(p, {
                    [att_name] = {
                        ["value"] = self._config[att_name].value,
                        ["min"] = self._config[att_name].min,
                        ["max"] = self._config[att_name].max,
                        ["parent_script"] = self._config[att_name].parent_script,
                    }
                })
            end
        end)
    end
end

if _G.Configify then
    return _G.Configify
else
    return configify.new()
end
