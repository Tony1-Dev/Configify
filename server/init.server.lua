require(game.ReplicatedStorage.Configify)

local SWORD_DAMAGE = _G.Cfg:Set("SWORD_DMG", 10, 0, 100)
local BOOL = _G.Cfg:Set("BOOL", false)
local SERVER_NAME = _G.Cfg:Set("SERVER_NAME", "N/A")

print("Test")

while true do
    task.wait(10)
    print(SWORD_DAMAGE())
    print(BOOL())
    print(`Server name is: {SERVER_NAME()}`)
end