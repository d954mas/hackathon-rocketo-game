local COMMON = require "libs.common"
local Storage = require "world.storage.storage"
local GameWorld = require "world.game.game_world"
local CommandExecutor = require "world.commands.command_executor"
local Balance = require "world.balance.balance"
local Ads = require "libs.ads.ads"
local Sdk = require "libs.sdk.sdk"
local Utils = require "world.utils.utils"
local SOUNDS = require "libs.sounds"
local YA = require "libs.yagames.yagames"
local JSON = require "libs.json"
local CRYPTO = require "libs.crypto"
local GameReceiver = require "libs_project.games_receiver"

local TAG = "WORLD"
---@class World
local M = COMMON.class("World")

function M:initialize()
	COMMON.i("init", TAG)
	self.subscription = COMMON.RX.SubscriptionsStorage()
	self.scheduler = COMMON.RX.CooperativeScheduler.create()
	self.storage = Storage(self)
	self.command_executor = CommandExecutor()
	self.balance = Balance(self)
	self.game = GameWorld(self)
	self.ads = Ads(self)
	self.sdk = Sdk(self)
	self.utils = Utils(self)
	self.games_receiver = GameReceiver(self)
	self.sounds = SOUNDS
	self.sounds.world = self
	self.time = 0
	self.skip_time = 0

	--if (COMMON.html5_is_mobile()) then
	--	self.storage.debug:show_mobile_input_set(true)
	--elseif (COMMON.CONSTANTS.VERSION_IS_RELEASE) then
	--	self.storage.debug:show_mobile_input_set(false)
--	end

	self.subscription:add(COMMON.EVENT_BUS:subscribe(COMMON.EVENTS.WINDOW_RESIZED)
								:go_distinct(self.scheduler):subscribe(function(data)
		if (imgui) then
			imgui.set_display_size(data.width, data.height)
		end
		self:on_resize()
	end))
end

function M:update(dt)
	self.time = self.time + dt
	self.scheduler:update(dt)
	self.command_executor:act(dt)
	self.storage:update(dt)
	self.games_receiver:update(dt)
	self.skip_time = self.skip_time + dt
end

function M:on_resize()
	self.game:on_resize()
end

function M:on_storage_changed()

end

function M:final()
	COMMON.i("final", TAG)
	self.subscription:unsubscribe()
	self.subscription = nil
end

function M:ya_load_storage(cb)
	YA.player_get_data({ "storage_new" }, function(_, err, result)
		print("GET STORAGE")
		pprint(result)
		if (not err) then


			local stars = self.game:levels_get_all_stars()
			local time = self.game:levels_get_all_time()

			if (not result.storage_new) then
				cb()
				return
			end

			---@type StorageData
			local ya_storage_data = result.storage_new
			local success = true

			if (ya_storage_data.data) then
				if (ya_storage_data.encrypted) then
					ya_storage_data = CRYPTO.crypt(ya_storage_data.data, COMMON.CONSTANTS.CRYPTO_KEY)
				else
					ya_storage_data = ya_storage_data.data
				end
			else
				print("bad ya storage")
				cb()
				return
			end

			success, ya_storage_data = pcall(JSON.decode, ya_storage_data)
			if (not success) then
				print("can't decode ya storage")
				cb()
				return
			end

			self.sdk.yagames.ya_storage_data = ya_storage_data

			local ya_time = 0
			local ya_stars = 0

			for _, level in ipairs(ya_storage_data.game.levels) do
				if (level.completed) then
					ya_stars = ya_stars + level.stars
					if (level.play_time > 0) then
						ya_time = ya_time + level.play_time
					end
				end
			end
			print(string.format("local. stars:%d time:%f", stars, time))
			print(string.format("ya. stars:%d time:%f", ya_stars, ya_time))

			if (ya_stars > stars or (ya_stars == stars and ya_time < time)) then
				print("rewrite storage. Use ya.")
				self.storage.data = ya_storage_data
				self.storage:update_data()
				self.storage:save()
			end

			self.sdk.yagames.ya_storage_data = JSON.encode(self.storage.data)

		end
		COMMON.EVENT_BUS:event(COMMON.EVENTS.STORAGE_CHANGED)
		cb()
	end)
end

function M:skip_can_use()
	return self.skip_time >= self.balance.config.skip_delay
end

function M:skip_can_show()
	return false
end

return M()