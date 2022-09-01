local COMMON = require "libs.common"
local GUI = require "libs_project.gui.gui"
local GOOEY = require "gooey.gooey"
local CLIPBOARD = require "libs.clipboard"

local Base = require "scenes.game.views.base_view"

---@class NewGameView:BaseView
local View = COMMON.class("NewGameView", Base)

function View:init(root_name)
	Base.init(self, root_name)
end

function View:bind_vh()
	self.vh = {

	}

	self.views = {
		btn_new_game = GUI.ButtonScale(self.root_name .. "/btn_new_game"),
		btn_input_clear = GUI.ButtonScale(self.root_name .. "/name_input/clear"),
		checkboxes = {
			{ chb = GUI.CheckboxWithLabel(self.root_name .. "/chb_7"), value = 7 },
			{ chb = GUI.CheckboxWithLabel(self.root_name .. "/chb_11"), value = 11 },
			{ chb = GUI.CheckboxWithLabel(self.root_name .. "/chb_13"), value = 13 },
		},
	}
end
function View:init_gui()
	Base.init_gui(self)
	for idx, chb in ipairs(self.views.checkboxes) do
		chb.chb:set_input_listener(function()
			for _, chb2 in ipairs(self.views.checkboxes) do
				chb2.chb:set_checked(false)
			end
			chb.chb:set_checked(true)
			self.checkbox_selected = idx
		end)
	end
	self.views.checkboxes[1].chb:set_checked(true)
	self.checkbox_selected = 1

	self.views.btn_new_game:set_input_listener(function()
		local gui_object = GOOEY.input(self.root_name .. "/name_input/text", gui.KEYBOARD_TYPE_DEFAULT, nil, nil, self.name_input_config,
				self.name_input_refresh)
		local name = gui_object.text
		if (name and name ~= "") then
			roketo.contract_create_game(roketo.get_account_id(), name, self.views.checkboxes[self.checkbox_selected].value)
		end

	end)

	self.views.btn_input_clear:set_input_listener(function()
		local gui_object = GOOEY.input(self.root_name .. "/name_input/text", gui.KEYBOARD_TYPE_DEFAULT, nil, nil, self.name_input_config,
				self.name_input_refresh)
		gui_object.set_text("")
		--update
		GOOEY.input(self.root_name .. "/name_input/text", gui.KEYBOARD_TYPE_DEFAULT, nil, nil, self.name_input_config,
				self.name_input_refresh)
	end)

	self.name_input_config = {
		empty_text = "opponent name",
		max_length = 99
	}

	self.name_input_refresh = function(input)
		local config = self.name_input_config
		local node_id = self.root_name .. "/name_input"
		if input.empty and not input.selected then
			gui.set_text(input.node, config and config.empty_text or "")
			gui.set_color(input.node, vmath.vector4(0.8, 0.8, 0.8, 0.66))
		else
			--gui.set_text(input.node,input.text)
			gui.set_color(input.node, vmath.vector4(1, 1, 1, 1))
		end

		local cursor = gui.get_node(node_id .. "/cursor")
		if input.selected then
			gui.set_enabled(cursor, true)
			gui.set_position(cursor, vmath.vector3(14 + input.total_width, 0, 0))
			gui.cancel_animation(cursor, gui.PROP_COLOR)
			gui.set_color(cursor, vmath.vector4(1))
			gui.animate(cursor, gui.PROP_COLOR, vmath.vector4(1, 1, 1, 0), gui.EASING_INSINE, 0.8, 0, nil, gui.PLAYBACK_LOOP_PINGPONG)
		else
			gui.set_enabled(cursor, false)
			gui.cancel_animation(cursor, gui.PROP_COLOR)
		end
	end
	GOOEY.input(self.root_name .. "/name_input/text", gui.KEYBOARD_TYPE_DEFAULT, nil, nil, self.name_input_config,
			self.name_input_refresh)

	self.clipboard_listener = function(message_id, message)
		if (message_id == CLIPBOARD.CLIPBOARD_PASTE) then
			local paste = message.value
			if (paste and paste ~= "") then
				COMMON.CONTEXT:set_context_top_game_gui()
				local gui_object = GOOEY.input(self.root_name .. "/name_input/text", gui.KEYBOARD_TYPE_DEFAULT, nil, nil, self.name_input_config,
						self.name_input_refresh)
				if (gui_object.selected) then
					gui_object.set_text(gui_object.text .. tostring(paste))
					--update
					GOOEY.input(self.root_name .. "/name_input/text", gui.KEYBOARD_TYPE_DEFAULT, nil, nil, self.name_input_config,
							self.name_input_refresh)
				end
			end
		end
	end

	CLIPBOARD.add_listener(self.clipboard_listener)
end

function View:update(dt)
	Base.update(self, dt)
end

function View:on_input(action_id, action)
	if (self.ignore_input) then return false end
	if (self.views.btn_new_game:on_input(action_id, action)) then return true end
	if (self.views.btn_input_clear:on_input(action_id, action)) then return true end
	GOOEY.input(self.root_name .. "/name_input/text", gui.KEYBOARD_TYPE_DEFAULT, action_id, action,
			self.name_input_config, self.name_input_refresh)
	for _, chb in ipairs(self.views.checkboxes) do
		if (chb.chb:on_input(action_id, action)) then
			return true
		end
	end
end

return View