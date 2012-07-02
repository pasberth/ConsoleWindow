
$:.unshift File.dirname(__FILE__) + '/../lib'
require 'console_window'

begin
  Curses.init_screen
  window = ConsoleWindow::Screen.new
  msg = "will echo. input plz: "
  window.lines << msg
  window.cursor.x = msg.length
  window.paint
  s = window.gets
  window.lines << s
  window.paint
  Curses.getch
ensure
  Curses.close_screen
end
