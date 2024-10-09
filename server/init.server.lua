require(game.ReplicatedStorage.Configify)

local SWORD_DAMAGE = _G.Cfg:Set("SWORD_DMG", 10, 0, 100)
local BOOL = _G.Cfg:Set("BOOL", false)
local SERVER_NAME = _G.Cfg:Set("Server_Name", "Cav's Server")

while true do
    task.wait(1)
    --print(SWORD_DAMAGE())
    --print(BOOL())


    print(SERVER_NAME())
end