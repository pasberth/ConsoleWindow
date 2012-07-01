
$:.unshift File.dirname(__FILE__) + '/../lib'
require 'console_window'

begin
  Curses.init_screen
  window = ConsoleWindow::Window.new(:curses_window => Curses.stdscr)
  window.lines << "will echo. input plz: "
  window.paint
  s = window.gets
  window.lines << s
  window.paint
  Curses.getch
ensure
  Curses.close_screen
end
