require 'console_window'

screen = ConsoleWindow::Screen.new
screen.activate do
  screen.text << "hello world"
  screen.getc
  screen.unfocus!
end
