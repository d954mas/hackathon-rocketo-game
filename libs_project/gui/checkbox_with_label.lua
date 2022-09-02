local COMMON = require "libs.common"
local GOOEY = require "gooey.gooey"

local Btn = COMMON.class("ButtonScale")

local CHEKCKBOX_PRESSED = hash("checkbox_normal")
local CHEKCKBOX_CHECKED_PRESSED = hash("checkbox_checked_normal")
local CHEKCKBOX_CHECKED_NORMAL = hash("checkbox_checked_normal")
local CHEKCKBOX_NORMAL = hash("checkbox_normal")

local COLOR_CHECKED = COMMON.LUME.color_parse_hex("#00A2CB")
local COLOR_NORMAL = COMMON.LUME.color_parse_hex("#819197")

function Btn:initialize(root_name, path)
	self.vh = {
		root = gui.get_node(root_name .. (path or "/root")),
		box = gui.get_node(root_name .. (path or "/root/box")),
		label = gui.get_node(root_name .. (path or "/root/label")),
	}
	self.scale = gui.get_scale(self.vh.box)
	self.scale_pressed = gui.get_scale(self.vh.box)*0.9
	self.root_name = root_name .. (path or "/root")
	self.gooey_listener = function(cb)
		self.checked = cb.checked
		if self.input_listener then self.input_listener() end
	end
	self.checked = false
	self.refresh =  function(checkbox)
		if checkbox.pressed and not checkbox.checked then
			gui.set_color(self.vh.label,COLOR_NORMAL)
			gui.play_flipbook(self.vh.box, CHEKCKBOX_PRESSED)
			gui.set_scale(self.vh.box,self.scale_pressed)
		elseif checkbox.pressed and checkbox.checked then
			gui.set_scale(self.vh.box,self.scale_pressed)
			gui.play_flipbook(self.vh.box, CHEKCKBOX_CHECKED_PRESSED)
			gui.set_color(self.vh.label,COLOR_CHECKED)
		elseif checkbox.checked then
			gui.set_scale(self.vh.box,self.scale)
			gui.play_flipbook(self.vh.box, CHEKCKBOX_CHECKED_NORMAL)
			gui.set_color(self.vh.label,COLOR_CHECKED)
		else
			gui.set_color(self.vh.label,COLOR_NORMAL)
			gui.set_scale(self.vh.box,self.scale)
			gui.play_flipbook(self.vh.box, CHEKCKBOX_NORMAL)
		end
	end
end

function Btn:set_input_listener(listener)
	self.input_listener = listener
end

function Btn:set_checked(checked)
	self.checked = checked
	local cb = GOOEY.checkbox(self.root_name,nil,nil,nil,self.refresh)
	cb.set_checked(self.checked)
end

function Btn:on_input(action_id, action)
	if(not self.ignore_input)then
		local cb = GOOEY.checkbox(self.root_name, action_id, action, self.gooey_listener,self.refresh)
		return cb.consumed
	end
end

function Btn:set_enabled(enable)
	gui.set_enabled(self.vh.root, enable)
end

function Btn:set_ignore_input(ignore)
	self.ignore_input = ignore
end

return Btn