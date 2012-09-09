
$:.unshift File.dirname(__FILE__) + '/../lib'
require 'console_window'

screen = ConsoleWindow::Screen.new

input_window = screen.create_sub_window(40, 1, 0, 0)
display_window = screen.create_sub_window(40, 1, 0, 1)
screen.components << input_window
screen.components << display_window

input_window.text << "will echo. input plz: "

input_window.frames.on :main do
  case s = input_window.gets
  when /^exit/
    input_window.unfocus!
  else
    display_window.text[0] = s
  end
end

input_window.focus!

screen.activate
