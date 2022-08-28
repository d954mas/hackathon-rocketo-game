local COMMON = require "libs.common"
local HERO = require "world.balance.hero"

---@class Balance
local Balance = COMMON.class("Balance")

Balance.config = {
	HERO = HERO
}

---@param world World
function Balance:initialize(world)
	checks("?", "class:World")
	self.world = world
end

return Balance