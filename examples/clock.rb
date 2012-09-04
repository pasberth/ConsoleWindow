# -*- coding: utf-8 -*-

$:.unshift File.dirname(__FILE__) + '/../lib'
require 'console_window'

include ConsoleWindow

screen = Screen.new

clock = screen.create_sub(Window, 40, 1, 0, 0)
clock.frames.background do
  clock.text = Time.now.to_s
end

input = screen.create_sub(Window, 40, 1, 0, 1)

input.frames.on :main do
  case str = input.gets
  when nil
  else
    input.unfocus!
  end
end

screen.components << clock << input
input.focus!

screen.activate
