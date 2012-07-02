
$:.unshift File.dirname(__FILE__) + '/../lib'
require 'console_window'

begin
  Curses.init_screen
  window = ConsoleWindow::Screen.new
  window.lines << "hello world!"
  window.paint
  Curses.getch
ensure
  Curses.close_screen
end
