
$:.unshift File.dirname(__FILE__) + '/../lib'
require 'console_window'

ConsoleWindow.start do

  screen = ConsoleWindow::Screen.new
  input_window = screen.create_sub_window(40, 1, 0, 0)
  display_window = screen.create_sub_window(40, 1, 0, 1)
  screen.components << input_window
  screen.components << display_window

  msg = "will echo. input plz: "
  input_window.lines[0] = msg
  input_window.cursor.x = msg.length

  screen.paint

  str = input_window.gets
  display_window.lines[0] = str

  screen.paint
  Curses.getch
end
