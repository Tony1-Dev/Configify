require(script.Parent.Configify)

local SWORD_DAMAGE = _G.Cfg:Set("SWORD_DMG", 10, 0, 100)

while true do
    wait(5)
    print(SWORD_DAMAGE())
end