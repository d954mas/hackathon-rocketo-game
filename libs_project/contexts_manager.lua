local CLASS = require "libs.middleclass"
local ContextManager = require "libs.contexts_manager"

---@class ContextManagerProject:ContextManager
local Manager = CLASS.class("ContextManagerProject", ContextManager)

Manager.NAMES = {
	GAME = "GAME",
	MAIN = "MAIN",
	GAME_GUI = "GAME_GUI",
	GAME_HERO_PANEL_GUI = "GAME_HERO_PANEL_GUI",
	GAME_TABS_GUI = "GAME_TABS_GUI",
	DEBUG_GUI = "DEBUG_GUI",
	SITELOCK_GUI = "SITELOCK_GUI",
	CURTAINS_GUI = "CURTAINS_GUI",
	LOSE_GUI = "LOSE_GUI",
	WIN_GUI = "WIN_GUI",
}

---@class ContextStackWrapperMain:ContextStackWrapper
-----@field data ScriptMain

---@return ContextStackWrapperMain
function Manager:set_context_top_main()
	return self:set_context_top_by_name(self.NAMES.MAIN)
end

---@class ContextStackWrapperGame:ContextStackWrapper
---@field data ScriptGame
---@return ContextStackWrapperGame
function Manager:set_context_top_game()
	return self:set_context_top_by_name(self.NAMES.GAME)
end

---@class ContextStackWrapperGameGui:ContextStackWrapper
---@field data GameSceneGuiScript

---@return ContextStackWrapperGameGui
function Manager:set_context_top_game_gui()
	return self:set_context_top_by_name(self.NAMES.GAME_GUI)
end

---@class ContextStackWrapperCurtainsGui:ContextStackWrapper
---@field data CurtainsGuiScript

---@return ContextStackWrapperCurtainsGui
function Manager:set_context_top_curtains_gui()
	return self:set_context_top_by_name(self.NAMES.CURTAINS_GUI)
end


---@class ContextStackWrapperGameTabsGui:ContextStackWrapper
---@field data GameTabsGuiScript

---@return ContextStackWrapperGameTabsGui
function Manager:set_context_top_game_tabs_gui()
	return self:set_context_top_by_name(self.NAMES.GAME_TABS_GUI)
end

---@class ContextStackWrapperLoseSceneGui:ContextStackWrapper
---@field data LoseSceneGuiScript

---@return ContextStackWrapperLoseSceneGui
function Manager:set_context_top_lose_scene_gui()
	return self:set_context_top_by_name(self.NAMES.LOSE_GUI)
end

---@class ContextStackWrapperWinSceneGui:ContextStackWrapper
---@field data WinSceneGuiScript

---@return ContextStackWrapperWinSceneGui
function Manager:set_context_top_win_scene_gui()
	return self:set_context_top_by_name(self.NAMES.WIN_GUI)
end


---@class ContextStackWrapperHeroPanelGui:ContextStackWrapper
---@field data GameHeroPanelGuiScript

---@return ContextStackWrapperHeroPanelGui
function Manager:set_context_top_hero_panel_gui()
	return self:set_context_top_by_name(self.NAMES.GAME_HERO_PANEL_GUI)
end

return Manager()