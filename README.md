<div align="center">

# Configify

A non invasive, plug-and-play constant/config variable editor during runtime, meant to help debug and find the perfect values for your games.

Configify is a simple tool thats meant to be simple to add to pre-existing projects in order to really lock in those values for balancing, debugging or whatever you need.

[![License](https://img.shields.io/github/license/virtualbutfake/vfx-editor?style=flat)](https://github.com/Tony1-Dev/Configify/blob/main/LICENSE)

Reply in the [devforum thread](https://roblox.com/) if you have an issues/bugs.

</div>

# Example

Here is an example of using the module.
Please note that Configify needs to be created before any other scripts start making constants/configs with it!
This means you will need to have some sort of module execution order, or require configify before other modules.

```lua
-- Some main client script 
require(path.to.configify)

-- Method 1
local CONSTANT = _G.Cfg:Set("MY_CONSTANT", 50, 0, 100)

RunService.RenderStepped:Connect(function()
    SomeUI.Text = CONSTANT()
end)

-- Method 2
local Configify = require(Configify) -- Requiring configify after its been initialized will just return you the object
Configify:Set("MY_CONSTANT", 50, 0, 100)

RunService.RenderStepped:Connect(function()
    SomeUI.Text = Configify.MY_CONSTANT
end)
```

# Support

Please just support by starring the repo and sharing with friends you might think its useful to.