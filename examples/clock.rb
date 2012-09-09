# -*- coding: utf-8 -*-

$:.unshift File.dirname(__FILE__) + '/../lib'
require 'console_window'

include ConsoleWindow

screen = Screen.new

clock = screen.create_sub(Window, 40, 1, 0, 0)
clock.frames.background do
  clock.text = "\e[1m" + Time.now.to_s + "\e[m"
end

input = screen.create_sub(Window, 40, 1, 0, 1)

input.frames.on :main do
  input.getc
  input.unfocus!
end

screen.components << clock << input
input.focus!

screen.activate
