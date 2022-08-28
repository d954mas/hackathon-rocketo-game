local COMMON = require "libs.common"
local CONSTANTS = require "libs.constants"
local JSON = require "libs.json"
local DEFS = require "world.balance.def.defs"
local OptionsStoragePart = require "world.storage.options_storage_part"
local DebugStoragePart = require "world.storage.debug_storage_part"
local ResourceStoragePart = require "world.storage.resource_storage_part"
local GameStoragePart = require "world.storage.game_storage_part"
local ItemsStoragePart = require "world.storage.items_storage_part"
local SkillsStoragePart = require "world.storage.skills_storage_part"
local HeroStoragePart = require "world.storage.hero_storage_part"
local CRYPTO = require "libs.crypto"
local BASE64 = require "libs.base64"

local TAG = "Storage"

---@class Storage
local Storage = COMMON.class("Storage")

Storage.FILE_PATH = "d954mas_mine_cards"
Storage.VERSION = 11
Storage.AUTOSAVE = 30 --seconds
Storage.CLEAR = CONSTANTS.VERSION_IS_DEV and false --BE CAREFUL. Do not use in prod
Storage.LOCAL = CONSTANTS.VERSION_IS_DEV and CONSTANTS.PLATFORM_IS_PC
		and CONSTANTS.TARGET_IS_EDITOR and true --BE CAREFUL. Do not use in prod

---@param world World
function Storage:initialize(world)
	checks("?", "class:World")
	self.world = world
	local status, error = pcall(self._load_storage, self)
	if (not status) then
		COMMON.i("error load storage:" .. tostring(error), TAG)
		self:_init_storage()
		self:_migration()
		self:save(true)
	end
	self.prev_save_time = socket.gettime()
	self.save_on_update = false

	self:update_data()
end

function Storage:update_data()
	self.options = OptionsStoragePart(self)
	self.debug = DebugStoragePart(self)
	self.resource = ResourceStoragePart(self)
	self.hero = HeroStoragePart(self)
	self.game = GameStoragePart(self)
	self.items = ItemsStoragePart(self)
	self.skills = SkillsStoragePart(self)
end

function Storage:changed()
	self.change_flag = true
end

function Storage:_get_path()
	if (Storage.LOCAL) then
		return lfs.currentdir() .. "/" .. "storage.json"
	end
	local path = Storage.FILE_PATH
	if (CONSTANTS.VERSION_IS_DEV) then
		path = path .. "_dev"
	end
	if (html5) then
		return path
	end
	return sys.get_save_file(path, "storage.json")
end

function Storage:_load_storage()
	local path = self:_get_path()
	local data = nil
	if (Storage.CLEAR) then
		COMMON.i("clear storage", TAG)
	else
		if (html5) then
			local html_data = html5.run([[(function(){try{return window.localStorage.getItem(']] .. path .. [[')||'{}'}catch(e){return'{}'}})()]])
			if (not html_data or html_data == "{}" or html_data == "nil") then
				COMMON.i("html5 data. Empty or error:" .. tostring(html_data), TAG)
			else
				COMMON.i("html5 data:" .. tostring(html_data), TAG)
				local status_json, file_data = pcall(JSON.decode, html_data)
				if (not status_json) then
					COMMON.i("can't parse json:" .. tostring(file_data), TAG)
				else
					data = file_data
				end
			end


		else
			local status, file = pcall(io.open, path, "r")
			if (not status) then
				COMMON.i("can't open file:" .. tostring(file), TAG)
			else
				if (file) then
					COMMON.i("load", TAG)
					local contents, read_err = file:read("*a")
					if (not contents) then
						COMMON.i("can't read file:\n" .. read_err, TAG)
					else
						COMMON.i("from file:\n" .. contents, TAG)
						local status_json, file_data = pcall(JSON.decode, contents)
						if (not status_json) then
							COMMON.i("can't parse json:" .. tostring(file_data), TAG)
						else
							data = file_data
						end
					end
					file:close()
				else
					COMMON.i("no file", TAG)
				end
			end
		end
	end

	if (data) then
		if (data.encrypted) then
			data.data = BASE64.decode(data.data)
			data = CRYPTO.crypt(data.data, CONSTANTS.CRYPTO_KEY)
		else
			data = data.data
		end

		local result, storage = pcall(JSON.decode, data)
		if (result) then
			self.data = assert(storage)
		else
			COMMON.i("can't parse json:" .. tostring(storage), TAG)
			self:_init_storage()
		end
		COMMON.i("data:\n" .. tostring(data), TAG)
	else
		COMMON.i("no data.Init storage", TAG)
		self:_init_storage()
	end

	self:_migration()
	self:save(true)
	COMMON.i("loaded", TAG)
end

function Storage:update(dt)
	self.game.game.last_time = socket.gettime()

	if (self.change_flag) then
		self.world:on_storage_changed()
		COMMON.EVENT_BUS:event(COMMON.EVENTS.STORAGE_CHANGED)
		self.change_flag = false
	end
	if (self.save_on_update) then
		self:save(true)
	end
	if (Storage.AUTOSAVE and Storage.AUTOSAVE ~= -1) then
		if (socket.gettime() - self.prev_save_time > Storage.AUTOSAVE) then
			COMMON.i("autosave", TAG)
			self:save(true)
		end
	end

end

function Storage:_init_storage()
	COMMON.i("init new", TAG)
	---@class StorageData
	local data = {
		debug = {
			developer = false,
		},
		options = {
			sound = true,
			music = true
		},
		resource = {
			gems = 0,
			food = 5
		},
		hero = {
			level = 1,
			exp = 0
		},
		items = {
			sword = 1,
			pickaxe = 1,
			helmet = 0,
			armor = 0,
			pants = 0,
			boots = 0
		},
		skills = {

		},
		game = {

		},
		location = {

		},
		version = Storage.VERSION
	}
	for idx, line in ipairs(DEFS.SKILLS) do
		data.skills[line.id] = { skills = 0 }
	end
	self.data = data
end

function Storage:_migration()
	if (self.data.version < Storage.VERSION) then
		COMMON.i(string.format("migrate from:%s to %s", self.data.version, Storage.VERSION), TAG)

		if (self.data.version < 11) then
			self:_init_storage()
		end

		self.data.version = Storage.VERSION
	end
end

function Storage:__save()
	local data = {
		data = JSON.encode(self.data),
	}
	data.encrypted = COMMON.CONSTANTS.VERSION_IS_RELEASE

	if (data.encrypted) then
		data.data = CRYPTO.crypt(data.data, CONSTANTS.CRYPTO_KEY)
		data.data = BASE64.encode(data.data)
	end

	local encoded_data = JSON.encode(data, false)
	encoded_data:gsub("'", "\'") -- escape ' character
	if (html5) then
		html5.run("try{window.localStorage.setItem('" .. self:_get_path() .. "', '" .. encoded_data .. "')}catch(e){}")
	else
		local file = io.open(self:_get_path(), "w+")
		-- encoded_data = BASE64.encode(encoded_data)
		file:write(encoded_data)
		file:close()
	end
end

function Storage:save(force)
	if (force) then
		COMMON.i("save", TAG)
		self.prev_save_time = socket.gettime()
		local status, error = pcall(self.__save, self)
		if (not status) then
			COMMON.i("error save storage:" .. tostring(error), TAG)
		end
		self.save_on_update = false
		COMMON.EVENT_BUS:event(COMMON.EVENTS.STORAGE_SAVED)
	else
		self.save_on_update = true
	end
end

return Storage

