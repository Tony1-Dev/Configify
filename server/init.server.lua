require(game.ReplicatedStorage.Configify)

local SWORD_DAMAGE = _G.Cfg:Set("SWORD_DMG", 10, 0, 100)
local BOOL = _G.Cfg:Set("BOOL", false)

while true do
    wait(5)
    print(SWORD_DAMAGE())
    print(BOOL())
end