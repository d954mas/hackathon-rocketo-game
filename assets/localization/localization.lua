local I18N = require "libs.i18n.init"
local LOG = require "libs.log"
local CONSTANTS = require "libs.constants"
local TAG = "LOCALIZATION"
local LUME = require "libs.lume"
local LOCALES = { "en", "ru" }
local DEFAULT = CONSTANTS.LOCALIZATION.DEFAULT
local FALLBACK = DEFAULT

---@class Localization
local M = {
	pause_back_to_game = { en = "BACK TO GAME", ru = "В ИГРУ" },
	pause_restart = { en = "RESTART", ru = "ПЕРЕЗАПУСК" },
	pause_main_menu = { en = "MAIN MENU", ru = "В МЕНЮ" },
	pause_title = { en = "PAUSE", ru = "ПАУЗА" },

	upgrade_ATTACK = { en = "ATTACK", ru = "АТАКА" },
	upgrade_ATTACK_description = { en = "Attack:%{power}", ru = "Атака:%{power}" },
	upgrade_MINE = { en = "MINE", ru = "ДОБЫЧА" },
	upgrade_MINE_description = { en = "Mine:%{power}", ru = "Добыча:%{power}" },

	craft_SWORD_description = { en = "Multiply by:\n%{power}", ru = "Умножение на:\n%{power}" },
	craft_PICKAXE_description = { en = "Multiply by:\n%{power}", ru = "Умножение на:\n%{power}" },

	item_SWORD_WOOD = { en = "Wood Sword", ru = "Деревянный меч" },
	item_PICKAXE_WOOD = { en = "Wood Pickaxe", ru = "Деревянная кирка" },

	sitelock_title = {en = "GAME NOT AVAILABLE", ru = "ИГРА НЕ ДОСТУПНА"},
	sitelock_description = {en = "For host:\n%{host}", ru = "Для хоста:\n%{host}"},



	card_GEMS_1_name = {en = "Old Mine", ru = "Старая Шахта"},
	card_ZOMBIE_1_name = {en = "Zombie", ru = "Зомби"},





}

function M:locale_exist(key)
	local locale = self[key]
	if not locale then
		LOG.w("key:" .. key .. " not found", TAG,2)
	end
end

function M:set_locale(locale)
	LOG.w("set locale:" .. locale,TAG)
	I18N.setLocale(locale)
end

function M:locale_get()
	return I18N.getLocale()
end

I18N.setFallbackLocale(FALLBACK)
M:set_locale(DEFAULT)
if(CONSTANTS.LOCALIZATION.FORCE_LOCALE)then
	LOG.i("force locale:" .. CONSTANTS.LOCALIZATION.FORCE_LOCALE,TAG)
	M:set_locale(CONSTANTS.LOCALIZATION.FORCE_LOCALE)
elseif(CONSTANTS.LOCALIZATION.USE_SYSTEM)then
	local system_locale = sys.get_sys_info().language
	LOG.i("system locale:" .. system_locale,TAG)
	if(LUME.findi(LOCALES,system_locale)) then
		M:set_locale(system_locale)
	else
		LOG.i("unknown system locale:" .. system_locale,TAG)
		pprint(LOCALES)
	end

end

for _, locale in ipairs(LOCALES) do
	local table = {}
	for k, v in pairs(M) do
		if type(v) ~= "function" then
			table[k] = v[locale]
		end
	end
	I18N.load({ [locale] = table })
end

for k, v in pairs(M) do
	if type(v) ~= "function" then
		M[k] = function(data)
			return I18N(k, data)
		end
	end
end

--return key if value not founded
---@type Localization
local t = setmetatable({ __VALUE = M, }, {
	__index = function(_, k)
		local result = M[k]
		if not result then
			LOG.w("no key:" .. k, TAG,2)
			result = function() return k end
			M[k] = result
		end
		return result
	end,
	__newindex = function() error("table is readonly", 2) end,
})


return t
