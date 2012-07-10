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
echo = screen.create_sub(Window, 40, 1, 0, 2)

input.frames.on :main do
  case str = input.gets
  when nil
  when /^exit/
    input.unfocus!
  else
    echo.text = str
  end
end

screen.components << clock << input << echo
input.focus!

screen.activate
