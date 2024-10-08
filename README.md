<div align="center">

# Configify

A non invasive, plug-and-play constant/config variable editor during runtime, meant to help debug and find the perfect values for your games.

Configify is a simple tool thats meant to be simple to add to pre-existing projects in order to really lock in those values for balancing, debugging or whatever you need.

[![License](https://img.shields.io/github/license/virtualbutfake/vfx-editor?style=flat)](https://github.com/Tony1-Dev/Configify/blob/main/LICENSE)

Reply in the [devforum thread](https://devforum.roblox.com/t/configify-a-runtime-constantconfig-editor/3186154) if you have an issues/bugs.

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

![Example](https://i.giphy.com/media/v1.Y2lkPTc5MGI3NjExeTlvenZ2ZzBzMGk1ajRrYmtiZWtvbDV4a214eG16M3F6OGs3NzB1cCZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/EkFB33KzHUfMxp3wuk/giphy.gif)

# Planned Features
<ul>
    <li>Server side constants</li>
    <li>String support</li>
</ul>

# Build

You can build Configify using Wally, downloading from releases, or getting the model from the devforum thread (see the top of this readme)
Please note that getting the latest version from github/wally will be best, the model might not be up to date.

```toml
[dependencies]
Configify = "tony1-dev/configify@0.1.6"
```

# Support

Please just support by starring the repo and sharing with friends you might think its useful to.
