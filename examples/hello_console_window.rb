
$:.unshift File.dirname(__FILE__) + '/../lib'
require 'console_window'

screen = ConsoleWindow::Screen.new
screen.text << "hello world"
screen.frames.on :main do
  screen.getc
  screen.unfocus!
end
screen.focus!
screen.activate
