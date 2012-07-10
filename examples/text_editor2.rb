# -*- coding: utf-8 -*-

$:.unshift File.dirname(__FILE__) + '/../lib'
require 'console_window'
require 'console_window/text_editor'

if ARGV.empty?
  puts "Usage: #{$0} <path>"
  exit
end

filename = ARGV[0]

include ConsoleWindow

screen = Screen.new
editor = screen.create_sub(TextEditor, 80, 20, 0, 0)

if File.exist? filename
  editor.text = File.read(filename)
end

cmd_line = screen.create_sub(Window, 80, 1, 0, 19)
info_bar = screen.create_sub(Window, 80, 1, 0, 18)

editor.frames.before :main do
  info_bar.text[0] = "Type any key, edit the file. Press the ESC, back to the normal mode."
end

cmd_line.frames.before :main do
  info_bar.text[0] = "Type h/j/k/l, move cursor. Type 'i', change to the insert mode. Type ':', input command."
end

cmd_line.frames.before :command do
  info_bar.text[0] = "Type 'q' and the enter key, quit the application. (but will not save.) Type 'w', write into the '#{filename}'."
end

cmd_line.frames.on :main do
  case cmd_line.getc
  when 'h' then editor.cursor.left! || editor.scroll.right!
  when 'j' then editor.cursor.down! || editor.scroll.down!
  when 'k' then editor.cursor.up! || editor.scroll.up!
  when 'l' then editor.cursor.right! || editor.scroll.right!
  when 'i' then editor.focus!
  when ':' then cmd_line.focus!(:command)
  end
end

cmd_line.frames.on :command do
  case cmd_line.gets
  when /^wq/
    File.write(filename, editor.text.as_string)
    cmd_line.unfocus!(:command)
    cmd_line.unfocus!(:main)
  when /^q/
    cmd_line.unfocus!(:command)
    cmd_line.unfocus!(:main)
  when /^w/
    File.write(filename, editor.text.as_string)
    cmd_line.unfocus!(:command)
  end  
end

screen.components << editor << cmd_line << info_bar

cmd_line.focus! # 最初のエントリポイント
screen.activate
